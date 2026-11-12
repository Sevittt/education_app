"use strict";
/**
 * Telegram hisobini ilova profiliga bogʻlash qoidalari.
 * Asosiy kalit — Firebase Auth uid; Telegram ID `telegram_links/{telegramId}`
 * orqali bitta uid ga bogʻlanadi. Bot (sudqollanma_bot) shu formatni oʻqiydi.
 * Firebase'ga bogʻliq emas — unit testlarda ishlatiladi.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.LINK_CODE_LENGTH = exports.LINK_CODE_TTL_MS = exports.BOT_USERNAME = void 0;
exports.codeFromBytes = codeFromBytes;
exports.isValidLinkCode = isValidLinkCode;
exports.deepLink = deepLink;
exports.isExpired = isExpired;
exports.BOT_USERNAME = "sudqollanma_bot";
exports.LINK_CODE_TTL_MS = 10 * 60 * 1000;
// 0/O, 1/I/L kabi adashtiriladigan belgilarsiz
const ALPHABET = "ABCDEFGHJKMNPQRSTUVWXYZ23456789";
exports.LINK_CODE_LENGTH = 8;
/** [randomBytes] dan kod yasaydi (har bayt alifbodan bitta belgi). */
function codeFromBytes(bytes) {
    if (bytes.length < exports.LINK_CODE_LENGTH)
        throw new Error("not enough random bytes");
    let code = "";
    for (let i = 0; i < exports.LINK_CODE_LENGTH; i++) {
        code += ALPHABET[bytes[i] % ALPHABET.length];
    }
    return code;
}
function isValidLinkCode(code) {
    return typeof code === "string" && code.length === exports.LINK_CODE_LENGTH &&
        [...code].every((c) => ALPHABET.includes(c));
}
function deepLink(code) {
    return `https://t.me/${exports.BOT_USERNAME}?start=link_${code}`;
}
function isExpired(expiresAtMs, nowMs) {
    return nowMs >= expiresAtMs;
}
//# sourceMappingURL=link.js.map