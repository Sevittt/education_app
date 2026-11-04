// Gamification qoidalari uchun unit testlar: `npm test` (avval tsc build qiladi).
const test = require("node:test");
const assert = require("node:assert/strict");
const {
  parseAwardRequest,
  dedupKey,
  pointsFor,
  applyAward,
  calculateLevel,
  lastLoginDay,
  nextStreak,
  tashkentDay,
} = require("../lib/gamification/rules");

const zero = { xp: 0, quizzesPassed: 0, quizzesAced: 0, currentStreak: 0, simulationsCompleted: 0 };

test("parseAwardRequest noma'lum harakat va bo'sh targetId ni rad etadi", () => {
  assert.equal(typeof parseAwardRequest(null), "string");
  assert.equal(typeof parseAwardRequest({ action: "free_xp", targetId: "x" }), "string");
  assert.equal(typeof parseAwardRequest({ action: "quiz_passed", targetId: "" }), "string");
  assert.equal(typeof parseAwardRequest({ action: "quiz_passed", targetId: 42 }), "string");
  assert.equal(typeof parseAwardRequest({ action: "quiz_passed", targetId: "x".repeat(513) }), "string");
});

test("parseAwardRequest lesson_completed uchun courseId talab qiladi", () => {
  assert.equal(typeof parseAwardRequest({ action: "lesson_completed", targetId: "l1" }), "string");
  const ok = parseAwardRequest({ action: "lesson_completed", targetId: "l1", courseId: "c1" });
  assert.deepEqual(ok, { action: "lesson_completed", targetId: "l1", courseId: "c1", speedBonus: false });
});

test("client yuborgan points maydoni e'tiborga olinmaydi", () => {
  const req = parseAwardRequest({ action: "video_watched", targetId: "v1", points: 100000 });
  assert.equal(pointsFor(req), 10);
});

test("quiz pass va aced bitta dedup kalitini bo'lishadi", () => {
  const passed = parseAwardRequest({ action: "quiz_passed", targetId: "q1" });
  const aced = parseAwardRequest({ action: "quiz_aced", targetId: "q1" });
  assert.equal(dedupKey(passed), dedupKey(aced));
  const otherQuiz = parseAwardRequest({ action: "quiz_passed", targetId: "q2" });
  assert.notEqual(dedupKey(passed), dedupKey(otherQuiz));
});

test("dars kaliti kurs bo'yicha ajratiladi", () => {
  const a = parseAwardRequest({ action: "lesson_completed", targetId: "l1", courseId: "c1" });
  const b = parseAwardRequest({ action: "lesson_completed", targetId: "l1", courseId: "c2" });
  assert.notEqual(dedupKey(a), dedupKey(b));
});

test("quiz ballari: pass 20, aced 70, speed bonus +5", () => {
  assert.equal(pointsFor(parseAwardRequest({ action: "quiz_passed", targetId: "q" })), 20);
  assert.equal(pointsFor(parseAwardRequest({ action: "quiz_aced", targetId: "q" })), 70);
  assert.equal(pointsFor(parseAwardRequest({ action: "quiz_passed", targetId: "q", speedBonus: true })), 25);
});

test("lesson_completed XP kurs hujjatidagi qiymatdan olinadi", () => {
  const req = parseAwardRequest({ action: "lesson_completed", targetId: "l1", courseId: "c1" });
  assert.equal(pointsFor(req, 15), 15);
  assert.equal(pointsFor(req, -5), 0);
});

test("applyAward hisoblagichlarni yangilaydi", () => {
  const aced = applyAward(zero, parseAwardRequest({ action: "quiz_aced", targetId: "q" }), 70);
  assert.deepEqual(aced, { ...zero, xp: 70, quizzesPassed: 1, quizzesAced: 1 });
  const sim = applyAward(zero, parseAwardRequest({ action: "simulation_completed", targetId: "s" }), 100);
  assert.equal(sim.simulationsCompleted, 1);
});

test("calculateLevel gatekeeper qoidalariga amal qiladi", () => {
  assert.equal(calculateLevel({ ...zero, xp: 99 }), "levelBeginner");
  assert.equal(calculateLevel({ ...zero, xp: 100 }), "levelIntermediate");
  assert.equal(calculateLevel({ ...zero, xp: 2500 }), "levelSpecialist");
  assert.equal(calculateLevel({ ...zero, xp: 2500, quizzesPassed: 5, quizzesAced: 3 }), "levelExpert");
  assert.equal(calculateLevel({ ...zero, xp: 6000 }), "levelExpert");
  assert.equal(calculateLevel({ ...zero, xp: 6000, simulationsCompleted: 3, currentStreak: 7 }), "levelMaster");
});

test("lastLoginDay zonasiz eski matnni mahalliy sana deb oladi", () => {
  const local = lastLoginDay("2026-10-30T23:30:00.000");
  const utc = lastLoginDay("2026-10-30T18:30:00.000Z"); // Toshkentda 23:30
  assert.equal(local, utc);
  assert.equal(lastLoginDay("2026-10-30T19:30:00.000Z"), local + 1); // Toshkentda 00:30
  assert.equal(lastLoginDay(null), null);
  assert.equal(lastLoginDay("not a date"), null);
});

test("nextStreak: bir kunda bir marta, ketma-ket kunda oshadi, uzilsa 1 ga tushadi", () => {
  const today = tashkentDay(new Date("2026-10-31T06:00:00Z"));
  assert.deepEqual(nextStreak(4, today, today), { changed: false, currentStreak: 4, xpGained: 0 });
  assert.deepEqual(nextStreak(4, today - 1, today), { changed: true, currentStreak: 5, xpGained: 5 });
  assert.deepEqual(nextStreak(4, today - 3, today), { changed: true, currentStreak: 1, xpGained: 5 });
  assert.deepEqual(nextStreak(0, null, today), { changed: true, currentStreak: 1, xpGained: 5 });
  assert.equal(nextStreak(4, today + 1, today).changed, false);
});
