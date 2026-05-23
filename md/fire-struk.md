# Firestore Ma'lumotlar Strukturasi (Sud Qo'llanma)

Ushbu hujjat Flutter modellari va Python populate skriptlari bilan to'liq mos keladi.
Har bir maydon nomi Dart modeli (`fromJson`/`toJson`) bilan tekshirilgan.

---

## 1. Kurslar Tizimi

### `courses` (Kolleksiya)

| Maydon | Tur | Tavsif |
|--------|-----|--------|
| `title` | String | Kurs nomi |
| `description` | String | Qisqacha tavsif |
| `thumbnailUrl` | String? | Muqova rasmi (ixtiyoriy) |
| `targetRole` | Array\<String\> | `judge`, `assistant`, `chancellery`, `archive`, `ict_specialist` |
| `difficulty` | String | `beginner`, `intermediate`, `advanced` |
| `estimatedMinutes` | Number | Taxminiy vaqt (daqiqada) |
| `isPublished` | Boolean | Kurs faolligi |
| `authorId` | String | Muallif UID (yoki `"system"`) |
| `order` | Number | Ko'rsatish tartibi |
| `hasCertificate` | Boolean | Sertifikat beriladimi |
| `certificateTitle` | String? | Sertifikat sarlavhasi (ixtiyoriy) |
| `createdAt` | Timestamp | Yaratilgan vaqt |
| `updatedAt` | Timestamp | Yangilangan vaqt |
| `modules` | Array\<Map\> | Modullar ro'yxati (pastda) |

**`modules[]` ichidagi har bir Map:**

| Maydon | Tur | Tavsif |
|--------|-----|--------|
| `id` | String | UUID hex (20 belgi) |
| `title` | String | Modul nomi |
| `description` | String | Qisqacha tavsif |
| `order` | Number | Tartib raqami |
| `lessons` | Array\<Map\> | Darslar ro'yxati (pastda) |

**`lessons[]` ichidagi har bir Map:**

| Maydon | Tur | Tavsif |
|--------|-----|--------|
| `id` | String | UUID hex (20 belgi) |
| `title` | String | Dars nomi |
| `order` | Number | Tartib raqami |
| `type` | String | `video`, `article`, `pdf`, `quiz` |
| `refId` | String | Kontent kolleksiyasidagi hujjat ID si |
| `sourceCollection` | String | `video_tutorials`, `knowledge_base`, `resources`, `quizzes` |
| `estimatedMinutes` | Number? | Taxminiy vaqt (ixtiyoriy) |
| `isRequired` | Boolean | Ketma-ketlik uchun majburiy (`true` = keyingisi bloklanadi) |

> **Izoh:** `sourceCollection` maydonini `type` bo'yicha avtomatik aniqlash ham mavjud (fallback), lekin populate skriptlari uni doim yozadi.

---

## 2. Kontent Omborlari

### `video_tutorials` (Kolleksiya)

| Maydon | Tur | Tavsif |
|--------|-----|--------|
| `title` | String | Video nomi |
| `videoUrl` | String | Video havolasi (Storage yoki tashqi) |
| `storagePath` | String? | Firebase Storage yo'li |
| `systemId` | String | Tizim: `ESUD`, `EXAT`, `MS`, `EDO` va boshqalar |
| `order` | Number | Tartib (bir tizim ichida) |
| `duration` | Number? | Davomiylik (sekundlarda, `null` bo'lishi mumkin) |
| `description` | String? | Qo'shimcha tavsif |
| `thumbnailUrl` | String? | Muqova rasmi |
| `authorId` | String? | Muallif UID |
| `authorName` | String? | Muallif ismi |

### `knowledge_base` (Kolleksiya) — articles

| Maydon | Tur | Tavsif |
|--------|-----|--------|
| `title` | String | Maqola nomi |
| `content` | String | HTML yoki Markdown matn |
| `systemId` | String | Tizim ID si |
| `category` | String? | Kategoriya (`esud`, `security`, `exat`, `edo` va boshqalar) |

### `resources` (Kolleksiya) — PDF fayllar

| Maydon | Tur | Tavsif |
|--------|-----|--------|
| `title` | String | Fayl nomi |
| `description` | String? | Qisqacha tavsif |
| `type` | String | `pdf`, `doc`, `xls` va boshqalar |
| `fileUrl` | String | Yuklab olish havolasi |
| `storagePath` | String? | Firebase Storage yo'li |
| `systemId` | String? | Tizim ID si |

### `quizzes` (Kolleksiya)

| Maydon | Tur | Tavsif |
|--------|-----|--------|
| `title` | String | Test nomi |
| `description` | String | Test haqida |
| `resourceId` | String | Bog'liq resurs ID si |
| `questionCount` | Number | Savollar soni (kesh) |
| `category` | String? | Kategoriya (`esud`, `security` va boshqalar) |

**`quizzes/{quizId}/questions` (Sub-kolleksiya)** — savollar alohida saqlanadi:

| Maydon | Tur | Tavsif |
|--------|-----|--------|
| `questionText` | String | Savol matni |
| `questionType` | String | `multipleChoice`, `trueFalse` va boshqalar |
| `options` | Array\<String\> | Javob variantlari |
| `correctAnswer` | String | To'g'ri javob matni |

---

## 3. Foydalanuvchi va Progress

### `users` (Kolleksiya)

| Maydon | Tur | Tavsif |
|--------|-----|--------|
| `id` | String | Firebase Auth UID (hujjat ID si bilan bir xil) |
| `name` | String | To'liq ism |
| `email` | String? | Email manzili |
| `username` | String? | Foydalanuvchi nomi |
| `role` | String | `judge`, `assistant`, `chancellery`, `archive`, `ict_specialist`, `unknown` |
| `profilePictureUrl` | String? | Avatar havolasi |
| `bio` | String? | Qisqacha ma'lumot |
| `xp` | Number | To'plangan XP ballari |
| `level` | String | `levelBeginner`, `levelIntermediate`, `levelAdvanced`, `levelSpecialist`, `levelExpert`, `levelMaster` |
| `quizzesPassed` | Number | O'tilgan testlar soni |
| `totalQuizzesAced` | Number | 100% natija bilan topshirilgan testlar |
| `simulationsCompleted` | Number | Tugatilgan simulatsiyalar |
| `currentStreak` | Number | Joriy kunlik streak |
| `lastLoginDate` | Timestamp? | Streak hisoblash uchun |
| `registrationDate` | String (ISO) | Ro'yxatdan o'tgan sana |
| `lastLogin` | String (ISO) | Oxirgi kirish |
| `fastestQuizTime` | Number? | Eng tez test vaqti (sekundlarda) |
| `previousRank` | Number? | Avvalgi liderlik o'rni |
| `notificationsEnabled` | Boolean | Bildirishnoma sozlamasi |
| `regionId` | String? | Viloyat ID si |
| `regionName` | String? | Viloyat nomi |
| `courtTypeId` | String? | Sud turi ID si (`jib`, `fib`, `iqtisodiy`) |
| `courtTypeName` | String? | Sud turi nomi |
| `courtId` | String? | Sud ID si |
| `courtName` | String? | Sud nomi |
| `position` | String? | Lavozim |

**XP darajalari:**
- `levelBeginner`: 0–99 XP
- `levelIntermediate`: 100–499 XP
- `levelAdvanced`: 500–999 XP
- `levelSpecialist`: 1000–1999 XP
- `levelExpert`: 2000–4999 XP (+ ≥5 quiz topshirilgan, ≥3 ace)
- `levelMaster`: 5000+ XP (+ ≥3 simulatsiya, ≥7 kun streak)

### `user_course_progress` (Kolleksiya)

**Hujjat ID:** `{userId}_{courseId}`

| Maydon | Tur | Tavsif |
|--------|-----|--------|
| `userId` | String | Foydalanuvchi UID |
| `courseId` | String | Kurs hujjat ID si |
| `completedLessonIds` | Array\<String\> | Tugatilgan dars IDlari ro'yxati |
| `startedAt` | Timestamp | Boshlangan vaqt |
| `lastAccessedAt` | Timestamp | Oxirgi kirish vaqti |
| `completedAt` | Timestamp? | Tugatilgan vaqt (`null` = hali tugamagan) |
| `percentComplete` | Number | 0.0 – 100.0 |
| `earnedXp` | Number | Ushbu kursdan olingan XP |
| `totalRequiredLessons` | Number | Majburiy darslar soni (kurs boshlanishida yoziladi) |
| `certificateUrl` | String? | PDF sertifikat havolasi (tugaganda to'ldiriladi) |

---

## 4. Testlar va Natijalar

### `quiz_attempts` (Kolleksiya)

| Maydon | Tur | Tavsif |
|--------|-----|--------|
| `userId` | String | Foydalanuvchi UID |
| `quizId` | String | Test ID si |
| `quizTitle` | String | Test nomi (kesh) |
| `score` | Number | To'g'ri javoblar soni |
| `totalQuestions` | Number | Jami savollar soni |
| `attemptedAt` | Timestamp | Topshirilgan vaqt |
| `timeTakenSeconds` | Number? | Sarflangan vaqt |

---

## 5. Tizimli Ma'lumotlar

### `courts` (Kolleksiya)

| Maydon | Tur | Tavsif |
|--------|-----|--------|
| `courtName` | String | Sud nomi |
| `region` | String | Viloyat/Hudud |
| `courtType` | String | `fib`, `jib`, `iqtisodiy` va boshqalar |
| `isActive` | Boolean | Faollik holati |

### `certificates` (Kolleksiya)

**Hujjat ID:** `{userId}_{courseId}`

| Maydon | Tur | Tavsif |
|--------|-----|--------|
| `userId` | String | Foydalanuvchi UID |
| `courseId` | String | Kurs ID si |
| `userName` | String | Foydalanuvchi ismi |
| `courseTitle` | String | Kurs nomi |
| `pdfUrl` | String | Firebase Storage PDF havolasi |
| `issuedAt` | Timestamp | Sertifikat berilgan vaqt |

---

## 6. Boshqa Kolleksiyalar

### `news`
Dashboard uchun yangiliklar. Asosiy maydonlar: `title`, `content`, `imageUrl`, `publishedAt`, `isPublished`.

### `notifications`
Foydalanuvchilarga yuborilgan bildirishnomalar. Asosiy maydonlar: `userId`, `title`, `body`, `isRead`, `createdAt`, `type`.

### `faqs`
Ko'p beriladigan savollar. Asosiy maydonlar: `question`, `answer`, `category`, `order`.

### `community_topics`
Muhokama mavzulari. Asosiy maydonlar: `title`, `body`, `authorId`, `createdAt`, `likesCount`, `commentsCount`.

### `xapi_statements` (eski: `learning_records`)
xAPI format: `actor` (Map), `verb` (Map), `object` (Map), `timestamp`.

---

## 7. Kontent Turi → Kolleksiya Xaritasi

| `type` qiymati | `sourceCollection` | Flutter screen |
|----------------|-------------------|----------------|
| `video` | `video_tutorials` | `VideoPlayerScreen` (via `VideoEntity`) |
| `article` | `knowledge_base` | `LessonViewerScreen` (HTML/Markdown) |
| `pdf` | `resources` | `LessonViewerScreen` (URL launch) |
| `quiz` | `quizzes` | `QuizScreen(quizId: lesson.refId)` |

---

## 8. Python Populate Skriptlari

Skriptlar `D:\project_BMI\bot-bmi\sudqollanma_bot\` papkasida joylashgan.
Ishlatish tartibi:

```
1. python populate_videos.py        → video_tutorials
2. python populate_articles.py      → knowledge_base
3. python populate_files.py         → resources
4. python populate_quizzes.py       → quizzes
5. python populate_courses.py       → courses (real refId lar bilan)
```

`populate_courses.py` `ContentIndex` klassi orqali real Firestore doc IDlarini o'qib, kurs tuzilmasini quradi. `--dry-run` bayrog'i bilan preview ko'rish mumkin.
