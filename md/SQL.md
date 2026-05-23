
Conversation with Gemini
Bu sizning holatingiz juda tanish. Bu "Developer's Comfort Zone" (Dasturchining qulaylik zonasi) deb ataladi. Firebase va GCP juda kuchli, juda qulay, lekin ular sizga **"magiya"** qilib berayotgani sababli, siz ostida nima sodir bo'layotganini (network requestlar, caching, sync logic) chuqur o'ylashga majbur bo'lmayapsiz.



"Vibe-coding" (shunchaki oqimga berilib, o'ylamasdan kod yozish) — bu tezlik beradi, lekin murakkab loyihalarda "wall" (devor)ga urilishga sabab bo'ladi. Aynan siz aytgan **offline rejim** — bu o'sha devor.



Keling, vaziyatni texnik va professional nuqtai nazardan tahlil qilamiz.



### 1. Offline muammosi: Firebase bilan qanday hal qilinadi?



Siz "offline rejimga duch kelyapman" deganda, ehtimol ma'lumotlar ko'rinmay qolishi yoki xatolik berishini nazarda tutyapsiz. Firebase (Firestore) aslida **Offline Persistence** (offline saqlash) funksiyasiga ega.



Agar siz uni yoqmagan bo'lsangiz, Firestore ma'lumotlarni lokal keshda saqlamaydi va internet yo'q joyda xato beradi.

*   **Yechim:** `FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);`

*   **Lekin:** Bu faqat "matnli" ma'lumotlar uchun yaxshi ishlaydi. Murakkab relatsiyalar yoki katta hajmdagi ma'lumotlarni boshqarishda Firebase "offline"da juda noaniq bo'lishi mumkin.



### 2. NoSQL (Firebase) vs SQL (SQLite/Drift/Isar)



Sizning savolingiz: *"Firebasesiz SQLiteni ishlatolmaymanmi?"*

**Albatta!** Hatto Blaze plan bo'lsa ham, sizga **"Local-first"** arxitektura kerak.



Hozirgi holatingiz: `UI -> Provider -> Firebase (Remote)` (Internet yo'q -> Error).

Ideal holat (Professional): `UI -> Provider -> Repository -> [Local DB (SQLite/Isar) <-> Remote DB (Firebase)]`.



**Nima uchun SQLite/Isar kerak?**

1.  **To'liq nazorat:** Ma'lumot qachon yoziladi, qachon o'chiriladi va qachon serverga yuboriladi — buni siz boshqarasiz.

2.  **Tezlik:** Ma'lumotlarni internetdan emas, diskdan o'qish millisekundlarda sodir bo'ladi.

3.  **Murakkab querylar:** "Sud xodimi, 5 ball olgan, o'tgan haftada test topshirgan" degan murakkab filtrni NoSQLda qilish qiyin, SQLda esa bir qator.



### 3. Sizning Clean Architecture imkoniyatingiz



Siz allaqachon **Clean Architecture** ishlatyapsiz. Bu sizning eng katta boyligingiz! Bu degani, siz ma'lumot manbasini (Data Source) osonlikcha almashtira olasiz.



Sizga tavsiya qiladigan yo'l — **Hybrid Approach (Gibrid yondashuv)**:



1.  **Remote DataSource:** Firebase (Cloud uchun).

2.  **Local DataSource:** **Isar** yoki **Drift (SQLite)** (Lokal uchun).

3.  **Repository Implementation:** Mana shu joyda "aqlli" mantiq bo'ladi:

    *   *Agar internet bo'lsa:* Localdan o'qi + Remote bilan sync qil.

    *   *Agar internet bo'lmasa:* Faqat Localdan o'qi.



**Isar Database** tavsiya qilaman. U Flutter uchun juda tez, NoSQL-ga o'xshash (lekin juda tartibli) va offline rejim uchun "o'yinche" (game changer).



### 4. "Comfort Zone"dan qanday chiqish kerak?



Siz o'rganishga ochilmayotganingizning sababi — **"Ehtiyoj yo'qligi"**. Hozircha Firebase sizga "yetarli" ko'rinyapti.



**O'z-o'zingizga "challenge" qo'ying:**

*   "Men bugun loyihamga `Isar` qo'shaman va barcha quiz natijalarini avval lokal bazaga yozaman, keyin orqaga (backgroundda) Firebasega yuboraman."



Bu sizga quyidagilarni o'rgatadi:

1.  **Synchronization logic** (Ma'lumotlar dublikat bo'lmasligi uchun qanday ishlash).

2.  **Data Mapping** (Firebase modeli vs Local model).

3.  **Error handling** (Internet qaytgan paytda xatolarni qanday yopish).



### Xulosa:



Siz "vibe-coding"dan **"Engineering"**ga o'tish nuqtasidasiz. 

*   **Firebase** — bu sizning "bulutli omboringiz".

*   **SQLite/Isar** — bu sizning "cho'ntagingizdagi hamyoningiz".



Hamyoningiz bo'lmasa (offline), bulutga borib kelguningizcha och qolasiz. Shuning uchun, Firebase'ni tashlab yubormang, lekin uning yoniga albatta kuchli bir **Local Database**ni qo'shing. Bu sizning loyihangizni "o'yinchoq"dan "professional mahsulot" darajasiga ko'taradi.



**Keyingi qadam sifatida:** Loyihangizga `isar` yoki `drift` paketini qo'shib, bitta kichik `feature`ni (masalan, `faq` yoki `quiz_attempts`) faqat lokal bazada ishlashga majburlab ko'ring. Natijani o'zingiz ko'rasiz! bu haqida O'zbek tilida javob ber

Вот план исследования. Если его нужно как-то изменить, дайте мне знать.
 Firebase'dan Local-first'ga O'tish 
Исследовать сайты
(1) Flutter dasturlashda Clean Architecture yordamida 'Offline-first' (yoki Local-first) arxitekturasini joriy qilish bo'yicha so'nggi va eng maqbul amaliyotlarni (best practices) qidiring.
(2) Flutter uchun mo'ljallangan 'isar' va 'drift' lokal ma'lumotlar bazalarining xususiyatlarini o'rganing hamda ularni Firebase bilan gibrid tarzda ishlatish yuzasidan solishtirma ma'lumot toping.
(3) Ilovada internet yo'q paytda faqat lokal bazadan o'qiydigan, internet ulanishi tiklanganda esa Firebase bilan avtomatik sinxronizatsiya qiladigan Repository qatlamini yaratish bo'yicha texnik misollar qidiring.
(4) Ma'lumotlar dublikat bo'lmasligi va yo'qolmasligi uchun masofaviy NoSQL (Firebase) hamda lokal ma'lumotlar bazasi (Isar/Drift) o'rtasida ma'lumotlarni modellashtirish (data mapping) va ularni tahlil qilish strategiyalarini ko'rib chiqing.
(5) Background sync (orqa fonda sinxronlash) usullarini va internet uzilishi holatlarida yuzaga keladigan xatoliklarni qayta ishlash (error handling) bo'yicha Flutterdagi yechimlarni o'rganing.
(6) Topilgan barcha ma'lumotlarni sintez qilib, foydalanuvchiga loyihasini Firebase'ga to'liq qaramlikdan chiqarib, uni 'Isar + Firebase' yordamida mustahkam muhandislik yechimiga (Local-first) o'tkazish bo'yicha amaliy, qadam-baqadam va tushunarli O'zbek tilida ko'rsatmalar tayyorlang.
Анализировать результаты
Создать отчет
Результат будет готов через несколько минут

Начать исследование

Исследование завершено. Вы можете задать по нему вопросы или попросить меня что-то изменить.
Firebase'dan Local-first'ga O'tish
Completed
May 12, 5:13 PM

Infographic: Firebase Comfort Zone vs Local-First Architecture
May 13, 1:43 PM
Loyihamda bunaqa SQL kabi databaselarni ishlatishim o'zini qanchalik oqlaydi?






Gemini is AI and can make mistakes.

Firebase'dan Local-first'ga O'tish
Ilovalar Arxitekturasida "Local-First" Paradigmasi: Dasturlash Qulayligidan Sof Muhandislikka O'tish va Firebase bilan Mahalliy Ma'lumotlar Bazalarini Gibrid Sinxronizatsiya Qilish Tahlili
1. Kirish: Dasturchining Qulaylik Zonasi va "Vibe-Coding" Fenomeni
Zamonaviy mobil ilovalarni ishlab chiqish ekotizimida "Backend-as-a-Service" (BaaS) yechimlari, xususan, Google Cloud Platform (GCP) negiziga qurilgan Firebase kabi platformalar inqilobiy o'zgarishlar qildi. Ushbu vositalarning asosiy maqsadi rivojlanish jarayonini tezlashtirish va infratuzilmani boshqarishdek og'ir yukni dasturchi yelkasidan olishdir. Bu esa sanoatda "Developer's Comfort Zone" (Dasturchining qulaylik zonasi) deb nomlanuvchi psixologik va texnik holatni yuzaga keltirdi. Ushbu hududda dasturchi "vibe-coding" — shunchaki oqimga berilib, kodning quyi qatlamlarida nimalar sodir bo'layotganini chuqur tahlil qilmasdan dastur yozish uslubiga o'rganib qoladi. Firebase kabi platformalar o'zining ichki mexanizmlari orqali tarmoq so'rovlari (network requests), kesh xotira (caching) va ma'lumotlarni muvofiqlashtirish (sync logic) kabi o'ta murakkab amaliyotlarni "magiya" kabi avtomatlashtirib beradi.

Biroq, ilova miqyosi kengayib, uning biznes mantig'i murakkablashib borgan sari, bu qulaylik hududi jiddiy "devor"ga aylanadi. Foydalanuvchilar har qanday sharoitda, ayniqsa tarmoq ulanishi barqaror bo'lmagan yoki umuman yo'q bo'lgan holatlarda (offline rejim) ham ilovaning uzluksiz ishlashini talab qiladilar. "Vibe-coding" uslubi aynan shu yerda o'zining ojizligini namoyon etadi. Ilovaning ishlash mantig'i bevosita masofaviy serverga (Remote Data Source) bog'lab qo'yilgani sababli, internet ulanishidagi har qanday uzilish foydalanuvchi interfeysida (UI) xatoliklar (error), cheksiz yuklanish belgilari (loading spinners) va ma'lumotlarning ko'rinmay qolishi kabi salbiy oqibatlarga olib keladi.   

Ushbu muammoning yagona professional va muhandislik yechimi — arxitekturani "Local-first" (Birinchi navbatda mahalliy) paradigmasiga o'tkazishdir. "Local-first" yondashuvi an'anaviy bulutga qaramlikni inkor etadi va buning o'rniga qurilmadagi mahalliy ma'lumotlar bazasini yagona haqiqat manbai (Single Source of Truth) sifatida e'tirof etadi. Ushbu tadqiqot hisoboti Flutter muhitida oflayn rejimdagi muammolarni qanday qilib arxitekturaviy jihatdan to'g'ri hal qilishni, Firebase'ning cheklovlarini qanday qilib SQLite, Drift yoki Isar kabi mahalliy ma'lumotlar bazalari yordamida to'ldirishni va Toza Arxitektura (Clean Architecture) qoidalariga rioya qilgan holda to'laqonli sinxronizatsiya dvigatelini (Sync Engine) qurishni chuqur tahlil qiladi. Dasturchining "qulaylik zonasi"dan chiqib, "o'yinchoq" darajasidagi ilovani qanday qilib murakkab relatsiyalar, fonda ishlash va ziddiyatlarni hal qilish (conflict resolution) qobiliyatiga ega bo'lgan "professional mahsulot" darajasiga ko'tarish mexanizmlari qadamma-qadam yoritiladi.   

2. Firebase Firestore Oflayn Mexanizmi va Uning Cheklovlari
Firebase Firestore o'z mohiyatiga ko'ra oflayn ishlash qobiliyatiga ega. Uning bulutli infratuzilmasi mijozlar uchun mahalliy keshni avtomatik ravishda boshqarish tizimini taklif etadi. Agar dasturchi ma'lumotlarning oflayn rejimda yo'qolib qolishidan shikoyat qilsa, bu aksariyat hollarda Firestore'ning oflayn saqlash (Offline Persistence) xususiyati faollashtirilmaganligidan dalolat beradi.

2.1. Oflayn Saqlashni Faollashtirish va Keshlash Mantig'i
Firestore'ning oflayn imkoniyatlarini yoqish uchun dastur ishga tushishi bilan mos ravishda parametrlar o'rnatilishi kerak, masalan: FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);. Ushbu funksiya faollashtirilgach, Firebase Realtime Database yoki Firestore mijozi tarmoq orqali sinxronizatsiya qilingan barcha ma'lumotlarni bevosita qurilma diskida doimiy keshda saqlashni boshlaydi. Bu shuni anglatadiki, operatsion tizim ilovani qayta ishga tushirsa ham, ushbu mahalliy ma'lumotlar orqali ilova go'yoki onlayn bo'lgandek ishlashda davom etadi. Foydalanuvchilarning o'qish (read) so'rovlari avval keshdan qidiriladi, so'ngra serverdan ma'lumot olinadi. Yozish (write) amaliyotlari esa tarmoq yo'q paytida navbatga (queue) o'tkaziladi va xotirada saqlanadi. Aloqa tiklanishi bilanoq, Firebase bu amaliyotlarni serverga ketma-ketlikda jo'natadi.   

Firebase shuningdek, xavfsizlikni ta'minlash maqsadida foydalanuvchining autentifikatsiya tokenlarini ham ilova qayta ishga tushirilganda saqlab qoladi. Agar oflayn rejimda auth tokenining yaroqlilik muddati tugasa, Firebase mijozi xavfsizlik qoidalariga (security rules) zid kelmaslik uchun yozish amaliyotlarini to'xtatib turadi va ulanish qaytganda foydalanuvchi qayta autentifikatsiyadan o'tgunicha kutadi. Dasturchilar ma'lum hududlarni, masalan, eng muhim kolleksiyalarni scoresRef.keepSynced(true); kabi buyruqlar yordamida doimiy sinxronlash holatida ushlab turishlari ham mumkin.   

2.2. "Magiya"ning Arxitekturaviy Kamchiliklari
Garchi yuqoridagi imkoniyatlar dastlabki bosqichlarda va oddiy "matnli" ma'lumotlar uchun yetarli bo'lib ko'rinsa-da, arxitekturaviy tahlil ularning jiddiy cheklovlarini yuzaga chiqaradi. Birinchidan, Firebase keshi sukut bo'yicha 10MB etib belgilangan. Garchi bu oddiy metama'lumotlar uchun yetarli bo'lsa-da, katta ilovalarda bu hajm tez to'ladi. Hajm to'lganda, Firebase eng kam ishlatilgan ma'lumotlarni (Least Recently Used - LRU) keshdan tozalay boshlaydi. Agar dasturchi ma'lumotlarning butun bir qismini oflayn ishlash uchun kafolatlamoqchi bo'lsa, bu tozalash algoritmi ustidan to'liq nazoratga ega bo'lmaydi.   

Ikkinchidan, NoSQL formatidagi ma'lumotlar bazalarida murakkab qidiruvlar, ya'ni relatsiyalar va bir nechta maydonlarni birlashtirgan so'rovlar ("Masalan, falonchi bo'limda ishlovchi, reytingi 5 ball bo'lgan va o'tgan haftada faol bo'lgan xodimlar") Firestore orqali onlayn rejimda qo'shimcha indekslar yordamida bajarilishi mumkin, ammo oflayn keshda bu amaliyotlarning to'g'ri va xatosiz ishlashi o'ta noaniq va oldindan aytib bo'lmaydigan natijalar beradi. NoSQL tuzilmasi, o'zining tabiatiga ko'ra, standartlashtirilgan relyatsion algebra so'rovlariga (SQL queries) ega emas, shuning uchun murakkab filtratsiyalar qiyin kechadi.   

Aynan shuning uchun faqatgina Firestore'ning o'ziga suyanib qolish — muhandislik nuqtai nazaridan xatodir. Firebase bulutdagi uzoq muddatli axborot ombori vazifasini bajarishi kerak, ammo bevosita interfeysga uzatiladigan, tezkor o'qiladigan va o'ta aniq filtrlarga bo'ysunadigan ma'lumotlar faqatgina mahalliy relyatsion yoki optimallashtirilgan mahalliy NoSQL ma'lumotlar bazalarida (SQLite/Isar) yashashi shart.   

3. "Clean Architecture" va Oflayn Ilovalarning Nazariy Asoslari
"Developer's Comfort Zone"dan chiqishning eng ishonchli yo'li Toza Arxitektura (Clean Architecture) tamoyillariga qat'iy amal qilishdir. Oflayn rejimni mukammal darajaga ko'tarish uchun ilova qatlamlarini bir-biridan butunlay uzish (decoupling) kerak bo'ladi.   

Hozirgi standart amaliyotlarda dasturchilar holatni quyidagicha shakllantiradilar: UI -> Provider (yoki BLoC) -> Firebase (Remote). Ushbu zanjirda internet ulanishi uzilishi bilan UI to'g'ridan-to'g'ri xatolik qabul qiladi. Professional va ideal holatda esa zanjir quyidagi shaklni olishi kerak: UI -> Provider -> Repository ->.   

3.1. Repository (Ombor) Naqshining Mohiyati
Ushbu arxitekturaning markazida Repository (Ombor) naqshi yotadi. Repository bu biznes mantiq va axborot manbalari o'rtasidagi asosiy vositachi (vaziyatni boshqaruvchi darvozabon) hisoblanadi. Haqiqiy "Local-first" ilovalarda Repository'ning vazifasi faqatgina mahalliy ma'lumotlar bazasi bilan aloqa qilishdir.   

Repository tarmoq ulanishining holati haqida umuman hech qanday ma'lumotga ega bo'lmasligi kerak. U ilovani "onlayn" yoki "oflayn" deb ajratmaydi. Uning yagona haqiqat manbai faqatgina qurilma xotirasidagi ma'lumotlardir. Bu xususiyat ma'lumotlarning oqimini bir yo'nalishli (unidirectional data flow) qilib, ularni qat'iy mantiqiy ketma-ketlikda boshqarishga imkon beradi: UI qatlami Cubit/BLoC ga signal beradi, Cubit UseCase'ni chaqiradi, UseCase esa Repository bilan ishlaydi. Freezed kabi paketlar yordamida switch ifodalari orqali xatolarni aniq ushlab olish va ularni tahlil qilish tavsiya etiladi.   

3.2. Optimistik Yozish va Reaktiv UI
Bu yondashuv orqali "Optimistik holat" (Optimistic State) deb ataladigan dizayn naqshi joriy qilinadi. Foydalanuvchi ma'lumot yaratganda, tahrirlaganda yoki o'chirganda, Repository uni zudlik bilan lokal ma'lumotlar bazasiga yozadi. Mahalliy baza, o'z navbatida, reaktiv oqimlar (Stream) orqali UI ga yangi holatni uzatadi. Foydalanuvchi hech qanday yuklanish yoki kutish vaqtini sezmaydi. Ma'lumotlarni masofaviy serverga yuborish (va sinxronizatsiya) masalasi esa butunlay boshqa, alohida komponent bo'lgan "Sync Engine" (Sinxronizatsiya dvigateli) ga topshiriladi. Holatni boshqarish qatlamlari (Riverpod, BLoC) tarmoq va ma'lumot manbalaridan uzilganligi sababli, ularni mustaqil test qilish (unit testing) juda osonlashadi.   

4. Mahalliy Ma'lumotlar Bazalari: Obyektga Yo'naltirilgan va Relyatsion Tizimlar Qiyosiy Tahlili
Flutter loyihalarida Firebase yoniga qaysi mahalliy bazani qo'shish kerakligi ko'pincha bahslarga sabab bo'ladi. 2025-2026 yillardagi eng mashhur yechimlar asosan ikkita katta toifaga bo'linadi: Relyatsion SQL bazalar (SQLite ustiga qurilgan Drift yoki Floor) va tezkor NoSQL bazalar (Isar, Hive, Sembast).   

4.1. Bazalarning Arxitektura Turlari
Tarmoq ma'lumotlariga tayanib, quyidagi asosiy tizimlarni chuqur tahlil qilish mumkin:

Drift (sobiq Moor): Bu to'g'ridan-to'g'ri SQLite ustiga qurilgan kuchli ORM (Object-Relational Mapping) hisoblanadi. Drift o'zining type-safe (turi xavfsiz) SQL va so'rov konstruktorlari (query builders) orqali ajralib turadi. U relatsiyalar (joins), ko'rinishlar (views) va qat'iy sxemalar tuzish imkonini beradi. SQLite ommaviy domen litsenziyasi ostida tarqatilsa, Drift MIT litsenziyasiga ega. Jadvallar o'rtasidagi bog'liqliklar muhim bo'lgan o'ta murakkab analitik ilovalarda Drift tengsizdir.   

Isar: Hive muallifi tomonidan yaratilgan ushbu baza NoSQL formatida bo'lib, relyatsion bazalardan farqli o'laroq kolleksiyalar va havolalarga (links) asoslangan. Isar C++ tilida yozilgan yadrosi hisobiga boshqa barcha bazalardan tezroq ishlaydi (benchmarklar shuni ko'rsatadiki, Isar barcha o'qish/yozish operatsiyalarida eng tezkoridir). U murakkab kompozit indekslar va to'liq matnli qidiruvni mukammal qo'llab-quvvatlaydi, shuningdek isolates (izolyatorlar) va ko'p oqimli arxitekturaga moslashtirilgan.   

Hive: Juda oddiy va tezkor kalit-qiymat (key-value) tizimi bo'lib, u ko'proq sozlamalar yoki kichik ro'yxatlarni saqlash uchun mo'ljallangan. Murakkab sinxronizatsiya va oflayn-birinchi ilovalar uchun uning imkoniyatlari juda cheklangan, chunki unda murakkab qidiruv tili mavjud emas. Hozirda uning rivojlanishi sekinlashgan bo'lib, asosan hamjamiyat (hive_ce) tomonidan quvvatlanmoqda.   

Sembast va Floor: Sembast kod generatsiyasiz ishlaydigan va shifrlashni (encryption) oson qo'llab-quvvatlovchi NoSQL yechimdir. Floor esa SQLite ustida qurilgan yana bir ORM bo'lib, uning yondashuvi ko'proq Java/Android Room arxitekturasiga yaqinroq, ammo Drift kabi ulkan qamrovga ega emas.   

4.2. Taqqoslash Jadvali
Xususiyat / Ma'lumotlar Bazasi	Drift (SQLite)	Isar (NoSQL)	Hive (Key-Value)	Sembast (NoSQL)
Arxitektura asosi	Relyatsion (ORM), Jadvallar va ustunlar	Obyektga yo'naltirilgan, Kolleksiyalar	Kalit-qiymat qutilari (Boxes)	Kalit-qiymat xaritalari (Maps)
Ishlash tezligi (Ommaviy)	Yuqori (~47ms)	Eng yuqori (~8ms)	Tez, lekin cheklangan o'qish bilan	O'rtacha
So'rovlar mantig'i (Query)	Type-safe SQL, Joins, Views	Fluent Dart so'rovlari, Kompozit indekslar	Minimal, asosan O(1) izlash	Oddiy lug'at izlash mexanizmlari
Sxema migratsiyasi	Murakkab, ammo juda xavfsiz va boshqariluvchi	Avtomatik, qisman cheklangan	Talab etilmaydi	Talab etilmaydi
Ideal foydalanish sohasi	Qat'iy ma'lumot yaxlitligi, Analitika	Katta ma'lumotlar to'plami, matnli qidiruv	Sozlamalar va oddiy keshlar	Shifrlangan oflayn ma'lumotlar ombori
4.3. Isar yoki Drift? Qaysi Birini Tanlash Kerak?
Ilovani Firebase'dan gibrid modelga o'tkazishda eng oqilona qaror Isar yoki Drift orasida bo'ladi. Agar ilova Firebase Firestore ishlatayotgan bo'lsa, ma'lumotlar allaqachon hujjatli (document-based) NoSQL formatida strukturalangan bo'ladi. Shu sababli, Isar Firestore modellarini mahalliy xotiraga o'tkazishda eng mos va intuitiv tanlovdir. Isar NoSQL bo'lishiga qaramay, juda tartibli tuzilishga ega. Indekslar o'rnatish orqali Isar'da murakkab qidiruvlarni millisekundlarda bajarish mumkin ("Masalan, falon ball olgan sud xodimi" kabi mantiq Isar`da bitta Fluent Dart qatoriga aylanadi). Ikkinchi tomondan, agar loyihada ma'lumotlarning takrorlanmasligi, transaksiyalarning kislotaliligi (ACID compliance) keskin talab etilsa, Driftning SQL quvvatini tanlash maqsadga muvofiq. Drift bilan ishlashda 1000 ta ob'ektni bazaga yozish taxminan 47 millisekund vaqt olsa, Isar buni 8 millisekundda uddalaydi.   

5. Sinxronizatsiya Dvigateli (Sync Engine) va Tranzaksion "Outbox" Naqshi
Mahalliy ma'lumotlar bazasiga yozish jarayonning faqatgina yarmini tashkil qiladi. Asosiy qiyinchilik ushbu yozuvlarni bulutdagi Firebase tizimiga yo'qotishlarsiz yetkazib berishda. Buning uchun maxsus Sinxronizatsiya Dvigateli (Sync Engine) yaratiladi. Ushbu dvigatel Repository'dan va UI'dan butunlay ajratilgan, fonda ishlovchi xizmatdir. U faqat ikkita oqim bilan ishlaydi: uzoqdagi serverdan yangi o'zgarishlarni tortib olish (PullService) va mahalliy bazadagi o'zgarishlarni serverga surish (PushService).   

5.1. Tranzaksion Outbox (Chiqish Qutisi) Mantig'i
Agar ma'lumotlar faqatgina operativ xotirada (RAM) navbatga qo'yilsa va shu payt ilova yopilib qolsa (crash), barcha saqlanmagan so'rovlar yo'qoladi. Bunga yo'l qo'ymaslik uchun sanoat standartidagi Tranzaksion Outbox (Transactional Outbox) namunasi qo'llaniladi.
Bu qanday ishlaydi? Foydalanuvchi ilovada harakatni amalga oshirganda (masalan, testni tugatib natijani saqlaganda), ikkita amaliyot bitta atomar (atomic) bazaviy tranzaksiya ichida amalga oshiriladi :   

Haqiqiy ma'lumot (quiz natijasi) o'zining tegishli jadvaliga (yoki Isar kolleksiyasiga) yoziladi.

Ayni shu tranzaksiya ichida, sync_outbox (yoki sync_queue) nomli alohida maxsus jadvalga sinxronizatsiya hodisasi yoziladi.   

sync_outbox jadvalidagi yozuv (odatda UpsertOp deb ataladi) quyidagi muhim qismlarni o'z ichiga oladi:

opId: Har bir amaliyot uchun unikal identifikator (UUID). Bu takrorlanishlar (idempotency) ni oldini olish uchun zarur.   

kind: Qaysi kolleksiyaga tegishli ekanligi (masalan, 'quiz_attempts').   

payloadJson: Ma'lumotning asl nusxasi, JSON shaklida.   

status: Amaliyot holati (Pending, Synced, Failed).   

retryCounter: Necha marta yuborishga urinish bo'lganligi.   

Sinxronizatsiya dvigateli doimiy ravishda sync_outbox jadvalini tekshirib turadi. U yozuvlarni birinchi kiritilgan tartibda (ORDER BY created_at ASC) qayta ishlashni boshlaydi va ularni Firebase'ga jo'natadi. Agar server qabul qilsa, yozuv navbatdan o'chiriladi.   

5.2. Qayta Urinish va Eksponensial Orqaga Qaytish
Agar internet yo'qligi sababli Firebase so'rovni rad etsa, dvigatel "Eksponensial orqaga qaytish" (Exponential Backoff) algoritmini ishga tushiradi. Ya'ni, birinchi xatolikdan so'ng 2 soniya, keyingisida 4, 8, 16 soniya kutib, serverga ortiqcha yuk tushirmagan holda ma'lumotni yetkazib berishga harakat qiladi. Bunday mexanizm ilovaning mutlaqo bardoshli va xavfsiz ekanligini kafolatlaydi.   

6. Ma'lumotlar Konfliktini Hal Qilish (Conflict Resolution)
Haqiqiy devor — ma'lumotlarning oflayn rejimda birlashish vaqtidagi konfliktidir. Tassavvur qiling, oflayn rejimdagi foydalanuvchi ma'lumotni soat 10:00 da o'zgartirdi (masalan, test bahosini yangiladi). Ammo soat 10:05 da boshqa bir admin yoki tizim o'sha hujjatni serverda o'zgartirib qo'ydi. Qaysi ma'lumot to'g'ri deb o'qilishi kerak? Agar bu jarayon noto'g'ri boshqarilsa, ulkan axborot fojiasi yuz beradi.   

Ushbu muammoni hal qilish uchun server tomonida ham, mijoz tomonida ham murakkab tahlil mexanizmi bo'lishi kerak. Bulutli server mijoz jo'natgan yozuvdagi _baseUpdatedAt maydonini o'zidagi asl hujjatning yangilanish vaqti bilan solishtiradi. Agar vaqtlar farq qilsa, u mijozga HTTP 409 (Conflict) xatosini qaytaradi va sinxronizatsiya dvigateli o'zining kelishuv strategiyalarini (Conflict Strategies) ishga soladi.   

Asosiy kelishuv strategiyalari quyidagilardan iborat:

autoPreserve (Aqlli birlashtirish): Bu eng xavfsiz standart hisoblanadi. Bunda tizim asosiy ma'lumot sifatida serverdagini qabul qiladi. Mijoz qaysi aniq maydonlarni (changedFields) o'zgartirganini hisobga oladi va faqatgina o'sha o'zgartirilgan ma'lumotlarni serverdagi fayl ustiga tikadi. Ichma-ich joylashgan murakkab obyektlar (nested objects) rekursiv ravishda tekshirilib, birlashtiriladi. Shundan so'ng, ulangan xujjat maxsus X-Force-Update: true sarlavhasi (header) orqali majburiy tarzda saqlanadi. Muhim tizim maydonlari (id va updatedAt) doimo serverdan olinishi shart, aks holda yagona vaqt standartida chalkashlik yuz beradi.   

serverWins (Server yutadi): Mijozning barcha oflayn o'zgarishlari bekor qilinadi va qurilmaga bulutdagi mavjud to'g'ri ma'lumotlar ko'chiriladi.   

clientWins (Mijoz yutadi): Bu orqali qurilmadagi ma'lumot serverdagini to'liq ezib yozadi va o'zgartiradi.   

lastWriteWins (So'nggi yozilgani yutadi): updatedAt maydonlaridagi vaqt tamg'asi tekshirilib, qaysi biri eng oxirgi vaqtda amalga oshirilgan bo'lsa, o'shani qoldiradi.   

manual (Qo'lda hal qilish): Juda sezgir axborotlarda tizim UI ga chaqiruv jo'natadi, va foydalanuvchi qarshisiga "Sizning versiyangiz" va "Server versiyasi" qiyoslanib turgan oyna ochiladi va qarorni inson qabul qiladi.   

Kelajak istiqbolida Isar dvigatellari va sinxronizatsiya tizimlarida "Conflict-Free Replicated JSON Datatype" (CRDT) kabi ilmiy texnologiyalarni integratsiya qilish ko'zda tutilgan. CRDT amaliyotlari ma'lumotlar konfliktini avtomatik va deterministik ravishda hech qanday ma'lumot yo'qotishisiz gibrid holatda birlashtirish kafolatini beradi, hatto to'liq markazlashmagan bluetooth-tarmoqlarda (peer-to-peer) ham ishlay oladi.   

7. Fon Rejimi (Background Processing) va Tarmoq Kuzatuvi
Oflayn rejimning eng dolzarb shartlaridan yana biri — bu foydalanuvchi ilovani yopib qo'yganda ham sinxronizatsiya ishlashda davom etishidir. Bu jarayon Android WorkManager va Flutter'ning izolyatsiya (Isolates) qilingan oqimlari orqali ta'minlanadi.   

7.1. Flutter Isolates va WorkManager Integratsiyasi
Dart tili bir oqimli (single-threaded) hisoblanadi. Agar navbatda yig'ilib qolgan minglab JSON obyektlar asosiy oqimda tahlil qilinib Firebase'ga yuborilsa, ilovada animatsiyalar qotib qoladi. Buning oldini olish uchun Flutter'da "Isolates" (Izolyatorlar) ishlatiladi. Izolyatorlar bir-biri bilan umumiy xotirani bo'lishmaydigan, faqat xabarlar orqali muloqot qiladigan mustaqil ijro muhitlaridir. Sinxronizatsiya mexanizmi butunlay o'z izolyatorida yashaydi.   

Uzoq muddatli barqarorlik uchun workmanager kabi plaginlardan keng foydalaniladi. WorkManager qurilma qayta ishga tushirilganda ham esdan chiqmaydigan "periodic tasks" (davriy vazifalar) yaratadi. Masalan, har 15 daqiqada yoki kechasi soat 3:00 da (yuklama kam bo'lganda) dvigatelni uyg'otib, oflayn rejimda to'plangan ma'lumotlarni serverga muvofiqlashtirishi mumkin.   

7.2. Tarmoq Ulanishini Kuzatishning Kichik Sirlari
Tarmoqqa ulanish holatini aniqlash uchun connectivity_plus plagini keng ishlatiladi. BLoC yoki Riverpod orqali ulanish o'zgarishlari tinglanadi (connectivity.onConnectivityChanged.listen(...)) va aloqa paydo bo'lganda dvigatel faollashadi. Resurslarni to'g'ri boshqarish uchun close() metodi yordamida ushbu tinglovchilar obunasi o'chirilishi xotira sizib chiqishlarining (memory leaks) oldini oladi.   

Biroq, connectivity_plus faqat qurilmaning tarmoq adapteri holatini bildiradi, u to'laqonli internet mavjudligiga javob bermaydi. Masalan, mehmonxona WiFi tarmog'iga ulanilganda tarmoq bor bo'ladi, lekin internetga chiqish bo'lmasligi mumkin. Shu sababli, Repository mantiqiy jihatdan tarmoq uzatish xizmatidan foydalanishdan oldin, InternetAddress.lookup('example.com') so'rovi yordamida haqiqiy aloqani tasdiqlaydi. Agar bu sinovdan muvaffaqiyatli o'tilsa, Push va Pull operatsiyalari boshlanadi, aks holda SocketException tutilib, amaliyot keyinga qoldiriladi.   

Qo'shimcha ilg'or arxitekturalarda fon rejimini tejash va real vaqtga yaqin sinxronizatsiyani ta'minlash maqsadida Firebase Cloud Messaging (FCM) orqali "sokin" push-xabarnomalar (silent push payloads) qabul qilinadi. Serverda biror ma'lumot yangilansa, server qurilmaga sezilmas bildirishnoma jo'natadi. Ilova bu xabarni ushlab olib, darhol Firebase'dan faqat kerakli maydonlarni o'zining mahalliy (Isar) bazasiga tortib (Pull) qo'yadi. Bu orqali energiya sarfi keskin kamayadi.   

8. Ma'lumotlarni Xaritalash (Data Mapping) va Gibrid Yondashuv
Qulaylik zonasidan chiqishning amaliy qadamlaridan biri bu obyektlarni qatlamlar o'rtasida to'g'ri xaritalashdir (Data Mapping). Firebase modelidagi DocumentSnapshot to'g'ridan-to'g'ri UI'ga etib bormasligi kerak. Gibrid tizimda ma'lumotlar bir necha darajada transformatsiyaga uchraydi.

Masalan, loyihaga Isar kiritilganda, alohida modellarni yaratish zaruriyati tug'iladi. Mahalliy model Isar talablariga mos @collection va qidiruvni optimallashtirish uchun @Index() annotatsiyalari bilan yoziladi. Yaratilgan ob'yektda Isar o'zining ichki avto-inkrement qilinuvchi o'zgaruvchisiga (Id) ega bo'ladi, ammo Firebase hujjatining haqiqiy ID'si maxsus indekslangan firestoreId deb nomlangan maydonda saqlanadi.   

Dart
// Transformatsiya namunasidagi xaritalash (Mapping) mantig'i:
@collection
class CollectionModelIsar {
  Id? id; // Mahalliy operatsiyalar uchun tezkor id
  @Index() 
  late String firestoreId; // Bulut bilan zanjirni saqlovchi indeks
  @Index() 
  late String userId; // Qidiruv uchun alohida indeks
  @Index() 
  late DateTime updatedAt; // Oflayn filtrlash va tartiblash uchun

  // Uzoqdagi modeldan Mahalliy modelga konvertatsiya funksiyasi
  factory CollectionModelIsar.fromCollectionModel(CollectionModel remoteModel) {
    return CollectionModelIsar(
      //... maydonlarni biriktirish amaliyoti...
    );
  }
}
Yuqoridagi namunada ko'rinib turibdiki, @Index lar yordamida qidiruv amaliyotlari kesh bo'ylab chaqmoqdek tez aylanadi. Shuningdek, updatedAt indekslanishi hisobiga qatorlarni tartiblash Isar ichidagi maxsus .sortByUpdatedAt() kabi ichki xususiyatlar yordamida soniyaning mingdan bir ulushida UI ga yetkazib beriladi.   

8.1. "Pull-Through Cache" Arxitekturasi
Ideal gibrid yondashuvda (masalan, quiz_attempts xususiyati uchun) arxitektura qanday ishlashini tasavvur qilaylik.
Dastur so'rov yuborganda Repository quyidagi mantiqni bajaradi:   

U SharedPreferences dan ushbu jadvallar oxirgi marta qachon bulutdan tortib olinganini (Full Sync Timestamp) tekshiradi.   

Agar ma'lumot eskirmagan bo'lsa (konfiguratsiya qilingan muddatdan o'tmagan bo'lsa), shunchaki Isar'dan ma'lumotni o'qiydi.   

Agar ma'lumotlar eski bo'lsa (stale) va tarmoq mavjud bo'lsa, u Firebase'dan yangi axborotni so'raydi.   

Olingan natijalar to'g'ridan-to'g'ri ekranga uzatilmaydi, balki avval Isar xotirasini yangilaydi (insert/update).   

Isar arxitekturasida UI uning watch() oqimiga obuna bo'lgani uchun o'zgarishlar darhol ekranda paydo bo'ladi.   

Ushbu ketma-ketlik nafaqat ilova tezligini ta'minlaydi, balki tarmoq trafigini va Firebase hisob-kitob varaqasidagi (billing) o'qish xarajatlarini ulkan darajada optimallashtiradi. Agar o'n minglab aktiv foydalanuvchilar har safar ilovaga kirganda barcha ma'lumotlarni Firebase'dan o'qiyversa, bu moliyaviy barbod bo'lishga (pricing blow outs) olib keladi.   

9. Xulosa: "O'yinchoq"dan "Sanoat Darajasi"gacha Bo'lgan Yo'l
Ushbu tahlillar shuni ko'rsatadiki, faqatgina Firebase'ning o'ziga qaram bo'lib, uning "magiya"si orqasida kod yozish — ma'lum bosqichda to'xtashga mahkum bo'lgan yondashuvdir. Oflayn rejim atrofidagi devorni yorib o'tish "Local-first" tamoyillariga asoslangan mustahkam muhandislik qarorlarini qabul qilishni talab qiladi.   

Firebase ilovaning global, uzoq muddatli xotirasi — "bulutli ombori" hisoblanadi. Mahalliy ma'lumotlar bazalari (Isar yoki Drift) esa har doim, har qanday ulanish darajasida ishlaydigan "cho'ntagingizdagi hamyon"dir. Cho'ntakda ma'lumot bo'lmaganda, to bulutga borib kelgunga qadar butun tizim kutishga majbur bo'ladi, bu esa yakuniy iste'molchiga yoqmaydi. Clean Architecture yordamida ma'lumot manbalarini aniq chegaralash , ma'lumotlarning tranzaksion navbatini (Outbox) to'g'ri tashkil etish , tarmoq xatolarida mantiqiy tiklanishlarni eksponensial ravishda amalga oshirish  kabi qat'iy tamoyillar joriy qilinishi loyihaning barqarorligini tasdiqlaydi.   

Endigi navbatda dasturchining qulaylik zonasini tark etish sari qo'yadigan birinchi amaliy qadami quyidagicha bo'lishi taklif etiladi: arxitekturani butunlay o'zgartirmasdan turib, loyihaning bitta kichik va nisbatan oddiy qismini (masalan, faq yoki quiz_attempts moduli) tanlab oling. Unga isar yoki drift bazalarini o'rnating va faqat shu modulni onlayn bulutsiz, mutlaqo oflayn ishlashga, so'ngra fonda Firebase bilan sinxronizatsiya qilinishiga majburlab ko'ring. Bu tajriba orqali sinxronizatsiya logikasi, ma'lumotlar mappingi, va muammoli holatlardagi boshqaruv amaliy ravishda o'zlashtiriladi. Natijada ilova nafaqat tezlik, barqarorlik va foydalanuvchi tajribasi bo'yicha to'liq transformatsiyaga uchraydi, balki arxitekturaviy jihatdan mukammal ishlab chiqilgan professional mahsulot darajasiga ko'tariladi.