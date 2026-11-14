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
exports.RAG_LIMIT = exports.RAG_MAX_DISTANCE = exports.EMBEDDING_DIM = exports.EMBEDDING_MODEL = exports.RAG_COLLECTION = void 0;
exports.buildEmbedRequest = buildEmbedRequest;
exports.extractEmbedding = extractEmbedding;
exports.formatContext = formatContext;
exports.embedQuery = embedQuery;
exports.searchChunks = searchChunks;
exports.retrieveContext = retrieveContext;
const admin = __importStar(require("firebase-admin"));
/**
 * RAG qidiruv: rag_chunks_v2 (bot repodagi rag/build.py yig'adi).
 * Hujjatlar gemini-embedding-2 + RETRIEVAL_DOCUMENT bilan indekslangan,
 * shuning uchun savol aynan shu model va RETRIEVAL_QUERY bilan embed qilinadi.
 */
exports.RAG_COLLECTION = "rag_chunks_v2";
exports.EMBEDDING_MODEL = "gemini-embedding-2";
exports.EMBEDDING_DIM = 768;
/** Cosine masofa chegarasi: mavzuga oid savollar 0.20–0.28, aloqasizlar 0.365+ chiqqan. */
exports.RAG_MAX_DISTANCE = 0.33;
exports.RAG_LIMIT = 3;
const MAX_CHUNK_CHARS = 3000;
const MAX_QUERY_CHARS = 2000;
function buildEmbedRequest(query) {
    return {
        model: `models/${exports.EMBEDDING_MODEL}`,
        content: { parts: [{ text: query.slice(0, MAX_QUERY_CHARS) }] },
        taskType: "RETRIEVAL_QUERY",
        outputDimensionality: exports.EMBEDDING_DIM,
    };
}
function extractEmbedding(json) {
    const values = json?.embedding?.values;
    if (!Array.isArray(values) || values.length !== exports.EMBEDDING_DIM) {
        throw new Error(`Embedding javobi noto'g'ri (${Array.isArray(values) ? values.length : "yo'q"})`);
    }
    return values;
}
/** Topilgan bo'laklarni manbasi ko'rsatilgan kontekstga aylantiradi (bot bilan bir xil format). */
function formatContext(hits) {
    return hits
        .map((hit) => {
        const text = (hit.text ?? "").slice(0, MAX_CHUNK_CHARS);
        if (!text)
            return "";
        const header = hit.section || hit.doc_title || "";
        return header ? `[Manba: ${header}]\n${text}` : text;
    })
        .filter((part) => part.length > 0)
        .join("\n\n---\n\n");
}
async function embedQuery(query, apiKey) {
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${exports.EMBEDDING_MODEL}:embedContent` +
        `?key=${encodeURIComponent(apiKey)}`;
    const response = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(buildEmbedRequest(query)),
        signal: AbortSignal.timeout(15000),
    });
    const body = await response.text();
    if (!response.ok) {
        throw new Error(`Embedding API xatosi (${response.status}): ${body.slice(0, 300)}`);
    }
    return extractEmbedding(JSON.parse(body));
}
async function searchChunks(vector) {
    const snapshot = await admin
        .firestore()
        .collection(exports.RAG_COLLECTION)
        .findNearest({
        vectorField: "embedding",
        queryVector: vector,
        limit: exports.RAG_LIMIT,
        distanceMeasure: "COSINE",
        distanceResultField: "distance",
        distanceThreshold: exports.RAG_MAX_DISTANCE,
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
async function retrieveContext(query, apiKey) {
    const trimmed = query.trim();
    if (!trimmed)
        return "";
    const vector = await embedQuery(trimmed, apiKey);
    return formatContext(await searchChunks(vector));
}
//# sourceMappingURL=retrieval.js.map