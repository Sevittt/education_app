import '../repositories/quiz_repository.dart';

class DeleteQuiz {
  final QuizRepository repository;

  DeleteQuiz(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteQuiz(id);
  }
}
