import '../entities/question.dart';
import '../entities/quiz.dart';
import '../entities/quiz_attempt.dart';

abstract class QuizRepository {
  Future<List<Quiz>> getQuizzes();
  Future<List<Quiz>> getQuizzesByResourceId(String resourceId);
  Future<Quiz?> getQuizById(String id);
  Future<void> submitQuizAttempt(QuizAttempt attempt);
  Future<List<QuizAttempt>> getUserAttempts(String userId);
  Future<List<QuizAttempt>> getRecentUserAttempts(String userId, {int limit = 3});
  Future<void> deleteQuiz(String id);
  Future<String> createQuiz(Quiz quiz);
  Future<void> addQuestion(String quizId, Question question);
}
