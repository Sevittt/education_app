import 'package:equatable/equatable.dart';

enum LessonContentType {
  video,
  article,
  pdf,
  quiz,
}

extension LessonContentTypeExtension on LessonContentType {
  String get displayName {
    switch (this) {
      case LessonContentType.video:
        return 'Video dars';
      case LessonContentType.article:
        return 'O\'qish uchun matn';
      case LessonContentType.pdf:
        return 'Qo\'llanma (PDF)';
      case LessonContentType.quiz:
        return 'Test (Quiz)';
    }
  }
}

class LessonEntity extends Equatable {
  final String id;
  final String courseId;
  final String title;
  final int order; // 1, 2, 3...
  final LessonContentType contentType;
  
  // This is the ID of the actual resource (Video ID, Article ID, PDF ID, or Quiz ID)
  // This allows us to reuse existing content.
  final String contentId; 

  const LessonEntity({
    required this.id,
    required this.courseId,
    required this.title,
    required this.order,
    required this.contentType,
    required this.contentId,
  });

  @override
  List<Object?> get props => [
        id,
        courseId,
        title,
        order,
        contentType,
        contentId,
      ];
}
