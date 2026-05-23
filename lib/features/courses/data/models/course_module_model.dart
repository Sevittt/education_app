import '../../domain/entities/course_module_entity.dart';
import 'course_lesson_model.dart';

/// CourseModuleEntity uchun Firestore JSON modeli
class CourseModuleModel extends CourseModuleEntity {
  const CourseModuleModel({
    required super.id,
    required super.title,
    required super.description,
    required super.order,
    required super.lessons,
    super.learningObjectives,
  });

  factory CourseModuleModel.fromJson(Map<String, dynamic> json) {
    final lessonsJson = json['lessons'] as List<dynamic>? ?? [];
    final objectivesJson = json['learningObjectives'] as List<dynamic>? ?? [];
    return CourseModuleModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      lessons: lessonsJson
          .map((l) => CourseLessonModel.fromJson(l as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order)),
      learningObjectives: objectivesJson.map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'order': order,
      'lessons': lessons
          .map((l) => CourseLessonModel(
                id: l.id,
                title: l.title,
                order: l.order,
                type: l.type,
                refId: l.refId,
                sourceCollection: l.sourceCollection,
                estimatedMinutes: l.estimatedMinutes,
                isRequired: l.isRequired,
                xpReward: l.xpReward,
                minPassScore: l.minPassScore,
              ).toJson())
          .toList(),
      if (learningObjectives.isNotEmpty) 'learningObjectives': learningObjectives,
    };
  }
}
