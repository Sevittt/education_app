import '../entities/course_entity.dart';
import '../entities/user_course_progress_entity.dart';
import '../entities/course_lesson_entity.dart';

/// Kurslar uchun abstract repository interfeysi.
/// Clean Architecture: Data layer bu interfeysni implement qiladi.
abstract class CourseRepository {
  // ─── Kurslar ───────────────────────────────────────────────

  /// Kurslar ro'yxatini bir marta olish (filter bilan, faqat published)
  Future<List<CourseEntity>> getCourses({
    String? roleFilter,
    String? difficulty,
  });

  /// Admin uchun: barcha kurslarni olish (published + draft)
  Future<List<CourseEntity>> getAllCoursesAdmin();

  /// Kurslarni real-time stream sifatida kuzatish
  Stream<List<CourseEntity>> watchCourses();

  /// ID bo'yicha bitta kursni olish
  Future<CourseEntity?> getCourseById(String id);

  /// Yangi kurs yaratish → qaytaradi: yaratilgan document ID
  Future<String> createCourse(CourseEntity course);

  /// Mavjud kursni yangilash
  Future<void> updateCourse(CourseEntity course);

  /// Kursni o'chirish
  Future<void> deleteCourse(String courseId);

  // ─── Foydalanuvchi Progressi ───────────────────────────────

  /// Foydalanuvchining bitta kurs bo'yicha progressini olish
  Future<UserCourseProgressEntity?> getUserProgress(
    String userId,
    String courseId,
  );

  /// Foydalanuvchining barcha kurslar progressini real-time kuzatish
  Stream<List<UserCourseProgressEntity>> watchUserAllProgress(String userId);

  /// Kursni boshlash — progress yozuvi yaratish
  Future<void> startCourse(String userId, String courseId);

  /// Darsni tugallangan deb belgilash (XP + xAPI ichida)
  Future<void> markLessonComplete(
    String userId,
    String courseId,
    String lessonId,
    String lessonType, {
    int? score,
  });

  // ─── Darslarni boshqarish ───────────────────────────────────

  /// Kurs uchun barcha darslarni olish
  Future<List<CourseLessonEntity>> getLessonsForCourse(String courseId);

  /// Kursga dars qo'shish
  Future<void> addLesson(String courseId, String moduleId, CourseLessonEntity lesson);

  /// Darsni yangilash
  Future<void> updateLesson(String courseId, String moduleId, CourseLessonEntity lesson);

  /// Darsni o'chirish
  Future<void> deleteLesson(String courseId, String moduleId, String lessonId);
}
