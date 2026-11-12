// firestore.rules regression testlari.
// Ishga tushirish (repo ildizidan, Java 11+ kerak):
//   npm --prefix rules_tests install
//   firebase emulators:exec --only firestore --project demo-sud-qollanma "npm --prefix rules_tests test"
import { after, before, beforeEach, describe, test } from "node:test";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";
import {
  addDoc,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
} from "firebase/firestore";

const rulesPath = fileURLToPath(new URL("../firestore.rules", import.meta.url));

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: "demo-sud-qollanma",
    firestore: { rules: readFileSync(rulesPath, "utf8") },
  });
});

after(async () => {
  await env?.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, "users/alice"), profile("alice", "judge"));
    await setDoc(doc(db, "users/bob"), profile("bob", "assistant"));
    await setDoc(doc(db, "users/ict"), profile("ict", "ict_specialist"));
    await setDoc(doc(db, "users/admin"), profile("admin", "admin"));
    await setDoc(doc(db, "user_course_progress/alice_c1"), progress("alice", "c1"));
  });
});

function profile(id, role) {
  return {
    id,
    name: id,
    role,
    xp: 0,
    level: "levelBeginner",
    quizzesPassed: 0,
    totalQuizzesAced: 0,
    simulationsCompleted: 0,
    currentStreak: 0,
    lastLoginDate: null,
    fastestQuizTime: null,
    previousRank: null,
  };
}

function progress(userId, courseId) {
  return {
    userId,
    courseId,
    completedLessonIds: [],
    quizScores: {},
    percentComplete: 0,
    earnedXp: 0,
    totalRequiredLessons: 3,
  };
}

const as = (uid) => env.authenticatedContext(uid).firestore();

describe("users: huquq oshirish", () => {
  test("yangi user xavfsiz lavozim bilan profil yaratadi", async () => {
    await assertSucceeds(setDoc(doc(as("carol"), "users/carol"), profile("carol", "chancellery")));
  });

  test("yangi user o'zini admin qilib yarata olmaydi", async () => {
    await assertFails(setDoc(doc(as("carol"), "users/carol"), profile("carol", "admin")));
  });

  test("yangi user XP bilan profil yarata olmaydi", async () => {
    await assertFails(setDoc(doc(as("carol"), "users/carol"), { ...profile("carol", "judge"), xp: 500 }));
  });

  test("boshqa user nomidan profil yaratib bo'lmaydi", async () => {
    await assertFails(setDoc(doc(as("carol"), "users/dave"), profile("dave", "judge")));
  });

  test("egasi o'z rolini admin qila olmaydi", async () => {
    await assertFails(updateDoc(doc(as("alice"), "users/alice"), { role: "admin" }));
  });

  test("egasi XP, level va hisoblagichlarni o'zgartira olmaydi", async () => {
    const ref = doc(as("alice"), "users/alice");
    await assertFails(updateDoc(ref, { xp: 99999 }));
    await assertFails(updateDoc(ref, { level: "levelMaster" }));
    await assertFails(updateDoc(ref, { quizzesPassed: 50 }));
    await assertFails(updateDoc(ref, { currentStreak: 100 }));
  });

  test("egasi profil maydonlari va fcmToken ni yangilaydi", async () => {
    const ref = doc(as("alice"), "users/alice");
    await assertSucceeds(updateDoc(ref, { name: "Alisa", bio: "sudya", position: "Sudya" }));
    await assertSucceeds(updateDoc(ref, { fcmToken: "t1" }));
    await assertSucceeds(updateDoc(ref, { preferredLanguage: "uz" }));
    await assertSucceeds(updateDoc(ref, { courtId: "c", courtName: "Sud", regionId: "r" }));
  });

  test("egasi telegram_id ni to'g'ridan-to'g'ri yoza olmaydi (2ta profil oldini olish)", async () => {
    const ref = doc(as("alice"), "users/alice");
    await assertFails(updateDoc(ref, { telegram_id: "123456" }));
    await assertFails(setDoc(doc(as("carol"), "users/carol"), {
      ...profile("carol", "judge"),
      telegram_id: "123456",
    }));
  });

  test("ruxsatli va himoyalangan maydon aralash yozuv rad etiladi", async () => {
    await assertFails(updateDoc(doc(as("alice"), "users/alice"), { name: "A", xp: 10 }));
  });

  test("user boshqa userning profilini o'zgartira olmaydi", async () => {
    await assertFails(updateDoc(doc(as("bob"), "users/alice"), { name: "x" }));
  });

  test("egasi o'z profilini o'chira olmaydi", async () => {
    await assertFails(deleteDoc(doc(as("alice"), "users/alice")));
  });

  test("admin boshqa userning rolini o'zgartiradi", async () => {
    await assertSucceeds(updateDoc(doc(as("admin"), "users/alice"), { role: "chancellery" }));
  });

  test("ict_specialist admin emas: bildirishnoma yoza olmaydi", async () => {
    await assertFails(setDoc(doc(as("ict"), "app_notifications/n1"), { title: "x" }));
    await assertSucceeds(setDoc(doc(as("admin"), "app_notifications/n1"), { title: "x" }));
  });
});

describe("user_course_progress: {uid}_{courseId}", () => {
  test("egasi kursni boshlaydi", async () => {
    await assertSucceeds(setDoc(doc(as("alice"), "user_course_progress/alice_c2"), progress("alice", "c2")));
  });

  test("boshqa user nomidan progress yaratib bo'lmaydi", async () => {
    await assertFails(setDoc(doc(as("alice"), "user_course_progress/alice_c2"), progress("bob", "c2")));
    await assertFails(setDoc(doc(as("alice"), "user_course_progress/bob_c2"), progress("alice", "c2")));
    await assertFails(setDoc(doc(as("alice"), "user_course_progress/alice_c2"), progress("alice", "c3")));
  });

  test("progressni tugallangan holatda yaratib bo'lmaydi", async () => {
    await assertFails(
      setDoc(doc(as("alice"), "user_course_progress/alice_c2"), {
        ...progress("alice", "c2"),
        completedLessonIds: ["l1"],
        percentComplete: 1,
      })
    );
  });

  test("egasi o'z progressini o'qiydi; boshlanmagan kurs null qaytaradi", async () => {
    await assertSucceeds(getDoc(doc(as("alice"), "user_course_progress/alice_c1")));
    await assertSucceeds(getDoc(doc(as("alice"), "user_course_progress/alice_c9")));
  });

  test("boshqa user progressni o'qiy olmaydi", async () => {
    await assertFails(getDoc(doc(as("bob"), "user_course_progress/alice_c1")));
    await assertFails(getDoc(doc(as("bob"), "user_course_progress/alice_c9")));
  });

  test("userId bo'yicha list faqat o'zi uchun", async () => {
    const col = (db) => collection(db, "user_course_progress");
    await assertSucceeds(getDocs(query(col(as("alice")), where("userId", "==", "alice"))));
    await assertFails(getDocs(query(col(as("bob")), where("userId", "==", "alice"))));
    await assertFails(getDocs(col(as("bob"))));
  });

  test("egasi progressni yangilaydi, lekin egasini almashtira olmaydi", async () => {
    const ref = doc(as("alice"), "user_course_progress/alice_c1");
    await assertSucceeds(updateDoc(ref, { completedLessonIds: ["l1"], percentComplete: 0.3, earnedXp: 10 }));
    await assertFails(updateDoc(ref, { userId: "bob" }));
    await assertFails(updateDoc(doc(as("bob"), "user_course_progress/alice_c1"), { earnedXp: 0 }));
  });

  test("admin hisobot uchun o'qiydi, ict_specialist o'qiy olmaydi", async () => {
    await assertSucceeds(getDoc(doc(as("admin"), "user_course_progress/alice_c1")));
    await assertSucceeds(getDocs(collection(as("admin"), "user_course_progress")));
    await assertFails(getDoc(doc(as("ict"), "user_course_progress/alice_c1")));
  });
});

describe("quiz_attempts: egasi", () => {
  test("user faqat o'z nomidan attempt yaratadi", async () => {
    const col = collection(as("alice"), "quiz_attempts");
    await assertSucceeds(addDoc(col, { userId: "alice", quizId: "q1", score: 7, totalQuestions: 10 }));
    await assertFails(addDoc(col, { userId: "bob", quizId: "q1", score: 10, totalQuestions: 10 }));
  });
});

describe("kontent: faqat admin yozadi", () => {
  test("sudya va AKT xodimi kurs, test, resurs va FAQ yoza olmaydi", async () => {
    await assertFails(setDoc(doc(as("alice"), "courses/c9"), { title: "x" }));
    await assertFails(setDoc(doc(as("ict"), "quizzes/q9"), { title: "x" }));
    await assertFails(setDoc(doc(as("ict"), "resources/r9"), { title: "x" }));
    await assertFails(setDoc(doc(as("alice"), "faqs/f9"), { question: "x" }));
  });

  test("admin kontent yozadi", async () => {
    await assertSucceeds(setDoc(doc(as("admin"), "courses/c9"), { title: "x" }));
    await assertSucceeds(setDoc(doc(as("admin"), "faqs/f9"), { question: "x" }));
  });
});

describe("ict_reports: AKT xodimi → admin → FAQ", () => {
  const report = (authorId, extra = {}) => ({
    authorId,
    authorName: authorId,
    category: "technical",
    problem: "E-SUD sertifikat xatosi",
    description: "",
    solution: "Sertifikatni qayta o'rnatish",
    status: "pending",
    createdAt: serverTimestamp(),
    ...extra,
  });

  beforeEach(async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      const db = ctx.firestore();
      await setDoc(doc(db, "ict_reports/pending1"), { ...report("ict"), createdAt: new Date() });
      await setDoc(doc(db, "ict_reports/approved1"), {
        ...report("ict"),
        status: "approved",
        createdAt: new Date(),
      });
    });
  });

  test("AKT xodimi o'z nomidan muammo/yechim yuboradi", async () => {
    await assertSucceeds(addDoc(collection(as("ict"), "ict_reports"), report("ict")));
  });

  test("boshqa lavozim yoki boshqa user nomidan yuborib bo'lmaydi", async () => {
    await assertFails(addDoc(collection(as("alice"), "ict_reports"), report("alice")));
    await assertFails(addDoc(collection(as("ict"), "ict_reports"), report("bob")));
  });

  test("tasdiqlangan holatda yoki ortiqcha maydon bilan yaratib bo'lmaydi", async () => {
    const col = collection(as("ict"), "ict_reports");
    await assertFails(addDoc(col, report("ict", { status: "approved" })));
    await assertFails(addDoc(col, report("ict", { faqId: "f1" })));
    await assertFails(addDoc(col, report("ict", { solution: "" })));
  });

  test("muallif va admin o'qiydi, boshqalar o'qiy olmaydi", async () => {
    await assertSucceeds(getDoc(doc(as("ict"), "ict_reports/pending1")));
    await assertSucceeds(getDoc(doc(as("admin"), "ict_reports/pending1")));
    await assertFails(getDoc(doc(as("bob"), "ict_reports/pending1")));
    await assertSucceeds(
      getDocs(query(collection(as("ict"), "ict_reports"), where("authorId", "==", "ict")))
    );
  });

  test("AKT xodimi o'z yozuvini tasdiqlay olmaydi; admin tasdiqlaydi", async () => {
    await assertFails(updateDoc(doc(as("ict"), "ict_reports/pending1"), { status: "approved" }));
    await assertSucceeds(
      updateDoc(doc(as("admin"), "ict_reports/pending1"), {
        status: "approved",
        faqId: "f1",
        reviewedAt: serverTimestamp(),
        reviewedBy: "admin",
      })
    );
  });

  test("admin ham muallif matnini o'zgartira olmaydi", async () => {
    await assertFails(
      updateDoc(doc(as("admin"), "ict_reports/pending1"), { status: "rejected", solution: "x" })
    );
  });

  test("muallif faqat ko'rib chiqilmagan yozuvni o'chiradi", async () => {
    await assertSucceeds(deleteDoc(doc(as("ict"), "ict_reports/pending1")));
    await assertFails(deleteDoc(doc(as("ict"), "ict_reports/approved1")));
  });
});

describe("users/{uid}/video_progress: faqat egasi", () => {
  const progress = {
    lastPositionSeconds: 125,
    durationSeconds: 300,
    watchedRanges: [{ start: 0, end: 125 }],
    completed: false,
    updatedAt: serverTimestamp(),
  };

  test("egasi o'z video holatini yozadi va o'qiydi", async () => {
    const ref = doc(as("alice"), "users/alice/video_progress/v1");
    await assertSucceeds(setDoc(ref, progress));
    await assertSucceeds(getDoc(ref));
  });

  test("boshqa user o'qiy ham, yoza ham olmaydi", async () => {
    await assertFails(setDoc(doc(as("bob"), "users/alice/video_progress/v1"), progress));
    await assertFails(getDoc(doc(as("bob"), "users/alice/video_progress/v1")));
  });

  test("ortiqcha maydon yoki juda ko'p oraliq rad etiladi", async () => {
    const ref = doc(as("alice"), "users/alice/video_progress/v1");
    await assertFails(setDoc(ref, { ...progress, xp: 100 }));
    const ranges = Array.from({ length: 101 }, (_, i) => ({ start: i * 2, end: i * 2 + 1 }));
    await assertFails(setDoc(ref, { ...progress, watchedRanges: ranges }));
  });
});

describe("xp_awards: faqat server", () => {
  test("client mukofot yozuvini yarata olmaydi", async () => {
    await assertFails(setDoc(doc(as("alice"), "users/alice/xp_awards/k1"), { points: 100 }));
  });
});
