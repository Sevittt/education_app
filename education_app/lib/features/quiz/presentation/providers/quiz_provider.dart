// lib/features/quiz/presentation/providers/quiz_provider.dart
import 'package:flutter/foundation.dart';
import '../../domain/usecases/get_quizzes.dart';
import '../../domain/usecases/get_quiz_by_id.dart';
import '../../domain/usecases/get_quizzes_by_resource_id.dart';
import '../../domain/usecases/submit_quiz_attempt.dart';
import '../../domain/usecases/delete_quiz.dart';
import '../../domain/usecases/get_user_attempts.dart';
import '../../domain/usecases/get_recent_user_attempts.dart';
import '../../domain/usecases/create_quiz.dart';
import '../../domain/usecases/add_question_to_quiz.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/quiz_attempt.dart';
import '../../domain/entities/question.dart';

class QuizProvider extends ChangeNotifier {
  final GetQuizzes getQuizzes;
  final GetQuizById getQuizById;
  final SubmitQuizAttempt submitQuizAttempt;
  final GetUserAttempts getUserAttempts;
  final DeleteQuiz deleteQuizUseCase;
  final CreateQuiz createQuizUseCase;
  final AddQuestionToQuiz addQuestionToQuizUseCase;
  final GetRecentUserAttempts getRecentUserAttempts;
  final GetQuizzesByResourceId getQuizzesByResourceId;

  QuizProvider({
    required this.getQuizzes,
    required this.getQuizById,
    required this.submitQuizAttempt,
    required this.getUserAttempts,
    required this.getRecentUserAttempts,
    required this.getQuizzesByResourceId,
    required this.deleteQuizUseCase,
    required this.createQuizUseCase,
    required this.addQuestionToQuizUseCase,
  });

  List<Quiz> _quizzes = [];
  List<Quiz> get quizzes => _quizzes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // Stream for reactive updates
  Stream<List<Quiz>> get quizzesStream {
    return Stream.fromFuture(getQuizzes());
  }

  String? _error;
  String? get error => _error;

  Future<void> fetchQuizzes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _quizzes = await getQuizzes();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Quiz?> fetchQuizById(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await getQuizById(id);
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitResult(QuizAttempt attempt) async {
    await submitQuizAttempt(attempt);
  }

  Future<List<QuizAttempt>> fetchUserAttempts(String userId) async {
    return await getUserAttempts(userId);
  }

  Future<List<QuizAttempt>> fetchRecentUserAttempts(String userId, {int limit = 3}) async {
    return await getRecentUserAttempts(userId, limit: limit);
  }

  Future<List<Quiz>> fetchQuizzesForResource(String resourceId) async {
    return await getQuizzesByResourceId(resourceId);
  }

  Future<void> deleteQuiz(String id) async {
    await deleteQuizUseCase(id);
    // Invalidate caches or reload list
    await fetchQuizzes(); 
  }

  Future<String> createQuiz(Quiz quiz) async {
    final id = await createQuizUseCase(quiz);
    await fetchQuizzes();
    return id;
  }

  Future<void> addQuestion(String quizId, Question question) async {
    await addQuestionToQuizUseCase(quizId, question);
    // Note: We don't automatically refetch quiz here as it might be expensive.
    // The UI should handle refreshing the specific quiz view.
  }
}
