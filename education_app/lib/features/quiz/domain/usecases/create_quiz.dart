import '../entities/quiz.dart';
import '../repositories/quiz_repository.dart';

class CreateQuiz {
  final QuizRepository repository;

  CreateQuiz(this.repository);

  Future<String> call(Quiz quiz) {
    return repository.createQuiz(quiz);
  }
}
