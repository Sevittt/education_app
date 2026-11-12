# Sud Qoʻllanma: loyiha tartibi tahlili

Sana: 2026-11-11. Branch: `backup-v2`. Bu hujjat 2026-10-12 dagi auditni (xavfsizlik va mantiq xatolari) toʻldiradi: bu yerda **tuzilma, ortiqcha kod, maʼlumotlar modeli va texnik tartib** koʻrib chiqilgan.

Tekshirilgan: `lib/` (257 Dart fayl), repo ildizi, `firestore.rules`, `functions/src`, `pubspec.yaml`, `flutter analyze`, `flutter test`. Tekshirilmagan: Firestore'dagi real maʼlumotlar (production), deploy qilingan rules, qurilmada ishlatib koʻrish.

## Qisqa xulosa

Ilova ishlaydi va asosi yomon emas (modullarga ajratilgan, analyzer deyarli toza, testlar oʻtadi). Tartibsizlik uch joyda yigʻilgan:

1. **Repo ildizi va yordamchi papkalar** — bir martalik skriptlar, hisobot fayllari, eski arxiv va AI-agent papkalari asosiy kod bilan aralash.
2. **Kod ichida** — 16 ta fayl (~2 600 qator) hech qayerdan chaqirilmaydi; bir xil narsaning ikki versiyasi bor.
3. **Maʼlumotlar modeli** — kontent 4 ta alohida kolleksiyaga sochilgan, darsning ikki xil modeli va rules'da eski yoʻllar qolgan.

## 1. Repo darajasida

| Nima | Holat | Taklif |
|---|---|---|
| `check_titles.js`, `fix_title_case.js`, `init_categories.js`, `update_arb.js` | Gitda; bir martalik maʼlumot skriptlari | `scripts/` ga koʻchirish yoki oʻchirish |
| `analysis.json`, `missing_keys.json`, `pro.md` | Gitda; eski hisobot/eslatma | Oʻchirish yoki `docs/archive/` |
| `test_enum.dart`, `web_entrypoint.dart`, `serve_web.py` | Gitda; ildizda sinov fayllari | Kerakligini aniqlab, oʻchirish yoki `tool/` ga |
| `lib/scratch_api_check.dart` | `lib` ichida skretch fayl (8 qator) | Oʻchirish |
| `files/` (31 fayl: CSV, zip, analiz chiqishlari) | Gitda; monitoring eksportlari | Gitdan chiqarish |
| `archive/web_ui` (19), `md/` (23), `scratch/` | Gitda; eski material | `docs/archive/` ga yigʻish yoki oʻchirish |
| `.agent/` (15), `.agents/` (122), `.rune/`, `skills-lock.json` | AI-agent sozlamalari | Kerak boʻlsa qoldirish, lekin README'da izohlash |
| `.mcp.json.backup-2026-05-23…` | Gitda; zaxira nusxa | Oʻchirish |

Maxfiy kalitlar: `.mcp.json` fayllarida kalit/token nomli maydon topilmadi; `.env` gitignore'da.

## 2. Kod ichida

### Hech qayerdan chaqirilmaydigan fayllar (`main.dart` dan erishib boʻlmaydi)

| Qator | Fayl |
|---|---|
| 422 | `features/library/presentation/screens/create_resource_screen.dart` |
| 368 | `features/library/presentation/screens/tabs/articles_tab.dart` |
| 365 | `features/library/presentation/screens/tabs/videos_tab.dart` |
| 329 | `features/library/presentation/screens/tabs/files_tab.dart` |
| 280 | `features/courses/data/seeds/dars_courses_seed.dart` |
| 168 | `features/profile/presentation/screens/change_password_screen.dart` |
| 117 | `features/community/presentation/screens/edit_topic_screen.dart` |
| 109 | `core/widgets/selection_loader.dart` |
| 95 | `features/library/presentation/widgets/library_card.dart` |
| 77 | `features/library/presentation/screens/resources_screen.dart` |
| 73 | `features/auth/presentation/screens/splash_screen.dart` |
| 55 | `core/presentation/screens/placeholder_screen.dart` |
| 54 | `features/courses/domain/entities/lesson_entity.dart` |
| 46 | `features/courses/data/models/lesson_model.dart` |
| 32 | `features/courses/presentation/screens/edit_course_screen.dart` |
| 8 | `scratch_api_check.dart` |

Jami ~2 600 qator. Ayrimlari (masalan, `edit_topic_screen`, `create_resource_screen`) tugallanmagan funksiya boʻlishi mumkin — oʻchirishdan oldin har birini koʻrib chiqish kerak. `dars_courses_seed.dart` kontent yuklash uchun ishlatilgan boʻlsa, `tool/` ga koʻchiriladi.

### Takrorlanishlar

- **Parol oʻzgartirish ekrani ikki marta:** `profile/.../change_password_screen.dart` (ishlatilmaydi) va `settings/.../change_password_screen.dart`.
- **Darsning ikki modeli:** eski `LessonEntity`/`LessonModel` (`courses/{id}/lessons`) va yangi `CourseLessonEntity` (modul ichida). Eskisi ishlatilmaydi.
- **`gamification_rules.dart` ikki joyda:** `lib/config/` va `lib/core/constants/` (ikkinchisi faqat qayta eksport).
- **Eski papka:** `lib/widgets/` da bitta fayl (`quiz_attempt_card.dart`) — `shared/widgets` yoki `features/quiz` ga tegishli.

### Arxitektura va uslub

- **`main.dart` — 679 qator, 98 ta provider.** Barcha bogʻliqliklar bitta faylda yigʻilgan; har feature uchun alohida ulash funksiyasiga ajratish kerak.
- **Ekranlardan toʻgʻridan-toʻgʻri Firestore:** `admin_analytics_screen`, `lesson_viewer_screen`, `admin_notification_management_screen` — repository qatlamini chetlab oʻtadi.
- **193 ta `isDark ? … : …`** — ranglar mavzu (ThemeData) orqali emas, har ekranda qoʻlda tanlanadi. Yangi dizaynga oʻtishda asosiy toʻsiq.
- **58+ ta qattiq yozilgan matn** (`Text('…')`), ~100 faylda oʻzbekcha matnlar koddagi qatorlarda — rus/ingliz tilida aralash koʻrinadi, yangi alifbo ularga taʼsir qilmaydi.
- **Ishlatilmagan paketlar:** `confetti`, `lottie`, `animations`, `flutter_staggered_animations`, `csv` (importi yoʻq); `flutter_skill` — dasturchi vositasi, `dev_dependencies` ga tegishli.
- **Eng katta fayllar:** `lesson_viewer_screen.dart` (1 431), `quiz_screen.dart` (801), `add_questions_screen.dart` (781), `create_course_screen.dart` (778) — boʻlish kerak.

## 3. Maʼlumotlar modeli

### Kontent 4 ta kolleksiyaga sochilgan

| Kontent | Kolleksiya | Kim ishlatadi |
|---|---|---|
| Maqola | `knowledge_base` | Kutubxona + kurs darsi |
| Video | `video_tutorials` | Kutubxona + kurs darsi |
| Fayl/PDF | `resources` | Kutubxona + kurs darsi |
| Test | `quizzes` (+ `questions`) | Testlar roʻyxati + kurs darsi |
| Kurs | `courses` (modullar hujjat ichida) | Kurslar |

Kurs darsi kontentga `refId` + `sourceCollection` orqali bogʻlanadi. Natija: bitta materialni tahrirlash/oʻchirish kursni buzishi mumkin, kontent turini qoʻshish 4 joyda ish talab qiladi, qidiruv va RAG har kolleksiyani alohida yigʻadi.

### Progress va natijalar bir necha joyda

`user_course_progress`, `video_progress` (users ostida), `learning_records`, `quiz_attempts`, `users/{uid}/xp_awards`. Har biri boshqa formatda; "xodim nimani tugatdi" degan oddiy savolga javob uchun 4–5 manbani birlashtirish kerak. Kurs progressi (`completedLessonIds`, `percentComplete`) hali client tomonidan hisoblanadi.

### Rules'da eski yoki takroriy yoʻllar

- `/faq/` va `/faqs/` — kod faqat `faqs` ni ishlatadi.
- `/topics/` va `/discussion_topics/` — kod faqat `discussion_topics` ni ishlatadi.
- `courses/{id}/lessons` va `courses/{id}/modules/{id}/lessons` — kod ikkalasini ham ishlatmaydi (modullar kurs hujjati ichida).
- Kolleksiya nomlari kodda turli joylarda satr sifatida yozilgan (yagona konstantalar fayli yoʻq).

## 4. Hozirgi holat

- `flutter analyze`: 1 ta info (`main.dart` dagi ortiqcha `dart:ui` importi).
- `flutter test`: 32 ta test oʻtadi.
- 1-paket (XP server orqali, rules) kodda bor, **deploy qilinmagan**.
- Alifbo ishi (yangi alifbo, oʻ/gʻ), Figma plagini — **commit qilinmagan**.

## 5. Real maʼlumotlar (Firestore, 2026-11-11)

`educationapp-4780a` loyihasining `(default)` bazasi faqat oʻqish rejimida tekshirildi (`samadovubaydullo3@gmail.com` hisobi orqali). Faqat sonlar va maydonlarning toʻldirilganligi yigʻildi, shaxsiy qiymatlar chiqarilmadi.

### Foydalanish deyarli yoʻq

| Koʻrsatkich | Qiymat |
|---|---|
| Foydalanuvchilar | 38 |
| Soʻnggi 30 kunda kirgan | 1 |
| Soʻnggi 7 kunda kirgan | 0 |
| Kirish sanasi yoʻq | 9 |
| Roʻyxatdan oʻtish | 2025-11 … 2026-05 (eng koʻp 2026-04: 11) |
| Sud tanlagan | 15 (39%) |
| Lavozim kiritgan | 1 |
| XP = 0 | 16; 100 dan yuqori — atigi 2 |
| Kurs progressi (`user_course_progress`) | **0 ta hujjat** |
| `video_progress`, `xp_awards` | 0 |
| Test urinishlari | 33 ta, jami 7 kishi (oxirgisi 2026-05) |
| Hamjamiyat | 2 mavzu, 4 izoh |
| AKT murojaatlari (`ict_reports`) | 0 |

Kurs progressi umuman yoʻq: hech kim kursni boshlamagan yoki progress yozuvi rules tufayli rad etilgan (2026-10-12 auditidagi #2 — progress yoʻli rules bilan mos emas edi). Har ikki holatda ham kurslar amalda ishlatilmagan.

### Kontent

| Kolleksiya | Soni | Holat |
|---|---|---|
| `courses` | 9 (hammasi chop etilgan) | 57 dars: 33 video, 15 maqola, 9 test. **10 ta darsda kontent havolasi yoʻq** (boʻsh dars). Hech bir kursda rasm yoʻq |
| `video_tutorials` | 35 | Hammasida davomiylik, muqova va YouTube ID boʻsh |
| `knowledge_base` (maqolalar) | 9 | Hammasi bir oyda yuklangan |
| `resources` (fayllar) | 67 | |
| `faqs` | 63 | Eng toʻliq toʻldirilgan boʻlim |
| `quizzes` | 10 | Har birida 10 savol |
| `systems` | 8 | Yoʻriqnoma/video havolalari deyarli boʻsh |
| `news` | 5 | Rasmlar boʻsh |
| `rag_chunks` | 1 577 | AI qidiruv uchun boʻlaklar; 80% `source`, 20% `module` maydoni bilan — ikki xil format |
| `courts` | 294 | Ilova bu kolleksiyani oʻqimaydi — xuddi shu maʼlumot `uzbekistan_courts.dart` (2 088 qator) da kodga yozilgan |

Kontent asosan bir martalik yuklashlar bilan kiritilgan (har kolleksiya bitta oyda); doimiy yangilanish jarayoni koʻrinmaydi.

### Maʼlumot sifati muammolari

- **Ikkinchi tizim xuddi shu bazaga yozadi.** `conversations` (26), foydalanuvchilarning 24% ida `telegram_id`, `firstName`, `competency_score`, `digital_level`, testlarning 12% ida `source: telegram`. Bu Telegram bot boʻlsa kerak — uning kodi bu repoda yoʻq, sxemasi ilovanikidan farq qiladi.
- **Daraja (`level`) uch xil formatda:** `levelBeginner` (14 ta kod formati), `Boshlangʻich` (14 ta — matn), `1` (9 ta — raqam). Reyting va daraja hisoblari notoʻgʻri chiqishi mumkin.
- **Rollar ilova roʻyxatida yoʻq qiymatlar bilan:** `unknown` — 10, `xodim` — 7 (kod `assistant` deb talqin qiladi), `archive` — 12, `judge` — 6, admin — 1.
- **Kurs auditoriyasi (`targetRole`) ikki xil lugʻatda:** 5 kursda ilova rollari (`judge`, `assistant`, …), 4 kursda boshqa nomlar (`clerk`, `secretary`, `it_admin`, `all`). Hozir kurslar rol boʻyicha filtrlanmaydi, lekin filtr yoqilsa bu kurslar yoʻqoladi.
- **Sanalar aralash:** `lastLogin`, `registrationDate` — matn, `createdAt` — timestamp; foydalanuvchilarning faqat bir qismida bor.
- **Eski kolleksiyalar:** `notifications` (1) va `app_notifications` (4) — bir xil maqsad; `wiki_log`, `wiki_meta` — AI wiki jurnali.

### Xulosa

Muammo ilova kodidan ham chuqurroq: real foydalanish deyarli nolga teng, kurslar hech qachon ishlatilmagan, va bazaga ikki tizim turli sxemada yozadi. Shuning uchun keyingi qadamlar tartibi:

1. Telegram bot va ilova uchun **yagona maʼlumot shartnomasi** (rol, daraja, sana formatlari) — va mavjud yozuvlarni shunga keltiruvchi migratsiya.
2. Boʻsh darslarni (10 ta) toʻldirish yoki olib tashlash; video davomiyligi va muqovalarni toʻldirish.
3. `courts` kolleksiyasi va `uzbekistan_courts.dart` dan bittasini yagona manba qilish.
4. Shundan keyin kodni tozalash (6-boʻlim).

## 6. Tozalash rejasi

Har bosqich alohida commit; har biridan keyin `flutter analyze` va `flutter test`.

1. **Xavfsiz tozalash (funksiyaga taʼsir qilmaydi):** ildizdagi skriptlar va hisobotlarni `scripts/` / `docs/archive/` ga, `files/`, `scratch/`, `.mcp.json.backup*` ni gitdan chiqarish; `scratch_api_check.dart`, ishlatilmagan paketlar, ortiqcha import.
2. **Oʻlik kod:** yuqoridagi 16 faylni koʻrib chiqib oʻchirish yoki ulash; takroriy parol ekrani va eski dars modelini olib tashlash; `lib/widgets` ni koʻchirish.
3. **Maʼlumotlar shartnomasi:** kolleksiya nomlari uchun yagona konstantalar; rules'dagi eski yoʻllarni olib tashlash; progressni bitta manbaga (server hisoblaydigan) keltirish.
4. **Arxitektura:** `main.dart` ni feature boʻyicha ajratish; ekranlardagi toʻgʻridan-toʻgʻri Firestore'ni repository'ga koʻchirish; katta ekranlarni boʻlish.
5. **UI asosi:** `isDark` tanlovlarini ThemeData'ga koʻchirish va qattiq yozilgan matnlarni ARB'ga oʻtkazish — yangi dizayn va alifbo uchun zamin.

Kontentni bitta kolleksiyaga birlashtirish (3-boʻlim) eng katta ish va production maʼlumot migratsiyasini talab qiladi — real maʼlumotlarni koʻrmasdan rejalashtirish tavsiya etilmaydi.
