import '../repositories/quiz_repository.dart';

class DeleteQuestionFromQuiz {
  final QuizRepository repository;

  DeleteQuestionFromQuiz(this.repository);

  Future<void> call(String quizId, String questionId) {
    return repository.deleteQuestion(quizId, questionId);
  }
}
