# Telegram bot ↔ ilova: Firestore maʼlumot shartnomasi tahlili (2026-11-11)

Manba: `https://github.com/Sevittt/sudqollanma_bot`, `git clone --depth 1`, HEAD `61181b4` (PR #3 merge). Bot kodi faqat oʻqildi, ishga tushirilmadi. Havolalar shakli: `botrepo/<fayl>:<qator>` — bot, `lib/...`, `functions/...`, `firestore.rules`, `scripts/...` — ilova (`D:\dasturlar\b-v22`).

> **Cheklov.** Klon sayoz (`--depth 1`), shuning uchun git tarixi tekshirilmadi. Auditda koʻrilgan baʼzi qiymatlar botning hozirgi kodida **yoʻq** (6.3-boʻlimga qarang). Ular botning eski versiyalaridan, ilovaning eski versiyalaridan yoki qoʻlda kiritilgan maʼlumotdan qolgan boʻlishi mumkin.

## Qisqacha xulosa

- Bot Python 3.11 + aiogram 3 da yozilgan va Firebase **Admin SDK** orqali `educationapp-4780a` loyihasining `(default)` bazasiga ulanadi. Shuning uchun `firestore.rules` uning yozuvlariga **taʼsir qilmaydi**.
- Bot `users` hujjatlarini **avto-ID** (`.add()`) bilan yaratadi va ularni `telegram_id` (string) maydoni orqali topadi. Ilovada esa hujjat kaliti Firebase Auth `uid` boʻladi. Ilova `phoneNumber` yozmaydi, shu sababli botning telefon orqali bogʻlash mantigʻi amalda ilova profiliga yetib bormaydi: bitta odam uchun **ikkita profil** paydo boʻladi.
- Bot `level` maydoniga **son** (`1`) yozadi va uni hech qachon qayta hisoblamaydi. `role` maydoniga `'user'` yoki callbackdan kelgan **tekshirilmagan** qiymatni yozadi. Har bir toʻgʻri javob uchun `xp` ni +10 ga oshiradi. Bunda server qoidalari (`awardXp`, 70% chegara, idempotentlik) chetlab oʻtiladi.
- `quiz_attempts.userId` maydoniga amalda **telegram ID** yoziladi, shuning uchun ilova bu urinishlarni koʻrsatmaydi.
- `rag_chunks` da **uch xil embedding modeli** aralashib ketgan: botning yuklovchisi `gemini-embedding-2` ni, botning soʻrovi `gemini-embedding-exp-03-07` ni, ilova skripti esa EmbeddingGemma-2 ni ishlatadi. Bu vektor qidiruv sifatini buzadi.
- `wiki_log` va `wiki_meta` ni na bot, na ilova kodi yozadi. Ilova `wiki_pages` dan foydalanadi.
- **Xavfsizlik:** `setrole_*` callback qiymati tekshirilmaydi (ehtimoliy admin eskalatsiyasi). `.gcloudignore` `serviceAccountKey.json` ni ataylab yuklashga qoldiradi.

---

## 1. Stek, kirish nuqtasi, Firebase autentifikatsiyasi

| Mavzu | Topilma | Havola |
|---|---|---|
| Til/runtime | Python 3.11 (Docker `python:3.11-slim`) | `botrepo/Dockerfile:1` |
| Kutubxonalar | `aiogram>=3`, `firebase-admin`, `google-genai`, `aiohttp`, `python-dotenv`, `reportlab`, `Pillow` | `botrepo/requirements.txt:1-7` |
| Kirish nuqtasi | `python main.py`, `main()` | `botrepo/Dockerfile:13`, `botrepo/main.py:72-104` |
| Ishlash rejimi | `WEBHOOK_URL` boʻlsa, aiohttp webhook (`/webhook`, Cloud Run `PORT`) ishlaydi, aks holda polling | `botrepo/main.py:76-98`, `botrepo/main.py:100-104`, `botrepo/config.py:18-20` |
| Routerlar | onboarding → commands → stats → quizzes → resources → kb_articles → courses → helpdesk (catch-all) | `botrepo/main.py:32-39` |
| Muhit oʻzgaruvchilari (faqat nomlari) | `BOT_TOKEN`, `GEMINI_API_KEY`, `FIREBASE_CREDENTIALS`, `GEMINI_MODEL` (standart `gemini-2.5-flash`), `ADMIN_IDS`, `WEBHOOK_URL`, `WEBAPP_HOST`, `PORT` | `botrepo/config.py:6-20` |
| Firebase autentifikatsiyasi | Agar `FIREBASE_CREDENTIALS` fayl yoʻli mavjud boʻlsa, `credentials.Certificate(...)` (service account JSON, izohda `serviceAccountKey.json`) ishlatiladi. Aks holda **ADC** va `projectId: 'educationapp-4780a'` | `botrepo/loader.py:29-40` |
| Firestore bazasi | `firestore.client()` — database ID berilmagan, demak `(default)` | `botrepo/loader.py:43` |
| SDK turi | `firebase_admin` (Admin SDK), xavfsizlik qoidalari qoʻllanmaydi | `botrepo/loader.py:6-7`, `botrepo/services/firestore_service.py:1-6` |
| Skriptlar | `scripts/*.py` ham `serviceAccountKey.json` yoki ADC + `educationapp-4780a` ga ulanadi | masalan `botrepo/scripts/populate_courts.py:15-20` |

`ADMIN_IDS` oʻqiladi (`botrepo/config.py:14-15`), lekin bot kodining hech bir joyida ishlatilmaydi (grep natijasi boʻsh).

## 2. Kolleksiyalar va yoziladigan maydonlar

### 2.1 `users` (oʻqiydi va yozadi)

**Hujjat kaliti.** Bot `collection('users').add(...)` chaqiradi, yaʼni hujjat **avto-ID** bilan yaratiladi, Firebase Auth uid ham, telegram id ham kalit boʻlmaydi (`botrepo/services/firestore_service.py:62`, `:100`). Foydalanuvchi har doim `where('telegram_id','==',str)` soʻrovi bilan topiladi (`:21`). Int koʻrinishidagi eski qiymat uchun zaxira soʻrov bor va u topilgan qiymatni stringga aylantirib qayta yozadi (`:28-33`).

**Yaratishning 1-yoʻli: lavozim tugmasi** (`setrole_<role>`). Agar foydalanuvchi topilmasa, quyidagi hujjat yaratiladi (`botrepo/handlers/onboarding.py:481-492`):

| Maydon | Turi/qiymati |
|---|---|
| `telegram_id` | string |
| `firstName` | string (Telegram first_name) |
| `fullName` | string (Telegram full_name) |
| `role` | callback qiymatidan olingan `role_key`, **tekshiruvsiz** (`:474`, `:485`) |
| `xp` | `0` (int) |
| `level` | `1` (**int**) |
| `quiz_correct` | `0` |
| `createdAt` | `SERVER_TIMESTAMP` (Timestamp) |
| `last_updated_by` | `'telegram_bot'` |

**Yaratishning 2-yoʻli: kontakt (telefon) yuborish.** `link_telegram_to_phone` quyidagicha ishlaydi (`botrepo/services/firestore_service.py:69-104`):
- `phoneNumber == '+<raqam>'` boʻyicha hujjat topilsa, unga faqat `telegram_id` va `last_updated_by` yoziladi (`:83-86`).
- Topilmasa, yangi hujjat yaratiladi: `phoneNumber` (string, `+` bilan), `telegram_id`, `firstName` (bu yerda Telegram **full_name** yoziladi), `xp: 0`, `level: 1`, `role: 'user'`, `quiz_correct: 0`, `createdAt: SERVER_TIMESTAMP`, `last_updated_by` (`:89-100`).
- Kontakt boshqa odamniki boʻlsa, qabul qilinmaydi (`botrepo/handlers/onboarding.py:153-167`).

**Mavjud hujjatni yangilash:**

| Funksiya | Yoziladigan maydonlar | Havola |
|---|---|---|
| `add_xp` | `xp: Increment(n)`, `last_updated_by` | `botrepo/services/firestore_service.py:116-119` |
| `increment_quiz_correct` | `quiz_correct: Increment(n)` | `:135-138` |
| `save_competency_level` | `digital_level` (string: `"Boshlang'ich"` / `"O'rta"` / `"Ilg'or"`, ASCII apostrof bilan), `competency_score` (0–3, int) | `:154-158`, qiymatlar `botrepo/handlers/onboarding.py:277-284` |
| `update_user_role` | `role: role_key` (tekshiruvsiz) | `botrepo/services/firestore_service.py:216-219`, chaqiruv `botrepo/handlers/onboarding.py:504` |
| `update_court_info` | `courtName`, `courtType` (`jib`/`fib`/`viloyat`/`iqtisodiy`/`oliy`), `region` (matn), `position` (matn) | `botrepo/services/firestore_service.py:490-496`, `botrepo/handlers/onboarding.py:94-100`, `:445-453` |

**Role qiymatlari.** Bot yozishi mumkin boʻlgan qiymatlar: `judge`, `assistant`, `chancellery`, `archive`, `ict_specialist` (tugmalar, `botrepo/handlers/onboarding.py:71-75`), `'user'` (`botrepo/services/firestore_service.py:95`) hamda soxta callback orqali har qanday string (1.5-boʻlimga qarang).

**Level.** Bot `level` maydonini hech qachon hisoblamaydi va yangilamaydi: u faqat yaratilganda `1` boʻladi. Profil sahifasi uni son deb hisoblaydi: `xp_for_next = level*100 - xp` (`botrepo/handlers/commands.py:73-78`), `stats.py` esa `level >= 10` kabi taqqoslashlarni bajaradi (`botrepo/handlers/stats.py:23-33`). Bot ilova foydalanuvchisiga ulangan boʻlsa (`level: 'levelBeginner'`), Python `str >= int` va `str*int - int` amallarida **TypeError** chiqaradi. Bu xatoni ishlovchi middleware ushlab qoladi, ammo `/profile` va `/stats` buyruqlari ishlamay qoladi. Bu taxmin kod asosida chiqarilgan, ishga tushirib tekshirilmagan.

**Sanalar.** Bot faqat `createdAt` ni Timestamp sifatida yozadi. `lastLogin` va `registrationDate` ni bot **yozmaydi**: ular ilovaning oʻzi tomonidan ISO string koʻrinishida yoziladi (`lib/features/auth/data/models/app_user_model.dart:139-140`, `lib/features/auth/data/datasources/auth_remote_datasource.dart:185-186`).

### 2.2 `quiz_attempts` (faqat yozadi)

Maydonlar `botrepo/services/firestore_service.py:420-431` da yoziladi:

| Maydon | Qiymat |
|---|---|
| `userId` | `user.get('uid', tg_id)`. Na bot, na ilova `users` hujjatiga `uid` maydonini yozadi (ilova `id` yozadi: `lib/features/auth/data/models/app_user_model.dart:132`), shuning uchun amalda doim **telegram id** yoziladi (`:418`) |
| `quizId`, `quizTitle` | string (standart qiymat `'bot_quiz'`/`'Bot testi'`, `botrepo/handlers/quizzes.py:228-234`) |
| `score` | toʻgʻri javoblar soni (int) |
| `totalQuestions` | int |
| `attemptedAt` | `SERVER_TIMESTAMP` |
| `source` | `'telegram_bot'` |
| `telegramId` | string |

`timeTakenSeconds` yozilmaydi. Ilova bu maydonni nullable sifatida qabul qiladi (`lib/features/quiz/data/models/quiz_attempt_model.dart:52`).

### 2.3 `conversations` (oʻqiydi, yozadi, oʻchiradi)

- Yozish: `{telegram_id: string, role: 'user'|'model', text: string, timestamp: SERVER_TIMESTAMP}` (`botrepo/services/firestore_service.py:171-176`). Har bir AI savol-javobida ikki hujjat yoziladi (`botrepo/services/ai_service.py:185`, `:197`).
- Oʻqish: soʻnggi 6 ta xabar, `telegram_id` + `timestamp DESC` boʻyicha, bu kompozit indeks talab qiladi (`botrepo/services/firestore_service.py:188-192`).
- `/reset` buyrugʻi foydalanuvchining barcha xabarlarini batch delete orqali oʻchiradi (`:265-292`, `botrepo/handlers/commands.py:100-102`).
- Ilova bu kolleksiyani ishlatmaydi (`lib` boʻyicha grep natijasi boʻsh).

### 2.4 `rag_chunks`

- **Bot runtime faqat oʻqiydi:** `find_nearest(vector_field='embedding', COSINE, limit=3)`, soʻrov embeddingi `gemini-embedding-exp-03-07` modeli bilan, 768 oʻlchamda olinadi. Matn `text` maydonidan oʻqiladi (`botrepo/services/ai_service.py:76-98`).
- **`scripts/upload_knowledge.py` yozadi:**
  - `km_0000…` IDlar uchun `{title, text, embedding(list[float] 768), source:'knowledge.md', chunk_index}` (`botrepo/scripts/upload_knowledge.py:146-162`);
  - `faq_<id>` IDlar uchun `{title, text, embedding, source:'faqs', faq_id}` (`:208-214`).
  - Model `gemini-embedding-2`, 768 oʻlcham (`:59`, `:78`).
  - Skript eski `source=='knowledge.md'` va `source=='faqs'` chunklarni oʻchiradi (`:125`, `:182-184`).
- **Auditdagi 20% (`module`/`category`/`updatedAt` string) bot yozuvlari emas.** Ularni ilovaning oʻz skripti yozgan: `scripts/sync_to_firestore.py:35-44` (`title, text, module, category, embedding, updatedAt` (ISO string), `merge=True`). Embeddinglar EmbeddingGemma-2 modeli bilan olingan (`scripts/generate_embeddings.py:15`, `:46`, `:91`).
- **Embedding embeddinglar aralash:** botning soʻrov modeli (`exp-03-07`) uning yuklovchi modeli (`gemini-embedding-2`) bilan **mos emas**, garchi kod izohida „bir xil boʻlishi SHART“ deb yozilgan boʻlsa ham (`botrepo/services/ai_service.py:75-77` va `botrepo/scripts/upload_knowledge.py:59`). Ilovaning masofaviy fallbacki `ext-firestore-vector-search-queryCallable` kengaytmasidan foydalanadi (`lib/features/search/data/datasources/search_remote_datasource.dart:20`). Kengaytmaning embedding modeli repoda konfiguratsiya qilinmagan (`extensions/` papkasi yoʻq), shuning uchun **tekshirib boʻlmadi**.

### 2.5 `wiki_log`, `wiki_meta`

Bot kodida bu nomlar ham, umuman `wiki` soʻzi ham yoʻq (grep natijasi boʻsh). Ilova ham ularni ishlatmaydi: ilova `wiki_pages` kolleksiyasiga `{slug, title, content, source_query, hit_count, created_at}` yozadi (`lib/core/services/wiki_service.dart:20`, `:71-78`). **Kim yozgani aniqlanmadi.** Ular botning eski versiyasidan, boshqa skriptdan yoki qoʻlda yaratilgan boʻlishi mumkin. Buni git tarixini toʻliq klonlab tekshirish kerak.

### 2.6 `courts`

- Faqat `scripts/populate_courts.py` yozadi. U **avval barcha hujjatlarni oʻchiradi** (`botrepo/scripts/populate_courts.py:167-176`), keyin yangi avto-ID hujjatlar yaratadi (`:182`).
- Maydonlar: `courtName` (string), `courtType` (`viloyat`/`jib`/`fib`), `region` (matn, masalan `"Andijon viloyati"`), `isActive: true`, `order` (int) (`:119-125`, `:133-134`, `:142-143`).
- Bot runtime uni faqat oʻqiydi: hududlar roʻyxati va `region`+`courtType` boʻyicha `orderBy courtName` (kompozit indeks kerak) (`botrepo/services/firestore_service.py:444-470`).
- Ilova bu kolleksiyani oʻqimaydi va oʻzining `courtId`/`courtTypeId`/`regionId` sxemasidan foydalanadi (`lib/features/auth/data/models/app_user_model.dart:89-94`).

### 2.7 Boshqa kolleksiyalar (bot runtime faqat oʻqiydi)

`quizzes/{id}/questions` (`questionText`, `options`, `correctAnswer`, ixtiyoriy `correct_index`) — `botrepo/services/firestore_service.py:303-387`, `botrepo/handlers/quizzes.py:194-202`; `resources`, `knowledge_base`, `faqs`, `courses` (`isPublished`, `order`) — `:509-593`.

Skriptlar quyidagilarga **yozadi**: `courses`, `knowledge_base`, `faqs`, `quizzes`, `resources`/files, `news`, `systems`, `video_tutorials`, `certificates`, `user_course_progress`. Masalan: `botrepo/scripts/populate_quizzes.py:194-200`, `botrepo/scripts/populate_news.py:53-73` (avval tozalaydi), `botrepo/scripts/generate_certificate.py:283-294`. Bular faqat qoʻlda ishga tushiriladigan admin/ETL skriptlari, Cloud Run'ga yuklanmaydi (`botrepo/.gcloudignore:23-39`).

## 3. Bot foydalanuvchisi ↔ ilova foydalanuvchisi

1. **Bogʻlash faqat `phoneNumber` orqali amalga oshadi** (`botrepo/services/firestore_service.py:75`). Ilova `users` hujjatiga `phoneNumber` yozmaydi: `lib` dagi grep faqat FirebaseAuth ichki kodini topdi, `app_user_model.toMap` da bunday maydon yoʻq. Natijada bogʻlash amalda **hech qachon** ilova hujjatini topmaydi va har safar yangi hujjat yaratadi (`:89-101`).
2. **Bitta odam uchun ikki va undan ortiq hujjat paydo boʻladi:**
   - ilova hujjati (`users/{uid}`) va bot hujjati (`users/{autoId}`, `telegram_id` bilan) alohida yashaydi;
   - bot ichida ham dublikat yuzaga kelishi mumkin. Foydalanuvchi avval lavozim tugmasini bossa, telefonsiz hujjat yaratiladi (`botrepo/handlers/onboarding.py:481-492`). Keyin kontakt yuborsa, `phoneNumber` boʻyicha topilmagani uchun yana bitta hujjat yaratiladi va unda **xuddi shu `telegram_id`** boʻladi. Shundan soʻng `get_user` `limit(1)` bilan tartibsiz holda istalgan bittasini qaytaradi (`botrepo/services/firestore_service.py:21`).
3. **Ilova maydonlarini ustidan yozish** (agar hujjat qaysidir yoʻl bilan ilova hujjati bilan bogʻlangan boʻlsa):
   - `xp` — `Increment` orqali, ilova qoidalaridan tashqari (`:116-119`);
   - `role` — lavozim tugmasi qayta bosilganda **har doim** ustidan yoziladi, admin ham `judge` ga tushib qolishi mumkin (`botrepo/handlers/onboarding.py:503-504`);
   - `courtName`, `position` — ustidan yoziladi, lekin `courtId`/`courtTypeId`/`regionId` yangilanmaydi va ular bir-biriga zid boʻlib qoladi (`botrepo/services/firestore_service.py:490-496`);
   - `level`, `currentStreak`, `quizzesPassed` — bot ularga **tegmaydi**. Biroq bog‘lanmagan bot hujjatida `level: 1` (int) qoladi.
4. **Leaderboard.** Ilova `users` ni `orderBy('xp')` boʻyicha oʻqiydi (`lib/features/gamification/data/datasources/gamification_remote_datasource.dart:61`). Bot hujjatlari ham reytingga tushadi, lekin ularda `name` maydoni yoʻq (`fromMap` faqat `name` ni oʻqiydi: `lib/features/auth/data/models/app_user_model.dart:70`), shuning uchun ismsiz koʻrinadi. `role: 'user'` esa `unknown` deb talqin qilinadi (`:182-221`).

## 4. Gamifikatsiya: bot va ilova qoidalari

| Jihat | Ilova | Bot |
|---|---|---|
| XP manbai | Faqat server callable `awardXp`, idempotent (`xp_awards`) (`functions/src/callables/gamification.ts:38-84`) | Klient (bot) toʻgʻridan-toʻgʻri `Increment` qiladi (`botrepo/services/firestore_service.py:116-119`) |
| Test uchun XP | `quizPass: 20`, `quizPerfect: 50`, `speedBonus: 5`, 70% oʻtish chegarasi (`functions/src/gamification/rules.ts:8-16`) | Har bir toʻgʻri javob uchun **+10 XP**, oʻtish chegarasi yoʻq, takrorlash cheklanmagan, bitta testni qayta-qayta ishlab XP yigʻish mumkin (`botrepo/handlers/quizzes.py:211-226`, `:119`) |
| Level | `levelBeginner…levelMaster`, chegaralar 100/500/1000/2000/5000 va gatekeeper shartlari (`functions/src/gamification/rules.ts:19-31`, `:160-172`) | Int `1`, hech qachon oshirilmaydi; UI `level*100` formulasidan foydalanadi (`botrepo/handlers/commands.py:77`) |
| Hisoblagichlar | `quizzesPassed`, `totalQuizzesAced` | `quiz_correct` (javoblar soni, testlar soni emas) |
| Faollik | `lastActivity` (server Timestamp) (`functions/src/callables/gamification.ts:82`) | yozmaydi (auditdagi `lastActivity` ilova serveridan keladi) |

**Qoidalar.** Klient faqat `ownerEditableUserFields` roʻyxatidagi maydonlarni yoza oladi (`firestore.rules:35-39`, `:65-68`). Yangi profil uchun `xp==0`, `level=='levelBeginner'` va `role ∈ selfAssignableRoles` shartlari bor (`firestore.rules:29-31`, `:41-56`). Bot esa **Admin SDK** orqali ishlaydi (`botrepo/loader.py:31-43`), shuning uchun bu qoidalarning **hech biri** unga taʼsir qilmaydi. `level: 1`, `role: 'user'`, `xp` increment va `quiz_attempts.userId != auth.uid` (`firestore.rules:196-197`) kabi yozuvlar qoidalar tomonidan bloklanmaydi.

Keyingi `awardXp` chaqiruvida server `calculateLevel(after)` ni qayta hisoblaydi (`functions/src/callables/gamification.ts:68`). Shu sababli bot qoʻshgan XP bogʻlangan foydalanuvchining levelini bilvosita oshirib yuboradi.

## 5. AI/RAG

- **Bot chat:** model `GEMINI_MODEL` (standart `gemini-2.5-flash`, `botrepo/config.py:11`). Kontekst `rag_chunks` vektor qidiruvidan olinadi, xato yuz bersa `knowledge_base` dan oddiy oʻqishga oʻtiladi (`botrepo/services/ai_service.py:66-110`). Suhbat tarixi `conversations` dan olinadi (`:163`).
- **`rag_chunks` ga kim yozadi:**
  - bot repo `scripts/upload_knowledge.py` (`gemini-embedding-2`, 768);
  - ilova repo `scripts/sync_to_firestore.py` (EmbeddingGemma-2, 768, `module`/`category`/`updatedAt`).
  - Bot runtime yozmaydi.
- **`wiki_log`/`wiki_meta`:** hech bir repoda yozuvchi topilmadi (2.5-boʻlim).
- **Ilova kutgan format:**
  - `RagService` wiki, keyin lokal RAG (Drift/EmbeddingGemma), keyin masofaviy vektor qidiruv tartibida ishlaydi (`lib/core/services/rag_service.dart:19-79`);
  - masofaviy natijalar `rag_chunks/{id}` dan oʻqiladi; `text` boʻlmasa `content` olinadi, `title` boʻlmasa standart qiymat qoʻyiladi (`lib/features/search/data/datasources/search_remote_datasource.dart:56-76`). Bu botning `{title,text}` formati bilan **mos keladi**;
  - wiki qatlami **`wiki_pages`** dan foydalanadi (`lib/core/services/wiki_service.dart:20`), `wiki_log`/`wiki_meta` dan emas.
- **Asosiy muammo:** bir `embedding` maydonida uch xil vektor fazosi aralashgan. Cosine masofasi faqat bir xil model bilan olingan vektorlar orasida maʼnoli boʻladi, shuning uchun bot ham, ilova kengaytmasi ham chunklarning bir qismi uchun notoʻgʻri natija oladi. Ilova kengaytmasining modelini **tekshirib boʻlmadi**.
- **Qoʻshimcha (ilova bagʻi):** `WikiService._buildSlug` funksiyasida `.substring(0, text.length.clamp(0, 80))` asl matn uzunligini oʻzgartirilgan satrga qoʻllaydi. `o'`→`o` almashtirilganda satr qisqaradi va `RangeError` chiqishi mumkin (`lib/core/services/wiki_service.dart:102-110`).

## 6. Ziddiyatlar va yagona shartnoma

### 6.1 Ziddiyatlar roʻyxati

| # | Maydon | Ilova kutadi | Bot yozadi | Taʼsir |
|---|---|---|---|---|
| 1 | `users` hujjat kaliti | Auth `uid` (`lib/features/auth/data/datasources/auth_remote_datasource.dart:120`) | avto-ID + `telegram_id` (`botrepo/services/firestore_service.py:62`, `:100`) | Bitta odam uchun ikki profil, leaderboard va analitika ikki marta hisoblaydi |
| 2 | bogʻlash kaliti | — (`phoneNumber` yozilmaydi) | `phoneNumber` (`:75`) | Bogʻlash amalda ishlamaydi |
| 3 | `level` | `levelBeginner…` string | `1` (int) (`botrepo/handlers/onboarding.py:487`) | Ilova `_migrateLevel` uni default qiymatga tushiradi (`lib/features/auth/data/models/app_user_model.dart:233-260`); bot ilova qiymati bilan TypeError beradi |
| 4 | `role` | `CourtRole` enum nomlari | `'user'`, tekshiruvsiz `role_key` | `'user'`→`unknown`; soxta `setrole_admin` → **admin** (`app_user_model.dart:191-193`) |
| 5 | ism | `name` | `firstName`, `fullName` | Ilovada ism boʻsh koʻrinadi |
| 6 | `xp` | faqat `awardXp` | `Increment(+10/javob)` | Qoidalar chetlab oʻtiladi, XP farm qilish mumkin |
| 7 | test statistikasi | `quizzesPassed`, `totalQuizzesAced` | `quiz_correct` | Mos kelmaydi |
| 8 | `quiz_attempts.userId` | Auth uid (`lib/features/quiz/data/datasources/quiz_remote_datasource.dart:85-88`) | telegram id | Ilova tarixida koʻrinmaydi |
| 9 | `quiz_attempts.source` | yoʻq | `'telegram_bot'` | Zararsiz, lekin auditdagi `telegram` qiymati bilan mos emas (6.3) |
| 10 | sud maʼlumoti | `courtId/courtName/courtTypeId/regionId/position` | `courtName/courtType/region/position` | `courtName` va `courtId` bir-biriga zid boʻladi; `courtType`/`region` ortiqcha maydonlar |
| 11 | `courts` | oʻqilmaydi (ilovaning oʻz katalogi bor) | 294 hujjat, skript har gal toʻliq qayta yaratadi | Ikki manba, IDlar barqaror emas |
| 12 | sanalar | aralash: `lastLogin`/`registrationDate` ISO string (ilovaning oʻzi yozadi), `lastActivity` Timestamp | `createdAt` Timestamp | Ikki format bitta hujjatda |
| 13 | `rag_chunks.embedding` | kengaytma modeli (nomaʼlum) / EmbeddingGemma | `gemini-embedding-2`; soʻrov `exp-03-07` | Vektor qidiruv sifati buziladi |
| 14 | wiki | `wiki_pages` | — | `wiki_log`/`wiki_meta` egasiz qolgan |
| 15 | `digital_level` | yoʻq | `"Boshlang'ich"`/`"O'rta"`/`"Ilg'or"` | Ilova bilmaydi; `level` bilan adashtirilishi mumkin |

### 6.2 Taklif etilayotgan yagona shartnoma

- **Hujjat kaliti:** `users/{firebaseUid}`. Telegram identifikatori alohida indeks kolleksiyasida saqlanadi: `telegram_links/{telegramId} = {uid, linkedAt: Timestamp}`. `users/{uid}.telegramId` (string) maydoni ham qoʻshiladi va uni faqat server yozadi.
- **Bogʻlash:** ilovada „Telegram'ni ulash“ tugmasi bosilganda callable bir martalik kod yaratadi. Foydalanuvchi botga `/start link_<kod>` yuboradi, bot uni server orqali tekshirib `telegram_links` ga yozadi. Telefon orqali bogʻlashdan voz kechiladi, chunki ilova telefonni saqlamaydi. Bogʻlanmagan bot foydalanuvchisi `users` ga **yozilmaydi**; uning maʼlumotlari `telegram_guests/{telegramId}` da saqlanadi.
- **Rollar enumi:** `judge | assistant | chancellery | archive | ict_specialist | admin | unknown`. `user` va `xodim` qiymatlari yangi yozuvlarda taqiqlanadi. Bot faqat `selfAssignableRoles` (`firestore.rules:29-31`) qiymatlarini oq roʻyxat asosida qabul qiladi, `admin` ni hech qachon yozmaydi.
- **Level:** faqat `levelBeginner…levelMaster`, faqat server `calculateLevel` hisoblaydi. Bot XP qoʻshmaydi, buning oʻrniga ilova bilan bir xil idempotent kalit (`quiz:<quizId>:<attemptId>`) bilan umumiy XP xizmatini (Cloud Function / HTTP) chaqiradi.
- **Ism:** `name` (string). `firstName`/`fullName` dan voz kechiladi.
- **Sanalar:** barcha yangi yozuvlar Firestore `Timestamp` koʻrinishida (`createdAt`, `lastLogin`, `registrationDate`, `lastActivity`). Ilova `toMap` ham ISO stringdan Timestampga oʻtkaziladi. `_parseDate` ikkalasini ham oʻqiydi (`lib/features/auth/data/models/app_user_model.dart:114-127`).
- **`quiz_attempts`:** `userId` = Auth uid (majburiy), `source: 'app'|'telegram'`, `attemptedAt` Timestamp, `score`, `totalQuestions`, `timeTakenSeconds?`.
- **`rag_chunks`:** bitta embedding modeli va oʻlchami tanlanadi va `embeddingModel` maydonida saqlanadi. Ixtiyoriy maydonlar: `title`, `text`, `source`, `module?`, `category?`, `updatedAt` (Timestamp).
- **`courts`:** yagona katalog. Ilova katalogi asosiy manba deb belgilanadi, yoki `courts` barqaror ID (`courtId`) bilan saqlanadi va bot `courtId` yozadi.

### 6.3 Auditdagi, lekin bot HEAD kodida topilmagan qiymatlar (TASDIQLANMAGAN)

- `level: 'Boshlangʻich'` (U+02BB) — bot `level` ga son yozadi, Uzbek matnini esa (ASCII `'` bilan) faqat `digital_level` ga yozadi. Ilova `_migrateLevel` funksiyasida `Boshlang'ich` **ASCII** apostrof bilan yozilgan (`lib/features/auth/data/models/app_user_model.dart:235`). `Boshlangʻich` default qiymat orqali baribir `levelBeginner` ga tushadi, lekin `Oʻrta`/`Ilgʻor` (U+02BB) **notoʻgʻri** `levelBeginner` ga tushadi. Bu qiymatlar ilovaning eski versiyalaridan qolgan boʻlishi ehtimoli bor.
- `role: 'xodim'` — bot yozmaydi. Ilova uni legacy sifatida `assistant` ga xaritalaydi (`app_user_model.dart:207-211`).
- `quiz_attempts.source: 'telegram'` — botning hozirgi kodi `'telegram_bot'` yozadi. Audit qiymatini aniq qayta tekshirish kerak.
- `lastActivity` — ilova serveri yozadi (`functions/src/callables/gamification.ts:82`).
- `wiki_log`, `wiki_meta` — yozuvchi topilmadi.

### 6.4 Migratsiya rejasi (taklif, bajarilmagan)

1. **Botni muzlatish:** botning `users` ga yozadigan barcha yoʻllari (`add_xp`, `update_user_role`, `create_user`, `link_telegram_to_phone`) vaqtincha oʻchiriladi yoki server callable'ga yoʻnaltiriladi. `setrole_` callback uchun oq roʻyxat darhol qoʻshiladi.
2. **Inventar (faqat oʻqish):** `telegram_id` maydoni bor `users` hujjatlari roʻyxatga olinadi va ilova hujjatlari bilan solishtiriladi (email yoki ism + sud boʻyicha qoʻlda tasdiqlash).
3. **Birlashtirish skripti (Admin SDK, dry-run → tasdiq → bajarish):**
   - mos keladigan juftliklar uchun `xp`ni server qoidalari boʻyicha qayta hisoblash (bot XP sini qanday hisobga olish — mahsulot qarori);
   - `telegram_links` yozish, bot hujjatini `archived_users` ga koʻchirish;
   - mos kelmaganlarni `telegram_guests` ga koʻchirish.
4. **Normallashtirish:**
   - `level` → `calculateLevel` bilan qayta hisoblanadi;
   - `role` `user`/`xodim` → `unknown`/`assistant`;
   - `firstName`/`fullName` → `name`;
   - ISO string sanalar → Timestamp;
   - ortiqcha maydonlar (`quiz_correct`, `last_updated_by`, `digital_level`, `competency_score`) oʻchiriladi yoki `telegram_guests` ga koʻchiriladi.
5. **`quiz_attempts`:** `userId == telegramId` boʻlgan yozuvlarda `userId` → `uid` ga oʻzgartiriladi (`telegram_links` orqali). Mos kelmaganlari arxivlanadi.
6. **`rag_chunks`:** bitta model tanlanadi, barcha chunklar qayta embed qilinadi, `embeddingModel` maydoni qoʻshiladi, vektor indeksi qayta quriladi. Bot soʻrov modeli shunga moslanadi.
7. **`wiki_log`/`wiki_meta`:** egasi aniqlanadi, keyin `wiki_pages` ga koʻchiriladi yoki oʻchiriladi.
8. **Botni yangilash:** bot server API orqali ishlaydigan qilib yangilanadi. Admin SDK huquqlari minimal service accountga cheklanadi.

## 7. Repo gigiyenasi (xavfsizlik)

- Treked fayllar orasida maxfiy kalitlar topilmadi: `.json`, `.env` yoʻq; `AIza…`, `private_key`, bot token naqshlari boʻyicha grep natijasi boʻsh. `.gitignore` `.env`, `serviceAccountKey.json`, `*.json` ni chiqarib tashlaydi (`botrepo/.gitignore:1-4`). **Git tarixi tekshirilmadi** (sayoz klon).
- `.gcloudignore` `serviceAccountKey.json` ni **ataylab yuklashga qoldiradi** (`botrepo/.gcloudignore:14-15`). Shu bilan birga `.dockerignore` uni imijdan chiqaradi (`botrepo/.dockerignore:7`) va runtime ADC ga tushadi (`botrepo/loader.py:36-40`). Kalit Cloud Build manba arxiviga (GCS) yuklanishi mumkin. `.gcloudignore` `.env` ni ham chiqarmaydi.
- **Imtiyozlarni oshirish xavfi:** `set_role_callback` har qanday `setrole_<x>` qiymatini qabul qiladi va `role` ga yozadi (`botrepo/handlers/onboarding.py:472-504`). Callback data'ni moslashtirilgan MTProto klient soxtalashtirishi mumkin, deb hisoblanadi. **Amalda sinab koʻrilmadi.** Ilova `role=='admin'` ni toʻliq admin deb qabul qiladi (`lib/features/auth/data/models/app_user_model.dart:191-193`, `firestore.rules:20-21`). Bogʻlangan hujjatda bu admin huquqini berishi mumkin. Bogʻlanmagan bot hujjatida esa ilova login qila olmaydi, lekin rol baribir koʻrinadi.
- `ADMIN_IDS` sozlamasi ishlatilmaydi (`botrepo/config.py:14-15`).
- `scratch/handlers/*` — handlerlarning eskirgan nusxalari, ular asosiy handlerlardan farq qiladi va chalkashlik keltirib chiqaradi.
