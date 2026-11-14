# RAG'ni yagona yig'ish yo'liga o'tkazish rejasi

Sana: 2026-11-13 · Holat: **reja, hali bajarilmagan**

## 1. Hozirgi holat (2026-11-13 da Firestore'da tekshirilgan)

| # | Yaratuvchi | Joyi | Embedding modeli | Natija |
|---|---|---|---|---|
| 1 | `extract_chunks.py` → `generate_embeddings.py` → `sync_to_firestore.py` | `b-v22/scripts` | EmbeddingGemma 2 (lokal, CPU) | `rag_chunks`: 370 ta bo'lak, ilovaga 3 ta JSON asset |
| 2 | `upload_knowledge.py` (`knowledge.md` + `faqs`) | `sudqollanma_bot/scripts` | gemini-embedding-2, 768 | `rag_chunks`: 1144 + 63 ta bo'lak |
| 3 | `wiki_builder.py` / `WikiService.build_page` | `sudqollanma_bot` | gemini-embedding-2, 768 | `wiki_pages`: **0 ta** |

### Aniqlangan nosozliklar

1. **Vektor qidiruv ishlamaydi.** `rag_chunks` dagi 1577 ta `embedding` oddiy massiv sifatida saqlangan, `Vector` turida emas. 768 o'lchamli vektor indeksi deploy qilingan bo'lsa ham, `find_nearest` bo'sh natija qaytaradi.
2. **Bot amalda RAG'siz ishlaydi.** Vektor qidiruv bo'sh bo'lgani uchun `AIService.get_system_manuals()` ishga tushadi. U `knowledge_base` dagi istalgan **birinchi 5 ta** hujjatni (har biridan 3000 belgi) kontekst sifatida beradi, savolga mos-mosligini tekshirmaydi.
3. **Modellar aralashgan.** Bot savolni gemini-embedding-2 bilan vektorga aylantiradi, 370 ta bo'lak esa EmbeddingGemma 2 bilan yasalgan. Vektorlar bir fazoda emas, shuning uchun o'xshashlik ma'nosiz.
4. **Ilovaning lokal RAG qatlami vektor ishlatmaydi.** `LocalRagService.getGroundingContext` `queryVector`siz chaqiriladi va faqat kalit so'z bo'yicha qidiradi. Ilova tomonidagi zaxira (`ext-firestore-vector-search-queryCallable`) ham 1-banddagi sabab bilan bo'sh qaytadi.
5. **Wiki qatlami bo'sh.** `wiki_pages` da hujjat yo'q, ammo bot va ilova har so'rovda unga avval murojaat qiladi.
6. **Ilova hajmi ortiqcha og'ir.** `pubspec.yaml` butun `assets/data/` papkasini qo'shadi (9.6 MB). Unga ilova o'qimaydigan `firestore_rag_chunks.json` (3.8 MB) va `raw_chunks.json` (1 MB) ham kiradi.
7. **Takrorlar.** `knowledge.md` bo'laklarida 17 ta takroriy matn bor.
8. **DARS darslarida bir xil matn.** `knowledge_base` dagi DARS hujjatlari modul darajasida birlashtirilgan, shuning uchun bir moduldagi darslar bir xil matnni ko'rsatadi. Bu RAG'dan alohida xato, lekin xuddi shu bo'laklash qoidasidan kelib chiqadi.

### EmbeddingGemma 2 o'lchovi (shu kompyuter, CPU, 8 oqim)

- Model yuklanishi: 10 s. Hajmi 1.5 GB, matn qismi 271M parametr.
- Indekslash: bitta bo'lakka ~0.87 s; 404 ta bo'lak ~6 daqiqa.
- Bitta savol: 90–150 ms.
- **Xulosa:** oflayn indekslash uchun yaroqli. Lekin savolni ham shu model vektorga aylantirishi shart, 1.5 GB modelni esa telefon yoki Cloud Run'dagi botga arzon joylab bo'lmaydi.

## 2. Qarorlar (bajarishdan oldin tasdiqlanadi)

| Savol | Tavsiya | Sabab |
|---|---|---|
| Embedding modeli | **gemini-embedding-2 (Gemini API orqali), 768 o'lcham** — ✅ tasdiqlandi 2026-11-14 | Bot allaqachon ishlatadi; hujjat ham, savol ham serverda arzon va tez vektorga aylanadi. |
| Inglizcha umumiy IT kitoblari (`knowledge.md`, ~650 bo'lak) | **Kiritiladi** — ✅ tasdiqlandi 2026-11-14 | Umumiy kompyuter savollarida foydali. Agar o'zbekcha savollar natijasini suyultirsa, 2-bosqichdagi eval'da ko'rinadi. |
| API darajasi | **Pullik (billing yoqilgan) loyiha kaliti** | Bepul darajada yuborilgan ma'lumot Google mahsulotlarini yaxshilashga ishlatilishi mumkin. |
| Hujjat va savol uchun `task_type` | `RETRIEVAL_DOCUMENT` / `RETRIEVAL_QUERY` | Shu juftlik qidiruv sifatini oshiradi. |
| Yig'uvchi kod qayerda turadi | **`sudqollanma_bot/rag/`** | Admin SDK, Gemini klienti va `config` shu repoda. Ilova faqat o'qiydi. |
| EmbeddingGemma 2 | Faqat STT/SudMatn kabi lokal, maxfiy ishlar uchun qoladi | Server qidiruvi bilan aralashtirilmaydi. |
| Wiki qatlami | **O'chiriladi** (kod olib tashlanadi) | Bo'sh, har so'rovga kechikish qo'shadi. Keyin kerak bo'lsa, yangi sxemadan qaytadan quriladi. |
| Maxfiylik | Manbalar Gemini API'ga yuboriladi | 65 ta PDF va DARS materiallarida maxfiy (DSP) qism yo'qligini **foydalanuvchi tasdiqlaydi**. |

## 3. Maqsadli arxitektura

```
manbalar (sources.yaml)
  ├─ DARS markdown (5 modul)
  ├─ Sud_Qollanmalari PDF (65 ta)
  ├─ knowledge.md
  ├─ faqs (Firestore)
  └─ knowledge_base maqolalari (Firestore)
        │
   bitta bo'laklovchi  →  bitta embedder (gemini-embedding-2)
        │
   rag_chunks_v2  (Vector, 768, cosine)
        │
   ├─ bot: AIService.retrieve()  ── RETRIEVAL_QUERY
   └─ ilova: sodiqChat (server)  ── RETRIEVAL_QUERY
```

### `rag_chunks_v2` hujjat sxemasi

| Maydon | Tur | Izoh |
|---|---|---|
| id | `{source}:{doc_slug}:{n}` | Barqaror: qayta yig'ishda o'zgarmaydi. |
| `source` | string | `dars`, `pdf`, `knowledge_md`, `faq`, `kb_article` |
| `doc_id`, `doc_title` | string | Asl hujjat. DARS uchun dars id (`m1_l2`). |
| `section` | string | Sarlavha zanjiri: "1-Modul › Word › Ctrl+H" |
| `text` | string | ≤ 1200 belgi |
| `embedding` | **Vector(768)** | gemini-embedding-2 |
| `model`, `dim` | string, int | Model aralashib ketishidan himoya. |
| `hash` | string | sha256(text + model). O'zgarmasa qayta hisoblanmaydi. |
| `updatedAt` | timestamp | |

## 4. Bajarish bosqichlari

### 1-bosqich. Yagona yig'uvchi (`sudqollanma_bot/rag/build.py`)
- `sources.yaml`: har manba uchun yo'l yoki kolleksiya, `source` nomi va bo'laklash turi.
- **Bitta bo'laklovchi:**
  - markdown sarlavhalari (`#`–`###`) bo'yicha bo'linadi; 1200 belgidan katta bo'lim 150 belgilik qoplama bilan bo'linadi;
  - PDF `fitz` bilan sahifa va sarlavha bo'yicha o'qiladi;
  - FAQ: savol + javob = 1 bo'lak.
- **DARS:** bo'laklar darsga bog'lanadi (`doc_id = m1_l2`). Har dars faqat o'z oralig'ini oladi. Shu xarita DARS darslarida bir xil matn chiqish xatosini ham tuzatadi (1-bo'lim, 8-band).
- Rejimlar: `--dry-run` (faqat hisobot), `--source dars` (bitta manba).
- **Faqat o'zgarganini yangilash:** `hash` o'zgarmasa embedding chaqirilmaydi. Manbadan yo'qolgan id'lar o'chiriladi.
- Yozish: batch, 50 tadan; Gemini so'rovlari soniyasiga chegaralanadi; vaqtinchalik xatolarda qayta urinadi.
- **Hisobot:** manba bo'yicha soni, yangi, o'zgargan, o'chirilgan, takror va bo'sh bo'laklar.
- Testlar: bo'laklovchi (sarlavha, uzun bo'lim, DARS oralig'i), `hash` va id barqarorligi.

### 2-bosqich. Sifat o'lchovi (eval)
- 30 ta haqiqiy savol (ICT so'rovlari va FAQ'dan), har biriga kutilgan `doc_id`.
- `rag/eval.py` hit@1 va hit@5 ni o'lchaydi.
- **Qabul mezoni:** hit@5 ≥ 80%. Bugungi holat amalda 0%, chunki qidiruv bo'sh qaytadi.

### 3-bosqich. Yangi kolleksiyaga yig'ish (jonli Firestore — **ruxsat bilan**)
- `firestore.indexes.json` ga `rag_chunks_v2.embedding` (768, flat, cosine) qo'shiladi va deploy qilinadi.
- `build.py` to'liq ishga tushiriladi. Taxminiy hajm: ~1600 bo'lak × ~400 token ≈ 0.65M token, bir martalik.
- Eski `rag_chunks` hali o'chirilmaydi: almashtirish orqaga qaytariladigan bo'lib qoladi.

### 4-bosqich. O'qish yo'llarini almashtirish
- **Bot (`services/ai_service.py`):**
  - `rag_chunks_v2` + `RETRIEVAL_QUERY`;
  - `get_system_manuals()` zaxirasi va wiki chaqiruvi olib tashlanadi;
  - natija bo'sh bo'lsa, "manbada topilmadi" deb javob beriladi.
- **Ilova:**
  - qidiruv `sodiqChat` ichida serverda bajariladi, mijoz `context` yubormaydi;
  - `RagService`, `WikiService` (Dart) va `ext-firestore-vector-search` chaqiruvi olib tashlanadi;
  - `LocalRagService` faqat oflayn kalit so'z qidiruvi sifatida qoladi. Ichidagi vektorlar olib tashlanadi; `assets/data` dan faqat kerakli, vektorsiz JSON qoladi (~1 MB).
- `firestore.rules`: `rag_chunks_v2` mijozga yopiq, faqat server o'qiydi.

### 5-bosqich. Tozalash (eval va 1 haftalik kuzatuvdan keyin)
- Olib tashlanadigan kod:
  - `b-v22/scripts/{extract_chunks,generate_embeddings,sync_to_firestore}.py`;
  - bot `scripts/{upload_knowledge,wiki_builder,wiki_linter}.py`;
  - `services/wiki_service.py`.
- Firestore'dan o'chiriladi (**ruxsat bilan**): eski `rag_chunks`, `wiki_pages`, `wiki_meta`, `wiki_log`.
- Hujjatlar: bot `CLAUDE.md` va `docs/` ga yangi yo'l yoziladi. "Bilim qo'shish = manbani yangilab, `build.py` ni ishga tushirish".

## 5. Ruxsat talab qiladigan nuqtalar

| Qadam | Nima o'zgaradi |
|---|---|
| 3-bosqich | Firestore indeks deploy va `rag_chunks_v2` ga yozish |
| 4-bosqich | Bot Cloud Run'ga deploy (GitHub `main` ga push), `sodiqChat` va ilova deploy |
| 5-bosqich | Eski kolleksiyalarni o'chirish (qaytarib bo'lmaydi) |

## 6. Xavflar

- **Gemini kvotasi yoki narxi:** to'liq yig'ish kichik. Kundalik yangilash faqat o'zgargan bo'laklar uchun bo'ladi.
- **PDF matn sifati:** skanerlangan PDF'larda matn chiqmasligi mumkin. Hisobotda "bo'sh bo'lak" sifatida ko'rinadi, kerak bo'lsa OCR keyinroq qo'shiladi.
- **Bot va ilova bir vaqtda almashmasligi:** eski kolleksiya 5-bosqichgacha saqlanadi, shuning uchun har bir yo'lni alohida qaytarish mumkin.
- **`sodiqChat` limiti:** foydalanuvchi bo'yicha kunlik limit shu ish bilan birga qo'shilishi tavsiya etiladi (alohida topilma).
