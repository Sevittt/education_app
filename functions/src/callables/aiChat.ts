import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import * as logger from "firebase-functions/logger";
import {
  SODIQ_MODEL,
  buildGeminiPayload,
  extractGeminiText,
  parseSodiqChatRequest,
} from "../ai/gemini";
import { retrieveContext } from "../ai/retrieval";

const geminiApiKey = defineSecret("GEMINI_API_KEY");

/**
 * Sodiq AI yordamchi uchun server-tomon Gemini proksi.
 * App Check va mijoz tomonidagi API kalit muammolarisiz Web, Android va iOS'da ishlaydi.
 */
export const sodiqChat = onCall(
  {
    region: "us-central1",
    secrets: [geminiApiKey],
    timeoutSeconds: 60,
    memory: "256MiB",
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Auth required");
    }

    const parsed = parseSodiqChatRequest(request.data);
    if (typeof parsed === "string") {
      throw new HttpsError("invalid-argument", parsed);
    }

    const apiKey = geminiApiKey.value().trim();
    if (!apiKey) {
      logger.error("GEMINI_API_KEY secret is empty");
      throw new HttpsError("failed-precondition", "Gemini API key not configured");
    }

    // Chat rejimida kontekst serverda rag_chunks_v2 dan olinadi.
    // Natija bo'lmasa (yoki qidiruv xato bersa) mijoz yuborgan kontekst ishlatiladi
    // — eski ilova versiyalari bilan moslik uchun.
    if (parsed.mode === "chat" && parsed.message) {
      try {
        const serverContext = await retrieveContext(parsed.message, apiKey);
        if (serverContext) parsed.context = serverContext;
      } catch (err) {
        logger.warn("RAG qidiruv xatosi, kontekstsiz davom etiladi", { err: String(err) });
      }
    }

    const url = `https://generativelanguage.googleapis.com/v1beta/models/${SODIQ_MODEL}:generateContent?key=${encodeURIComponent(apiKey)}`;
    const payload = buildGeminiPayload(parsed);

    let response: Response;
    try {
      response = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
        signal: AbortSignal.timeout(45_000),
      });
    } catch (err) {
      logger.error("Gemini fetch error", { err: String(err) });
      throw new HttpsError("unavailable", "AI server bilan bog'lanib bo'lmadi");
    }

    const rawBody = await response.text();
    if (!response.ok) {
      logger.error("Gemini API error", {
        status: response.status,
        body: rawBody.slice(0, 500),
      });
      if (response.status === 401 || response.status === 403) {
        throw new HttpsError(
          "failed-precondition",
          "Gemini API kaliti yaroqsiz yoki ruxsat etilmagan"
        );
      }
      if (response.status === 429) {
        throw new HttpsError(
          "resource-exhausted",
          "AI so'rovlar limiti vaqtincha tugadi. Birozdan so'ng urinib ko'ring."
        );
      }
      throw new HttpsError("internal", `Gemini API xatosi (${response.status})`);
    }

    try {
      const json = JSON.parse(rawBody) as unknown;
      const text = extractGeminiText(json);
      return { text };
    } catch (err) {
      logger.error("Gemini response parse error", {
        err: String(err),
        body: rawBody.slice(0, 500),
      });
      throw new HttpsError("internal", "AI javobini qayta ishlashda xatolik");
    }
  }
);
