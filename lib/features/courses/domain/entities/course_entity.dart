import 'package:equatable/equatable.dart';
import 'course_module_entity.dart';
import 'course_lesson_entity.dart';

/// Kurs qiyinlik darajasi
enum CourseDifficulty { beginner, intermediate, advanced }

extension CourseDifficultyExtension on CourseDifficulty {
  String get value {
    switch (this) {
      case CourseDifficulty.beginner:
        return 'beginner';
      case CourseDifficulty.intermediate:
        return 'intermediate';
      case CourseDifficulty.advanced:
        return 'advanced';
    }
  }

  String get displayName {
    switch (this) {
      case CourseDifficulty.beginner:
        return "Boshlang'ich";
      case CourseDifficulty.intermediate:
        return "O'rta";
      case CourseDifficulty.advanced:
        return 'Yuqori';
    }
  }

  static CourseDifficulty fromString(String value) {
    switch (value) {
      case 'intermediate':
        return CourseDifficulty.intermediate;
      case 'advanced':
        return CourseDifficulty.advanced;
      default:
        return CourseDifficulty.beginner;
    }
  }
}

/// Kursning asosiy entity modeli.
/// [modules] — embedded array (subcollection emas, soddalik uchun)
class CourseEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? thumbnailUrl;
  final List<String> targetRole; // 'judge', 'ict_specialist', 'clerk', etc.
  final CourseDifficulty difficulty;
  final int estimatedMinutes;
  final List<CourseModuleEntity> modules;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String authorId;
  final int order;
  final bool hasCertificate;
  final String? certificateTitle;

  const CourseEntity({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnailUrl,
    required this.targetRole,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.modules,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
    required this.authorId,
    required this.order,
    this.hasCertificate = false,
    this.certificateTitle,
  });

  CourseEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    List<String>? targetRole,
    CourseDifficulty? difficulty,
    int? estimatedMinutes,
    List<CourseModuleEntity>? modules,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorId,
    int? order,
    bool? hasCertificate,
    String? certificateTitle,
  }) {
    return CourseEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      targetRole: targetRole ?? this.targetRole,
      difficulty: difficulty ?? this.difficulty,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      modules: modules ?? this.modules,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorId: authorId ?? this.authorId,
      order: order ?? this.order,
      hasCertificate: hasCertificate ?? this.hasCertificate,
      certificateTitle: certificateTitle ?? this.certificateTitle,
    );
  }

  /// Barcha darslar ro'yxati (barcha modullardan yig'ilgan)
  List<CourseLessonEntity> get allLessons =>
      modules.expand((m) => m.lessons).toList();

  /// Jami darslar soni
  int get totalLessonsCount => allLessons.length;

  /// Majburiy darslar soni (progress hisoblash uchun)
  int get requiredLessonsCount =>
      allLessons.where((l) => l.isRequired).length;

  /// Video darslar soni
  int get videoCount =>
      allLessons.where((l) => l.type == LessonType.video).length;

  /// PDF darslar soni
  int get pdfCount =>
      allLessons.where((l) => l.type == LessonType.pdf).length;

  /// Quiz darslar soni
  int get quizCount =>
      allLessons.where((l) => l.type == LessonType.quiz).length;

  /// Kurs uchun jami XP (KVI og'irliklari yig'indisi, faqat majburiy darslar)
  /// Weighted progress hisoblash uchun ishlatiladi
  int get totalXp =>
      modules.fold(0, (sum, m) => sum + m.totalXp);

  @override
  List<Object?> get props => [
        id, title, description, thumbnailUrl, targetRole,
        difficulty, estimatedMinutes, modules, isPublished,
        createdAt, updatedAt, authorId, order, hasCertificate, certificateTitle,
      ];
}
