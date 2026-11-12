/**
 * Telegram hisobini ilova profiliga bogʻlash qoidalari.
 * Asosiy kalit — Firebase Auth uid; Telegram ID `telegram_links/{telegramId}`
 * orqali bitta uid ga bogʻlanadi. Bot (sudqollanma_bot) shu formatni oʻqiydi.
 * Firebase'ga bogʻliq emas — unit testlarda ishlatiladi.
 */

export const BOT_USERNAME = "sudqollanma_bot";
export const LINK_CODE_TTL_MS = 10 * 60 * 1000;

// 0/O, 1/I/L kabi adashtiriladigan belgilarsiz
const ALPHABET = "ABCDEFGHJKMNPQRSTUVWXYZ23456789";
export const LINK_CODE_LENGTH = 8;

/** [randomBytes] dan kod yasaydi (har bayt alifbodan bitta belgi). */
export function codeFromBytes(bytes: Uint8Array): string {
  if (bytes.length < LINK_CODE_LENGTH) throw new Error("not enough random bytes");
  let code = "";
  for (let i = 0; i < LINK_CODE_LENGTH; i++) {
    code += ALPHABET[bytes[i] % ALPHABET.length];
  }
  return code;
}

export function isValidLinkCode(code: unknown): code is string {
  return typeof code === "string" && code.length === LINK_CODE_LENGTH &&
    [...code].every((c) => ALPHABET.includes(c));
}

export function deepLink(code: string): string {
  return `https://t.me/${BOT_USERNAME}?start=link_${code}`;
}

export function isExpired(expiresAtMs: number, nowMs: number): boolean {
  return nowMs >= expiresAtMs;
}
