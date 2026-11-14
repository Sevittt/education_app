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
exports.sodiqChat = void 0;
const https_1 = require("firebase-functions/v2/https");
const params_1 = require("firebase-functions/params");
const logger = __importStar(require("firebase-functions/logger"));
const gemini_1 = require("../ai/gemini");
const retrieval_1 = require("../ai/retrieval");
const geminiApiKey = (0, params_1.defineSecret)("GEMINI_API_KEY");
/**
 * Sodiq AI yordamchi uchun server-tomon Gemini proksi.
 * App Check va mijoz tomonidagi API kalit muammolarisiz Web, Android va iOS'da ishlaydi.
 */
exports.sodiqChat = (0, https_1.onCall)({
    region: "us-central1",
    secrets: [geminiApiKey],
    timeoutSeconds: 60,
    memory: "256MiB",
}, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Auth required");
    }
    const parsed = (0, gemini_1.parseSodiqChatRequest)(request.data);
    if (typeof parsed === "string") {
        throw new https_1.HttpsError("invalid-argument", parsed);
    }
    const apiKey = geminiApiKey.value().trim();
    if (!apiKey) {
        logger.error("GEMINI_API_KEY secret is empty");
        throw new https_1.HttpsError("failed-precondition", "Gemini API key not configured");
    }
    // Chat rejimida kontekst serverda rag_chunks_v2 dan olinadi.
    // Natija bo'lmasa (yoki qidiruv xato bersa) mijoz yuborgan kontekst ishlatiladi
    // — eski ilova versiyalari bilan moslik uchun.
    if (parsed.mode === "chat" && parsed.message) {
        try {
            const serverContext = await (0, retrieval_1.retrieveContext)(parsed.message, apiKey);
            if (serverContext)
                parsed.context = serverContext;
        }
        catch (err) {
            logger.warn("RAG qidiruv xatosi, kontekstsiz davom etiladi", { err: String(err) });
        }
    }
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${gemini_1.SODIQ_MODEL}:generateContent?key=${encodeURIComponent(apiKey)}`;
    const payload = (0, gemini_1.buildGeminiPayload)(parsed);
    let response;
    try {
        response = await fetch(url, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload),
            signal: AbortSignal.timeout(45000),
        });
    }
    catch (err) {
        logger.error("Gemini fetch error", { err: String(err) });
        throw new https_1.HttpsError("unavailable", "AI server bilan bog'lanib bo'lmadi");
    }
    const rawBody = await response.text();
    if (!response.ok) {
        logger.error("Gemini API error", {
            status: response.status,
            body: rawBody.slice(0, 500),
        });
        if (response.status === 401 || response.status === 403) {
            throw new https_1.HttpsError("failed-precondition", "Gemini API kaliti yaroqsiz yoki ruxsat etilmagan");
        }
        if (response.status === 429) {
            throw new https_1.HttpsError("resource-exhausted", "AI so'rovlar limiti vaqtincha tugadi. Birozdan so'ng urinib ko'ring.");
        }
        throw new https_1.HttpsError("internal", `Gemini API xatosi (${response.status})`);
    }
    try {
        const json = JSON.parse(rawBody);
        const text = (0, gemini_1.extractGeminiText)(json);
        return { text };
    }
    catch (err) {
        logger.error("Gemini response parse error", {
            err: String(err),
            body: rawBody.slice(0, 500),
        });
        throw new https_1.HttpsError("internal", "AI javobini qayta ishlashda xatolik");
    }
});
//# sourceMappingURL=aiChat.js.map