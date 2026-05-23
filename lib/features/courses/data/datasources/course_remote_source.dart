import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';
import '../models/user_course_progress_model.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/user_course_progress_entity.dart';

/// Firestore bilan to'g'ridan-to'g'ri ishlaydi.
/// courses va user_course_progress kolleksiyalariga CRUD + progress yozish.
class CourseRemoteSource {
  final FirebaseFirestore _db;

  CourseRemoteSource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  static const String _coursesCol = 'courses';
  static const String _progressCol = 'user_course_progress';

  // ─── Kurslar ──────────────────────────────────────────────

  /// Admin uchun: barcha kurslarni (published + draft) oladi
  Future<List<CourseEntity>> getAllCoursesAdmin() async {
    try {
      final snapshot = await _db
          .collection(_coursesCol)
          .orderBy('order')
          .get();
      return snapshot.docs.map((doc) => CourseModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Kurslarni yuklashda xatolik: $e');
    }
  }

  Future<List<CourseEntity>> getCourses({
    String? roleFilter,
    String? difficulty,
  }) async {
    try {
      Query query = _db
          .collection(_coursesCol)
          .where('isPublished', isEqualTo: true)
          .orderBy('order');

      if (difficulty != null) {
        query = query.where('difficulty', isEqualTo: difficulty);
      }
      if (roleFilter != null) {
        query = query.where('targetRole', arrayContains: roleFilter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => CourseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Kurslarni yuklashda xatolik: $e');
    }
  }

  Stream<List<CourseEntity>> watchCourses() {
    return _db
        .collection(_coursesCol)
        .where('isPublished', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => CourseModel.fromFirestore(d)).toList());
  }

  Future<CourseEntity?> getCourseById(String id) async {
    try {
      final doc = await _db.collection(_coursesCol).doc(id).get();
      if (!doc.exists) return null;
      return CourseModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Kursni olishda xatolik: $e');
    }
  }

  Future<String> createCourse(CourseEntity course) async {
    try {
      final model = CourseModel(
        id: course.id,
        title: course.title,
        description: course.description,
        thumbnailUrl: course.thumbnailUrl,
        targetRole: course.targetRole,
        difficulty: course.difficulty,
        estimatedMinutes: course.estimatedMinutes,
        modules: course.modules,
        isPublished: course.isPublished,
        createdAt: course.createdAt,
        updatedAt: course.updatedAt,
        authorId: course.authorId,
        order: course.order,
        hasCertificate: course.hasCertificate,
        certificateTitle: course.certificateTitle,
      );
      final ref = await _db.collection(_coursesCol).add(model.toJson());
      return ref.id;
    } catch (e) {
      throw Exception('Kurs yaratishda xatolik: $e');
    }
  }

  Future<void> updateCourse(CourseEntity course) async {
    try {
      final model = CourseModel(
        id: course.id,
        title: course.title,
        description: course.description,
        thumbnailUrl: course.thumbnailUrl,
        targetRole: course.targetRole,
        difficulty: course.difficulty,
        estimatedMinutes: course.estimatedMinutes,
        modules: course.modules,
        isPublished: course.isPublished,
        createdAt: course.createdAt,
        updatedAt: DateTime.now(),
        authorId: course.authorId,
        order: course.order,
        hasCertificate: course.hasCertificate,
        certificateTitle: course.certificateTitle,
      );
      await _db
          .collection(_coursesCol)
          .doc(course.id)
          .update(model.toJson());
    } catch (e) {
      throw Exception('Kursni yangilashda xatolik: $e');
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      await _db.collection(_coursesCol).doc(courseId).delete();
    } catch (e) {
      throw Exception('Kursni o\'chirishda xatolik: $e');
    }
  }

  // ─── Progress ─────────────────────────────────────────────

  String _progressDocId(String userId, String courseId) =>
      '${userId}_$courseId';

  Future<UserCourseProgressEntity?> getUserProgress(
    String userId,
    String courseId,
  ) async {
    try {
      final doc = await _db
          .collection(_progressCol)
          .doc(_progressDocId(userId, courseId))
          .get();
      if (!doc.exists) return null;
      return UserCourseProgressModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Progressni olishda xatolik: $e');
    }
  }

  Stream<List<UserCourseProgressEntity>> watchUserAllProgress(String userId) {
    return _db
        .collection(_progressCol)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => UserCourseProgressModel.fromFirestore(d))
            .toList());
  }

  Future<void> startCourse(String userId, String courseId, {int totalRequiredLessons = 0}) async {
    try {
      final docId = _progressDocId(userId, courseId);
      final ref = _db.collection(_progressCol).doc(docId);
      final existing = await ref.get();
      if (existing.exists) return; // Allaqachon boshlangan

      final initial = UserCourseProgressModel.initial(
        userId: userId,
        courseId: courseId,
        totalRequiredLessons: totalRequiredLessons,
      );
      await ref.set(initial.toJson());
    } catch (e) {
      throw Exception('Kursni boshlashda xatolik: $e');
    }
  }

  /// completedLessonIds ga lessonId qo'shadi, percentComplete va lastAccessedAt yangilaydi.
  /// [totalRequiredLessons] — faqat startCourse da yoziladi, bu yerda o'zgarmaydi.
  Future<void> updateProgress({
    required String userId,
    required String courseId,
    required List<String> completedLessonIds,
    required double percentComplete,
    required int earnedXp,
    Map<String, int>? quizScores,
    DateTime? completedAt,
    String? certificateUrl,
  }) async {
    try {
      final docId = _progressDocId(userId, courseId);
      final data = <String, dynamic>{
        'completedLessonIds': completedLessonIds,
        'percentComplete': percentComplete,
        'earnedXp': earnedXp,
        'lastAccessedAt': Timestamp.fromDate(DateTime.now()),
        if (quizScores != null) 'quizScores': quizScores,
        if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt),
        if (certificateUrl != null) 'certificateUrl': certificateUrl,
      };
      await _db.collection(_progressCol).doc(docId).update(data);
    } catch (e) {
      throw Exception('Progressni yangilashda xatolik: $e');
    }
  }
}
