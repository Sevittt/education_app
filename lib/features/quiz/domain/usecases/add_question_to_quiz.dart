import '../entities/question.dart';
import '../repositories/quiz_repository.dart';

class AddQuestionToQuiz {
  final QuizRepository repository;

  AddQuestionToQuiz(this.repository);

  Future<void> call(String quizId, Question question) {
    return repository.addQuestion(quizId, question);
  }
}
