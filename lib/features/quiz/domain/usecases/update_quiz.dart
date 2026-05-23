// lib/features/quiz/domain/usecases/update_quiz.dart
import '../entities/quiz.dart';
import '../repositories/quiz_repository.dart';

class UpdateQuiz {
  final QuizRepository repository;

  UpdateQuiz(this.repository);

  Future<void> call(Quiz quiz) {
    return repository.updateQuiz(quiz);
  }
}
