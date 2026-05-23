import 'package:equatable/equatable.dart';

/// Foydalanuvchining kurs bo'yicha progressi entity.
/// Firestore'da: user_course_progress/{userId}_{courseId}
class UserCourseProgressEntity extends Equatable {
  final String userId;
  final String courseId;
  final List<String> completedLessonIds;
  final Map<String, int> quizScores; // Qo'shildi: lessonId -> to'plangan ball
  final DateTime startedAt;
  final DateTime lastAccessedAt;
  final DateTime? completedAt; // null = hali tugallanmagan
  final double percentComplete; // 0.0 dan 1.0 gacha
  final int earnedXp;
  final int totalRequiredLessons; // Firestore'dan keladigan haqiqiy son
  final String? certificateUrl; // Firebase Storage PDF URL

  const UserCourseProgressEntity({
    required this.userId,
    required this.courseId,
    required this.completedLessonIds,
    this.quizScores = const {}, // Default bo'sh map
    required this.startedAt,
    required this.lastAccessedAt,
    this.completedAt,
    required this.percentComplete,
    required this.earnedXp,
    this.totalRequiredLessons = 0,
    this.certificateUrl,
  });

  /// Jami darslar soni (haqiqiy qiymat, teskari formuladan emas)
  int get totalLessons => totalRequiredLessons;

  /// Composite document ID
  String get docId => '${userId}_$courseId';

  /// Kurs to'liq tugallanganmi?
  bool get isCompleted => completedAt != null;

  /// Kurs hali boshlanmaganmi?
  bool get isNotStarted => completedLessonIds.isEmpty;

  /// Dars tugallanganmi?
  bool isLessonCompleted(String lessonId) =>
      completedLessonIds.contains(lessonId);

  UserCourseProgressEntity copyWith({
    List<String>? completedLessonIds,
    Map<String, int>? quizScores,
    DateTime? lastAccessedAt,
    DateTime? completedAt,
    double? percentComplete,
    int? earnedXp,
    int? totalRequiredLessons,
    String? certificateUrl,
  }) {
    return UserCourseProgressEntity(
      userId: userId,
      courseId: courseId,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      quizScores: quizScores ?? this.quizScores,
      startedAt: startedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      completedAt: completedAt ?? this.completedAt,
      percentComplete: percentComplete ?? this.percentComplete,
      earnedXp: earnedXp ?? this.earnedXp,
      totalRequiredLessons: totalRequiredLessons ?? this.totalRequiredLessons,
      certificateUrl: certificateUrl ?? this.certificateUrl,
    );
  }

  @override
  List<Object?> get props => [
        userId, courseId, completedLessonIds, quizScores, startedAt,
        lastAccessedAt, completedAt, percentComplete, earnedXp,
        totalRequiredLessons, certificateUrl,
      ];
}
