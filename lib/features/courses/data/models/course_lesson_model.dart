import '../../domain/entities/course_lesson_entity.dart';

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

  factory CourseLessonModel.fromJson(Map<String, dynamic> json) {
    final type = LessonTypeExtension.fromString(json['type'] as String? ?? 'video');
    return CourseLessonModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      type: type,
      refId: json['refId'] as String? ?? '',
      sourceCollection: json['sourceCollection'] as String? ?? _defaultCollection(type),
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt(),
      isRequired: json['isRequired'] as bool? ?? true,
      // KVI og'irligi: Firestore'dan o'qiladi, bo'lmasa tur bo'yicha default
      xpReward: (json['xpReward'] as num?)?.toInt() ?? type.defaultXpReward,
      // Quiz gating: faqat quiz turida ishlaydi
      minPassScore: (json['minPassScore'] as num?)?.toInt(),
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
