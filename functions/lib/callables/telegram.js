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
exports.createTelegramLinkCode = void 0;
const https_1 = require("firebase-functions/v2/https");
const admin = __importStar(require("firebase-admin"));
const crypto_1 = require("crypto");
const link_1 = require("../telegram/link");
/**
 * Telegram'ni ulash uchun bir martalik kod. Kodni bot iste'mol qiladi
 * (telegram_link_codes → telegram_links/{telegramId} = uid). Foydalanuvchida
 * bir vaqtda bitta faol kod bo'ladi.
 */
exports.createTelegramLinkCode = (0, https_1.onCall)({ region: "us-central1" }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Auth required");
    }
    const uid = request.auth.uid;
    const db = admin.firestore();
    const codes = db.collection("telegram_link_codes");
    const old = await codes.where("uid", "==", uid).get();
    const batch = db.batch();
    old.docs.forEach((d) => batch.delete(d.ref));
    const expiresAt = Date.now() + link_1.LINK_CODE_TTL_MS;
    const code = (0, link_1.codeFromBytes)((0, crypto_1.randomBytes)(link_1.LINK_CODE_LENGTH));
    batch.create(codes.doc(code), {
        uid,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt: admin.firestore.Timestamp.fromMillis(expiresAt),
    });
    await batch.commit();
    return { code, url: (0, link_1.deepLink)(code), expiresAt };
});
//# sourceMappingURL=telegram.js.map