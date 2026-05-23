# To'liq Prompt: "Kurslar" funksiyasi uchun

## PROMPT

> **Loyiha konteksti:**
> Bu Flutter ilovasi — O'zbekiston sud tizimi xodimlariga mo'ljallangan raqamli kompetentlik platformasi. Ilova allaqachon ishlaydi: `LibraryProvider` orqali **maqolalar** (`knowledge_base`), **videolar** (`video_tutorials`), **resurslar/PDFlar** (`resources`) Firestore'dan olinadi; **Quiz** tizimi alohida mavjud (`QuizProvider`, `quiz` kolleksiyasi); **xAPI** va **gamifikatsiya** (XP, ball) ham ulangan.
>
> **Muammo:** Hozir bu kontentlar bir-biridan ajralgan holda turadi. Foydalanuvchi qayerdan boshlashini, nima o'rganganini, qancha qolganini bilmaydi.
>
> **Maqsad:** Mavjud kontentlarni (videolar + PDFlar + quizlar) **ketma-ket, progress kuzatiladigan kurs formatiga** birlashtirish. Yangi kontent yaratilmaydi — mavjud `video_tutorials`, `resources`, `knowledge_base` va `quiz` kolleksiyalaridan foydalaniladi.

---

> **Yaratilishi kerak bo'lgan to'liq feature: `lib/features/courses/`**

---

### DOMAIN LAYER

**`CourseEntity`** — kursning asosiy modeli:
```
id, title, description, thumbnailUrl,
targetRole (List<String>: 'judge', 'ict_specialist', 'clerk'...),
difficulty ('beginner' | 'intermediate' | 'advanced'),
estimatedMinutes (int),
modules (List<CourseModuleEntity>),
isPublished (bool),
createdAt, updatedAt, authorId, order (int — tartib uchun)
```

**`CourseModuleEntity`** — kurs ichidagi bo'lim:
```
id, title, description, order (int),
lessons (List<CourseLessonEntity>)
```

**`CourseLessonEntity`** — dars (mavjud kontentga ko'rsatkich):
```
id, title, order (int),
type ('video' | 'article' | 'pdf' | 'quiz'),
refId (String — Firestore'dagi haqiqiy document ID),
durationMinutes (int, ixtiyoriy),
isRequired (bool — progressga hisoblanadimi)
```

**`UserCourseProgressEntity`** — foydalanuvchi progressi:
```
userId, courseId,
completedLessonIds (List<String>),
startedAt (DateTime),
lastAccessedAt (DateTime),
completedAt (DateTime?),
percentComplete (double — 0.0 dan 1.0 gacha),
earnedXp (int)
```

**`CourseRepository`** (abstract interfeys):
```dart
// Kurslar
Future<List<CourseEntity>> getCourses({String? roleFilter, String? difficulty});
Stream<List<CourseEntity>> watchCourses();
Future<CourseEntity?> getCourseById(String id);
Future<String> createCourse(CourseEntity course);
Future<void> updateCourse(CourseEntity course);
Future<void> deleteCourse(String courseId);

// Progress
Future<UserCourseProgressEntity?> getUserProgress(String userId, String courseId);
Stream<List<UserCourseProgressEntity>> watchUserAllProgress(String userId);
Future<void> markLessonComplete(String userId, String courseId, String lessonId, String lessonType);
Future<void> startCourse(String userId, String courseId);
```

---

### DATA LAYER

**Firestore kolleksiyalari (yangi):**

1. **`courses`** — kurslar:
```
courses/{courseId}
  title, description, thumbnailUrl,
  targetRole: ['judge', 'ict_specialist'],
  difficulty: 'beginner',
  estimatedMinutes: 45,
  isPublished: true,
  order: 1,
  authorId, createdAt, updatedAt,
  modules: [   ← subcollection emas, embedded array (soddalik uchun)
    {
      id, title, description, order,
      lessons: [
        { id, title, order, type: 'video', refId: 'video_tutorials/xxxx', isRequired: true, durationMinutes: 10 },
        { id, title, order, type: 'pdf',   refId: 'resources/yyyy',        isRequired: true },
        { id, title, order, type: 'quiz',  refId: 'quiz/zzzz',             isRequired: true }
      ]
    }
  ]
```

2. **`user_course_progress`** — progress:
```
user_course_progress/{userId}_{courseId}
  userId, courseId,
  completedLessonIds: ['lessonId1', 'lessonId2'],
  startedAt, lastAccessedAt, completedAt (null yoki timestamp),
  percentComplete: 0.6,
  earnedXp: 30
```

**`CourseRemoteSource`** — Firestore CRUD + progress yozish

**`CourseRepositoryImpl`:**
- `markLessonComplete()` ichida:
  1. `completedLessonIds` ga lessonId qo'shiladi
  2. `percentComplete` qayta hisoblanadi: `completedRequired / totalRequired`
  3. Agar 100% bo'lsa → `completedAt` yoziladi + xAPI `completed` statement + **50 XP** gamifikatsiya
  4. Aks holda → xAPI `progressed` statement
  5. `SearchIndexer` ga kurs nomini indeksga qo'shadi (global qidiruv uchun)

---

### PRESENTATION LAYER

**`CourseProvider`** (ChangeNotifier):
```dart
List<CourseEntity> _courses
Map<String, UserCourseProgressEntity> _progressMap  // courseId → progress
bool _isLoading
String? _error

// Metodlar
loadCourses({String? roleFilter})
watchCourses()
getUserProgress(String courseId)   // _progressMap dan o'qiydi
startCourse(String courseId)
markLessonComplete(String courseId, String lessonId, String lessonType)
createCourse(CourseEntity)         // admin/expert
updateCourse(CourseEntity)
deleteCourse(String id)
```

---

### EKRANLAR

#### 1. `CoursesListScreen` — kurslar katalogi
- `AppBar`: "Kurslar" + filter icon
- Yuqorida **filter chips**: `Hammasi | Boshlang'ich | O'rta | Yuqori`
- Agar foydalanuvchi rolida mos kurslar bo'lsa — **"Siz uchun tavsiya"** section (horizontal scroll)
- Qolgan kurslar vertikal ro'yxat
- Har bir karta (`CourseCard`):
  - Thumbnail + title + difficulty badge + `estimatedMinutes`
  - **Progress bar** (0% boshlangan bo'lmasa, aks holda `percentComplete`)
  - "Boshlash" / "Davom etish" / "✓ Tugallangan" holat tugmasi
- FAB: faqat `judge`/`ict_specialist` rolida ko'rinadi → `CreateCourseScreen`

#### 2. `CourseDetailScreen` — kurs sahifasi
Qabul qiladi: `CourseEntity course`

Tuzilmasi:
```
Hero image (thumbnailUrl)
Title + difficulty + estimatedMinutes
Description
"Boshlash" / "Davom etish" tugmasi (katta, primary color)
──────────────────────────────
Umumiy progress: CircularProgressIndicator + "X / Y dars"
──────────────────────────────
Modullar ro'yxati (ExpansionTile):
  ▶ 1-bo'lim: "Tizimga kirish"
      □ Dars 1 — [VIDEO] "eSud tizimiga kirish" (10 min) ✓
      □ Dars 2 — [PDF]   "Qo'llanma: bosqichlar"         ✓
      □ Dars 3 — [QUIZ]  "Bilimni tekshirish"             ○
  ▶ 2-bo'lim: "Amaliyot"
      □ Dars 4 — [VIDEO] "..."                             🔒 (oldingi tugallanmagan)
```

- Har bir dars qatori bosilganda:
  - `type == 'video'` → `VideoPlayerScreen` push (mavjud)
  - `type == 'article'` → `ArticleDetailScreen` push (mavjud)
  - `type == 'pdf'` → `ResourceDetailScreen` push (mavjud)
  - `type == 'quiz'` → `QuizScreen` push (mavjud)
  - **Qaytganda** (`Navigator.pop` dan keyin) → `markLessonComplete()` chaqiriladi

- **Lock logikasi:** `isRequired == true` bo'lgan oldingi dars tugallanmagan bo'lsa → keyingi dars `🔒` ikonka bilan, bosilganda snackbar: *"Avval oldingi darsni tugallang"*

#### 3. `CreateCourseScreen` / `EditCourseScreen`
**Maydonlar:**
- Title (text field)
- Description (multiline)
- Thumbnail URL (text field + preview)
- Target roles (MultiSelect chips: judge, ict_specialist, clerk, admin)
- Difficulty (DropdownButton)
- Estimated minutes (number field)
- `isPublished` (Switch)
- **Modullar quruvchisi** (asosiy qism):
  - "＋ Bo'lim qo'shish" tugmasi
  - Har bir bo'lim: title + "＋ Dars qo'shish"
  - Dars qo'shish dialogi:
    - Type tanlash (video/article/pdf/quiz) — DropdownButton
    - Mos `LibraryProvider`/`QuizProvider` dan ro'yxat — SearchableDropdown
    - Title (auto-fill from selected content)
    - `isRequired` checkbox
  - Modullar va darslar `ReorderableListView` bilan qayta tartiblanadi

#### 4. `MyCoursesDashboard` (widget yoki alohida ekran)
- Foydalanuvchining **barcha boshlangan kurslari** progressi
- Har biri: LinearProgressIndicator + "X% tugallangan" + "Davom etish" tugmasi
- `HomeDashboardScreen` da ham chiqarish uchun `Consumer<CourseProvider>` widget sifatida eksport

---

### BOG'LIQLIKLAR VA INTEGRATSIYA

**`main.dart` da ro'yxatga olish:**
```dart
Provider<CourseRepository>(
  create: (_) => CourseRepositoryImpl()
),
ChangeNotifierProvider<CourseProvider>(
  create: (context) => CourseProvider(
    repository: context.read<CourseRepository>()
  )
),
```

**`ResourcesScreen` (mavjud) ga qo'shish:**
- `DefaultTabController` length `4 → 5`
- Tab 4: `CoursesListScreen` — "Kurslar"

**`HomeDashboardScreen` da:**
- `MyCoursesDashboard` widget qo'shiladi (progress ko'rinishi)

**`global_search_screen.dart` da:**
- `CourseProvider.searchCourses(query)` metodi qo'shiladi
- `SearchIndexer` kurslarni `search_index` ga yozadi

**`notifications_screen.dart` da:**
- Kurs tugallanganda avtomatik notification (`completedAt` o'zgarsa)

---

### xAPI STATEMENTS (mavjud LogXApiStatement use case orqali)

| Hodisa | Verb | Object |
|---|---|---|
| Kursni boshlash | `initialized` | `course/{courseId}` |
| Darsni ko'rish | `experienced` | `lesson/{lessonId}` |
| Darsni tugatish | `completed` | `lesson/{lessonId}` |
| Kursni 100% tugatish | `completed` | `course/{courseId}` |
| Progress yangilanishi | `progressed` | `course/{courseId}` |

---

### GAMIFIKATSIYA (mavjud tizim orqali)

| Hodisa | XP |
|---|---|
| Har bir dars tugallansa | +10 XP |
| Quiz dars tugallansa | +15 XP |
| Kurs to'liq tugallansa | +50 XP bonusi |

---

### TEXNIK TALABLAR

1. **Clean Architecture** — mavjud loyiha strukturasiga to'liq mos (domain/data/presentation)
2. **Mavjud provayderlardan foydalanish** — `LibraryProvider`, `QuizProvider`, `AuthNotifier` import qilinadi, dublikat yozilmaydi
3. **`refId` orqali lazy loading** — dars ochilgandagina mos ekran chaqiriladi, kurs yuklanishida barcha videoUrl/pdfUrl yuklanmaydi
4. **Offline-friendly** — progress `SharedPreferences` da ham cache qilinadi (internet yo'q bo'lganda oxirgi holat ko'rinadi)
5. **Rol asosida filter** — `CourseEntity.targetRole` va `AuthNotifier` dagi joriy rol taqqoslanadi
6. **Firestore security rules** — `user_course_progress` faqat `userId == request.auth.uid` bo'lganda yoziladi

---

### FAYL DARAXTI (yaratilishi kerak)

```
lib/features/courses/
├── domain/
│   ├── entities/
│   │   ├── course_entity.dart
│   │   ├── course_module_entity.dart
│   │   ├── course_lesson_entity.dart
│   │   └── user_course_progress_entity.dart
│   └── repositories/
│       └── course_repository.dart
├── data/
│   ├── datasources/
│   │   └── course_remote_source.dart
│   ├── models/
│   │   ├── course_model.dart
│   │   ├── course_module_model.dart
│   │   ├── course_lesson_model.dart
│   │   └── user_course_progress_model.dart
│   └── repositories/
│       └── course_repository_impl.dart
└── presentation/
    ├── providers/
    │   └── course_provider.dart
    ├── widgets/
    │   ├── course_card.dart
    │   ├── lesson_tile.dart
    │   ├── module_expansion_tile.dart
    │   └── my_courses_dashboard.dart
    └── screens/
        ├── courses_list_screen.dart
        ├── course_detail_screen.dart
        ├── create_course_screen.dart
        └── edit_course_screen.dart
```

---

# 🎨 FLUTTER UI PROMPT — Kurslar Ekrani (Premium Design)

---

## UMUMIY DIZAYN TILI

```
Ranglar sxemasi (sudlov tizimiga mos, professional):
  Primary:     #1A3C6E  (to'q ko'k — davlat rangiga mos)
  Accent:      #2DD4BF  (teal — zamonaviy, energik)
  Gold:        #F59E0B  (yulduz, progress — oltin rang)
  Success:     #10B981  (tugallangan — yashil)
  Card BG:     #FFFFFF
  Background:  #F0F4F8  (och kulrang-ko'k)
  Text Primary:#1E293B
  Text Sub:    #64748B

Tipografiya:
  Title:    FontWeight.w700, 20sp
  Subtitle: FontWeight.w600, 15sp
  Body:     FontWeight.w400, 13sp
  Font:     'Nunito' yoki 'Inter' (Google Fonts)

Border Radius: 16–20px (katta, yumshoq)
Elevation:    Card shadow — offset(0,4), blur 16, color black.08
```

---

## 1. `CoursesListScreen` — Asosiy ro'yxat ekrani

### AppBar
```dart
// Shaffof gradient AppBar
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF1A3C6E), Color(0xFF2563EB)],
      begin: Alignment.topLeft, end: Alignment.bottomRight
    )
  ),
  child: AppBar(
    backgroundColor: Colors.transparent,
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Xush kelibsiz, [Ism]", style: TextStyle(fontSize:12, color: Colors.white70)),
        Text("Kurslar", style: TextStyle(fontSize:20, fontWeight:FontWeight.w700, color:Colors.white)),
      ]
    ),
    actions: [
      // Animatsion notification qo'ng'iroq
      AnimatedBell(),           // lottie animatsiyasi — chayqaladigan qo'ng'iroq
      // Foydalanuvchi avatari
      CircleAvatar(radius: 18), // initials yoki photo
    ]
  )
)
```

### Search Bar (AppBar pastida, oq karta sifatida)
```dart
// Shimmer effekti bilan search (yuklanayotganda)
Container(
  margin: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: Offset(0,4))]
  ),
  child: TextField(
    decoration: InputDecoration(
      hintText: "Kurs qidiring...",
      prefixIcon: Icon(Icons.search, color: Color(0xFF2DD4BF)),
      suffixIcon: AnimatedFilterIcon(), // filter chiqsa rang o'zgaradi
      border: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(vertical:14)
    )
  )
)
```

### Stats Banner (qidiruv ostida — foydalanuvchi progressi)
```dart
// Gradient banner — screenshot'dagi kabi
Container(
  margin: EdgeInsets.symmetric(horizontal:16),
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    gradient: LinearGradient(colors:[Color(0xFF2DD4BF), Color(0xFF0EA5E9)]),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      StatItem(icon: Icons.play_circle, label: "Kurslar", value: "12"),
      VerticalDivider(color: Colors.white38),
      StatItem(icon: Icons.check_circle, label: "Tugallangan", value: "4"),
      VerticalDivider(color: Colors.white38),
      StatItem(icon: Icons.star, label: "XP ball", value: "320"),
    ]
  )
)
// ⚡ Animatsiya: SlideInDown + FadeIn — ekran ochilganda
```

### Tab Bar (All | Tugallangan | Davom etayotgan)
```dart
// Screenshot'dagi kabi custom animated tab
// Tanlangan tab: to'q ko'k background + oq text + pastida accent line
// O'tilgan tab: oddiy text + animatsiyali underline (AnimatedContainer)
DefaultTabController(
  length: 3,
  child: TabBar(
    indicator: BoxDecoration(
      borderRadius: BorderRadius.circular(25),
      color: Color(0xFF1A3C6E),
    ),
    indicatorSize: TabBarIndicatorSize.tab,
    labelColor: Colors.white,
    unselectedLabelColor: Color(0xFF64748B),
    tabs: [
      Tab(text: "Barchasi"),
      Tab(text: "✓ Tugallangan"),
      Tab(text: "▶ Davom etayotgan"),
    ]
  )
)
```

### Kurs kartasi — `CourseCard` widget
```dart
// Screenshot'dagi kabi gorizontal karta
// ⚡ Animatsiya: staggered list animation — har karta 50ms kechikib pastdan chiqadi

AnimatedCourseCard(
  index: index, // stagger delay uchun
  child: Container(
    margin: EdgeInsets.symmetric(horizontal:16, vertical:8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 16, offset: Offset(0,4))]
    ),
    child: Row(
      children: [
        // Thumbnail — chapda, qiyshiq clip bilan
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
          child: Stack(
            children: [
              CachedNetworkImage(width:110, height:110, fit:BoxFit.cover),
              // Difficulty badge — thumbnail ustida
              Positioned(
                top:8, left:8,
                child: DifficultyBadge(level: course.difficulty), // rang kodlanadi
              ),
            ]
          )
        ),
        // Kontent — o'ngda
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type icon qatori: VIDEO | PDF | QUIZ counts
                Row(children:[
                  TypeChip(icon: Icons.play_circle_outline, count: videoCount, color: Colors.blue),
                  TypeChip(icon: Icons.picture_as_pdf, count: pdfCount, color: Colors.red),
                  TypeChip(icon: Icons.quiz_outlined, count: quizCount, color: Colors.orange),
                ]),
                SizedBox(height:4),
                Text(course.title, style: TextStyle(fontWeight:FontWeight.w700, fontSize:14)),
                SizedBox(height:4),
                // Vaqt + darslar soni — screenshot'dagi kabi
                Row(children:[
                  Icon(Icons.schedule, size:12, color:Color(0xFF64748B)),
                  Text(" ${course.estimatedMinutes} min", style: TextStyle(fontSize:12, color:Color(0xFF64748B))),
                  SizedBox(width:8),
                  Icon(Icons.layers_outlined, size:12, color:Color(0xFF64748B)),
                  Text(" ${lessonCount} dars", style: TextStyle(fontSize:12, color:Color(0xFF64748B))),
                ]),
                SizedBox(height:8),
                // Progress bar — animatsiyali
                // ⚡ Animatsiya: TweenAnimationBuilder — 0'dan haqiqiy qiymatga
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, __) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: value,
                          minHeight: 6,
                          backgroundColor: Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation(
                            value == 1.0 ? Color(0xFF10B981) : Color(0xFF2DD4BF)
                          ),
                        )
                      ),
                      SizedBox(height:4),
                      Text("${(value*100).toInt()}% tugallangan",
                        style: TextStyle(fontSize:11, color: value==1.0 ? Color(0xFF10B981) : Color(0xFF64748B))
                      ),
                    ]
                  )
                ),
              ]
            )
          )
        ),
        // O'ng tomon: holat tugmasi
        Padding(
          padding: EdgeInsets.only(right:12),
          child: CourseStatusButton(status: courseStatus), // Boshlash / Davom / ✓
        )
      ]
    )
  )
)
```

---

## 2. `CourseDetailScreen` — Kurs ichki ekrani

### Hero header
```dart
// ⚡ Hero animatsiya — list'dan detail'ga o'tishda rasm kengayadi
Hero(
  tag: 'course_${course.id}',
  child: Stack(
    children: [
      // Blur gradient overlay
      CachedNetworkImage(height: 240, fit: BoxFit.cover),
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)]
          )
        )
      ),
      // Pastda: title + badges
      Positioned(
        bottom: 16, left: 16, right: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children:[
              DifficultyBadge(),
              SizedBox(width:8),
              TargetRoleBadge(), // "Sudyalar uchun"
            ]),
            SizedBox(height:8),
            Text(course.title, style: TextStyle(color:Colors.white, fontSize:22, fontWeight:FontWeight.w800)),
            SizedBox(height:4),
            Row(children:[
              Icon(Icons.schedule, color:Colors.white70, size:14),
              Text("  ${course.estimatedMinutes} daqiqa", style:TextStyle(color:Colors.white70, fontSize:13)),
              SizedBox(width:12),
              Icon(Icons.layers, color:Colors.white70, size:14),
              Text("  ${totalLessons} dars", style:TextStyle(color:Colors.white70, fontSize:13)),
            ])
          ]
        )
      )
    ]
  )
)
```

### Sticky progress panel (scroll qilganda yuqorida qoladi)
```dart
// Yopishqoq panel — SliverPersistentHeader
Container(
  padding: EdgeInsets.all(16),
  color: Colors.white,
  child: Column(children:[
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
      Text("Umumiy progress", style: TextStyle(fontWeight:FontWeight.w600)),
      Text("${completedCount}/${totalCount} dars", style: TextStyle(color: Color(0xFF2DD4BF), fontWeight:FontWeight.w700)),
    ]),
    SizedBox(height:8),
    // ⚡ Animatsiyali yog'och progress bar
    TweenAnimationBuilder<double>(
      tween: Tween(begin:0, end: progress),
      duration: Duration(milliseconds:1000),
      curve: Curves.easeOutCubic,
      builder: (_,val,__) => Stack(
        children:[
          Container(height:12, decoration: BoxDecoration(color:Color(0xFFE2E8F0), borderRadius:BorderRadius.circular(10))),
          FractionallySizedBox(
            widthFactor: val,
            child: Container(
              height:12,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors:[Color(0xFF2DD4BF), Color(0xFF0EA5E9)]),
                borderRadius: BorderRadius.circular(10),
              )
            )
          ),
        ]
      )
    ),
    SizedBox(height:12),
    // Boshlash / Davom etish tugmasi
    SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(progress == 0 ? Icons.rocket_launch : Icons.play_arrow),
        label: Text(progress == 0 ? "Kursni boshlash" : "Davom etish"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF1A3C6E),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical:14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () => _navigateToNextLesson(),
      )
    )
  ])
)
```

### Modullar ro'yxati (`ExpansionTile` custom)
```dart
// ⚡ Animatsiya: modul ochilganda darslar pastdan chiqadi (AnimatedList)
CustomExpansionTile(
  leading: CircleAvatar(
    radius: 16,
    backgroundColor: isModuleComplete ? Color(0xFF10B981) : Color(0xFF1A3C6E).withOpacity(0.1),
    child: isModuleComplete
      ? Icon(Icons.check, color:Colors.white, size:16)
      : Text("${moduleIndex+1}", style:TextStyle(color:Color(0xFF1A3C6E), fontWeight:FontWeight.w700)),
  ),
  title: Text(module.title, style: TextStyle(fontWeight:FontWeight.w700)),
  subtitle: Text("${module.lessons.length} dars • ${moduleMinutes} min"),
  // Dars qatorlari:
  children: module.lessons.map((lesson) => LessonTile(lesson: lesson)).toList()
)
```

### `LessonTile` — dars qatori
```dart
// ⚡ Animatsiya: tugallanganda checkmark animatsiyali paydo bo'ladi (Lottie)
ListTile(
  contentPadding: EdgeInsets.symmetric(horizontal:16, vertical:4),
  leading: AnimatedLessonIcon(
    type: lesson.type,    // har tip uchun rang va ikonka:
    // video  → 🔵 Icons.play_circle_filled  (ko'k)
    // pdf    → 🔴 Icons.picture_as_pdf      (qizil)
    // article→ 🟢 Icons.article_outlined    (yashil)
    // quiz   → 🟠 Icons.quiz               (to'q sariq)
    isCompleted: isCompleted,
    isLocked: isLocked,
  ),
  title: Text(lesson.title,
    style: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 13,
      color: isLocked ? Color(0xFFCBD5E1) : Color(0xFF1E293B), // lock bo'lsa kulrang
    )
  ),
  subtitle: Row(children:[
    if(lesson.durationMinutes != null) ...[
      Icon(Icons.schedule, size:11, color:Color(0xFF94A3B8)),
      Text(" ${lesson.durationMinutes} min", style:TextStyle(fontSize:11, color:Color(0xFF94A3B8))),
    ],
    if(lesson.type == 'quiz') ...[
      SizedBox(width:8),
      Container(
        padding: EdgeInsets.symmetric(horizontal:6, vertical:2),
        decoration: BoxDecoration(color:Color(0xFFFEF3C7), borderRadius:BorderRadius.circular(6)),
        child: Text("+15 XP", style:TextStyle(fontSize:10, color:Color(0xFFF59E0B), fontWeight:FontWeight.w700))
      )
    ]
  ]),
  trailing: isLocked
    ? Icon(Icons.lock_outline, color:Color(0xFFCBD5E1), size:18)
    : isCompleted
      ? LottieCheckmark()  // Lottie animatsiyali ✓
      : Icon(Icons.chevron_right, color:Color(0xFF94A3B8)),
  onTap: isLocked ? () => _showLockedSnackbar() : () => _openLesson(lesson),
)
```

---

## 3. ANIMATSIYALAR TO'PLAMI

### A) Staggered List Animation
```dart
// Kurslar ro'yxati ochilganda — har karta navbatma-navbat pastdan chiqadi
class AnimatedCourseCard extends StatelessWidget {
  final int index;
  final Widget child;
  // delay = index * 80ms
  // SlideTransition (pastdan) + FadeTransition birlashtiriladi
  // AnimationController + CurvedAnimation(Curves.easeOutBack)
}
```

### B) Progress Bar Animation (TweenAnimationBuilder)
```dart
// Ekran ochilganda progress 0'dan haqiqiy qiymatga silliq o'sadi
// Duration: 800ms, Curve: Curves.easeOutCubic
```

### C) Lesson Complete Celebration
```dart
// Dars tugallanganda:
// 1. Lottie confetti (0.5 soniya)
// 2. SnackBar: "+10 XP olindi! 🎉" (gradient background)
// 3. LessonTile trailing → checkmark Lottie
// 4. Progress bar silliq o'sadi
```

### D) AnimatedBell (Notification ikonka)
```dart
// Lottie yoki custom Animation:
// Har 5 soniyada bir marta chayqaladi (shake)
// Bildirishnoma bo'lsa — qizil badge paydo bo'ladi (ScaleTransition)
```

### E) Tab Switch Animation
```dart
// Tab o'zgarganda content: FadeTransition + SlideTransition (horizontal)
// PageView controller bilan bog'langan
```

### F) Shimmer Loading
```dart
// Ma'lumotlar yuklanayotganda karta skeleton shimmer effekti
// shimmer package yoki custom CustomPainter
```

### G) Pull-to-Refresh custom
```dart
// RefreshIndicator o'rniga custom:
// Sudya bolg'asi animatsiyasi (🔨) yoki LottieRefresh
// Colors: primary gradient
```

### H) Floating XP Toast
```dart
// Har dars tugallanganda ekranning yuqorisidan pastga tushadi:
// "+10 XP ⚡" — sariq gradient karta, 2 soniyada yo'qoladi
// OverlayEntry bilan implement qilinadi
```

---

## 4. `DifficultyBadge` va `TypeChip` widgetlari

```dart
// DifficultyBadge
// beginner    → 🟢 yashil  "Boshlang'ich"
// intermediate→ 🟡 sariq   "O'rta"
// advanced    → 🔴 qizil   "Yuqori"

Container(
  padding: EdgeInsets.symmetric(horizontal:8, vertical:3),
  decoration: BoxDecoration(
    color: color.withOpacity(0.15),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: color.withOpacity(0.4))
  ),
  child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700))
)

// TypeChip — video/pdf/quiz soni
Row(children:[
  Icon(icon, size:12, color:color),
  Text(" $count", style:TextStyle(fontSize:11, color:color))
])
```

---

## 5. `MyCoursesDashboard` widget (Home ekranida)

```dart
// Horizontal scroll — screenshot'dagi popular courses bilan bir xil
// Har karta: 200px keng, gradient background
// Ustida: kurs nomi + progress %
// Pastida: "Davom etish →" tugmasi

Column(children:[
  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
    Text("Mening kurslarim", style: TextStyle(fontSize:17, fontWeight:FontWeight.w700)),
    TextButton(child: Text("Barchasi"), onPressed: () => navigateToCourses()),
  ]),
  SizedBox(
    height: 160,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemBuilder: (_,i) => MiniCourseCard(course: courses[i], progress: progressMap[courses[i].id]),
    )
  )
])
```

---

## 6. PACKAGE'LAR RO'YXATI

```yaml
dependencies:
  lottie: ^3.0.0              # Animatsion ikonkalar (bell, confetti, check)
  shimmer: ^3.0.0             # Skeleton loading
  cached_network_image: ...   # Kurs rasmlari
  flutter_staggered_animations: ^1.1.1  # Staggered list
  google_fonts: ...           # Nunito / Inter
  animations: ^2.0.0         # OpenContainer, FadeScaleTransition (page transitions)
```

---

## 7. `CourseStatusButton` — 3 holat

```dart
// Boshlash:   to'q ko'k gradient, "Boshlash 🚀"
// Davom:      teal gradient, "Davom ▶"
// Tugallangan: yashil, "✓ Bajarildi" + Lottie small star

ElevatedButton(
  style: ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal:12, vertical:8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    backgroundColor: status == 'completed' ? Color(0xFF10B981)
                   : status == 'ongoing'   ? Color(0xFF2DD4BF)
                   :                         Color(0xFF1A3C6E),
  ),
  child: status == 'completed'
    ? Row(mainAxisSize:MainAxisSize.min, children:[
        Lottie.asset('assets/lottie/star.json', width:20, repeat:false),
        Text(" Bajarildi", style:TextStyle(color:Colors.white, fontSize:12))
      ])
    : Text(status == 'ongoing' ? "Davom ▶" : "Boshlash 🚀",
        style: TextStyle(color:Colors.white, fontSize:12))
)
```