// lib/features/quiz/domain/entities/question.dart
import 'package:equatable/equatable.dart';

enum QuestionType { multipleChoice, trueFalse }

class Question extends Equatable {
  final String id;
  final String questionText;
  final QuestionType questionType;
  final List<String> options;
  final String correctAnswer;

  const Question({
    required this.id,
    required this.questionText,
    required this.questionType,
    required this.options,
    required this.correctAnswer,
  });

  @override
  List<Object?> get props => [id, questionText, questionType, options, correctAnswer];

  // Utility to help identifying correct option index
  bool isCorrect(int index) {
    if (index < 0 || index >= options.length) return false;
    return options[index] == correctAnswer;
  }
}
