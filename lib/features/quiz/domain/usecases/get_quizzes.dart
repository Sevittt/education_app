// lib/features/quiz/domain/usecases/get_quizzes.dart
import '../entities/quiz.dart';
import '../repositories/quiz_repository.dart';

class GetQuizzes {
  final QuizRepository repository;

  GetQuizzes(this.repository);

  Future<List<Quiz>> call() {
    return repository.getQuizzes();
  }
}
