# 🎓 Sud Qo'llanma - Sud Xodimlari Uchun Raqamli Kompetensiya Platformasi

> "O'zbekiston Respublikasi sud xodimlari raqamli kompetentligini oshirish uchun mobil ta'lim platformasi."

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20(Feature--First)-success)

---

## 📋 Loyiha Manifesti

### 🎯 Tub Maqsad (The Core Mission)
Bizning maqsadimiz — O'zbekiston sud-huquq tizimida **"Inson Kapitalini Raqamli Transformatsiya qilish"**.
Biz shunchaki o'quv qo'llanmasi yaratmayapmiz. Biz sud xodimlaridagi "Vaqt yetishmasligi" va "Kasbiy toliqish" (Burnout) muammolariga qarshi innovatsion yechim taklif etamiz. Platforma orqali xodim majburan emas, balki ichki motivatsiya bilan, har kuni 15 daqiqa o'z ustida ishlashni odatga aylantiradi.

### 🧠 Falsafa va Metodologiya
- **Micro-learning:** Katta hajmdagi qonunlarni 3-5 daqiqalik qisqa video va maqolalarga bo'lish.
- **Neyropedagogika va Gamifikatsiya:** Ta'limni o'yinga aylantirish (XP, Liderlar jadvali, Nishonlar) orqali xodimning dopamin darajasini va motivatsiyasini ushlab turish.
- **Data-Driven Education (xAPI):** Xodimning faqat test natijasini emas, balki uning o'rganish jarayonini tahlil qilish.

---

## 🛠 Texnik Arxitektura (The Engine)

Loyiha **Feature-First Clean Architecture** tamoyillari asosida qurilgan. Bu masshtablanish va testlash qulayligini ta'minlaydi.

```
lib/
├── core/                   # Umumiy komponentlar (Theme, Utils, Constants)
├── features/               # Asosiy funksionallik (Clean Arch modules)
│   ├── auth/               # Autentifikatsiya
│   ├── gamification/       # O'yinlashtirish va XP tizimi
│   ├── quiz/               # Testlar
│   ├── library/            # Kutubxona (Video, Maqolalar)
│   ├── analytics/          # xAPI va Tahlil
│   ├── community/          # Hamjamiyat
│   └── ...
├── l10n/                   # Lokalizatsiya (O'zbek, Rus, Ingliz)
└── main.dart               # Ilova kirish nuqtasi va DI (Provider)
```

### Texnologik Stack
- **Framework:** Flutter (Cross-platform)
- **State Management:** Provider
- **Backend:** Firebase (Auth, Firestore, Storage)
- **Analytics:** xAPI (Custom Implementation over Firestore)

---

## ✨ Asosiy Imkoniyatlar

### 🎮 Gamification 2.0 (Gatekeeper Logic)
Biz shunchaki ball yig'ish tizimidan voz kechib, haqiqiy kompetensiyani baholash tizimini joriy qildik.

*   **XP (Experience Points):** Video ko'rish, test ishlash va maqola o'qish uchun beriladi.
*   **Gatekeeper (Darvoza) Mantiq:**
    *   *Specialist:* 200 XP.
    *   *Expert:* 800 XP + 5 ta Test + 3 ta A'lo (Perfect) natija.
    *   *Master:* 2000 XP + 3 ta Simulyatsiya + 7 kunlik uzluksiz kirish (Streak).

### 📊 Learning Analytics (xAPI)
Barcha o'quv faoliyatlari (Video ko'rish, Test ishlash) standart xAPI statement formatida saqlanadi. Bu ma'lumotlar keyinchalik sun'iy intellekt orqali tahlil qilinib, xodimga shaxsiy tavsiyalar berishda ishlatiladi.

---

## 🚀 O'rnatish va Ishga Tushirish

1. **Repository'ni klonlash:**
   ```bash
   git clone https://github.com/username/education_app.git
   ```

2. **Dependencies o'rnatish:**
   ```bash
   flutter pub get
   ```

3. **Ishga tushirish:**
   ```bash
   flutter run
   ```

---

## 🤖 Kelajak Rejalari (AI & Innovation)

Biz loyihani **"Aqlli Yordamchi"**ga aylantirish arafasidamiz:

- [ ] **On-Device AI (Gemma 2B):** Internet yo'q joyda ham sud xodimiga yuridik savollar bo'yicha maslahat beruvchi lokal model.
- [ ] **Automated Localization (TranslateGemma):** Yuridik terminologiyani aniq saqlagan holda 3 ta tilga avtomatik tarjima qilish.

---

<div align="center">

**Sud Qo'llanma** — Adolatli sud tizimi uchun raqamli kelajak.

</div>
