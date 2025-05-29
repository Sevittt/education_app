// lib/models/quiz_attempt.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class QuizAttempt {
  final String id;
  final String userId;
  final String quizId;
  final int score;
  final int totalQuestions;
  final Timestamp attemptedAt;

  QuizAttempt({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.attemptedAt,
  });

  factory QuizAttempt.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return QuizAttempt(
      id: doc.id,
      userId: data['userId'] ?? '',
      quizId: data['quizId'] ?? '',
      score: data['score'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      attemptedAt: data['attemptedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'quizId': quizId,
      'score': score,
      'totalQuestions': totalQuestions,
      'attemptedAt': attemptedAt,
    };
  }
}
