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
exports.dailyStreakReminder = void 0;
const scheduler_1 = require("firebase-functions/v2/scheduler");
const admin = __importStar(require("firebase-admin"));
const sendPush_1 = require("../helpers/sendPush");
const createAppNotification_1 = require("../helpers/createAppNotification");
const messages_1 = require("../config/messages");
exports.dailyStreakReminder = (0, scheduler_1.onSchedule)({ schedule: "0 13 * * *", timeZone: "UTC", region: "us-central1" }, async () => {
    const db = admin.firestore();
    const now = new Date();
    const twoDaysAgo = new Date(now);
    twoDaysAgo.setDate(twoDaysAgo.getDate() - 2);
    twoDaysAgo.setHours(0, 0, 0, 0);
    const threeDaysAgo = new Date(now);
    threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
    threeDaysAgo.setHours(0, 0, 0, 0);
    const usersSnap = await db
        .collection("users")
        .where("fcmToken", "!=", null)
        .get();
    const atRisk = [];
    const lost = [];
    for (const doc of usersSnap.docs) {
        const data = doc.data();
        const token = data["fcmToken"];
        if (!token)
            continue;
        const notificationsEnabled = data["notificationsEnabled"];
        if (notificationsEnabled === false)
            continue;
        const lastLoginRaw = data["lastLoginDate"];
        if (!lastLoginRaw)
            continue;
        const lastLogin = lastLoginRaw instanceof admin.firestore.Timestamp
            ? lastLoginRaw.toDate()
            : new Date(lastLoginRaw);
        const lastMidnight = new Date(lastLogin);
        lastMidnight.setHours(0, 0, 0, 0);
        const streak = data["currentStreak"] ?? 0;
        const lang = data["preferredLanguage"] ?? "uz";
        if (lastMidnight <= threeDaysAgo) {
            lost.push({ uid: doc.id, token, lang });
        }
        else if (lastMidnight <= twoDaysAgo) {
            atRisk.push({ uid: doc.id, token, streak, lang });
        }
    }
    for (const u of atRisk) {
        const msg = (0, messages_1.getMessage)("streakAtRisk", (0, messages_1.getLang)(u.lang), {
            streak: String(u.streak),
        });
        await (0, sendPush_1.sendPushToUsers)([{ uid: u.uid, token: u.token }], msg.title, msg.body, { type: "reminder" });
    }
    if (atRisk.length > 0) {
        await (0, createAppNotification_1.createAppNotification)({
            title: messages_1.MESSAGES.streakAtRisk.uz.title,
            body: messages_1.MESSAGES.streakAtRisk.uz.body.replace("{streak}", "?"),
            type: "reminder",
            targetAudience: "all",
        });
    }
    for (const u of lost) {
        const msg = (0, messages_1.getMessage)("streakLost", (0, messages_1.getLang)(u.lang));
        await (0, sendPush_1.sendPushToUsers)([{ uid: u.uid, token: u.token }], msg.title, msg.body, { type: "reminder" });
    }
    console.log(`Streak reminders sent: ${atRisk.length} at-risk, ${lost.length} lost`);
});
//# sourceMappingURL=streakReminder.js.map