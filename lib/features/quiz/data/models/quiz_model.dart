// lib/features/quiz/data/models/quiz_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/question.dart';

class QuizModel extends Quiz {
  const QuizModel({
    required super.id,
    required super.title,
    required super.description,
    required super.resourceId,
    required super.questions,
    super.questionCount,
  });

  factory QuizModel.fromFirestore(DocumentSnapshot doc, List<Question> questions) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return QuizModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      resourceId: data['resourceId'] ?? '',
      questions: questions,
      // Use cached count from Firestore if available (list view), else fall back to loaded questions
      questionCount: (data['questionCount'] as num?)?.toInt() ?? questions.length,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'resourceId': resourceId,
      'questionCount': questionCount,
    };
  }
}
