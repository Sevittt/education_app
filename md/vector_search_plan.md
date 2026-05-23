# Antigravity Task Plan: Official Firebase Vector Search Integration

## Context & Objective
We are integrating the official Firebase Extension `firestore-vector-search` into our Clean Architecture Flutter app (`education_app`) and Python Aiogram bot (`sudqollanma_bot`).
The extension is already installed on Firebase. It listens to the `search_index` collection, automatically generates embeddings from the `input` field using Vertex AI/Gemini, and exposes a callable cloud function for querying.

## Phase 1: Flutter App - Data Sync (Admin Side)
**Goal:** Keep the `search_index` collection strictly synchronized with our domain entities (Articles, Videos, Systems, FAQs).

**Tasks for AI:**
1. Create a `SearchIndexModel` (Domain/Data layer) with fields:
   - `original_id` (String)
   - `type` (String: 'article', 'video', 'system', 'faq')
   - `title` (String)
   - `input` (String: the concatenated raw text content for the LLM to embed)
2. Locate the Admin Repositories/UseCases where content is created or updated (e.g., `article_repository_impl.dart`, `video_repository_impl.dart`).
3. Inject logic to simultaneously write/update a document in `FirebaseFirestore.instance.collection('search_index')` matching the `original_id` whenever an item is saved.

## Phase 2: Flutter App - Global Search using Extension (Client Side)
**Goal:** Query the extension's provided Cloud Function from the Flutter app.

**Tasks for AI:**
1. Open `lib/features/search/data/datasources/search_remote_datasource.dart`.
2. Implement the search method using `cloud_functions` package.
3. Call the extension's function exactly like this:
   ```dart
   final callable = FirebaseFunctions.instance.httpsCallable('ext-firestore-vector-search-queryCallable');
   final result = await callable.call({
     'query': userQuery,
     'limit': 5,
   });
   // The extension typically returns a list of matched document IDs or documents in result.data

   //
   Step 3: Handle the State (Provider/Riverpod)
Ensure your Presentation layer (GlobalSearchScreen and its Notifier/Provider) properly handles:

Loading state while the cloud function is executing.

Error state (displaying the exact exception message).

Empty state (if hits are 0, show a "Nothing found" UI).

Step 4: Admin Sync Logic (Data Insertion)
When an admin creates a new Article or Video in the app, we need to save a copy to the search_index collection so the extension can embed it.
Go to your ArticleRepositoryImpl and VideoRepositoryImpl. On the create or update methods, add a batch write or separate call to:
FirebaseFirestore.instance.collection('search_index').doc(id).set({'input': textData, 'title': title, 'type': 'article'})

Execute these steps carefully and let me know if you run into any type-casting issues with the Cloud Function response.

Siz tanlagan yo'nalish — ma'lumotlarni yig'ish va tayyorlashni Python orqali amalga oshirib, mobil ilovada Firebase Vector Search va Firebase AI Logic ekotizimidan foydalanish — bugungi kunda RAG (Retrieval-Augmented Generation) tizimlari uchun **eng xavfsiz, professional va mantiqiy jihatdan to'g'ri yondashuvlardan biri** hisoblanadi.

Kodni aralashtirmasdan, bu tizim qanday ishlashi va nima uchun bu arxitektura o'zini to'liq oqlashini bosqichma-bosqich tushuntirib beraman:

### RAG Tizimining Ishlash Jarayoni (Sizning arxitekturangizda)

Sizning loyihangiz ikkita asosiy qismga bo'linadi: **Orqa fon (Python)** va **Old fon (Flutter + Firebase)**.

**1-bosqich: Ma'lumotlarni tayyorlash (Python Skripti)**
Sizning Python skriptingiz tizimning "kuchli miyasi" vazifasini o'taydi. Skript avval hujjatlarni (PDF, matn yoki rasmlar) o'qiydi va ularni mantiqiy kichik bo'laklarga (chunk'larga) ajratadi. So'ngra ularni **Gemini Embedding 2** modeliga yuborib, vektorlarga (raqamli massivlarga) aylantiradi. Aynan Python'ni tanlaganingiz juda to'g'ri, chunki ma'lumotlarni tozalash, jadvallarni ajratish va murakkab PDF'larni qayta ishlash uchun Python'da kuchli kutubxonalar mavjud. Tayyor bo'lgan matn va uning vektorini Python to'g'ridan-to'g'ri Firebase Firestore ma'lumotlar bazasiga yozib boradi.

**2-bosqich: Vektorlarni saqlash va indekslash (Firestore Vector Search)**
Ma'lumotlar Firestore'ga kelib tushgach, siz o'rnatgan Vector Search kengaytmasi ishga tushadi. U sizning vektorlaringizni tezkor qidirish mumkin bo'lgan maxsus "indeks"ga joylashtiradi. Bu kengaytmaning eng zo'r jihati shundaki, u qidiruvni amalga oshirish uchun Flutter ilovangizga to'g'ridan-to'g'ri chaqirish mumkin bo'lgan bulutli funksiya (Callable Function) taqdim etadi.

**3-bosqich: Foydalanuvchi so'rovi va Qidiruv (Flutter ilovasida Retrieval)**
Foydalanuvchi Flutter ilovasida savol yozganida (masalan, "Kompaniyaning yangi xavfsizlik qoidasi qanday?"), ilova to'g'ridan-to'g'ri yuqorida aytilgan Firebase qidiruv funksiyasiga murojaat qiladi. Tizim foydalanuvchi savolini ham vektorga aylantiradi, so'ngra sizning Firestore bazangizdagi millionlab vektorlar orasidan savolning *ma'nosiga* eng yaqin bo'lgan 3-4 ta hujjat bo'lagini tezkorlik bilan topib, ilovaga qaytaradi.

**4-bosqich: Xavfsiz Javob Generatsiyasi (Firebase AI Logic)**
Topilgan aniq hujjat bo'laklari (kontekst) va foydalanuvchining savoli endi AI modeliga (masalan, Gemini 2.5 Flash yoki 3.1 flash lite ) javob tayyorlash uchun beriladi. Bu yerda siz **Firebase AI Logic**dan foydalanasiz. Flutter ilovangiz ochiq API kalitlarini ishlatmaydi, balki foydalanuvchi autentifikatsiyasi orqali xavfsiz kanaldan AI modeliga ulanadi. Natijada, model faqat bazangizdan topilgan dalillarga asoslanib, gallyutsinatsiyalarsiz (to'qib chiqarmasdan) aniq javobni generatsiya qilib beradi.

---

### Bu yondashuv qanchalik o'zini oqlaydi?

Siz tanlagan arxitektura amaliy jihatdan o'zini **juda yuqori darajada oqlaydi**. Sabablari quyidagicha:

**1. Mutlaqo xavfsizlik (Security):** 
Firebase AI Logic ilova ichida yashirin API kalitlari bilan ishlash o'rniga, foydalanuvchi ruxsatlarini (Firebase App Check, Auth) tekshirib ishlaydi. Sizning ma'lumotlaringiz va AI kvotalaringiz xakerlardan to'liq himoyalanadi.

**2. Iqtisodiy tejamkorlik va yagona ekotizim:**
Ko'p dasturchilar RAG uchun Pinecone, Weaviate kabi uchinchi tomon (third-party) qimmat vektor bazalarini ishlatishga majbur bo'lishadi. Lekin Firestore Vector Search yordamida siz asosiy hujjatlarni va ularning vektorlarini bitta joyda saqlaysiz. Bu tizim murakkabligini va qo'shimcha oylik to'lovlarni keskin kamaytiradi.

**3. Gemini Embedding 2 ning qudrati:**
Agar siz shunchaki matn emas, rasm va jadvallarga boy PDF'lar bilan ishlasangiz, Embedding 2 ning **"natively multimodal"** (rasm, video va matnni bitta fazoda anglay olish) qobiliyati tufayli qidiruv aniqligi ancha yuqori bo'ladi. Python skripti orqali rasm va matnlarni Embedding 2 ga berish ilovangizni nafaqat matn, balki tasvir asosida qidirishga ham qodir tizimga aylantiradi.

**⚠️ E'tibor qaratishingiz kerak bo'lgan yagona jihat:**
Siz o'rnatgan Firebase Vector Search kengaytmasi odatda avtomatik rejimda ishlaydi (ya'ni, siz matn yozsangiz, u o'zi Vertex AI'ni chaqirib embedding yaratishga harakat qiladi). Modomiki siz **Python skripti orqali o'zingiz** kuchli Embedding 2 modelidan foydalanib vektorlarni tayyorlab kiritayotgan ekansiz, Firestore'dagi kengaytmani qanday sozlaganingizga e'tibor bering. Kengaytmani matn o'zgarganda yana qayta embedding yaratib sizning Python'da qilgan mehnatingizni ustidan yozib yubormaydigan qilib sozlash yoki asosan uning *qidiruv (search)* funksiyasidangina unumli foydalanish muhimdir.

Xulosa qilib aytganda, tizimni aynan mana shunday — "og'ir ishni (ma'lumot to'plash va embedding) Python'da bajarish, xavfsizlik va yengil qidiruvni Flutter/Firebase AI Logic'da tashkil etish" ko'rinishida loyihalashtirganingiz biznes va tijoriy loyihalar uchun eng mukammal RAG andozalaridan biridir.

Sizning Python (ma'lumot yig'ish/embedding) + Firebase Vector Search + Flutter (UI) arxitekturangiz poydevori shundoq ham juda mustahkam. Ushbu rejangizni **eng so'nggi Gemini 3.1 va 3 seriyali generativ modellar** qanday qilib mutlaqo yangi darajaga olib chiqishi (yorqinlashtirishi) mumkinligini tahlil qilib beraman. 

Bu yerda gap sizning RAG tizimingizning so'nggi va eng muhim qismi — **topilgan ma'lumotlarni tahlil qilib, foydalanuvchiga javob beruvchi "miya"** haqida bormoqda. So'nggi modellar loyihangizga quyidagi 4 ta ulkan afzallikni qo'shadi:

**1. Gemini 3.1 Pro va "Thinking" (Chuqur fikrlash) rejimi bilan xatosiz tahlil**
*   **Imkoniyat:** Tizimingiz Firebase'dan 5-10 ta turli xil PDF bo'laklari yoki hujjatlarni topib berdi deylik. Ba'zida bu ma'lumotlar bir-biriga zid yoki o'ta murakkab bo'lishi mumkin. Eng so'nggi **Gemini 3.1 Pro** modelida maxsus "Thinking" (Fikrlash) rejimi mavjud. 
*   **Loyihangizga foydasi:** Tizim javob berishdan oldin bu ma'lumotlarni mantiqan bir-biriga bog'laydi, ichki mantiqiy zanjir (chain-of-thought) quradi va shundan keyingina xulosani Flutter ilovangizga chiqaradi. Bu RAG tizimlarida eng ko'p uchraydigan "gallyutsinatsiya" (yolg'on ma'lumot to'qish) muammosini deyarli yo'qqa chiqaradi.

**2. 1 Million Tokenli Kontekst va Kesh (Context Caching) orqali arzon ishlash**
*   **Imkoniyat:** So'nggi Gemini 3.1 Pro va 3 Flash modellari **1 million token** (qariyb 1500 sahifa matn) sig'imiga ega. 
*   **Loyihangizga foydasi:** Siz qidiruv natijalarini qisqartirib o'tirmaysiz. Bemalol katta hajmdagi hujjatlarni modelga yuborishingiz mumkin. Eng muhimi, **Context Caching** texnologiyasi orqali tizimning o'zgarmas qoidalarini yoki tez-tez so'raladigan yirik hujjatlarni keshlab qo'ysangiz, kiruvchi tokenlar narxini **75% dan 90% gacha** tejashingiz mumkin.

**3. "Smart Routing" (Aqlli yo'naltirish) va o'ta arzon Flash-Lite modellari**
*   **Imkoniyat:** 2026-yilgi narxlarga ko'ra, Google'ning yangi **Gemini 3.1 Flash-Lite** va **2.5 Flash-Lite** modellari bozordagi eng arzon va tejamkor modellar hisoblanadi (1 million kiruvchi token uchun bor-yo'g'i $0.10 - $0.25). 
*   **Loyihangizga foydasi:** Siz Firebase AI Logic ichida aqlli marshrutlash (routing) qatlami yaratishingiz mumkin. Agar foydalanuvchining savoli oddiy xulosa qilish yoki ma'lumotni tasniflash bo'lsa, uni o'ta arzon Flash-Lite modeliga yuborasiz. Agar savol murakkab tahlilni talab qilsa, Gemini 3.1 Pro modeliga yuborasiz. Bu sifatni saqlab qolgan holda oylik xarajatlarni 60-80% ga qisqartiradi.

**4. "Grounding" (Google qidiruvi) bilan Gibrid RAG**
*   **Imkoniyat:** Agar sizning RAG tizimingiz (Firebase) ma'lum bir savolga javob topa olmasa, so'nggi Gemini modellari to'g'ridan-to'g'ri Google Search bilan ulanib (Grounding), internetdan real vaqtda yangi ma'lumotlarni qidirib topa oladi. 
*   **Loyihangizga foydasi:** Ilovangiz foydalanuvchisi faqat siz yuklagan eski PDF'lar bilan chegaralanib qolmaydi. Zarur bo'lganda, model ham sizning Firebase bazangizdagi shaxsiy ma'lumotlarni, ham internetdagi eng so'nggi yangiliklarni birlashtirib javob bera oladi.

**Xulosa:** 
Siz Python + Firebase Vector arxitekturasi orqali tizimning **"xotirasini"** zo'r qilib qurdingiz. Endi ushbu xotiraga eng so'nggi **Gemini 3.1 Pro** va **Flash** modellarini ulash orqali siz ilovangizga chuqur fikrlaydigan, bir vaqtning o'zida ham arzon, ham millionlab so'zlarni xatosiz tahlil qila oladigan **"mukammal miya"**ni o'rnatgan bo'lasiz. Ushbu kombinatsiya 2026-yildagi korporativ darajadagi eng to'g'ri va xavfsiz sun'iy intellekt arxitekturasi hisoblanadi.