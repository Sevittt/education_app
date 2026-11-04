import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { createHash } from "crypto";
import {
  AwardRequest,
  UserCounters,
  applyAward,
  calculateLevel,
  dedupKey,
  lastLoginDay,
  nextStreak,
  parseAwardRequest,
  pointsFor,
  tashkentDay,
} from "../gamification/rules";

/**
 * XP faqat shu yerda yoziladi: firestore.rules users hujjatidagi
 * xp/level/hisoblagich maydonlarini clientga yozdirmaydi.
 */

// Kontent turi → u mavjudligini tekshiradigan kolleksiya
const CONTENT_COLLECTIONS: Partial<Record<AwardRequest["action"], string>> = {
  video_watched: "video_tutorials",
  article_read: "knowledge_base",
  quiz_passed: "quizzes",
  quiz_aced: "quizzes",
};

// CourseLessonModel dagi tur bo'yicha default xpReward
const DEFAULT_LESSON_XP: Record<string, number> = {
  video: 10,
  article: 8,
  pdf: 6,
  quiz: 20,
};

export const awardXp = onCall({ region: "us-central1" }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Auth required");
  }
  const req = parseAwardRequest(request.data);
  if (typeof req === "string") {
    throw new HttpsError("invalid-argument", req);
  }

  const uid = request.auth.uid;
  const db = admin.firestore();
  const lessonXp = await verifyAward(db, uid, req);
  const points = pointsFor(req, lessonXp);

  const key = dedupKey(req);
  const userRef = db.collection("users").doc(uid);
  const awardRef = userRef
    .collection("xp_awards")
    .doc(createHash("sha256").update(key).digest("hex"));

  return db.runTransaction(async (tx) => {
    const [userSnap, awardSnap] = await Promise.all([tx.get(userRef), tx.get(awardRef)]);
    if (!userSnap.exists) {
      throw new HttpsError("not-found", "User not found");
    }
    if (awardSnap.exists) {
      return { awarded: 0, duplicate: true };
    }

    const after = applyAward(countersOf(userSnap.data()!), req, points);
    const level = calculateLevel(after);

    tx.create(awardRef, {
      key,
      action: req.action,
      points,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    tx.update(userRef, {
      xp: after.xp,
      level,
      quizzesPassed: after.quizzesPassed,
      totalQuizzesAced: after.quizzesAced,
      simulationsCompleted: after.simulationsCompleted,
      lastActivity: admin.firestore.FieldValue.serverTimestamp(),
    });
    return { awarded: points, duplicate: false, xp: after.xp, level };
  });
});

export const updateStreak = onCall({ region: "us-central1" }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Auth required");
  }

  const db = admin.firestore();
  const userRef = db.collection("users").doc(request.auth.uid);

  return db.runTransaction(async (tx) => {
    const snap = await tx.get(userRef);
    if (!snap.exists) {
      return { changed: false };
    }
    const data = snap.data()!;
    const now = new Date();
    const before = countersOf(data);
    const streak = nextStreak(before.currentStreak, lastLoginDay(data["lastLoginDate"]), tashkentDay(now));
    if (!streak.changed) {
      return { changed: false, currentStreak: streak.currentStreak };
    }

    const after: UserCounters = {
      ...before,
      xp: before.xp + streak.xpGained,
      currentStreak: streak.currentStreak,
    };
    tx.update(userRef, {
      currentStreak: after.currentStreak,
      xp: after.xp,
      level: calculateLevel(after),
      lastLoginDate: now.toISOString(),
    });
    return { changed: true, currentStreak: after.currentStreak, xp: after.xp };
  });
});

/**
 * Mukofot asosini tekshiradi. lesson_completed uchun darsning XP qiymatini qaytaradi.
 * Kurs progress hujjati client tomonidan yoziladi, lekin rules uni faqat egasiga
 * yozdiradi — shu sababli "dars tugallangan" belgisi shu foydalanuvchiga tegishli.
 */
async function verifyAward(
  db: admin.firestore.Firestore,
  uid: string,
  req: AwardRequest
): Promise<number> {
  const collection = CONTENT_COLLECTIONS[req.action];
  if (collection) {
    if (!(await docExists(db, collection, req.targetId))) {
      throw new HttpsError("not-found", "Content not found");
    }
    return 0;
  }

  if (req.action !== "lesson_completed" && req.action !== "course_completed") {
    return 0;
  }

  const courseId = req.action === "lesson_completed" ? req.courseId! : req.targetId;
  if (courseId.includes("/")) {
    throw new HttpsError("invalid-argument", "courseId is invalid");
  }
  const [courseSnap, progressSnap] = await Promise.all([
    db.collection("courses").doc(courseId).get(),
    db.collection("user_course_progress").doc(`${uid}_${courseId}`).get(),
  ]);
  if (!courseSnap.exists || !progressSnap.exists) {
    throw new HttpsError("failed-precondition", "Course progress not found");
  }
  const progress = progressSnap.data()!;

  if (req.action === "course_completed") {
    const percent = progress["percentComplete"];
    if (typeof percent !== "number" || percent < 1) {
      throw new HttpsError("failed-precondition", "Course is not completed");
    }
    return 0;
  }

  const lesson = findLesson(courseSnap.data()!, req.targetId);
  if (!lesson) {
    throw new HttpsError("not-found", "Lesson not found");
  }
  const completed = progress["completedLessonIds"];
  if (!Array.isArray(completed) || !completed.includes(req.targetId)) {
    throw new HttpsError("failed-precondition", "Lesson is not completed");
  }
  const xpReward = lesson["xpReward"];
  return typeof xpReward === "number"
    ? xpReward
    : DEFAULT_LESSON_XP[String(lesson["type"] ?? "video")] ?? 10;
}

async function docExists(
  db: admin.firestore.Firestore,
  collection: string,
  id: string
): Promise<boolean> {
  if (id.includes("/")) return false;
  return (await db.collection(collection).doc(id).get()).exists;
}

function findLesson(
  course: admin.firestore.DocumentData,
  lessonId: string
): Record<string, unknown> | undefined {
  const modules = Array.isArray(course["modules"]) ? course["modules"] : [];
  for (const module of modules) {
    const lessons = Array.isArray(module?.["lessons"]) ? module["lessons"] : [];
    const found = lessons.find((l: Record<string, unknown>) => l?.["id"] === lessonId);
    if (found) return found;
  }
  return undefined;
}

function countersOf(data: admin.firestore.DocumentData): UserCounters {
  return {
    xp: toNumber(data["xp"]),
    quizzesPassed: toNumber(data["quizzesPassed"]),
    quizzesAced: toNumber(data["totalQuizzesAced"]),
    currentStreak: toNumber(data["currentStreak"]),
    simulationsCompleted: toNumber(data["simulationsCompleted"]),
  };
}

function toNumber(value: unknown): number {
  if (typeof value === "number" && isFinite(value)) return Math.trunc(value);
  if (typeof value === "string") {
    const n = parseInt(value, 10);
    return isNaN(n) ? 0 : n;
  }
  return 0;
}
