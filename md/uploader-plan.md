# Sud Qo'llanma — Ma'lumot Arxitekturasi va Sinxronizatsiya Rejasi

> **Maqsad:** Flutter Admin Panel → Firestore → Telegram Bot zanjirini bir xil schema bilan ishlashini ta'minlash.

---

## 1. HOZIRGI HOLAT TAHLILI

### ✅ Flutter Admin Panel ekranlar (mavjud):
| Ekran | Kolleksiya | Status |
|---|---|---|
| `AdminFAQManagementScreen` | `faqs` | ✅ Bor, lekin schema xato |
| `AdminArticleManagementScreen` | `knowledge_base` | ✅ Bor |
| `AdminResourceManagementScreen` | `resources` | ✅ Bor |
| `AdminQuizManagementScreen` | `quizzes` | ✅ Bor |
| `AdminNewsManagementScreen` | `news` | ✅ Bor |
| `AdminVideoManagementScreen` | `video_tutorials` | ✅ Bor |
| `AdminSystemManagementScreen` | `systems` | ✅ Bor |
| `AdminUserListScreen` | `users` | ✅ Bor |
| ❌ YO'Q | `courts` | ❌ Yo'q — skript orqali yuklangan |

---

## 2. ASOSIY XATOLIKLAR

### 🔴 XATO 1: FAQ `category` field — Schema mos emas!

**Flutter `FaqCategory` enum → Firestore da saqlanadigan qiymat:**
```
FaqCategory.login     → "Kirish Muammolari"
FaqCategory.password  → "Parol Muammolari"
FaqCategory.upload    → "Fayl Yuklash"
FaqCategory.access    → "Ruxsat"
FaqCategory.general   → "Umumiy"
FaqCategory.technical → "Texnik"
```

**Hozirgi Firestore faqs dokumentlar:** ✅ `"Parol Muammolari"`, `"Ruxsat"` va h.k. — Flutter bilan mos.

**Bot `kb_articles.py` da FAQ qidiruv:** ❌
```python
# Xato: bot "esud", "exat" qidiradi — Firestore da "Parol Muammolari" bor!
CATEGORY_NAMES = {"esud": "E-SUD", "exat": "E-XAT", "edo": "EDO", ...}
ref.where('category', '==', 'esud')  # hech narsa topilmaydi!
```

### 🟡 XATO 2: `shortAnswer` va `systemId` Admin ekranida yo'q

`admin_add_edit_faq_screen.dart` faqat `question`, `answer`, `category` kiritadi.
`shortAnswer` va `systemId` — bot uchun muhim maydonlar — kiritilmaydi.

---

## 3. KELISHILGAN SCHEMA (Yagona Standart)

### `faqs` kolleksiyasi
```
question:     string
answer:       string (batafsil)
shortAnswer:  string (bot uchun qisqa versiya)
category:     "Kirish Muammolari" | "Parol Muammolari" | "Fayl Yuklash"
              | "Ruxsat" | "Umumiy" | "Texnik"
systemId:     "ESUD" | "EXAT" | "EDO" | "EIMZO" | "MYSUD" | "VKS" | "Umumiy"
tags:         string[]
relatedSteps: string[]
difficulty:   "boshlang'ich" | "o'rta" | "murakkab"
order:        int
isActive:     bool
viewCount:    int
```

### `knowledge_base` kolleksiyasi
```
title:       string
content:     string (AI RAG uchun to'liq matn)
description: string
category:    "esud" | "exat" | "edo" | "mysud" | "general" | "system"
systemId:    "ESUD" | "EXAT" | "EDO" | "EIMZO" | "MYSUD"
pdfUrl:      string?
tags:        string[]
isActive:    bool
```

### `resources` kolleksiyasi
```
title:       string
description: string
url:         string (Firebase Storage PDF)
type:        "esud" | "exat" | "edo" | "eimzo" | "mysud" | "vks" | "other"
isActive:    bool
```

---

## 4. AMALGA OSHIRILISHI KERAK BO'LGAN O'ZGARISHLAR

### QADAM A — Bot (tezkor tuzatish)

**`handlers/kb_articles.py`** — ikki alohida kategoriya lug'ati:
```python
# FAQ uchun (Firestore da saqlangan qiymatlar bilan mos):
FAQ_CATEGORY_NAMES = {
    "Kirish Muammolari":  "🔐 Kirish Muammolari",
    "Parol Muammolari":   "🔑 Parol Muammolari",
    "Fayl Yuklash":       "📤 Fayl Yuklash",
    "Ruxsat":             "🚫 Ruxsat muammolari",
    "Umumiy":             "❓ Umumiy savollar",
    "Texnik":             "🔧 Texnik muammolar",
}

# Knowledge Base uchun (alohida):
KB_CATEGORY_NAMES = {
    "esud": "🖥 E-SUD tizimi",
    "exat": "📧 E-XAT tizimi",
    "edo":  "📤 EDO tizimi",
    "mysud": "🌐 MY.SUD.UZ",
    "general": "💻 Umumiy IT",
}
```

**`/faq` yangi flow** — 2 darajali filter:
```
/faq → Tizim: [ESUD] [EXAT] [EDO] [Barchasi]
     → Kategoriya: [Kirish] [Parol] [Texnik] [Barchasi]
     → Natijalar (shortAnswer ko'rsatiladi)
```

### QADAM B — Flutter Admin Panel

**`admin_add_edit_faq_screen.dart`** ga qo'shiladigan maydonlar:
1. `shortAnswer` — TextFormField (max 2 qator)
2. `systemId` — DropdownButtonFormField (`ESUD`, `EXAT`, `EDO`, `EIMZO`, `MYSUD`, `VKS`, `Umumiy`)
3. `difficulty` — DropdownButtonFormField (`boshlang'ich`, `o'rta`, `murakkab`)
4. `isActive` — Switch/Checkbox
5. `order` — NumberField

**`faq_entity.dart`** — `fromMap` va `toMap` da yangi maydonlar qo'shish.

---

## 5. YANGI FAQ BOT FLOW

```
/faq yoki ❓ FAQ  
    ↓
[🖥 E-SUD]  [📧 E-XAT]  [📤 EDO]
[🔐 E-IMZO] [🌐 MY.SUD] [📋 Barchasi]
    ↓ (systemId filter)
[🔐 Kirish] [🔑 Parol] [📤 Yuklash]
[🚫 Ruxsat] [🔧 Texnik] [❓ Barchasi]
    ↓ (category filter)
Natijalar ro'yxati (shortAnswer ko'rsatiladi)
```

---

## 6. BAJARISH TARTIBI

### 🔴 Birinchi — Bot tuzatish (deploy zarur):
- [ ] `kb_articles.py` — `FAQ_CATEGORY_NAMES` alohida lug'at
- [ ] `kb_articles.py` — `systemId` bo'yicha 1-darajali filter inline keyboard
- [ ] `kb_articles.py` — `category` bo'yicha 2-darajali filter
- [ ] `shortAnswer` field ko'rsatish (agar mavjud bo'lsa)
- [ ] Deploy → test

### 🟡 Ikkinchi — Flutter Admin tuzatish:
- [ ] `admin_add_edit_faq_screen.dart` — `shortAnswer` maydoni
- [ ] `admin_add_edit_faq_screen.dart` — `systemId` dropdown
- [ ] `admin_add_edit_faq_screen.dart` — `difficulty` dropdown
- [ ] `admin_add_edit_faq_screen.dart` — `isActive` toggle
- [ ] `faq_entity.dart` — yangi maydonlar + copyWith

### 🟢 Uchinchi — Qo'shimcha:
- [ ] Mavjud `faqs` dokumentlarga `systemId` qo'shish (batch update skripti)
- [ ] Admin panelga `courts` boshqarish qo'shish

---

## 7. TEKSHIRISH MEZONLARI

| Test | Kutilgan natija |
|---|---|
| Bot `/faq` → `EDO` tanlang | systemId=EDO FAQ'lar chiqadi |
| Bot `/faq` → `EDO` → `Parol` | EDO + "Parol Muammolari" FAQ chiqadi |
| Flutter Admin → FAQ qo'shish | shortAnswer, systemId, isActive bilan saqlanadi |
| Bot `/maqolalar` → `E-SUD` | category="esud" knowledge_base maqolalari chiqadi |

---

> [!IMPORTANT]
> **Bot tuzatishi prioritet #1** — FAQ hozircha bo'shliq qaytaradi chunki kategoriyalar mos emas.
> Flutter tuzatishi #2, u orqali admin yangi standart schema bilan ma'lumot kirita oladi.
