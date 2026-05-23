import { onSchedule } from "firebase-functions/v2/scheduler";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { sendPushToUsers } from "../helpers/sendPush";
import { getMessage, getLang } from "../config/messages";

const INACTIVE_DAYS = 3; // Necha kun faol bo'lmasa eslatma yuboriladi

interface InactiveUser {
  uid: string;
  token: string;
  lang: string;
  courseId: string;
  courseTitle: string;
  percentComplete: number;
}

/**
 * Har kuni soat 09:00 UTC+5 (04:00 UTC) da ishga tushadi.
 * user_course_progress da tugallanmagan va 3+ kun faol bo'lmagan
 * foydalanuvchilarga eslatma yuboradi.
 */
export const scheduledCourseReminder = onSchedule(
  { schedule: "0 4 * * *", timeZone: "UTC", region: "us-central1" },
  async () => {
    const sent = await sendCourseReminders();
    console.log(`Course reminders sent: ${sent} users`);
  }
);

/**
 * Test uchun HTTP callable — admin panelidan chaqiriladi.
 * data.userId — kimga yuborish (bo'sh qolsa current user)
 * data.courseId — qaysi kursga (bo'sh qolsa birinchi topilgan)
 */
export const testCourseReminder = onCall(
  { region: "us-central1" },
  async (request) => {
    // Faqat autentifikatsiya qilingan foydalanuvchilar chaqira oladi
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Auth required");
    }

    const targetUserId =
      (request.data as { userId?: string }).userId ?? request.auth.uid;

    const db = admin.firestore();

    // Foydalanuvchi ma'lumotlarini olish
    const userDoc = await db.collection("users").doc(targetUserId).get();
    if (!userDoc.exists) {
      throw new HttpsError("not-found", "User not found");
    }
    const userData = userDoc.data()!;
    const token = userData["fcmToken"] as string | undefined;
    if (!token) {
      throw new HttpsError("failed-precondition", "No FCM token for this user");
    }

    const lang = getLang(userData["preferredLanguage"] as string | undefined);

    // Ushbu foydalanuvchining tugallanmagan kursini topish
    const progressSnap = await db
      .collection("user_course_progress")
      .where("userId", "==", targetUserId)
      .get();

    const inProgress = progressSnap.docs
      .map((d) => d.data())
      .filter((d) => (d["percentComplete"] as number) < 1.0);

    if (inProgress.length === 0) {
      throw new HttpsError(
        "not-found",
        "No incomplete courses found for this user"
      );
    }

    // Belgilangan courseId yoki birinchi topilgani
    const requestedCourseId = (request.data as { courseId?: string }).courseId;
    const targetProgress =
      inProgress.find((d) => d["courseId"] === requestedCourseId) ??
      inProgress[0];

    const courseId = targetProgress["courseId"] as string;

    // Kurs nomini olish
    const courseDoc = await db.collection("courses").doc(courseId).get();
    const courseTitle =
      (courseDoc.data()?.[" title"] as string) ||
      (courseDoc.data()?.["title"] as string) ||
      "Kurs";

    const msg = getMessage("courseReminder", lang, { course: courseTitle });

    await sendPushToUsers(
      [{ uid: targetUserId, token }],
      msg.title,
      msg.body,
      {
        type: "course_reminder",
        courseId,
        courseTitle,
      }
    );

    return {
      success: true,
      userId: targetUserId,
      courseId,
      courseTitle,
      lang,
    };
  }
);

/**
 * Barcha 3+ kun faol bo'lmagan, tugallanmagan kurs foydalanuvchilarini
 * topib, FCM eslatma yuboradi. Qaytaradi: yuborilganlar soni.
 */
async function sendCourseReminders(): Promise<number> {
  const db = admin.firestore();
  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - INACTIVE_DAYS);
  const cutoffTs = admin.firestore.Timestamp.fromDate(cutoff);

  // Tugallanmagan (percentComplete < 1.0) va eski (lastAccessedAt <= cutoff) progresslar
  const progressSnap = await db
    .collection("user_course_progress")
    .where("percentComplete", "<", 1.0)
    .where("lastAccessedAt", "<=", cutoffTs)
    .get();

  if (progressSnap.empty) return 0;

  // userId → progress (har foydalanuvchiga faqat bitta eslatma)
  const byUser = new Map<
    string,
    { courseId: string; percentComplete: number }
  >();
  for (const doc of progressSnap.docs) {
    const d = doc.data();
    const uid = d["userId"] as string;
    const pct = (d["percentComplete"] as number) ?? 0;
    const existing = byUser.get(uid);
    // Eng ko'p boshlangan kursni tanlash (foizi yuqori)
    if (!existing || pct > existing.percentComplete) {
      byUser.set(uid, { courseId: d["courseId"] as string, percentComplete: pct });
    }
  }

  // Foydalanuvchi tokenlarini batch olish
  const uids = Array.from(byUser.keys());
  const userChunks = chunkArray(uids, 30);
  const users = new Map<string, { token: string; lang: string }>();

  for (const chunk of userChunks) {
    const userSnaps = await db
      .collection("users")
      .where(admin.firestore.FieldPath.documentId(), "in", chunk)
      .where("fcmToken", "!=", null)
      .get();
    for (const doc of userSnaps.docs) {
      const d = doc.data();
      const token = d["fcmToken"] as string | undefined;
      if (!token) continue;
      if (d["notificationsEnabled"] === false) continue;
      users.set(doc.id, {
        token,
        lang: (d["preferredLanguage"] as string) ?? "uz",
      });
    }
  }

  // Kurs nomlarini batch olish
  const courseIds = [...new Set(Array.from(byUser.values()).map((v) => v.courseId))];
  const courseChunks = chunkArray(courseIds, 30);
  const courseTitles = new Map<string, string>();

  for (const chunk of courseChunks) {
    const courseSnaps = await db
      .collection("courses")
      .where(admin.firestore.FieldPath.documentId(), "in", chunk)
      .get();
    for (const doc of courseSnaps.docs) {
      courseTitles.set(doc.id, (doc.data()["title"] as string) ?? "Kurs");
    }
  }

  // Eslatmalar ro'yxatini tuzish
  const targets: InactiveUser[] = [];
  for (const [uid, progress] of byUser.entries()) {
    const user = users.get(uid);
    if (!user) continue;
    targets.push({
      uid,
      token: user.token,
      lang: user.lang,
      courseId: progress.courseId,
      courseTitle: courseTitles.get(progress.courseId) ?? "Kurs",
      percentComplete: progress.percentComplete,
    });
  }

  // Til bo'yicha guruhlash va yuborish
  await Promise.allSettled(
    targets.map((t) => {
      const msg = getMessage("courseReminder", getLang(t.lang), {
        course: t.courseTitle,
      });
      return sendPushToUsers(
        [{ uid: t.uid, token: t.token }],
        msg.title,
        msg.body,
        {
          type: "course_reminder",
          courseId: t.courseId,
          courseTitle: t.courseTitle,
        }
      );
    })
  );

  return targets.length;
}

function chunkArray<T>(arr: T[], size: number): T[][] {
  const chunks: T[][] = [];
  for (let i = 0; i < arr.length; i += size) {
    chunks.push(arr.slice(i, i + size));
  }
  return chunks;
}
