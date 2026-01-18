import '../../domain/entities/quiz.dart';
import '../../domain/entities/quiz_attempt.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../datasources/quiz_remote_datasource.dart';
import '../models/quiz_attempt_model.dart';
import '../../domain/entities/question.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';

class QuizRepositoryImpl implements QuizRepository {
  final QuizRemoteDataSource remoteDataSource;

  QuizRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<Quiz>> getQuizzes() async {
    return await remoteDataSource.getQuizzes();
  }

  @override
  Future<List<Quiz>> getQuizzesByResourceId(String resourceId) async {
    return await remoteDataSource.getQuizzesByResourceId(resourceId);
  }

  @override
  Future<Quiz?> getQuizById(String id) async {
    return await remoteDataSource.getQuizById(id);
  }

  @override
  Future<List<QuizAttempt>> getUserAttempts(String userId) async {
    return await remoteDataSource.getUserAttempts(userId);
  }

  @override
  Future<List<QuizAttempt>> getRecentUserAttempts(String userId, {int limit = 3}) async {
    return await remoteDataSource.getRecentUserAttempts(userId, limit: limit);
  }

  @override
  Future<void> deleteQuiz(String id) async {
    await remoteDataSource.deleteQuiz(id);
  }

  @override
  Future<String> createQuiz(Quiz quiz) async {
    // Convert Entity to Model. Note: ID might be empty initially, Firestore generates it.
    final quizModel = QuizModel(
      id: quiz.id,
      title: quiz.title,
      description: quiz.description,
      resourceId: quiz.resourceId,
      questions: [], 
    );
    return await remoteDataSource.createQuiz(quizModel);
  }

  @override
  Future<void> addQuestion(String quizId, Question question) async {
    final questionModel = QuestionModel(
      id: question.id,
      questionText: question.questionText,
      questionType: question.questionType,
      options: question.options,
      correctAnswer: question.correctAnswer,
    );
    await remoteDataSource.addQuestion(quizId, questionModel);
  }

  @override
  Future<void> submitQuizAttempt(QuizAttempt attempt) async {
    // Convert Entity to Model for Data Layer
    final attemptModel = QuizAttemptModel(
      id: attempt.id,
      userId: attempt.userId,
      quizId: attempt.quizId,
      quizTitle: attempt.quizTitle,
      score: attempt.score,
      totalQuestions: attempt.totalQuestions,
      attemptedAt: attempt.attemptedAt,
      timeTakenSeconds: attempt.timeTakenSeconds,
    );

    // 1. Save to Firestore
    await remoteDataSource.submitQuizAttempt(attemptModel);
  }
}
