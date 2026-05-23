import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/user_course_progress_entity.dart';
import '../../domain/repositories/course_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository repository;

  List<CourseEntity> _courses = [];
  List<CourseEntity> get courses => _courses;

  final Map<String, UserCourseProgressEntity> _progressMap = {};
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  StreamSubscription? _coursesSub;
  StreamSubscription? _progressSub;

  CourseProvider({required this.repository}) {
    // Ilova ochilganda kurslarni eshitib boramiz
    _initWatch();
  }

  void _initWatch() {
    _coursesSub = repository.watchCourses().listen((data) {
      _courses = data;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      notifyListeners();
    });

    // Foydalanuvchi auth holatiga qarab progresslarni eshitamiz
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _progressSub?.cancel();
      _progressMap.clear();
      
      if (user != null) {
        _progressSub = repository.watchUserAllProgress(user.uid).listen((data) {
          for (var p in data) {
            _progressMap[p.courseId] = p;
          }
          notifyListeners();
        });
      } else {
        notifyListeners();
      }
    });
  }

  // --- O'qish ---

  UserCourseProgressEntity? getUserProgress(String courseId) {
    return _progressMap[courseId];
  }

  Future<void> loadCourses({String? roleFilter, String? difficulty}) async {
    _setLoading(true);
    try {
      _courses = await repository.getCourses(
        roleFilter: roleFilter,
        difficulty: difficulty,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Admin uchun: barcha kurslarni (draft ham) yuklaydi
  Future<List<CourseEntity>> loadAllCoursesAdmin() async {
    try {
      return await repository.getAllCoursesAdmin();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // --- Amal qilish ---

  Future<void> startCourse(String courseId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    try {
      await repository.startCourse(user.uid, courseId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markLessonComplete(String courseId, String lessonId, String lessonType, {int? score}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await repository.markLessonComplete(user.uid, courseId, lessonId, lessonType, score: score);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // --- Admin ---

  Future<String?> createCourse(CourseEntity course) async {
    _setLoading(true);
    try {
      final id = await repository.createCourse(course);
      _error = null;
      return id;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCourse(CourseEntity course) async {
    _setLoading(true);
    try {
      await repository.updateCourse(course);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCourse(String id) async {
    _setLoading(true);
    try {
      await repository.deleteCourse(id);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  @override
  void dispose() {
    _coursesSub?.cancel();
    _progressSub?.cancel();
    super.dispose();
  }
}
