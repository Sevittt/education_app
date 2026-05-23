import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/lesson_entity.dart';

class LessonModel extends LessonEntity {
  const LessonModel({
    required super.id,
    required super.courseId,
    required super.title,
    required super.order,
    required super.contentType,
    required super.contentId,
  });

  factory LessonModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse content type
    LessonContentType contentType = LessonContentType.video;
    final typeStr = data['contentType'] as String?;
    if (typeStr != null) {
      contentType = LessonContentType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => LessonContentType.video,
      );
    }

    return LessonModel(
      id: doc.id,
      courseId: data['courseId'] ?? '',
      title: data['title'] ?? '',
      order: data['order'] ?? 0,
      contentType: contentType,
      contentId: data['contentId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'courseId': courseId,
      'title': title,
      'order': order,
      'contentType': contentType.name,
      'contentId': contentId,
    };
  }
}
