import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { randomBytes } from "crypto";
import { LINK_CODE_TTL_MS, LINK_CODE_LENGTH, codeFromBytes, deepLink } from "../telegram/link";

/**
 * Telegram'ni ulash uchun bir martalik kod. Kodni bot iste'mol qiladi
 * (telegram_link_codes → telegram_links/{telegramId} = uid). Foydalanuvchida
 * bir vaqtda bitta faol kod bo'ladi.
 */
export const createTelegramLinkCode = onCall({ region: "us-central1" }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Auth required");
  }
  const uid = request.auth.uid;
  const db = admin.firestore();
  const codes = db.collection("telegram_link_codes");

  const old = await codes.where("uid", "==", uid).get();
  const batch = db.batch();
  old.docs.forEach((d) => batch.delete(d.ref));

  const expiresAt = Date.now() + LINK_CODE_TTL_MS;
  const code = codeFromBytes(randomBytes(LINK_CODE_LENGTH));
  batch.create(codes.doc(code), {
    uid,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    expiresAt: admin.firestore.Timestamp.fromMillis(expiresAt),
  });
  await batch.commit();

  return { code, url: deepLink(code), expiresAt };
});
