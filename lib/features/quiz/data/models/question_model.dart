// lib/features/quiz/data/models/question_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/question.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    required super.questionText,
    required super.questionType,
    required super.options,
    required super.correctAnswer,
  });

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return QuestionModel(
      id: doc.id,
      questionText: data['questionText'] ?? '',
      questionType: QuestionType.values.byName(
        data['questionType'] ?? 'multipleChoice',
      ),
      options: List<String>.from(data['options'] ?? []),
      correctAnswer: data['correctAnswer'] ?? '',
    );
  }

  factory QuestionModel.fromMap(Map<String, dynamic> data, String id) {
    return QuestionModel(
      id: id,
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

  Map<String, dynamic> toMap() => toFirestore();
}
