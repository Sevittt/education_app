import * as admin from "firebase-admin";

/**
 * RAG qidiruv: rag_chunks_v2 (bot repodagi rag/build.py yig'adi).
 * Hujjatlar gemini-embedding-2 + RETRIEVAL_DOCUMENT bilan indekslangan,
 * shuning uchun savol aynan shu model va RETRIEVAL_QUERY bilan embed qilinadi.
 */
export const RAG_COLLECTION = "rag_chunks_v2";
export const EMBEDDING_MODEL = "gemini-embedding-2";
export const EMBEDDING_DIM = 768;
/** Cosine masofa chegarasi: mavzuga oid savollar 0.20–0.28, aloqasizlar 0.365+ chiqqan. */
export const RAG_MAX_DISTANCE = 0.33;
export const RAG_LIMIT = 3;
const MAX_CHUNK_CHARS = 3000;
const MAX_QUERY_CHARS = 2000;

export interface RagHit {
  section?: string;
  doc_title?: string;
  text?: string;
  distance?: number;
}

export function buildEmbedRequest(query: string): Record<string, unknown> {
  return {
    model: `models/${EMBEDDING_MODEL}`,
    content: { parts: [{ text: query.slice(0, MAX_QUERY_CHARS) }] },
    taskType: "RETRIEVAL_QUERY",
    outputDimensionality: EMBEDDING_DIM,
  };
}

export function extractEmbedding(json: unknown): number[] {
  const values = (json as { embedding?: { values?: unknown } } | null)?.embedding?.values;
  if (!Array.isArray(values) || values.length !== EMBEDDING_DIM) {
    throw new Error(`Embedding javobi noto'g'ri (${Array.isArray(values) ? values.length : "yo'q"})`);
  }
  return values as number[];
}

/** Topilgan bo'laklarni manbasi ko'rsatilgan kontekstga aylantiradi (bot bilan bir xil format). */
export function formatContext(hits: RagHit[]): string {
  return hits
    .map((hit) => {
      const text = (hit.text ?? "").slice(0, MAX_CHUNK_CHARS);
      if (!text) return "";
      const header = hit.section || hit.doc_title || "";
      return header ? `[Manba: ${header}]\n${text}` : text;
    })
    .filter((part) => part.length > 0)
    .join("\n\n---\n\n");
}

export async function embedQuery(query: string, apiKey: string): Promise<number[]> {
  const url =
    `https://generativelanguage.googleapis.com/v1beta/models/${EMBEDDING_MODEL}:embedContent` +
    `?key=${encodeURIComponent(apiKey)}`;
  const response = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(buildEmbedRequest(query)),
    signal: AbortSignal.timeout(15_000),
  });
  const body = await response.text();
  if (!response.ok) {
    throw new Error(`Embedding API xatosi (${response.status}): ${body.slice(0, 300)}`);
  }
  return extractEmbedding(JSON.parse(body));
}

export async function searchChunks(vector: number[]): Promise<RagHit[]> {
  const snapshot = await admin
    .firestore()
    .collection(RAG_COLLECTION)
    .findNearest({
      vectorField: "embedding",
      queryVector: vector,
      limit: RAG_LIMIT,
      distanceMeasure: "COSINE",
      distanceResultField: "distance",
      distanceThreshold: RAG_MAX_DISTANCE,
    })
    .get();
  return snapshot.docs.map((doc) => {
    const data = doc.data();
    return {
      section: data.section,
      doc_title: data.doc_title,
      text: data.text,
      distance: data.distance,
    };
  });
}

/** Savolga mos kontekstni qaytaradi; xato yoki natija bo'lmasa bo'sh satr. */
export async function retrieveContext(query: string, apiKey: string): Promise<string> {
  const trimmed = query.trim();
  if (!trimmed) return "";
  const vector = await embedQuery(trimmed, apiKey);
  return formatContext(await searchChunks(vector));
}
