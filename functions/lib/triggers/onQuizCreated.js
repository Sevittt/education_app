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
exports.onQuizCreated = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const admin = __importStar(require("firebase-admin"));
const sendPush_1 = require("../helpers/sendPush");
const createAppNotification_1 = require("../helpers/createAppNotification");
const messages_1 = require("../config/messages");
exports.onQuizCreated = (0, firestore_1.onDocumentCreated)({ document: "quizzes/{quizId}", region: "us-central1" }, async (event) => {
    const data = event.data?.data();
    if (!data)
        return;
    const quizName = (data["title"] ?? data["name"] ?? "Yangi test");
    const quizId = event.params.quizId;
    const snap = await admin
        .firestore()
        .collection("users")
        .where("fcmToken", "!=", null)
        .get();
    const users = snap.docs
        .filter((d) => d.data()["notificationsEnabled"] !== false)
        .map((d) => ({
        uid: d.id,
        token: d.data()["fcmToken"],
        lang: d.data()["preferredLanguage"] ?? "uz",
    }))
        .filter((u) => !!u.token);
    for (const u of users) {
        const msg = (0, messages_1.getMessage)("newQuiz", (0, messages_1.getLang)(u.lang), { name: quizName });
        await (0, sendPush_1.sendPushToUsers)([{ uid: u.uid, token: u.token }], msg.title, msg.body, {
            type: "newContent",
            relatedContentType: "quiz",
            relatedContentId: quizId,
        });
    }
    await (0, createAppNotification_1.createAppNotification)({
        title: (0, messages_1.getMessage)("newQuiz", "uz", { name: quizName }).title,
        body: (0, messages_1.getMessage)("newQuiz", "uz", { name: quizName }).body,
        type: "newContent",
        targetAudience: "all",
        relatedContentType: "quiz",
        relatedContentId: quizId,
    });
});
//# sourceMappingURL=onQuizCreated.js.map