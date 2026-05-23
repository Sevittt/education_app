// lib/features/quiz/domain/usecases/get_quiz_by_id.dart
import '../entities/quiz.dart';
import '../repositories/quiz_repository.dart';

class GetQuizById {
  final QuizRepository repository;

  GetQuizById(this.repository);

  Future<Quiz?> call(String id) {
    return repository.getQuizById(id);
  }
}
