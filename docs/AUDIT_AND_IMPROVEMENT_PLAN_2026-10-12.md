# Sud Qo‘llanma: audit va yaxshilash rejasi

Sana: 2026-10-12 (Asia/Tashkent). Branch: backup-v2. Audit bazasi: 3a4e11d6b3268bd9308f56f8c4e72094148d8037.

## Qamrov va tekshiruv chegarasi

Flutter ilovasining ishga tushishi va Provider bog‘lanishlari, autentifikatsiya, kurs/progress, quiz/XP, kutubxona, community, bildirishnomalar, qidiruv/AI/RAG, Drift/outbox, Cloud Functions, repodagi Firebase rules/indexes, Android release va CI ko‘rib chiqildi. Bu kod auditi; barcha ekranlar qurilmada ishlatib chiqilmadi.

`flutter analyze --no-pub`: **No issues found! (ran in 85.0s)**. Statik tahlil biznes mantiqi va server ruxsatlarining to‘g‘riligini kafolatlamaydi. Repoda `*_test.dart` test fayllari topilmadi; CI test qadami kommentga olingan. Functions dependencies mahalliy o‘rnatilmagan; TypeScript build va emulator testlari bajarilmadi. Android/Web release build bajarilmadi. Firebase Console, deploy qilingan rules/indexes, extension va production ma’lumotlari tekshirilmadi. Quyidagi rules bilan bog‘liq ta’sirlar aynan repodagi qoidalar ishlatilganda yuz beradi.

## Loyiha xaritasi

Sud xodimlari uchun Flutter LMS: kurslar, video/maqola/resurslar, quiz, yangilik, community, reyting, admin, AI yordamchi. State management — Provider; backend — Auth, Firestore, Storage va TypeScript Functions. O‘zbek/rus/ingliz lokalizatsiya infratuzilmasi mavjud. Feature papkalari data/domain/presentation qatlamlariga ajratilgan. Drift lokal baza hozir News va Outbox jadvallarini qamraydi; butun ilova uchun to‘liq oflayn LMS hali mavjud emas.

Yaxshi asoslar: modullarga ajratish, repository interfeyslari, lokal yozuv va outbox uchun atomik tranzaksiya, XP yozishda Firestore tranzaksiyasi, lokalizatsiya, Crashlytics integratsiyasi. Asosiy zaiflik — frontend, rules, server va konfiguratsiya o‘rtasidagi shartnomalar mosligi avtomatik tekshirilmaydi.

## Tasdiqlangan topilmalar

P0 — eng birinchi yopiladigan huquq oshirish muammosi. P1 — asosiy funksiyani yoki ma’lumot ishonchliligini buzadi. P2 — barqarorlik, masshtab va texnik qarz.

### 1. P0: foydalanuvchi o‘ziga admin huquqini bera oladi

Dalil: `firestore.rules:32-34` profil egasiga barcha maydonlarni yozishga ruxsat beradi. `isAdmin()` esa users hujjatidagi `role` ni tekshiradi. Egasi role qiymatini admin qilib yozgandan keyin admin tekshiruvidan o‘tadi. XP va reyting hisoblagichlari ham himoyalanmagan. Qo‘shimcha: registration ekranida ict_specialist tanlash mumkin; rules bu rolni admin deb hisoblaydi.

Tuzatish: ish lavozimi va tizim vakolatini ajratish; vakolatni ishonchli server/custom claims orqali berish. Profil update uchun maydonlar allowlisti, create uchun xavfsiz boshlang‘ich rol; XP/level vakolatini serverga ko‘chirish. Faqat UI’dan rolni yashirish yetarli emas.

Mezon: oddiy foydalanuvchining role/XP o‘zgartirishi emulator testida rad etiladi; profil nomi kabi ruxsatli maydon yangilanishi ishlaydi.

### 2. P1: kurs progress yo‘li rules bilan mos emas

Dalil: `course_remote_source.dart:143` hujjat ID’si `${userId}_$courseId`; `firestore.rules:161` esa shu ID’ni userId deb olib request.auth.uid bilan solishtiradi. O‘qish, boshlash va progress update oddiy user uchun rad etiladi; userId bo‘yicha list query ham qoidalarga mos emas.

Tuzatish: yagona progress sxemasi tanlash: mavjud flat hujjat + data.userId tekshiruvi yoki users/{uid}/courses/{courseId} yo‘li. Client, Functions, indexes va mavjud ma’lumot migratsiyasini birga yangilash.

Mezon: A foydalanuvchi o‘z kursini boshlaydi va qayta ochadi; B progressini o‘qiy/yoza olmaydi; admin hisobotni o‘qiydi.

### 3. P1: darsdan qaytish tugatish deb qabul qilinadi

Dalil: `course_detail_screen.dart:443` quizdan har qanday qaytishda didComplete=true; boshqa darslarda Navigator natijasi null bo‘lsa `?? true`. `lesson_viewer_screen.dart` videodan qaytishda ham true qaytaradi. Testni boshlamay chiqish yoki videoni darhol yopish dars completion va XPga olib kelishi mumkin.

Tuzatish: typed LessonResult, quiz pass chegarasi, video uchun kuzatilgan playback mezoni va maqola uchun aniq completion amali. null/cancel natija completion emas. Mezon: back/cancel XP bermaydi; o‘tmagan quiz keyingi majburiy darsni ochmaydi.

### 4. P1: yiqilgan quizga ham pass XP beriladi

Dalil: `analytics_usecases.dart:52` assessment tarmog‘i `result.success` yoki passed verbni tekshirmasdan xpQuizPass beradi. SubmitQuizAttempt failed statement yaratishi mumkin, lekin gamification uni baribir pass sifatida ishlaydi. Award chaqiruvida contentId berilmagan, mavjud dedup himoyasi bu oqimda ishlamaydi.

Tuzatish: success/verbni tekshirish, serverda natija hisoblash, event/attempt identifikatori orqali idempotency. Mezon: 0%, 69%, 70%, 100%, qayta yuborilgan event va tezkor qayta urinishlarni testlash.

### 5. P1: quiz javoblari va natijalari ishonchli server bilan himoyalanmagan

Dalil: question_model.dart correctAnswer’ni umumiy o‘qiladigan question hujjatida saqlaydi; rules questions uchun public read beradi. quiz_attempts create faqat loginni tekshiradi, userId va score’ni tasdiqlamaydi.

Tuzatish: agar test baholash/sertifikatga asos bo‘lsa, javob kalitini serverga ajratish, attempt egasini tekshirish va bahoni server hisoblash. Mezon: boshqa user nomidan attempt yaratish rad etiladi; javob kaliti clientga qaytmaydi. Mashq testlari uchun javob ko‘rsatish alohida mahsulot qarori bo‘lsin.

### 6. P1: RAG/Wiki va indeks yozuvlari rules tomonidan bloklanadi

Dalil: WikiService wiki_pages’ni o‘qiydi/yozadi, SearchRemoteDataSource rag_chunks’ni o‘qiydi, SearchIndexer search_index’ga yozadi. Bu kolleksiyalar uchun rules yo‘q, default deny ishlaydi. Xatolar ushlanib null/[] yoki logga aylantiriladi; AI manbasiz umumiy javob berishi mumkin. Vector extension deploy holati repodan tasdiqlanmaydi.

Tuzatish: client o‘qishi kerak bo‘lgan manbalar uchun aniq ruxsat; indeks/wiki generatsiyasini ishonchli serverga ko‘chirish; extension region, output formati va manba indeksini hujjatlashtirish. Mezon: ma’lum hujjat bo‘yicha savol manba havolasi bilan javob oladi; backend xatosi “natija yo‘q”dan farqlanadi.

### 7. P1: yangiliklarning incremental sync vaqt belgisi yozilmaydi

Dalil: NewsRemoteDataSource incremental query uchun updatedAt kutadi. Uning saveNews metodi serverTimestamp qo‘shadi, lekin real yozuvchi SyncWorker bu metodni chaqirmaydi: payloadni to‘g‘ridan-to‘g‘ri docRef.set qiladi. NewsLocalModel payloadida updatedAt yo‘q. PublicationDate esa ISO matn sifatida yuboriladi; tarixiy Timestamp yozuvlari bilan tur mosligi tekshirilishi kerak.

Tuzatish: yozish va o‘qishda yagona Timestamp shartnomasi, server revision/cursor, klient soatiga tayanmagan sync. Mezon: boshqa qurilmada tahrirlangan yangilik qayta o‘rnatishsiz ko‘rinadi.

### 8. P1: yangiliklarning remote o‘chirilishi lokal keshga o‘tmaydi

Dalil: saveNewsFromRemote faqat upsert qiladi; remote delete uchun tombstone/reconciliation yo‘q. News stream bir martalik fetch va lokal watchdan iborat; server yangilanishlarini uzluksiz tinglamaydi. Pending lokal o‘zgarishlarni remote upsert bosib ketishi uchun alohida himoya ham yo‘q.

Tuzatish: deletedAt/tombstone, cursor va pending mutation holati; reconnect/refresh mexanizmi. Mezon: A o‘chirgan yozuv B’da yo‘qoladi; pending lokal edit remote eski nusxa bilan bosilmaydi.

### 9. P1: notification read holatini oddiy user yoza olmaydi

Dalil: notification_remote_datasource.dart:62-75 markAsRead readBy’ni update qiladi; firestore.rules:82 barcha yozishni adminga cheklaydi. Shu sabab oddiy userda read belgisi saqlanmaydi.

Tuzatish: users/{uid}/notification_reads kabi shaxsiy holat; yuborish vakolati server/admin’da qolsin. Mezon: user o‘z read holatini saqlaydi, boshqa usernikini o‘zgartirmaydi.

### 10. P1: maxfiy profil va xabarlar barcha login qilganlarga ochiq

Dalil: rules barcha users hujjatlari va app_notifications uchun authenticated read beradi. Users modelida email, sud ma’lumotlari va fcmToken mavjud. Notification targetAudience faqat client queryda qo‘llanadi; server qoidasi boshqa adresat xabarini o‘qishni cheklamaydi.

Tuzatish: leaderboard uchun minimal public profil; private profil/tokenni alohida saqlash; xabar adresatini server qoidalarida tekshirish. Mezon: A Bning email/token/shaxsiy xabarini o‘qiy olmaydi, reyting ishlaydi.

### 11. P1: push vaqtinchalik xatoda ham token o‘chiriladi

Dalil: functions/src/helpers/sendPush.ts barcha xatolar uchun false qaytaradi; sendPushToUsers false bo‘lsa fcmToken’ni delete qiladi. Vaqtinchalik service/quota/network xatosi ham tokenni yo‘qotadi.

Tuzatish: success / invalid-token / retryable-error natijalari; faqat yaroqsiz tokenni o‘chirish, boshqasini retry qilish. Mezon: vaqtinchalik xatoda token saqlanadi; invalid token o‘chiriladi; hisoblagich real yuborilganlar sonini ko‘rsatadi.

### 12. P1: reminder callable boshqa foydalanuvchiga cheklovsiz yubora oladi

Dalil: courseReminder.ts:42 login tekshiriladi, so‘ng :45 da request.data.userId ixtiyoriy target sifatida olinadi. Admin/owner tekshiruvi va rate limit yo‘q.

Tuzatish: self-only yoki tasdiqlangan admin vakolati; tezlik cheklovi, input validation. Mezon: oddiy user boshqa userga reminder yubora olmaydi.

### 13. P1: toza checkout va CI build takrorlanmaydi

Dalil: CI Flutter 3.19.0, pubspec.lock esa Flutter >=3.41.0 va Dart >=3.11.0 talab qiladi. Workflow faqat main uchun; backup-v2 pushlari tekshirilmaydi. main.dart import qiladigan firebase_options.dart hamda asset .env Git’da yo‘q va CI ularni tayyorlamaydi. firebase.json storage.rules’ni ko‘rsatadi, lekin root storage.rules mavjud emas; md/storage.rules mavjud, avtomatik tanlanmaydi. Functions deploy oldidan build predeploy qadami yo‘q.

Tuzatish: SDK’ni yagona pin qilish; toza checkout bootstrap/config generator; zarur branch/PR uchun CI; mavjud bo‘lgan rules path; Functions typecheck/build. Mezon: toza runnerda analyze, test, Android/Web build va Functions build o‘tadi; deploy dry-run/config validation ishlaydi.

### 14. P1: Web uchun lokal baza native implementatsiyaga bog‘langan

Dalil: app_database.dart dart:io, drift/native va NativeDatabase ishlatadi; main.dart bu bazani Web uchun ham shartsiz yaratadi. Web executor/conditional import yo‘q. Web build/runtime qo‘llab-quvvatlanishi tasdiqlanmagan.

Tuzatish: native va Web executorlarini ajratish, Web uchun Drift WASM/IndexedDB yoki tanlangan cache adapteri. Mezon: Web release build va browserdagi news o‘qish/yozish/reload sinovi o‘tadi.

### 15. P2: search har so‘rovda katta ma’lumot to‘plamini yuklaydi

Dalil: SearchAll har call’da maqolalar, videolar, tizimlar, FAQ va kurslarni yuklab clientda saralaydi. Bitta source xatosi umumiy []ga aylanadi. SearchNotifier eski request kech tugasa yangi query natijasini bosmasligi uchun request ID tekshirmaydi.

Tuzatish: indekslangan qidiruv, debounce/cache, pagination; request ID va alohida partial error. Mezon: tez yozishda faqat so‘nggi query chiqadi; katta datasetda reads/latency o‘lchanadi; bir source xatosi butun natijani yashirmaydi.

### 16. P2: ayrim composite indekslar repoda yo‘q

Dalil: region/courtType/courtId + xp leaderboard so‘rovlari, courses difficulty/targetRole filtrlari va scheduledCourseReminder percentComplete + lastAccessedAt so‘rovining mos composite indekslari firestore.indexes.json’da topilmadi. Console’da qo‘lda yaratilgan bo‘lishi mumkin — tekshirilmagan.

Tuzatish: query inventory va kerakli indekslarni version controlga kiritish. Mezon: barcha filtrlash/reyting/reminder querylari test muhitida muvaffaqiyatli ishlaydi.

### 17. P2: streamlar va akkauntlar orasidagi holat yetarli boshqarilmagan

Dalil: AuthNotifier authStateChanges subscriptionini saqlamaydi/cancel qilmaydi; CourseProvider auth streami ham dispose’da cancel qilinmaydi. FcmService har saveTokenForUser chaqiruvida yangi onTokenRefresh listener yaratadi. AiNotifier/AiService global provider; logout oqimida clearChat/resetSession chaqirig‘i topilmadi. Oldingi akkauntning suhbat holati keyingi akkauntda qolishi mumkin.

Tuzatish: barcha subscription lifecycle; session scope va logoutda chat/private cache/outbox policy. Outbox’da userId yo‘qligi sabab pending amallar joriy akkaunt credentials’i bilan yuboriladi — owner scoping kerak. Mezon: A→logout→B’da A chat/private holati ko‘rinmaydi; faqat bitta token refresh handler ishlaydi.

### 18. P2: outbox retry va konfliktlarni tiklash to‘liq emas

Dalil: retryCount>=5 amallar getOldestPendingAction tomonidan tashlab ketiladi; ko‘rsatish/qayta yuborish UI yo‘q. Xatodan keyin cycle break qiladi; vaqtga asoslangan retry/backoff yo‘q. Connectivity listener saqlanmagan, dispose yo‘q. Merge update o‘chirilgan hujjatni qayta yaratishi mumkin.

Tuzatish: pending/syncing/failed holatlar, nextRetryAt/backoff, dead-letter UI, actorId va revision/conflict policy. Mezon: vaqtinchalik xato internet o‘zgarmasa ham tiklanadi; terminal xato foydalanuvchiga ko‘rinadi; reconnect’da duplicate ta’sir yo‘q.

### 19. P2: shifrlash helperi real saqlash oqimida ishlatilmagan

Dalil: EncryptionHelper init qilinadi, ammo lib’da encrypt chaqiriladigan boshqa joy topilmadi. SQLite/outbox oddiy text saqlaydi. Helper bir marta yaratilgan IV’ni barcha AES-CBC yozuvlarida qayta ishlatadi va integrity tag yo‘q.

Tuzatish: avval lokal maxfiy ma’lumot qamrovini belgilash; zarur bo‘lsa har yozuvga fresh nonce va authenticated encryption, migratsiya/key lifecycle. Hozirgi news jadvallarida profil PII saqlanayotgani tasdiqlanmagan; “hamma ma’lumot shifrlangan” deb hujjatlashtirmaslik. Mezon: tanlangan nozik payload plaintext chiqmaydi; buzilgan ciphertext rad etiladi.

### 20. P2: release va hujjatlar orasida texnik qarz

Dalil: Android release debug signing ishlatadi. CI secret tekshiruvi grep topilsa ham pipeline’ni yiqitmaydi; Firebase API key qidiruvi server credential auditini almashtirmaydi. Data Connect schema Movie/Watch/Review namunasi — ta’lim domeniga ulanmagan. Hujjatlarda Telegram bot va to‘liq tarjima kabi da’volar bor; bu checkout’da bot implementatsiyasi topilmadi. main.dart DI va routing bir katta faylda; ayrim domain/presentation qatlamlari Firebase’ga bevosita bog‘langan.

Tuzatish: haqiqiy release signing; server credential skani qiymatlarni oshkor qilmasdan; Data Connectni ishlatish yoki olib tashlash qarori; faktga mos README/bootstrap; feature composition. SDK va arxitekturani keng ko‘lamda almashtirish birinchi vazifa emas.

## Amalga oshirish rejasi

### 1-bosqich: huquqlar va asosiy oqimlar

1. Ish lavozimi/vakolat modelini kelishish; mavjud rollar va user hujjatlarini inventar qilish.
2. Role/XP allowlist yoki server claims, private/public profil va xabar adresati qoidalari.
3. Progress yo‘li va rulesni birlashtirish; eski ma’lumot migratsiyasini tayyorlash.
4. Dars completion, failed quiz XP va attempt ownershipni tuzatish.
5. Rules emulator regression suite: guest/user/expert/admin; owner/boshqa user; create/update/delete/list.

Chiqish mezoni: huquq oshirish yopiq, user kursni tugata oladi, back/cancel XP bermaydi, boshqa user ma’lumoti himoyalangan.

### 2-bosqich: takrorlanadigan build va kuzatuv

1. SDK/config bootstrap va .env.example; faqat public client konfiguratsiyasi assetda bo‘lsin, server credentiallari kiritilmasin.
2. PR/branch CI: analyze, unit/widget test, rules emulator, Functions typecheck, maqsad platforma build.
3. Storage rules path, Functions build/predeploy, composite indekslar, release signing.
4. Startup xatosi uchun tiklanadigan ekran; Crashlytics handlerlarini xavfli initlardan oldin o‘rnatish; startup, permission-denied va sync-failed o‘lchovlari.

Chiqish mezoni: toza checkout’dan hujjatlashtirilgan tartibda build; CI xatoni yashirmaydi.

### 3-bosqich: sync, push va sessiya ishonchliligi

1. Timestamp/cursor/tombstone, user-scoped outbox, retry/dead-letter va konflikt policy.
2. Push token klassifikatsiyasi, callable authorization/rate limit; token listener lifecycle.
3. Logout holat tozalash, provider/stream dispose; startup notification navigatsiyasini navigator tayyor bo‘lguncha navbatga qo‘yish.
4. Ikki qurilma, akkaunt almashishi, reconnect va vaqtinchalik server xatolarini integratsion tekshirish.

Chiqish mezoni: tarmoq uzilishida yo‘qolgan/eskirgan ma’lumot va boshqa akkaunt holati qolmaydi.

### 4-bosqich: qidiruv va AI sifati

1. Qidiruv indeksi va server ownership, cache/debounce/pagination.
2. RAG qoidalari va extension contract; manba havolasi, manba sanasi va manba topilmagan holati.
3. Wiki avtomatik javoblarini manba versiyasi bilan invalidatsiya qilish va ekspert tasdiqlashi.
4. O‘zbekcha 30–50 haqiqiy savol bilan relevance/groundedness sinovi; javob va qidiruv kechikishini o‘lchash.

Chiqish mezoni: ma’lum savollar tegishli hujjatni topadi; backend xatosi oddiy bo‘sh natija sifatida yashirilmaydi.

### 5-bosqich: mahsulot va UX

1. Kurs davom ettirish, haqiqiy tugallanish mezoni va server tasdiqlagan sertifikat oqimi.
2. Telefon/web’da asosiy journey sinovi: ro‘yxatdan o‘tish → kurs → video/maqola → quiz → progress → sertifikat.
3. O‘zbek/rus/ingliz hardcoded matn audit, katta shrift, kontrast, klaviatura va screen-reader tekshiruvi.
4. Kontent tahrirlash/publish vakolatlari, source version, audit log va admin hisobotlar.
5. Bir xil UI holatlari: loading, empty, retry, offline, pending sync; katta ekran fayllarini mazmunli qismlarga ajratish.

Chiqish mezoni: foydalanuvchi kursni xatosiz davom ettiradi; admin haqiqiy, tekshiriladigan progressni ko‘radi.

## Keyingi ish uchun aniq boshlanish

Birinchi implementation paketi: **role huquq oshirish + kurs progress ruxsatlari + noto‘g‘ri completion + failed quiz XP**, tegishli regression testlari bilan. Katta redesign yoki yangi backend qo‘shishdan oldin shu oqimlarni barqaror qilish kerak. Production qoidalarini o‘zgartirishdan oldin mavjud sxema/rollar va deploy holatini tekshirish, migratsiya va rollback rejasini tayyorlash zarur.

## 1-paket holati (2026-10-31)

Kodda tuzatildi, **deploy qilinmagan**:

- **#1 (P0)**: `isAdmin()` faqat `role == 'admin'`; users create xavfsiz lavozim (admin emas) va nol XP bilan; egasi faqat profil maydonlarini yozadi (`ownerEditableUserFields`). XP/level/hisoblagichlar va streak endi `awardXp` / `updateStreak` callable funksiyalarida hisoblanadi (`functions/src/callables/gamification.ts`), mukofot `users/{uid}/xp_awards` orqali bir kontentga bir marta beriladi.
- **#2**: progress rules `user_course_progress/{uid}_{courseId}` + `data.userId` sxemasiga moslandi; ishlatilmagan nested yo‘l olib tashlandi. Ma’lumot migratsiyasi kerak emas.
- **#3**: QuizScreen `QuizResult` qaytaradi, dars faqat `minPassScore` (yoki 70%) dan o‘tilganda yakunlanadi; lesson viewer’dan orqaga qaytish yakunlash emas; video oxirigacha ko‘rilganda yoki “bajarildi” tugmasi bosilganda yakunlanadi.
- **#4**: yiqilgan quiz XP so‘ramaydi; quiz attempt faqat o‘z nomidan yaratiladi.

Testlar: `functions` — `npm test` (11 ta unit test), Flutter — `flutter test` (17 ta), rules — `rules_tests/` (emulator va Java 11+ kerak; bu muhitda Java yo‘qligi sabab ishga tushirilmadi).

Deploy tartibi (eski client’lar XP’ni to‘g‘ridan-to‘g‘ri yozadi, yangi rules buni rad etadi):

1. `firebase deploy --only functions` (predeploy endi build qiladi).
2. Yangi client release’ni chiqarish.
3. `firebase deploy --only firestore:rules` — eski versiyadagi client’larda XP va profilni to‘liq qayta yozish ishlamay qoladi.
4. Deploy oldidan: production’da `role == 'ict_specialist'` bo‘lib admin vazifasini bajarayotgan hisoblar bo‘lsa, ularni `admin` ga o‘tkazish.

Ochiq qolganlar: ro‘yxatdan o‘tishda `judge`/`ict_specialist` tanlash hamon kontent yozish (`isExpertOrAdmin`) huquqini beradi — lavozim va vakolatni ajratish mahsulot qarori; progress maydonlari (`completedLessonIds`, `percentComplete`) hali client tomonidan hisoblanadi; video darsdagi “Ko‘rdim, bajarildi” tugmasi videoni ko‘rmasdan ham yakunlaydi.
