// lib/features/quiz/domain/usecases/get_quizzes_by_resource_id.dart
import '../entities/quiz.dart';
import '../repositories/quiz_repository.dart';

class GetQuizzesByResourceId {
  final QuizRepository repository;

  GetQuizzesByResourceId(this.repository);

  Future<List<Quiz>> call(String resourceId) {
    return repository.getQuizzesByResourceId(resourceId);
  }
}
