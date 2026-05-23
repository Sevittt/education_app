# 🎓 Sud qo'llanma - Professional Ta'lim Platformasi

> Sud tizimi xodimlari va ekspertlari uchun maxsus ishlab chiqilgan, zamonaviy va interaktiv bilim olish ekosistemasi.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20Feature--First-green)
![Language](https://img.shields.io/badge/Language-Uzbek%20%7C%20Russian%20%7C%20English-blue)

---

## 📱 Loyiha Haqida

**Sud qo'llanma** — bu shunchaki elektron kutubxona emas, balki to'liq qamrovli **LMS (Learning Management System)** hisoblanadi. Ilova foydalanuvchilarning bilim darajasini oshirish, testlar orqali tekshirish va yutuqlarni gamifikatsiya orqali rag'batlantirishga qaratilgan.

### 🎯 Asosiy Maqsadlar
- **Kompetensiyani Oshirish:** Sud xodimlarining huquqiy savodxonligini doimiy rivojlantirish.
- **Interaktiv Ta'lim:** Zerikarli matnlardan qochib, video darslar, kvestlar va simulyatsiyalar taqdim etish.
- **Monitoring:** Rahbariyat uchun xodimlar bilimini real vaqtda kuzatish imkoniyati.

---

## ✨ Asosiy Imkoniyatlar

### 🔐 1. Xavfsiz Autentifikatsiya (RBAC)
Bizning tizim **Role-Based Access Control** (Rollar bo'yicha boshqaruv) ga asoslangan:
- **👨‍💼 Xodim (User):** Resurslarni o'qish, test ishlash, XP yig'ish.
- **🎓 Ekspert (Content Creator):** Yangi maqolalar yozish, testlar tuzish.
- **👑 Admin (Superuser):** Foydalanuvchilarni boshqarish, statistikani ko'rish, tizim sozlamalari.

> **Login turlari:** Email/Parol, Google Sign-In, Mehmon (Guest) rejimi.

### 🎮 2. Gamifikatsiya va Statistika
O'qish jarayonini qiziqarli qilish uchun "RPG o'yin" elementlari qo'shilgan:
- **XP (Experience Points):** Har bir maqola, test yoki video uchun ball beriladi.
- **Levellar (Darajalar):** 
  - 🟢 *Boshlang'ich (Beginner)*: 0 - 100 XP
  - 🔵 *O'rta (Intermediate)*: 100 - 500 XP
  - 🟣 *Ilg'or (Advanced)*: 500 - 1000 XP
  - 🟡 *Ekspert (Expert)*: 1000+ XP
- **Profil Statistikasi:** Jami ishlangan testlar, to'g'ri javoblar foizi, o'qilgan kitoblar.

### 🌍 3. Multi-language (Lokalizatsiya)
Ilova to'liq 3 tilda ishlaydi:
- 🇺🇿 O'zbek tili (Lotin)
- 🇷🇺 Rus tili
- 🇬🇧 Ingliz tili
> Til o'zgarishi bilan butun interfeys va kontentlar avtomatik tarjima qilinadi.

### 📚 4. Elektron Kutubxona va Testlar
- **Resurslar:** PDF, Video va Maqolalar bazasi. "Bookmark" (Saqlab qo'yish) funksiyasi.
- **Quiz Engine:** 
  - Vaqtga chegaralangan testlar.
  - Natijani darhol ko'rish.
  - Xato javoblar tahlili.

### 💬 5. Hamjamiyat (Community)
- **Forum:** Savol berish va muhokama qilish maydoni.
- **Ekspert Javoblari:** Murakkab yuridik masalalar bo'yicha ekspertlardan javob olish.

---

## 🏗️ Texnik Arxitektura

Loyiha **Clean Architecture** tamoyillari asosida, **Feature-First** (Funksional bo'linish) usulida qurilgan. Bu kodni o'qish, testlash va kengaytirishni osonlashtiradi.

```
lib/
├── core/                              # Umumiy yordamchi kodlar
│   ├── constants/                     # Ranglar, API linklar
│   ├── errors/                        # Xatolarni ushlash (Failure)
│   └── utils/                         # DateFormatter, Validators
│
├── features/                          # ASOSIY MODULLAR
│   ├── auth/                          # Kirish tizimi
│   │   ├── data/                      # RepositoryImpl, DataSource (Firebase)
│   │   ├── domain/                    # Entities (AppUser), UseCases, Repository Interface
│   │   └── presentation/              # Screens (Login), Providers (AuthNotifier)
│   │
│   ├── home/                          # Bosh sahifa (Dashboard)
│   ├── profile/                       # Profil va Statistika
│   ├── gamification/                  # XP va Level logikasi
│   ├── community/                     # Forum va Chat
│   └── resource/                      # Kutubxona va Testlar
│
├── l10n/                              # Tarjima fayllari (.arb)
│   ├── app_uz.arb
│   ├── app_ru.arb
│   └── app_en.arb
│
└── main.dart                          # Ilovani ishga tushirish nuqtasi
```

### Texnologiyalar Steki
- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Serverless)
  - **Auth:** Foydalanuvchilarni tanish.
  - **Firestore:** NoSQL ma'lumotlar bazasi (Userlar, Resurslar, Chat).
  - **Storage:** Rasmlar va fayllar uchun.
- **State Management:** Provider (Sodda va samarali).

---

## � Ishga Tushirish (O'rnatish)

Loyiha kodini o'z kompyuteringizda ishlatib ko'rish uchun:

### 1. Talablar
- Flutter SDK (3.0 dan yuqori)
- Git
- VS Code yoki Android Studio

### 2. O'rnatish
```bash
# 1. Loyihani yuklab oling
git clone https://github.com/username/education_app.git

# 2. Papkaga kiring
cd education_app

# 3. Kutubxonalarni yuklang
flutter pub get
```

### 3. Firebase Sozlash
Loyiha Firebase bilan ishlagani uchun, o'zingizning `google-services.json` (Android) yoki `GoogleService-Info.plist` (iOS) faylingizni tegishli papkalarga qo'yishingiz kerak.

### 4. Ilovani Yoqish
```bash
flutter run
```

---

## 🤝 Hissa Qo'shish (Contributing)

Biz har qanday taklif va o'zgarishlarga ochiqmiz! 
1. **Fork** qiling.
2. Yangi **branch** oching (`git checkout -b feature/yangi-imkoniyat`).
3. O'zgarishni **commit** qiling.
4. Bizga **Pull Request** yuboring.

---

## � Litsenziya

MIT License.

---
**Made with ❤️ in Uzbekistan**
