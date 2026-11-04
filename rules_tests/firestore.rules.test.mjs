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
    await assertSucceeds(updateDoc(ref, { courtId: "c", courtName: "Sud", regionId: "r" }));
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

describe("xp_awards: faqat server", () => {
  test("client mukofot yozuvini yarata olmaydi", async () => {
    await assertFails(setDoc(doc(as("alice"), "users/alice/xp_awards/k1"), { points: 100 }));
  });
});
