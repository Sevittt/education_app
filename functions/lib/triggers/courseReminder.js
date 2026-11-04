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
exports.testCourseReminder = exports.scheduledCourseReminder = void 0;
const scheduler_1 = require("firebase-functions/v2/scheduler");
const https_1 = require("firebase-functions/v2/https");
const admin = __importStar(require("firebase-admin"));
const sendPush_1 = require("../helpers/sendPush");
const messages_1 = require("../config/messages");
const INACTIVE_DAYS = 3; // Necha kun faol bo'lmasa eslatma yuboriladi
/**
 * Har kuni soat 09:00 UTC+5 (04:00 UTC) da ishga tushadi.
 * user_course_progress da tugallanmagan va 3+ kun faol bo'lmagan
 * foydalanuvchilarga eslatma yuboradi.
 */
exports.scheduledCourseReminder = (0, scheduler_1.onSchedule)({ schedule: "0 4 * * *", timeZone: "UTC", region: "us-central1" }, async () => {
    const sent = await sendCourseReminders();
    console.log(`Course reminders sent: ${sent} users`);
});
/**
 * Test uchun HTTP callable — admin panelidan chaqiriladi.
 * data.userId — kimga yuborish (bo'sh qolsa current user)
 * data.courseId — qaysi kursga (bo'sh qolsa birinchi topilgan)
 */
exports.testCourseReminder = (0, https_1.onCall)({ region: "us-central1" }, async (request) => {
    // Faqat autentifikatsiya qilingan foydalanuvchilar chaqira oladi
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Auth required");
    }
    const targetUserId = request.data.userId ?? request.auth.uid;
    const db = admin.firestore();
    // Foydalanuvchi ma'lumotlarini olish
    const userDoc = await db.collection("users").doc(targetUserId).get();
    if (!userDoc.exists) {
        throw new https_1.HttpsError("not-found", "User not found");
    }
    const userData = userDoc.data();
    const token = userData["fcmToken"];
    if (!token) {
        throw new https_1.HttpsError("failed-precondition", "No FCM token for this user");
    }
    const lang = (0, messages_1.getLang)(userData["preferredLanguage"]);
    // Ushbu foydalanuvchining tugallanmagan kursini topish
    const progressSnap = await db
        .collection("user_course_progress")
        .where("userId", "==", targetUserId)
        .get();
    const inProgress = progressSnap.docs
        .map((d) => d.data())
        .filter((d) => d["percentComplete"] < 1.0);
    if (inProgress.length === 0) {
        throw new https_1.HttpsError("not-found", "No incomplete courses found for this user");
    }
    // Belgilangan courseId yoki birinchi topilgani
    const requestedCourseId = request.data.courseId;
    const targetProgress = inProgress.find((d) => d["courseId"] === requestedCourseId) ??
        inProgress[0];
    const courseId = targetProgress["courseId"];
    // Kurs nomini olish
    const courseDoc = await db.collection("courses").doc(courseId).get();
    const courseTitle = courseDoc.data()?.[" title"] ||
        courseDoc.data()?.["title"] ||
        "Kurs";
    const msg = (0, messages_1.getMessage)("courseReminder", lang, { course: courseTitle });
    await (0, sendPush_1.sendPushToUsers)([{ uid: targetUserId, token }], msg.title, msg.body, {
        type: "course_reminder",
        courseId,
        courseTitle,
    });
    return {
        success: true,
        userId: targetUserId,
        courseId,
        courseTitle,
        lang,
    };
});
/**
 * Barcha 3+ kun faol bo'lmagan, tugallanmagan kurs foydalanuvchilarini
 * topib, FCM eslatma yuboradi. Qaytaradi: yuborilganlar soni.
 */
async function sendCourseReminders() {
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
    if (progressSnap.empty)
        return 0;
    // userId → progress (har foydalanuvchiga faqat bitta eslatma)
    const byUser = new Map();
    for (const doc of progressSnap.docs) {
        const d = doc.data();
        const uid = d["userId"];
        const pct = d["percentComplete"] ?? 0;
        const existing = byUser.get(uid);
        // Eng ko'p boshlangan kursni tanlash (foizi yuqori)
        if (!existing || pct > existing.percentComplete) {
            byUser.set(uid, { courseId: d["courseId"], percentComplete: pct });
        }
    }
    // Foydalanuvchi tokenlarini batch olish
    const uids = Array.from(byUser.keys());
    const userChunks = chunkArray(uids, 30);
    const users = new Map();
    for (const chunk of userChunks) {
        const userSnaps = await db
            .collection("users")
            .where(admin.firestore.FieldPath.documentId(), "in", chunk)
            .where("fcmToken", "!=", null)
            .get();
        for (const doc of userSnaps.docs) {
            const d = doc.data();
            const token = d["fcmToken"];
            if (!token)
                continue;
            if (d["notificationsEnabled"] === false)
                continue;
            users.set(doc.id, {
                token,
                lang: d["preferredLanguage"] ?? "uz",
            });
        }
    }
    // Kurs nomlarini batch olish
    const courseIds = [...new Set(Array.from(byUser.values()).map((v) => v.courseId))];
    const courseChunks = chunkArray(courseIds, 30);
    const courseTitles = new Map();
    for (const chunk of courseChunks) {
        const courseSnaps = await db
            .collection("courses")
            .where(admin.firestore.FieldPath.documentId(), "in", chunk)
            .get();
        for (const doc of courseSnaps.docs) {
            courseTitles.set(doc.id, doc.data()["title"] ?? "Kurs");
        }
    }
    // Eslatmalar ro'yxatini tuzish
    const targets = [];
    for (const [uid, progress] of byUser.entries()) {
        const user = users.get(uid);
        if (!user)
            continue;
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
    await Promise.allSettled(targets.map((t) => {
        const msg = (0, messages_1.getMessage)("courseReminder", (0, messages_1.getLang)(t.lang), {
            course: t.courseTitle,
        });
        return (0, sendPush_1.sendPushToUsers)([{ uid: t.uid, token: t.token }], msg.title, msg.body, {
            type: "course_reminder",
            courseId: t.courseId,
            courseTitle: t.courseTitle,
        });
    }));
    return targets.length;
}
function chunkArray(arr, size) {
    const chunks = [];
    for (let i = 0; i < arr.length; i += size) {
        chunks.push(arr.slice(i, i + size));
    }
    return chunks;
}
//# sourceMappingURL=courseReminder.js.map