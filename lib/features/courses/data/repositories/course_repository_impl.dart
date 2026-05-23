import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/course_module_entity.dart';
import '../../domain/entities/course_lesson_entity.dart';
import '../../domain/entities/user_course_progress_entity.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/course_remote_source.dart';
import '../../../search/data/models/search_index_model.dart';
import '../../../analytics/domain/repositories/analytics_repository.dart';
import '../../../analytics/domain/entities/xapi_statement.dart';
import '../../../analytics/domain/entities/xapi_actor.dart';
import '../../../gamification/domain/repositories/gamification_repository.dart';
import '../../../search/utils/search_indexer.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteSource remoteSource;
  final AnalyticsRepository? analyticsRepository;
  final GamificationRepository? gamificationRepository;
  final SearchIndexer _searchIndexer;

  CourseRepositoryImpl({
    required this.remoteSource,
    this.analyticsRepository,
    this.gamificationRepository,
    SearchIndexer? searchIndexer,
  }) : _searchIndexer = searchIndexer ?? SearchIndexer();

  @override
  Future<List<CourseEntity>> getCourses({
    String? roleFilter,
    String? difficulty,
  }) {
    return remoteSource.getCourses(
      roleFilter: roleFilter,
      difficulty: difficulty,
    );
  }

  @override
  Future<List<CourseEntity>> getAllCoursesAdmin() {
    return remoteSource.getAllCoursesAdmin();
  }

  @override
  Stream<List<CourseEntity>> watchCourses() {
    return remoteSource.watchCourses();
  }

  @override
  Future<CourseEntity?> getCourseById(String id) {
    return remoteSource.getCourseById(id);
  }

  @override
  Future<String> createCourse(CourseEntity course) async {
    final id = await remoteSource.createCourse(course);
    
    // Indeksga qo'shish
    await _searchIndexer.indexDocument(
      SearchIndexModel(
        id: id,
        title: course.title,
        description: course.description,
        type: 'course',
        text: '${course.title}\n${course.description}',
        path: '/courses/$id',
        createdAt: DateTime.now(),
      ),
    );
    
    return id;
  }

  @override
  Future<void> updateCourse(CourseEntity course) async {
    await remoteSource.updateCourse(course);
    
    await _searchIndexer.indexDocument(
      SearchIndexModel(
        id: course.id,
        title: course.title,
        description: course.description,
        type: 'course',
        text: '${course.title}\n${course.description}',
        path: '/courses/${course.id}',
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    await remoteSource.deleteCourse(courseId);
    await _searchIndexer.deleteDocument(courseId);
  }

  @override
  Future<UserCourseProgressEntity?> getUserProgress(
    String userId,
    String courseId,
  ) {
    return remoteSource.getUserProgress(userId, courseId);
  }

  @override
  Stream<List<UserCourseProgressEntity>> watchUserAllProgress(String userId) {
    return remoteSource.watchUserAllProgress(userId);
  }

  @override
  Future<void> startCourse(String userId, String courseId) async {
    final course = await getCourseById(courseId);
    await remoteSource.startCourse(
      userId,
      courseId,
      totalRequiredLessons: course?.requiredLessonsCount ?? 0,
    );
    await _logXApi(
      verbId: XApiVerbs.initialized.id,
      objectId: 'course/$courseId',
      objectType: 'http://adlnet.gov/expapi/activities/course',
      objectName: course?.title ?? 'Course $courseId',
    );
  }

  @override
  Future<void> markLessonComplete(
    String userId,
    String courseId,
    String lessonId,
    String lessonType, {
    int? score,
  }) async {
    final course = await getCourseById(courseId);
    if (course == null) return;

    final progress = await getUserProgress(userId, courseId);
    if (progress == null) return;

    // 1. Agar allaqachon tugallangan bo'lsa, score'ni yangilab qo'yamiz (agar bo'lsa) va qaytamiz
    if (progress.completedLessonIds.contains(lessonId)) {
      if (score != null) {
        final newScores = Map<String, int>.from(progress.quizScores);
        // Faqat yuqoriroq ball bo'lsa yangilaymiz yoki oddiygina qayta yozamiz
        newScores[lessonId] = score;
        await remoteSource.updateProgress(
          userId: userId,
          courseId: courseId,
          completedLessonIds: progress.completedLessonIds,
          percentComplete: progress.percentComplete,
          earnedXp: progress.earnedXp,
          quizScores: newScores,
          completedAt: progress.completedAt,
        );
      }
      return;
    }

    // 2. Tugallangan dars topish (xpReward olish uchun)
    final completedLesson = course.allLessons
        .where((l) => l.id == lessonId)
        .firstOrNull;

    // 3. Yangi tugallangan ro'yxat va quizScores
    final newCompleted = List<String>.from(progress.completedLessonIds)
      ..add(lessonId);
    final newScores = Map<String, int>.from(progress.quizScores);
    if (score != null) {
      newScores[lessonId] = score;
    }

    // 4. ── Weighted Progress hisoblash (KVI og'irlik tizimi) ──────────────
    // Hozirgi davrgacha qo'shilgan XP (progress.earnedXp) + bu darsning XP si
    final lessonXp = completedLesson?.xpReward ?? 10;
    final newEarnedXp = progress.earnedXp + lessonXp;

    // Kurs jami XP si (0 bo'lmasligini ta'minlaymiz)
    final totalXp = course.totalXp > 0 ? course.totalXp : 1;

    // Foiz = to'plangan_xp / jami_xp
    double percent = newEarnedXp / totalXp;
    if (percent > 1.0) percent = 1.0;

    final isCourseComplete = percent >= 1.0 && progress.completedAt == null;

    // 5. ── Kurs bonus XP ──────────────────────────────────────────────────
    int bonusXp = 0;
    if (isCourseComplete) {
      bonusXp = 50; // Kurs tugatish bonus XP
    }

    DateTime? completedAt;
    if (isCourseComplete) {
      completedAt = DateTime.now();
    }

    // 6. DB ni yangilash
    await remoteSource.updateProgress(
      userId: userId,
      courseId: courseId,
      completedLessonIds: newCompleted,
      percentComplete: percent,
      earnedXp: newEarnedXp + bonusXp,
      quizScores: newScores,
      completedAt: completedAt,
    );

    // 7. ── Gamification: dars XP + kurs bonus ────────────────────────────
    if (gamificationRepository != null) {
      // Har dars uchun uning xpReward ini berish
      await gamificationRepository!.awardPoints(
        userId: userId,
        points: lessonXp,
        actionType: 'lesson_completed',
        description: 'Completed lesson: ${completedLesson?.title ?? lessonId}',
      );

      if (isCourseComplete) {
        await gamificationRepository!.awardPoints(
          userId: userId,
          points: bonusXp,
          actionType: 'course_completed',
          description: 'Completed course: ${course.title}',
        );
      }
    }

    // 8. ── xAPI logging ───────────────────────────────────────────────────
    if (isCourseComplete) {
      await _logXApi(
        verbId: XApiVerbs.completed.id,
        objectId: 'course/$courseId',
        objectType: 'http://adlnet.gov/expapi/activities/course',
        objectName: course.title,
        success: true,
      );
    } else {
      await _logXApi(
        verbId: XApiVerbs.progressed.id,
        objectId: 'course/$courseId',
        objectType: 'http://adlnet.gov/expapi/activities/course',
        objectName: course.title,
      );
    }
  }

  // ─── Lesson Management ────────────────────────────────────

  @override
  Future<List<CourseLessonEntity>> getLessonsForCourse(String courseId) async {
    final course = await getCourseById(courseId);
    if (course == null) return [];
    return course.allLessons;
  }

  @override
  Future<void> addLesson(String courseId, String moduleId, CourseLessonEntity lesson) async {
    final course = await getCourseById(courseId);
    if (course == null) return;

    final updatedModules = course.modules.map((m) {
      if (m.id == moduleId) {
        return m.copyWith(lessons: [...m.lessons, lesson]);
      }
      return m;
    }).toList();

    await updateCourse(course.copyWith(modules: updatedModules));
  }

  @override
  Future<void> updateLesson(String courseId, String moduleId, CourseLessonEntity lesson) async {
    final course = await getCourseById(courseId);
    if (course == null) return;

    final updatedModules = course.modules.map((m) {
      if (m.id == moduleId) {
        final updatedLessons = m.lessons.map((l) {
          return l.id == lesson.id ? lesson : l;
        }).toList();
        return m.copyWith(lessons: updatedLessons);
      }
      return m;
    }).toList();

    await updateCourse(course.copyWith(modules: updatedModules));
  }

  @override
  Future<void> deleteLesson(String courseId, String moduleId, String lessonId) async {
    final course = await getCourseById(courseId);
    if (course == null) return;

    final updatedModules = course.modules.map((m) {
      if (m.id == moduleId) {
        final updatedLessons = m.lessons.where((l) => l.id != lessonId).toList();
        return m.copyWith(lessons: updatedLessons);
      }
      return m;
    }).toList();

    await updateCourse(course.copyWith(modules: updatedModules));
  }

  Future<void> _logXApi({
    required String verbId,
    required String objectId,
    required String objectType,
    required String objectName,
    bool? success,
  }) async {
    if (analyticsRepository == null) return;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final actor = XApiActor(
      mbox: 'mailto:${user.uid}@sudqollanma.uz',
      name: user.displayName ?? 'User',
    );

    final statement = XApiStatement(
      actor: actor,
      verb: XApiVerb(id: verbId, display: {'en-US': verbId.split('/').last}),
      object: XApiObject(
        id: objectId,
        definition: {
          'type': objectType,
          'name': {'en-US': objectName},
        },
      ),
      result: success != null ? XApiResult(success: success, completion: success) : null,
      timestamp: DateTime.now(),
    );

    await analyticsRepository!.recordStatement(statement);
  }
}
