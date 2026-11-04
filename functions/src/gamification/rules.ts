/**
 * Gamification qoidalari — server tomonidagi yagona manba.
 * lib/config/gamification_rules.dart bilan mos bo'lishi kerak.
 * Bu fayl Firebase'ga bog'liq emas, shuning uchun unit testlarda ishlatiladi.
 */

export const XP = {
  videoComplete: 10,
  articleScroll: 5,
  quizPass: 20,
  quizPerfect: 50,
  speedBonus: 5,
  loginStreak: 5,
  simInteraction: 50,
  simComplete: 100,
  courseComplete: 50,
} as const;

const THRESHOLDS = {
  intermediate: 100,
  advanced: 500,
  specialist: 1000,
  expert: 2000,
  master: 5000,
} as const;

const GATEKEEPERS = {
  quizzesPassedForExpert: 5,
  quizzesAcedForExpert: 3,
  streakForMaster: 7,
  simsForMaster: 3,
} as const;

export type AwardAction =
  | "video_watched"
  | "article_read"
  | "quiz_passed"
  | "quiz_aced"
  | "simulation_completed"
  | "simulation_interaction"
  | "lesson_completed"
  | "course_completed";

const ACTIONS: ReadonlySet<string> = new Set<AwardAction>([
  "video_watched",
  "article_read",
  "quiz_passed",
  "quiz_aced",
  "simulation_completed",
  "simulation_interaction",
  "lesson_completed",
  "course_completed",
]);

const MAX_ID_LENGTH = 512;

export interface AwardRequest {
  action: AwardAction;
  targetId: string;
  courseId?: string;
  speedBonus: boolean;
}

export interface UserCounters {
  xp: number;
  quizzesPassed: number;
  quizzesAced: number;
  currentStreak: number;
  simulationsCompleted: number;
}

/** Callable kiritmasini tekshiradi; noto'g'ri bo'lsa sababini qaytaradi. */
export function parseAwardRequest(data: unknown): AwardRequest | string {
  if (typeof data !== "object" || data === null) return "data must be an object";
  const d = data as Record<string, unknown>;

  if (typeof d.action !== "string" || !ACTIONS.has(d.action)) {
    return "unknown action";
  }
  const action = d.action as AwardAction;

  if (!isValidId(d.targetId)) return "targetId is required";

  const needsCourse = action === "lesson_completed";
  if (needsCourse && !isValidId(d.courseId)) return "courseId is required";
  if (d.courseId !== undefined && d.courseId !== null && !isValidId(d.courseId)) {
    return "courseId is invalid";
  }

  return {
    action,
    targetId: d.targetId as string,
    courseId: (d.courseId as string | undefined) ?? undefined,
    speedBonus: d.speedBonus === true,
  };
}

function isValidId(value: unknown): value is string {
  return typeof value === "string" && value.length > 0 && value.length <= MAX_ID_LENGTH;
}

/**
 * Bir xil kontent uchun XP faqat bir marta beriladi.
 * Quiz uchun pass va aced bitta kalitni bo'lishadi: bitta quiz — bitta mukofot.
 */
export function dedupKey(req: AwardRequest): string {
  switch (req.action) {
    case "quiz_passed":
    case "quiz_aced":
      return `quiz:${req.targetId}`;
    case "lesson_completed":
      return `lesson:${req.courseId}/${req.targetId}`;
    case "course_completed":
      return `course:${req.targetId}`;
    default:
      return `${req.action}:${req.targetId}`;
  }
}

/**
 * Harakat uchun belgilangan XP. lesson_completed uchun XP kurs hujjatidan
 * olinadi, shuning uchun bu yerda [lessonXp] beriladi.
 */
export function pointsFor(req: AwardRequest, lessonXp = 0): number {
  const speed = req.speedBonus ? XP.speedBonus : 0;
  switch (req.action) {
    case "video_watched":
      return XP.videoComplete;
    case "article_read":
      return XP.articleScroll;
    case "quiz_passed":
      return XP.quizPass + speed;
    case "quiz_aced":
      return XP.quizPass + XP.quizPerfect + speed;
    case "simulation_completed":
      return XP.simComplete;
    case "simulation_interaction":
      return XP.simInteraction;
    case "lesson_completed":
      return Math.max(0, Math.floor(lessonXp));
    case "course_completed":
      return XP.courseComplete;
  }
}

export function applyAward(user: UserCounters, req: AwardRequest, points: number): UserCounters {
  const next = { ...user, xp: user.xp + points };
  if (req.action === "quiz_passed") {
    next.quizzesPassed++;
  } else if (req.action === "quiz_aced") {
    next.quizzesPassed++;
    next.quizzesAced++;
  } else if (req.action === "simulation_completed") {
    next.simulationsCompleted++;
  }
  return next;
}

/** GamificationRules.calculateLevel bilan bir xil gatekeeper mantig'i. */
export function calculateLevel(u: UserCounters): string {
  if (u.xp >= THRESHOLDS.master) {
    return u.simulationsCompleted >= GATEKEEPERS.simsForMaster &&
      u.currentStreak >= GATEKEEPERS.streakForMaster
      ? "levelMaster"
      : "levelExpert";
  }
  if (u.xp >= THRESHOLDS.expert) {
    return u.quizzesPassed >= GATEKEEPERS.quizzesPassedForExpert &&
      u.quizzesAced >= GATEKEEPERS.quizzesAcedForExpert
      ? "levelExpert"
      : "levelSpecialist";
  }
  if (u.xp >= THRESHOLDS.specialist) return "levelSpecialist";
  if (u.xp >= THRESHOLDS.advanced) return "levelAdvanced";
  if (u.xp >= THRESHOLDS.intermediate) return "levelIntermediate";
  return "levelBeginner";
}

// ─── Streak ────────────────────────────────────────────────

const TASHKENT_OFFSET_MS = 5 * 60 * 60 * 1000; // UTC+5, yozgi vaqt yo'q

/** Toshkent vaqti bo'yicha kun raqami (epoch kunlari). */
export function tashkentDay(date: Date): number {
  return Math.floor((date.getTime() + TASHKENT_OFFSET_MS) / 86_400_000);
}

/**
 * lastLoginDate qiymatini Toshkent kuniga aylantiradi.
 * Eski clientlar qurilma vaqtini zonasiz ISO matn sifatida yozgan
 * ("2026-10-30T22:15:00.000"): bunday matnda sana qismi mahalliy kun deb olinadi.
 */
export function lastLoginDay(raw: unknown): number | null {
  if (raw === null || raw === undefined) return null;
  if (typeof raw === "string") {
    const hasZone = /([zZ]|[+-]\d{2}:?\d{2})$/.test(raw.trim());
    if (!hasZone) {
      const m = /^(\d{4})-(\d{2})-(\d{2})/.exec(raw.trim());
      if (!m) return null;
      return Math.floor(Date.UTC(+m[1], +m[2] - 1, +m[3]) / 86_400_000);
    }
    const parsed = new Date(raw);
    return isNaN(parsed.getTime()) ? null : tashkentDay(parsed);
  }
  if (raw instanceof Date) return tashkentDay(raw);
  if (typeof raw === "object" && typeof (raw as { toDate?: unknown }).toDate === "function") {
    return tashkentDay((raw as { toDate: () => Date }).toDate());
  }
  return null;
}

export interface StreakResult {
  changed: boolean;
  currentStreak: number;
  xpGained: number;
}

export function nextStreak(currentStreak: number, lastDay: number | null, today: number): StreakResult {
  if (lastDay === null) {
    return { changed: true, currentStreak: 1, xpGained: XP.loginStreak };
  }
  const diff = today - lastDay;
  if (diff <= 0) {
    return { changed: false, currentStreak, xpGained: 0 };
  }
  return {
    changed: true,
    currentStreak: diff === 1 ? currentStreak + 1 : 1,
    xpGained: XP.loginStreak,
  };
}
