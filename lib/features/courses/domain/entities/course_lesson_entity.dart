import 'package:equatable/equatable.dart';

/// Dars turi — mavjud kontentga ko'rsatkich
enum LessonType { video, article, pdf, quiz }

extension LessonTypeExtension on LessonType {
  String get value {
    switch (this) {
      case LessonType.video:
        return 'video';
      case LessonType.article:
        return 'article';
      case LessonType.pdf:
        return 'pdf';
      case LessonType.quiz:
        return 'quiz';
    }
  }

  /// Dars turi bo'yicha default XP miqdori (KVI og'irlik)
  int get defaultXpReward {
    switch (this) {
      case LessonType.video:
        return 10;
      case LessonType.article:
        return 8;
      case LessonType.pdf:
        return 6;
      case LessonType.quiz:
        return 20; // Quiz eng ko'p XP beradi
    }
  }

  static LessonType fromString(String value) {
    switch (value) {
      case 'video':
        return LessonType.video;
      case 'article':
        return LessonType.article;
      case 'pdf':
        return LessonType.pdf;
      case 'quiz':
        return LessonType.quiz;
      default:
        return LessonType.video;
    }
  }
}

/// Kurs ichidagi bitta dars entity.
/// [refId] — Firestore'dagi haqiqiy document ID
/// [sourceCollection] — qaysi kolleksiyadan olish: 'video_tutorials' | 'knowledge_base' | 'resources' | 'quizzes'
/// [xpReward] — Darsni tugatganda beriladigan XP miqdori (KVI og'irligi)
/// [minPassScore] — Faqat quiz uchun: keyingi darsni ochish uchun minimal ball (0–100)
class CourseLessonEntity extends Equatable {
  final String id;
  final String title;
  final int order;
  final LessonType type;
  final String refId;
  final String sourceCollection;
  final int? estimatedMinutes;
  final bool isRequired;

  /// KVI og'irligi: tugalganda beriladigan XP.
  /// Video=10, Article=8, PDF=6, Quiz=20 (default).
  final int xpReward;

  /// Faqat [LessonType.quiz] uchun.
  /// Keyingi darsni blokdan chiqarish uchun minimal foiz (0–100).
  /// null = ball sharti yo'q.
  final int? minPassScore;

  const CourseLessonEntity({
    required this.id,
    required this.title,
    required this.order,
    required this.type,
    required this.refId,
    required this.sourceCollection,
    this.estimatedMinutes,
    this.isRequired = true,
    int? xpReward,
    this.minPassScore,
  }) : xpReward = xpReward ?? 10;

  /// Quiz gating: bu dars keyingi darsni bloklaydimi?
  bool get hasPassScoreRequirement => type == LessonType.quiz && minPassScore != null;

  @override
  List<Object?> get props => [
        id,
        title,
        order,
        type,
        refId,
        sourceCollection,
        estimatedMinutes,
        isRequired,
        xpReward,
        minPassScore,
      ];
}
