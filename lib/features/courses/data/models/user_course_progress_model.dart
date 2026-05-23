import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_course_progress_entity.dart';

/// UserCourseProgressEntity uchun Firestore JSON modeli
class UserCourseProgressModel extends UserCourseProgressEntity {
  const UserCourseProgressModel({
    required super.userId,
    required super.courseId,
    required super.completedLessonIds,
    super.quizScores,
    required super.startedAt,
    required super.lastAccessedAt,
    super.completedAt,
    required super.percentComplete,
    required super.earnedXp,
    super.totalRequiredLessons,
    super.certificateUrl,
  });

  factory UserCourseProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserCourseProgressModel.fromJson(data);
  }

  factory UserCourseProgressModel.fromJson(Map<String, dynamic> json) {
    return UserCourseProgressModel(
      userId: json['userId'] as String? ?? '',
      courseId: json['courseId'] as String? ?? '',
      completedLessonIds:
          List<String>.from(json['completedLessonIds'] as List? ?? []),
      quizScores: (json['quizScores'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, (value as num).toInt()),
          ) ??
          {},
      startedAt: (json['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastAccessedAt:
          (json['lastAccessedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (json['completedAt'] as Timestamp?)?.toDate(),
      percentComplete: (json['percentComplete'] as num?)?.toDouble() ?? 0.0,
      earnedXp: (json['earnedXp'] as num?)?.toInt() ?? 0,
      totalRequiredLessons: (json['totalRequiredLessons'] as num?)?.toInt() ?? 0,
      certificateUrl: json['certificateUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'courseId': courseId,
      'completedLessonIds': completedLessonIds,
      'quizScores': quizScores,
      'startedAt': Timestamp.fromDate(startedAt),
      'lastAccessedAt': Timestamp.fromDate(lastAccessedAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'percentComplete': percentComplete,
      'earnedXp': earnedXp,
      'totalRequiredLessons': totalRequiredLessons,
      if (certificateUrl != null) 'certificateUrl': certificateUrl,
    };
  }

  /// Yangi boshlangan progress yaratish uchun factory
  factory UserCourseProgressModel.initial({
    required String userId,
    required String courseId,
    int totalRequiredLessons = 0,
  }) {
    final now = DateTime.now();
    return UserCourseProgressModel(
      userId: userId,
      courseId: courseId,
      completedLessonIds: [],
      quizScores: const {},
      startedAt: now,
      lastAccessedAt: now,
      percentComplete: 0.0,
      earnedXp: 0,
      totalRequiredLessons: totalRequiredLessons,
    );
  }
}
