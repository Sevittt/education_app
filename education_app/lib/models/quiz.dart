// lib/models/quiz.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'question.dart';

class Quiz {
  final String id;
  final String title;
  final String description;
  final String resourceId; // Links this quiz to a specific learning resource
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.resourceId,
    required this.questions,
  });

  factory Quiz.fromFirestore(DocumentSnapshot doc, List<Question> questions) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Quiz(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      resourceId: data['resourceId'] ?? '',
      questions: questions,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'resourceId': resourceId,
    };
  }
}
