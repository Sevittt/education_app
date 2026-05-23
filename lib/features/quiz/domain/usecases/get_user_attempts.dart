// lib/features/quiz/domain/usecases/get_user_attempts.dart
import '../entities/quiz_attempt.dart';
import '../repositories/quiz_repository.dart';

class GetUserAttempts {
  final QuizRepository repository;

  GetUserAttempts(this.repository);

  Future<List<QuizAttempt>> call(String userId) {
    return repository.getUserAttempts(userId);
  }
}
