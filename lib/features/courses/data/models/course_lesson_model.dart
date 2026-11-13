import '../../domain/entities/course_lesson_entity.dart';
import '../seeds/dars_courses_seed.dart';

/// CourseLessonEntity uchun Firestore JSON modeli
class CourseLessonModel extends CourseLessonEntity {
  const CourseLessonModel({
    required super.id,
    required super.title,
    required super.order,
    required super.type,
    required super.refId,
    required super.sourceCollection,
    super.estimatedMinutes,
    super.isRequired,
    super.xpReward,
    super.minPassScore,
  });

  static final Map<String, CourseLessonEntity> _seedLessonsById = {
    for (final course in DarsCurriculumSeed.getOfficialCourses())
      for (final module in course.modules)
        for (final lesson in module.lessons) lesson.id: lesson,
  };

  factory CourseLessonModel.fromJson(Map<String, dynamic> json) {
    final lessonId = json['id'] as String? ?? '';
    final rawRefId = (json['refId'] as String? ?? '').trim();
    final seedLesson = _seedLessonsById[lessonId];
    final type = LessonTypeExtension.fromString(
      json['type'] as String? ?? seedLesson?.type.value ?? 'video',
    );
    final rawCollection = (json['sourceCollection'] as String? ?? '').trim();

    return CourseLessonModel(
      id: lessonId,
      title: json['title'] as String? ?? seedLesson?.title ?? '',
      order: (json['order'] as num?)?.toInt() ?? seedLesson?.order ?? 0,
      type: type,
      refId: rawRefId.isNotEmpty ? rawRefId : (seedLesson?.refId ?? ''),
      sourceCollection: rawCollection.isNotEmpty
          ? rawCollection
          : (seedLesson?.sourceCollection ?? _defaultCollection(type)),
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ??
          (json['durationMinutes'] as num?)?.toInt() ??
          seedLesson?.estimatedMinutes,
      isRequired: json['isRequired'] as bool? ?? seedLesson?.isRequired ?? true,
      // KVI og'irligi: Firestore'dan o'qiladi, bo'lmasa tur bo'yicha default
      xpReward: (json['xpReward'] as num?)?.toInt() ??
          seedLesson?.xpReward ??
          type.defaultXpReward,
      // Quiz gating: faqat quiz turida ishlaydi
      minPassScore: (json['minPassScore'] as num?)?.toInt() ?? seedLesson?.minPassScore,
    );
  }

  static String _defaultCollection(LessonType type) {
    switch (type) {
      case LessonType.video:
        return 'video_tutorials';
      case LessonType.article:
        return 'knowledge_base';
      case LessonType.pdf:
        return 'resources';
      case LessonType.quiz:
        return 'quizzes';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'order': order,
      'type': type.value,
      'refId': refId,
      'sourceCollection': sourceCollection,
      if (estimatedMinutes != null) 'estimatedMinutes': estimatedMinutes,
      'isRequired': isRequired,
      'xpReward': xpReward,
      if (minPassScore != null) 'minPassScore': minPassScore,
    };
  }
}
