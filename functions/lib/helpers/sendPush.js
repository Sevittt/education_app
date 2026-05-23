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
exports.sendPushToUsers = sendPushToUsers;
const admin = __importStar(require("firebase-admin"));
async function sendPushToToken(opts) {
    try {
        await admin.messaging().send({
            token: opts.token,
            notification: { title: opts.title, body: opts.body },
            data: opts.data ?? {},
            android: {
                notification: {
                    channelId: "sud_qollanma_high",
                    sound: "default",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                },
                priority: "high",
            },
            webpush: {
                notification: {
                    title: opts.title,
                    body: opts.body,
                    icon: "/icons/Icon-192.png",
                },
            },
        });
        return true;
    }
    catch (err) {
        const code = err && typeof err === "object" && "code" in err
            ? err.code
            : "";
        if (code === "messaging/registration-token-not-registered" ||
            code === "messaging/invalid-registration-token") {
            return false;
        }
        console.error("FCM send error:", err);
        return false;
    }
}
async function sendPushToUsers(users, title, body, data) {
    const db = admin.firestore();
    await Promise.allSettled(users.map(async ({ uid, token }) => {
        const success = await sendPushToToken({ token, title, body, data });
        if (!success) {
            await db
                .collection("users")
                .doc(uid)
                .update({ fcmToken: admin.firestore.FieldValue.delete() });
        }
    }));
}
//# sourceMappingURL=sendPush.js.map