import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/course_entity.dart';
import 'course_module_model.dart';

/// CourseEntity uchun Firestore JSON modeli
class CourseModel extends CourseEntity {
  const CourseModel({
    required super.id,
    required super.title,
    required super.description,
    super.thumbnailUrl,
    required super.targetRole,
    required super.difficulty,
    required super.estimatedMinutes,
    required super.modules,
    required super.isPublished,
    required super.createdAt,
    required super.updatedAt,
    required super.authorId,
    required super.order,
    super.hasCertificate,
    super.certificateTitle,
  });

  factory CourseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CourseModel.fromJson(data, id: doc.id);
  }

  factory CourseModel.fromJson(Map<String, dynamic> json, {String? id}) {
    final modulesJson = json['modules'] as List<dynamic>? ?? [];
    return CourseModel(
      id: id ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      targetRole: List<String>.from(json['targetRole'] as List? ?? []),
      difficulty: CourseDifficultyExtension.fromString(
        json['difficulty'] as String? ?? 'beginner',
      ),
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 0,
      modules: modulesJson
          .map((m) => CourseModuleModel.fromJson(m as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order)),
      isPublished: json['isPublished'] as bool? ?? false,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      authorId: json['authorId'] as String? ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      hasCertificate: json['hasCertificate'] as bool? ?? false,
      certificateTitle: json['certificateTitle'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      'targetRole': targetRole,
      'difficulty': difficulty.value,
      'estimatedMinutes': estimatedMinutes,
      'modules': modules
          .map((m) => CourseModuleModel(
                id: m.id,
                title: m.title,
                description: m.description,
                order: m.order,
                lessons: m.lessons,
              ).toJson())
          .toList(),
      'isPublished': isPublished,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'authorId': authorId,
      'order': order,
      'hasCertificate': hasCertificate,
      if (certificateTitle != null) 'certificateTitle': certificateTitle,
    };
  }
}
