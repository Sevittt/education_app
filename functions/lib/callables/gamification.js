"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateStreak = exports.awardXp = void 0;
const https_1 = require("firebase-functions/v2/https");
const admin = __importStar(require("firebase-admin"));
const crypto_1 = require("crypto");
const rules_1 = require("../gamification/rules");
/**
 * XP faqat shu yerda yoziladi: firestore.rules users hujjatidagi
 * xp/level/hisoblagich maydonlarini clientga yozdirmaydi.
 */
// Kontent turi → u mavjudligini tekshiradigan kolleksiya
const CONTENT_COLLECTIONS = {
    video_watched: "video_tutorials",
    article_read: "knowledge_base",
    quiz_passed: "quizzes",
    quiz_aced: "quizzes",
};
// CourseLessonModel dagi tur bo'yicha default xpReward
const DEFAULT_LESSON_XP = {
    video: 10,
    article: 8,
    pdf: 6,
    quiz: 20,
};
exports.awardXp = (0, https_1.onCall)({ region: "us-central1" }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Auth required");
    }
    const req = (0, rules_1.parseAwardRequest)(request.data);
    if (typeof req === "string") {
        throw new https_1.HttpsError("invalid-argument", req);
    }
    const uid = request.auth.uid;
    const db = admin.firestore();
    const lessonXp = await verifyAward(db, uid, req);
    const points = (0, rules_1.pointsFor)(req, lessonXp);
    const key = (0, rules_1.dedupKey)(req);
    const userRef = db.collection("users").doc(uid);
    const awardRef = userRef
        .collection("xp_awards")
        .doc((0, crypto_1.createHash)("sha256").update(key).digest("hex"));
    return db.runTransaction(async (tx) => {
        const [userSnap, awardSnap] = await Promise.all([tx.get(userRef), tx.get(awardRef)]);
        if (!userSnap.exists) {
            throw new https_1.HttpsError("not-found", "User not found");
        }
        if (awardSnap.exists) {
            return { awarded: 0, duplicate: true };
        }
        const after = (0, rules_1.applyAward)(countersOf(userSnap.data()), req, points);
        const level = (0, rules_1.calculateLevel)(after);
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
exports.updateStreak = (0, https_1.onCall)({ region: "us-central1" }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Auth required");
    }
    const db = admin.firestore();
    const userRef = db.collection("users").doc(request.auth.uid);
    return db.runTransaction(async (tx) => {
        const snap = await tx.get(userRef);
        if (!snap.exists) {
            return { changed: false };
        }
        const data = snap.data();
        const now = new Date();
        const before = countersOf(data);
        const streak = (0, rules_1.nextStreak)(before.currentStreak, (0, rules_1.lastLoginDay)(data["lastLoginDate"]), (0, rules_1.tashkentDay)(now));
        if (!streak.changed) {
            return { changed: false, currentStreak: streak.currentStreak };
        }
        const after = {
            ...before,
            xp: before.xp + streak.xpGained,
            currentStreak: streak.currentStreak,
        };
        tx.update(userRef, {
            currentStreak: after.currentStreak,
            xp: after.xp,
            level: (0, rules_1.calculateLevel)(after),
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
async function verifyAward(db, uid, req) {
    const collection = CONTENT_COLLECTIONS[req.action];
    if (collection) {
        if (!(await docExists(db, collection, req.targetId))) {
            throw new https_1.HttpsError("not-found", "Content not found");
        }
        return 0;
    }
    if (req.action !== "lesson_completed" && req.action !== "course_completed") {
        return 0;
    }
    const courseId = req.action === "lesson_completed" ? req.courseId : req.targetId;
    if (courseId.includes("/")) {
        throw new https_1.HttpsError("invalid-argument", "courseId is invalid");
    }
    const [courseSnap, progressSnap] = await Promise.all([
        db.collection("courses").doc(courseId).get(),
        db.collection("user_course_progress").doc(`${uid}_${courseId}`).get(),
    ]);
    if (!courseSnap.exists || !progressSnap.exists) {
        throw new https_1.HttpsError("failed-precondition", "Course progress not found");
    }
    const progress = progressSnap.data();
    if (req.action === "course_completed") {
        const percent = progress["percentComplete"];
        if (typeof percent !== "number" || percent < 1) {
            throw new https_1.HttpsError("failed-precondition", "Course is not completed");
        }
        return 0;
    }
    const lesson = findLesson(courseSnap.data(), req.targetId);
    if (!lesson) {
        throw new https_1.HttpsError("not-found", "Lesson not found");
    }
    const completed = progress["completedLessonIds"];
    if (!Array.isArray(completed) || !completed.includes(req.targetId)) {
        throw new https_1.HttpsError("failed-precondition", "Lesson is not completed");
    }
    const xpReward = lesson["xpReward"];
    return typeof xpReward === "number"
        ? xpReward
        : DEFAULT_LESSON_XP[String(lesson["type"] ?? "video")] ?? 10;
}
async function docExists(db, collection, id) {
    if (id.includes("/"))
        return false;
    return (await db.collection(collection).doc(id).get()).exists;
}
function findLesson(course, lessonId) {
    const modules = Array.isArray(course["modules"]) ? course["modules"] : [];
    for (const module of modules) {
        const lessons = Array.isArray(module?.["lessons"]) ? module["lessons"] : [];
        const found = lessons.find((l) => l?.["id"] === lessonId);
        if (found)
            return found;
    }
    return undefined;
}
function countersOf(data) {
    return {
        xp: toNumber(data["xp"]),
        quizzesPassed: toNumber(data["quizzesPassed"]),
        quizzesAced: toNumber(data["totalQuizzesAced"]),
        currentStreak: toNumber(data["currentStreak"]),
        simulationsCompleted: toNumber(data["simulationsCompleted"]),
    };
}
function toNumber(value) {
    if (typeof value === "number" && isFinite(value))
        return Math.trunc(value);
    if (typeof value === "string") {
        const n = parseInt(value, 10);
        return isNaN(n) ? 0 : n;
    }
    return 0;
}
//# sourceMappingURL=gamification.js.map