"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SODIQ_SYSTEM_PROMPT = exports.SODIQ_MODEL = void 0;
exports.parseSodiqChatRequest = parseSodiqChatRequest;
exports.augmentWithContext = augmentWithContext;
exports.buildGeminiPayload = buildGeminiPayload;
exports.extractGeminiText = extractGeminiText;
exports.SODIQ_MODEL = "gemini-2.5-flash";
exports.SODIQ_SYSTEM_PROMPT = "Ismingiz Sodiq. Siz Uzbekiston sud xodimlarining raqamli yordamchisisiz.\n\n" +
    "ASOSIY SOHA — quyidagi mavzularda to'liq mutaxassis:\n" +
    "• E-SUD, E-XAT, VKA, 1C, MSSQL, E-IMZO, kiberxavfsizlik\n" +
    "• Sudlov tizimining barcha IT dasturlari\n\n" +
    "KENGAYTIRILGAN YORDAM — agar savol yuqoridagi sohalardan tashqarida bo'lsa:\n" +
    "• Umumiy IT, dasturlash, kompyuter va texnologiya savollari bo'yicha yordam ber\n" +
    "• Iloji boricha foydali bo'l, haddan ziyod cheklamadan\n" +
    "• Agar bu ilova orqali hali qo'llab-quvvatlanmasa: " +
    "\"Bu xususiyat tez orada qo'shilishi rejalashtirilgan\" de va " +
    "muqobil manbalar (Google, YouTube, rasmiy hujjatlar) tavsiya et\n\n" +
    "CHEKLOVLAR:\n" +
    "• Yuridik maslahat berma\n" +
    "• Tibbiy, moliyaviy va shaxsiy hayotiy maslahatlar berma\n" +
    "• Siyosat, din va nizoli ijtimoiy masalalardan chetlan\n\n" +
    "Agar xabarda \"--- Kontekst ---\" bo'limi mavjud bo'lsa:\n" +
    "• O'sha kontekstdagi ma'lumotlarga tayan\n" +
    "• Kontekstda javob topilmasa ham umumiy bilimingdan yordam ber\n\n" +
    "Suhbat qoidalari:\n" +
    "1. Faqat birinchi xabardagina salomlash\n" +
    "2. O'zbek tilida (Lotin) gapir\n" +
    "3. Qisqa, to'g'ridan-to'g'ri javob ber\n" +
    "4. Tabiiy, do'stona ohangda yoz";
const MAX_HISTORY_TURNS = 16;
const MAX_HISTORY_TEXT_LEN = 4000;
const MAX_CONTEXT_LEN = 12000;
const MAX_MESSAGE_LEN = 6000;
// Base64 hajmi (~4.5 MB fayl uchun)
const MAX_IMAGE_BASE64_LEN = 6000000;
const ALLOWED_MIME_TYPES = new Set(["image/jpeg", "image/png", "image/webp"]);
/**
 * Mijozdan kelgan `sodiqChat` so'rovini tekshiradi va normallashtiradi.
 */
function parseSodiqChatRequest(data) {
    if (!data || typeof data !== "object") {
        return "So'rov ma'lumotlari noto'g'ri";
    }
    const raw = data;
    const mode = raw.mode === "wiki" ? "wiki" : "chat";
    const message = typeof raw.message === "string"
        ? raw.message.trim().slice(0, MAX_MESSAGE_LEN)
        : "";
    const imageBase64 = typeof raw.imageBase64 === "string" && raw.imageBase64.trim().length > 0
        ? raw.imageBase64.trim()
        : undefined;
    if (imageBase64 && imageBase64.length > MAX_IMAGE_BASE64_LEN) {
        return "Rasm hajmi juda katta (maksimal 4 MB)";
    }
    if (!message && !imageBase64) {
        return "Xabar yoki rasm yuborilishi shart";
    }
    const rawMime = typeof raw.imageMimeType === "string" ? raw.imageMimeType.trim() : "";
    const imageMimeType = ALLOWED_MIME_TYPES.has(rawMime)
        ? rawMime
        : "image/jpeg";
    const context = typeof raw.context === "string" && raw.context.trim().length > 0
        ? raw.context.trim().slice(0, MAX_CONTEXT_LEN)
        : undefined;
    const history = [];
    if (mode === "chat" && Array.isArray(raw.history)) {
        const slice = raw.history.slice(-MAX_HISTORY_TURNS);
        for (const item of slice) {
            if (!item || typeof item !== "object")
                continue;
            const entry = item;
            const role = entry.role === "model" ? "model" : entry.role === "user" ? "user" : null;
            const text = typeof entry.text === "string" ? entry.text.trim() : "";
            if (role && text) {
                history.push({ role, text: text.slice(0, MAX_HISTORY_TEXT_LEN) });
            }
        }
    }
    return {
        mode,
        message,
        context,
        history,
        imageBase64,
        imageMimeType,
    };
}
/**
 * Foydalanuvchi savoliga RAG kontekstini biriktiradi.
 */
function augmentWithContext(message, context) {
    if (!context || !context.trim())
        return message;
    const promptText = message.trim() || "Rasmni tahlil qilib yordam bering.";
    return `--- Kontekst ---\n${context.trim()}\n\n--- Foydalanuvchi savoli ---\n${promptText}`;
}
/**
 * Gemini Developer API `generateContent` so'rov tanasini yasaydi.
 */
function buildGeminiPayload(req) {
    const contents = req.history.map((turn) => ({
        role: turn.role,
        parts: [{ text: turn.text }],
    }));
    const currentParts = [];
    const augmented = augmentWithContext(req.message, req.context);
    if (augmented) {
        currentParts.push({ text: augmented });
    }
    if (req.imageBase64) {
        currentParts.push({
            inlineData: {
                mimeType: req.imageMimeType,
                data: req.imageBase64,
            },
        });
    }
    contents.push({
        role: "user",
        parts: currentParts,
    });
    const payload = {
        contents,
        generationConfig: {
            temperature: 0.2,
            topP: 0.8,
            topK: 40,
        },
    };
    if (req.mode === "chat") {
        payload.systemInstruction = {
            parts: [{ text: exports.SODIQ_SYSTEM_PROMPT }],
        };
    }
    return payload;
}
/**
 * Gemini API javobidan matnni ajratib oladi.
 */
function extractGeminiText(responseJson) {
    if (!responseJson || typeof responseJson !== "object") {
        throw new Error("Empty Gemini response");
    }
    const obj = responseJson;
    const candidates = Array.isArray(obj.candidates) ? obj.candidates : [];
    if (candidates.length === 0) {
        throw new Error("No candidates returned by Gemini");
    }
    const first = candidates[0];
    const content = first.content;
    const parts = Array.isArray(content?.parts) ? content.parts : [];
    const text = parts
        .map((p) => (p && typeof p === "object" ? p.text : ""))
        .filter((t) => typeof t === "string" && t.length > 0)
        .join("");
    if (!text.trim()) {
        const finishReason = typeof first.finishReason === "string" ? first.finishReason : "UNKNOWN";
        throw new Error(`Gemini returned empty text (finishReason: ${finishReason})`);
    }
    return text;
}
//# sourceMappingURL=gemini.js.map