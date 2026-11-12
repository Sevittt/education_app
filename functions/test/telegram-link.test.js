// Telegram bogʻlash kodi qoidalari: `npm test`.
const test = require("node:test");
const assert = require("node:assert/strict");
const {
  codeFromBytes,
  isValidLinkCode,
  deepLink,
  isExpired,
  LINK_CODE_LENGTH,
} = require("../lib/telegram/link");

test("codeFromBytes 8 belgili, adashtiriladigan belgilarsiz kod beradi", () => {
  const bytes = Uint8Array.from({ length: LINK_CODE_LENGTH }, (_, i) => i * 37);
  const code = codeFromBytes(bytes);
  assert.equal(code.length, LINK_CODE_LENGTH);
  assert.ok(isValidLinkCode(code));
  assert.doesNotMatch(code, /[01OIL]/);
});

test("codeFromBytes yetarli bayt boʻlmasa xato beradi", () => {
  assert.throws(() => codeFromBytes(new Uint8Array(3)));
});

test("isValidLinkCode notoʻgʻri kodlarni rad etadi", () => {
  assert.ok(!isValidLinkCode("ABC"));
  assert.ok(!isValidLinkCode("ABCDEFG0"));
  assert.ok(!isValidLinkCode("abcdefgh"));
  assert.ok(!isValidLinkCode(null));
});

test("deepLink bot start parametrini yasaydi", () => {
  assert.equal(deepLink("ABCDEFGH"), "https://t.me/sudqollanma_bot?start=link_ABCDEFGH");
});

test("isExpired muddat chegarasida tugagan hisoblanadi", () => {
  assert.ok(!isExpired(1000, 999));
  assert.ok(isExpired(1000, 1000));
});
