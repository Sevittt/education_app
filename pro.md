# VAZIFA: RAG'ni ikki kod bazasida birlashtirish va tuzatish

## ARXITEKTURA HAQIDA

Ikkita mustaqil sistema **bitta Firestore**'ni baham ko'radi:

### 1. Python Telegram Bot (`sudqollanma_bot`) — Cloud Run
- aiogram 3.x, google-genai SDK
- Servislar: `ai_service.py`, `wiki_service.py`, `firestore_service.py`
- RAG va wiki mantig'i to'liq Python'da yozilgan
- **Alohida repozitoriy**, bu Flutter proyektiga kirmaydi

### 2. Flutter App (`sud_qollanma`) — Bu repo (`d:\dasturlar\b-v22`)
- `firebase_ai` paketi (gemini-2.5-flash modeli)
- RAG pipeline: `core/services/rag_service.dart` + `wiki_service.dart`
- Vector search: `SearchRemoteDataSource` → `ext-firestore-vector-search-queryCallable` callable
- Wiki lookup: **FAQAT exact slug match** (Firestore `wiki_pages/{slug}`)
- Slug algoritmi: `_buildSlug()` — lowercased, regex tozalangan, **max 80 belgi**

## ANIQLANGAN MUAMMOLAR

### Muammo 1 — Ikki xil RAG implementatsiyasi
Python bot va Dart app har biri o'z RAG mantig'ini yozgan:
- Python: cosine vector search + threshold
- Dart (`rag_service.dart`): `ext-firestore-vector-search-queryCallable` callable → `rag_chunks` to'plami

### Muammo 2 — Embedding muvofiqsizligi (gumonda)
- `rag_chunks` vektorlari Python orqali **text-embedding-004** (768 dim) bilan yozilgan
- Firebase Extension (`ext-firestore-vector-search`) **qaysi embedding modelini ishlatadi?** — aniqlanmagan
- Ikkala model dim=768 bo'lgani uchun xato bermaydi, lekin **fazoviy muvofiqsizlik** → cosine natijasi ma'nosiz

### Muammo 3 — Wiki lookup farqi (TASDIQLANGAN)
- Python bot: **cosine vector search** (threshold 0.35) → semantik moslik
- Dart `wiki_service.dart` (`search()` metodi): **EXACT slug match** → `_buildSlug(query)` → Firestore `doc(slug).get()`
- Natija: "E-IMZO drayveri" va "E-IMZO drayver xatosi" **turli slug** → miss, RAG fallback

### Muammo 4 — Slug algoritmi xatosi (`wiki_service.dart`, 110-qator)
```dart
.substring(0, text.length.clamp(0, 80))  // ❌ XATO: slug uzunligi emas, text uzunligi!
```
`text.length` — original query uzunligi, `slug` esa tozalanganidan keyin qisqargan bo'lishi mumkin → `RangeError`

### Muammo 5 — `knowledge_base` kolleksiyasi
- Python bot `knowledge_base` kolleksiyasini fallback sifatida ishlatadi
- Dart `rag_service.dart` faqat `rag_chunks` ishlatadi — `knowledge_base` **umuman o'qilmaydi**

### Muammo 6 — Threshold nomuvofiqligi
- Python bot: `WIKI_HIT_THRESHOLD=0.35`, RAG threshold=0.25
- Dart app: Firebase Extension thresholdni o'zi boshqaradi (qiymati noma'lum)

## MAQSAD (yagona haqiqat manbai)

Python Cloud Run serverida **bitta `answer_core` moduli**:
- Ham bot **to'g'ridan** (in-process) chaqiradi
- Ham Flutter app **HTTP/callable** orqali chaqiradi
- **Bitta embedding modeli** (text-embedding-004, dim=768) — ham indexing, ham query
- **Bitta wiki-lookup** (vector cosine, bitta threshold)
- Flutter appdan Firebase Extension RAG yo'li olib tashlanadi

## QAT'IY SHARTLAR

- **Ishlab turgan botni buzma.** Foydalanuvchi uchun xulq o'zgarmasin.
- **Bitta embedding modeli** — `rag_chunks` va `wiki_pages` IKKALASI ham bir xil model bilan indexed va queried bo'lsin.
- **Taxmin qilma** — Firebase Extension konfiguratsiyasini avval o'qib tasdiqlang.
- **Barcha konstantalar** (threshold, model nomi, kolleksiya nomlari) `config.py`'da markazlashsin.
- **Slug xatosini tuzat** — `wiki_service.dart`'dagi `_buildSlug()` xatosi Faza 3'da tuzatilsin.

## FAZALAR — har fazadan keyin TO'XTA va hisobot ber, keyingisiga o'tma

### Faza 0 — Diagnostika (HECH NARSA o'zgartirma, faqat hisobot)

**Python bot (Cloud Run):**
- `config.py`'da qaysi embedding modeli va threshold ishlatilgani
- `wiki_service.py`'da wiki lookup mantig'i — vector yoki exact?
- `rag_chunks` yozuvlarida `embedding` maydoni: `dim`, yozilgan model

**Flutter app:**
- Firebase Console → Extensions → `ext-firestore-vector-search` → `EMBED_MODEL` sozlamasi nima?
- Extension qaysi kolleksiyani kuzatadi: `rag_chunks` yoki boshqa?
- `firestore.indexes.json` → qaysi kolleksiyada `__name__ ASC` + vector index bor?

**Dart kodi (`d:\dasturlar\b-v22\lib\core\services\`):**
- `wiki_service.dart`: `_buildSlug()` 110-qatordagi xato tasdiqlansinmi?
- `rag_service.dart`: `knowledge_base` fallback yo'q — bu mo'ljallangan xatti-harakat ekanini tasdiqlang

**Topilmalarni to'liq hisobot qilish:** modellar, threshold'lar, kolleksiya nomlari, xato tasdiqlanishi.
Keyin **TO'XTA**.

---

### Faza 1 — Python `answer_core` moduli

Python Cloud Run serverida yangi `answer_core.py` moduli:
```
embed(query, model=text-embedding-004)
  → wiki_pages cosine search (WIKI_HIT_THRESHOLD)
  → miss bo'lsa: rag_chunks vector search (RAG_THRESHOLD)
  → bo'sh bo'lsa: knowledge_base fallback
  → Gemini generate (rolga mos system prompt)
  → fon rejimida wiki build (unawaited)
  → return {answer, sources[], wiki_slug}
```

**HTTP endpoint** Cloud Run serverida: `POST /answer`
- Kirish: `{query: str, role: str, lang: str, image?: base64}`
- Chiqish: `{answer: str, sources: List[str], wiki_slug: str}`

**Bot**: `answer_core`'ni HTTP'siz, to'g'ridan `import` qilib chaqiradi.

Keyin **TO'XTA**.

---

### Faza 2 — Python botni `answer_core`'ga ulash

- `helpdesk.py` (yoki inline RAG joylashuvi)dagi RAG mantig'ini `answer_core.answer()` bilan almashtir
- Foydalanuvchi uchun **xulq o'zgarmasin**
- Bot loglarida qaysi qadam qaytarganini ko'rinsin

Keyin **TO'XTA**.

---

### Faza 3 — Flutter app'ni ulash, Extension yo'lini olib tashlash

**Dart o'zgarishlari:**
1. `search_remote_datasource.dart` → `ext-firestore-vector-search-queryCallable` chaqiruvini olib tashla
2. `wiki_service.dart` → exact slug lookup'ni olib tashla; yoki vaqtincha `search()` ni `/answer` endpointga yo'naltir
3. `rag_service.dart` → to'liqligicha `/answer` HTTP callable bilan almashtir
4. **`_buildSlug()` xatosini tuzat** (`text.length` → `slug.length`):
   ```dart
   // ❌ Hozirgi (xato):
   .substring(0, text.length.clamp(0, 80))
   // ✅ To'g'ri:
   final slug = ...pipeline...;
   return slug.substring(0, slug.length.clamp(0, 80));
   ```
5. Firebase Extension (`ext-firestore-vector-search`) RAG yo'lidan olib tashlansin; agar boshqa joyda ishlatilmasa — butunlay o'chirish tavsiya qilinsin

**Cloud Function yoki to'g'ridan Cloud Run URL** — qaysi usulni tanlash Faza 0 diagnostikasiga bog'liq.

Keyin **TO'XTA**.

---

### Faza 4 — Tekshiruv

- Bir xil savol → bot va app **BIR XIL kontekst/javob** qaytarsin
- `"E-IMZO drayveri"` va `"E-IMZO drayver xatosi"` → **bitta wiki kesh**ga tushsin (vector lookup orqali)
- Query va hujjat embedding'i bir xil model bilan ekanini log orqali tasdiqla
- `_buildSlug()` `RangeError` bermasligini tekshir (slug < 80 belgi bo'lgan query)

Keyin **TO'XTA**.

---

## CHIQISH FORMATI

Har fazadan keyin:
```
✅ Nima o'zgardi va nega
📁 Tegilgan fayllar ro'yxati (to'liq yo'l bilan)
⚠️  Ehtiyot bo'lish kerak bo'lgan joylar
🔴 TO'XTA — tasdiqingizni kutmoqdaman
```