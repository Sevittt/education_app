import '../../domain/entities/course_entity.dart';
import '../../domain/entities/course_module_entity.dart';
import '../../domain/entities/course_lesson_entity.dart';

/// O'zbekiston Respublikasi Oliy sudi va Toshkent shahar sudi
/// ko'rsatma xatlari (17 ta minimal talab) asosida ishlab chiqilgan
/// 5 ta rasmiy kurslar to'plami.
class DarsCurriculumSeed {
  static List<CourseEntity> getOfficialCourses() {
    final now = DateTime.now();

    return [
      // 1-KURS: Windows, Office va ofis texnikasi
      CourseEntity(
        id: 'course_dars_modul_1',
        title: '1-Modul: Windows, MS Office va Ofis Texnikasi',
        description:
            'Sud ish yurituvida Windows fayl tizimi (D:\\SUD_ISH_YURITUVI), hujjatlarni to\'g\'ri nomlash standarti, Word va Excel (jadvallar, avtosumma, filtrlar) hamda skaner/printer bilan ishlash ko\'nikmalari.',
        targetRole: const ['judge', 'assistant', 'chancellery', 'archive', 'ict_specialist'],
        difficulty: CourseDifficulty.beginner,
        estimatedMinutes: 120,
        isPublished: true,
        order: 1,
        createdAt: now,
        updatedAt: now,
        authorId: 'sud_qollanma_official',
        hasCertificate: true,
        certificateTitle: 'Windows va Ofis Savodxonligi Sertifikati',
        modules: [
          CourseModuleEntity(
            id: 'm1_mod_1',
            title: '1-Mavzu: Operatsion tizim (Windows) bilan ishlash',
            description: 'Fayllarni D: diskda xavfsiz papkalash va to\'g\'ri nomlash standarti.',
            order: 1,
            lessons: const [
              CourseLessonEntity(
                id: 'm1_l1',
                title: 'Nega sud hujjatlarini Ish stolida (Desktop) saqlash xavfli?',
                type: LessonType.article,
                refId: 'dars_1_modul_bo_yicha_to_liq_amaliy_qo_llanma_1',
                sourceCollection: 'knowledge_base',
                order: 1,
                isRequired: true,
                estimatedMinutes: 15,
                xpReward: 10,
              ),
              CourseLessonEntity(
                id: 'm1_l2',
                title: 'Sud ish yurituvi papkalar standarti va qidiruvda 3 soniyada topish',
                type: LessonType.article,
                refId: 'dars_1_modul_bo_yicha_to_liq_amaliy_qo_llanma_3',
                sourceCollection: 'knowledge_base',
                order: 2,
                isRequired: true,
                estimatedMinutes: 20,
                xpReward: 15,
              ),
            ],
          ),
          CourseModuleEntity(
            id: 'm1_mod_2',
            title: '2-Mavzu: Ofis dasturlari (MS Word, Excel, PDF)',
            description: 'Sud hujjatlarini formatlash, formulalar, avtosumma va PDF eksport.',
            order: 2,
            lessons: const [
              CourseLessonEntity(
                id: 'm1_l3',
                title: 'Word: Sahifa hoshiyalari, qidirish va almashtirish (Ctrl+H)',
                type: LessonType.article,
                refId: 'dars_1_modul_bo_yicha_to_liq_amaliy_qo_llanma_5',
                sourceCollection: 'knowledge_base',
                order: 1,
                isRequired: true,
                estimatedMinutes: 20,
                xpReward: 15,
              ),
              CourseLessonEntity(
                id: 'm1_l4',
                title: 'Excel: Sud qarorlari va da\'vo summasi bo\'yicha avtosumma va filtr',
                type: LessonType.article,
                refId: 'dars_1_modul_bo_yicha_to_liq_amaliy_qo_llanma_7',
                sourceCollection: 'knowledge_base',
                order: 2,
                isRequired: true,
                estimatedMinutes: 25,
                xpReward: 20,
              ),
            ],
          ),
        ],
      ),

      // 2-KURS: ERI va brauzer sozlamalari
      CourseEntity(
        id: 'course_dars_modul_2',
        title: '2-Modul: ERI, E-IMZO va Brauzer Sozlamalari',
        description:
            'Elektron raqamli imzo (ERI) kalitlarini C:\\DSKEYS da saqlash, E-IMZO moduli ishlamay qolganda to\'g\'rilash, brauzer keshini tozalash va sertifikat muddatini nazorat qilish.',
        targetRole: const ['judge', 'assistant', 'chancellery', 'ict_specialist'],
        difficulty: CourseDifficulty.intermediate,
        estimatedMinutes: 90,
        isPublished: true,
        order: 2,
        createdAt: now,
        updatedAt: now,
        authorId: 'sud_qollanma_official',
        hasCertificate: true,
        certificateTitle: 'ERI va E-IMZO Mutaxassisi Sertifikati',
        modules: [
          CourseModuleEntity(
            id: 'm2_mod_1',
            title: '1-Mavzu: ERI kalitlari va C:\\DSKEYS standarti',
            description: 'ERI ning huquqiy kuchi, sudya va yordamchi hamkorligi.',
            order: 1,
            lessons: const [
              CourseLessonEntity(
                id: 'm2_l1',
                title: 'ERI kalitlarining saqlanishi va C:\\DSKEYS papkasi',
                type: LessonType.article,
                refId: 'dars_2_modul_bo_yicha_to_liq_amaliy_qo_llanma_1',
                sourceCollection: 'knowledge_base',
                order: 1,
                isRequired: true,
                estimatedMinutes: 15,
                xpReward: 15,
              ),
            ],
          ),
          CourseModuleEntity(
            id: 'm2_mod_2',
            title: '2-Mavzu: Kesh tozalash va E-IMZO muammolarini hal qilish',
            description: 'Brauzer keshini tozalash va E-IMZO ni qayta ishga tushirish.',
            order: 2,
            lessons: const [
              CourseLessonEntity(
                id: 'm2_l2',
                title: 'E-IMZO ishlamay qolganda keshni tozalash va 3 qadamli yechim',
                type: LessonType.article,
                refId: 'dars_2_modul_bo_yicha_to_liq_amaliy_qo_llanma_3',
                sourceCollection: 'knowledge_base',
                order: 1,
                isRequired: true,
                estimatedMinutes: 20,
                xpReward: 20,
              ),
            ],
          ),
        ],
      ),

      // 3-KURS: Axborot xavfsizligi va maxfiylik
      CourseEntity(
        id: 'course_dars_modul_3',
        title: '3-Modul: Sudda Axborot Xavfsizligi va Maxfiylik',
        description:
            'Sud tizimida kiberxavfsizlik, fishing (aldamchi) xabarlarni aniqlash, begona fleshkalardan himoyalanish, murakkab parollar va shaxsiy ma\'lumotlar maxfiyligi.',
        targetRole: const ['judge', 'assistant', 'chancellery', 'archive', 'ict_specialist'],
        difficulty: CourseDifficulty.intermediate,
        estimatedMinutes: 80,
        isPublished: true,
        order: 3,
        createdAt: now,
        updatedAt: now,
        authorId: 'sud_qollanma_official',
        hasCertificate: true,
        certificateTitle: 'Kiberxavfsizlik va Maxfiylik Sertifikati',
        modules: [
          CourseModuleEntity(
            id: 'm3_mod_1',
            title: '1-Mavzu: Kiberxavfsizlik va Fishingdan himoya',
            description: 'Fishing elektron xatlarini aniqlash va begona USB fleshkalardan ehtiyot bo\'lish.',
            order: 1,
            lessons: const [
              CourseLessonEntity(
                id: 'm3_l1',
                title: 'Fishing hujumlarini aniqlash va xavfsiz pochta qoidalari',
                type: LessonType.article,
                refId: 'dars_3_modul_bo_yicha_to_liq_amaliy_qo_llanma_1',
                sourceCollection: 'knowledge_base',
                order: 1,
                isRequired: true,
                estimatedMinutes: 20,
                xpReward: 20,
              ),
            ],
          ),
        ],
      ),

      // 4-KURS: Oliy sud axborot tizimlari va EDO
      CourseEntity(
        id: 'course_dars_modul_4',
        title: '4-Modul: Oliy Sud Axborot Tizimlari va EDO',
        description:
            'my.sud.uz interaktiv portali, E-XSUD / JIB tizimlari, EDO ichki va idoralararo elektron hujjat aylanishi, topshiriqlar ijrosi monitoringi va davlat organlari bilan integratsiya.',
        targetRole: const ['judge', 'assistant', 'chancellery'],
        difficulty: CourseDifficulty.advanced,
        estimatedMinutes: 150,
        isPublished: true,
        order: 4,
        createdAt: now,
        updatedAt: now,
        authorId: 'sud_qollanma_official',
        hasCertificate: true,
        certificateTitle: 'Sud Axborot Tizimlari Mutaxassisi',
        modules: [
          CourseModuleEntity(
            id: 'm4_mod_1',
            title: '1-Mavzu: EDO elektron hujjat aylanish tizimi',
            description: 'Kiruvchi xatlar, rezyolutsiyalar, javob xati tayyorlash va imzolash.',
            order: 1,
            lessons: const [
              CourseLessonEntity(
                id: 'm4_l1',
                title: 'EDO: Kiruvchi xatlarni ro\'yxatga olish va rezolyutsiya chiqarish',
                type: LessonType.article,
                refId: 'dars_4_modul_bo_yicha_to_liq_amaliy_qo_llanma_1',
                sourceCollection: 'knowledge_base',
                order: 1,
                isRequired: true,
                estimatedMinutes: 25,
                xpReward: 25,
              ),
              CourseLessonEntity(
                id: 'm4_l2',
                title: 'Video dars: ERI orqali EDO tizimiga kirish va imzolash',
                type: LessonType.video,
                refId: 'video_edo_ERIorqalikirishEDO',
                sourceCollection: 'video_tutorials',
                order: 2,
                isRequired: true,
                estimatedMinutes: 15,
                xpReward: 20,
              ),
            ],
          ),
        ],
      ),

      // 5-KURS: VKA, audio-video va huquqiy bazalar
      CourseEntity(
        id: 'course_dars_modul_5',
        title: '5-Modul: VKA, Audio-Video va Huquqiy Bazalar',
        description:
            'Masofaviy sud majlislarini Videokonferensaloqa (VKA) orqali olib borish, sud zallaridagi audio-video qayd etish tizimlari, Lex.uz va qonunchilik bazalaridan samarali foydalanish.',
        targetRole: const ['judge', 'assistant', 'chancellery'],
        difficulty: CourseDifficulty.intermediate,
        estimatedMinutes: 100,
        isPublished: true,
        order: 5,
        createdAt: now,
        updatedAt: now,
        authorId: 'sud_qollanma_official',
        hasCertificate: true,
        certificateTitle: 'VKA va Sud Texnologiyalari Sertifikati',
        modules: [
          CourseModuleEntity(
            id: 'm5_mod_1',
            title: '1-Mavzu: Videokonferensaloqa (VKA) va audio-video yozuv',
            description: 'VKA sud majlisini boshqarish va audio-video tizimlarni sozlash.',
            order: 1,
            lessons: const [
              CourseLessonEntity(
                id: 'm5_l1',
                title: 'Masofaviy sud majlislarini VKA tizimida o\'tkazish tartibi',
                type: LessonType.article,
                refId: 'dars_5_modul_bo_yicha_to_liq_amaliy_qo_llanma_1',
                sourceCollection: 'knowledge_base',
                order: 1,
                isRequired: true,
                estimatedMinutes: 20,
                xpReward: 20,
              ),
            ],
          ),
        ],
      ),
    ];
  }
}
