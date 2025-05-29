// lib/models/question.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum QuestionType { multipleChoice, trueFalse }

class Question {
  final String id;
  final String questionText;
  final QuestionType questionType;
  final List<String>
  options; // For multipleChoice, list of choices; for trueFalse, it will be ["True", "False"]
  final String correctAnswer; // The value of the correct option from the list

  Question({
    required this.id,
    required this.questionText,
    required this.questionType,
    required this.options,
    required this.correctAnswer,
  });

  factory Question.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Question(
      id: doc.id,
      questionText: data['questionText'] ?? '',
      questionType: QuestionType.values.byName(
        data['questionType'] ?? 'multipleChoice',
      ),
      options: List<String>.from(data['options'] ?? []),
      correctAnswer: data['correctAnswer'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'questionText': questionText,
      'questionType': questionType.name,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }
}
