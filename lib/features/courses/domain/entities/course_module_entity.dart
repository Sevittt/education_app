import 'package:equatable/equatable.dart';
import 'course_lesson_entity.dart';

/// Kurs ichidagi bo'lim (modul) entity.
/// [learningObjectives] — ushbu modulni tugatgandan so'ng o'quvchi nimalarni biladi
class CourseModuleEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final int order;
  final List<CourseLessonEntity> lessons;

  /// Modul o'quv maqsadlari (course-core.md LMS standarti)
  final List<String> learningObjectives;

  const CourseModuleEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.lessons,
    this.learningObjectives = const [],
  });

  /// Modulning umumiy daqiqalari
  int get totalMinutes => lessons.fold(0, (sum, l) => sum + (l.estimatedMinutes ?? 0));

  /// Majburiy darslar soni
  int get requiredLessonsCount => lessons.where((l) => l.isRequired).length;

  /// Modul uchun jami XP (KVI og'irliklari yig'indisi)
  /// Faqat majburiy darslar hisoblanadi
  int get totalXp => lessons
      .where((l) => l.isRequired)
      .fold(0, (sum, l) => sum + l.xpReward);

  /// Ushbu modulda quiz gating mavjudmi?
  bool get hasQuizGating => lessons.any((l) => l.hasPassScoreRequirement);

  CourseModuleEntity copyWith({
    String? id,
    String? title,
    String? description,
    int? order,
    List<CourseLessonEntity>? lessons,
    List<String>? learningObjectives,
  }) {
    return CourseModuleEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
      lessons: lessons ?? this.lessons,
      learningObjectives: learningObjectives ?? this.learningObjectives,
    );
  }

  @override
  List<Object?> get props => [id, title, description, order, lessons, learningObjectives];
}
