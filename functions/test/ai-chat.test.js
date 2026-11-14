// Sodiq AI Cloud Function yordamchilari uchun birlik testlar (`npm test`).
const test = require("node:test");
const assert = require("node:assert/strict");
const {
  SODIQ_SYSTEM_PROMPT,
  augmentWithContext,
  buildGeminiPayload,
  extractGeminiText,
  parseSodiqChatRequest,
} = require("../lib/ai/gemini");

test("parseSodiqChatRequest bo'sh xabar va rasmsiz so'rovni rad etadi", () => {
  assert.equal(typeof parseSodiqChatRequest({ message: "   " }), "string");
  assert.equal(typeof parseSodiqChatRequest(null), "string");
});

test("parseSodiqChatRequest faqat rasm bilan chat so'rovini qabul qiladi", () => {
  const parsed = parseSodiqChatRequest({
    message: "",
    imageBase64: "AAAA",
    imageMimeType: "image/png",
    history: [
      { role: "user", text: "Salom" },
      { role: "model", text: "Va alaykum salom" },
      { role: "invalid", text: "ignored" },
    ],
  });
  assert.equal(typeof parsed, "object");
  assert.equal(parsed.mode, "chat");
  assert.equal(parsed.imageMimeType, "image/png");
  assert.equal(parsed.history.length, 2);
});

test("buildGeminiPayload chat rejimida systemInstruction va kontekst qo'shadi", () => {
  const parsed = parseSodiqChatRequest({
    mode: "chat",
    message: "VKA qanday ishlaydi?",
    context: "VKA qo'llanmasi matni",
    history: [{ role: "user", text: "Salom" }],
  });
  const payload = buildGeminiPayload(parsed);
  assert.equal(payload.systemInstruction.parts[0].text, SODIQ_SYSTEM_PROMPT);
  assert.equal(payload.contents.length, 2);
  assert.match(payload.contents[1].parts[0].text, /--- Kontekst ---/);
  assert.match(payload.contents[1].parts[0].text, /VKA qanday ishlaydi\?/);
});

test("buildGeminiPayload wiki rejimida systemInstruction va tarix qo'shmaydi", () => {
  const parsed = parseSodiqChatRequest({
    mode: "wiki",
    message: "Wiki yoz",
    history: [{ role: "user", text: "old" }],
  });
  const payload = buildGeminiPayload(parsed);
  assert.equal(payload.systemInstruction, undefined);
  assert.equal(payload.contents.length, 1);
  assert.equal(augmentWithContext("Savol", ""), "Savol");
});

test("extractGeminiText javob qismlarini birlashtiradi va bo'sh javobda xato beradi", () => {
  const text = extractGeminiText({
    candidates: [
      { content: { parts: [{ text: "Salom, " }, { text: "yordam beraman." }] } },
    ],
  });
  assert.equal(text, "Salom, yordam beraman.");
  assert.throws(() => extractGeminiText({ candidates: [] }));
});

// ── RAG qidiruv (rag_chunks_v2) ─────────────────────────────────────────────
const {
  RAG_MAX_DISTANCE,
  buildEmbedRequest,
  extractEmbedding,
  formatContext,
} = require("../lib/ai/retrieval");

test("buildEmbedRequest savol uchun RETRIEVAL_QUERY va 768 o'lcham so'raydi", () => {
  const req = buildEmbedRequest("E-IMZO ishlamayapti");
  assert.equal(req.model, "models/gemini-embedding-2");
  assert.equal(req.taskType, "RETRIEVAL_QUERY");
  assert.equal(req.outputDimensionality, 768);
  assert.equal(req.content.parts[0].text, "E-IMZO ishlamayapti");
  assert.equal(buildEmbedRequest("x".repeat(5000)).content.parts[0].text.length, 2000);
});

test("extractEmbedding o'lchami noto'g'ri javobni rad etadi", () => {
  assert.equal(extractEmbedding({ embedding: { values: new Array(768).fill(0.1) } }).length, 768);
  assert.throws(() => extractEmbedding({ embedding: { values: [0.1, 0.2] } }));
  assert.throws(() => extractEmbedding({}));
});

test("formatContext manbani ko'rsatadi, bo'sh bo'laklarni tashlaydi va bot formatiga mos", () => {
  const text = formatContext([
    { section: "E-IMZO › Kesh", text: "Keshni tozalang" },
    { doc_title: "FAQ", text: "javob" },
    { section: "Bo'sh", text: "" },
  ]);
  assert.equal(text, "[Manba: E-IMZO › Kesh]\nKeshni tozalang\n\n---\n\n[Manba: FAQ]\njavob");
  assert.equal(formatContext([]), "");
});

test("RAG masofa chegarasi bot bilan bir xil", () => {
  assert.equal(RAG_MAX_DISTANCE, 0.33);
});
