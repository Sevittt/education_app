// lib/features/quiz/domain/usecases/get_recent_user_attempts.dart
import '../entities/quiz_attempt.dart';
import '../repositories/quiz_repository.dart';

class GetRecentUserAttempts {
  final QuizRepository repository;

  GetRecentUserAttempts(this.repository);

  Future<List<QuizAttempt>> call(String userId, {int limit = 3}) {
    return repository.getRecentUserAttempts(userId, limit: limit);
  }
}
