// lib/features/quiz/data/models/quiz_attempt_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/quiz_attempt.dart';

class QuizAttemptModel extends QuizAttempt {
  const QuizAttemptModel({
    required super.id,
    required super.userId,
    required super.quizId,
    required super.quizTitle,
    required super.score,
    required super.totalQuestions,
    required super.attemptedAt,
    super.timeTakenSeconds,
  });

  factory QuizAttemptModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw FormatException(
        "Error: Document data is null for QuizAttempt doc ID: ${doc.id}",
      );
    }

    final String userIdValue = data['userId'] as String? ?? '';
    final String quizIdValue = data['quizId'] as String? ?? '';
    final String quizTitleValue =
        data['quizTitle'] as String? ?? 'Unnamed Quiz';
    
    int scoreValue = (data['score'] as num?)?.toInt() ?? 0;
    int totalQuestionsValue = (data['totalQuestions'] as num?)?.toInt() ?? 0;

    Timestamp attemptedAtValue;
    if (data['attemptedAt'] is Timestamp) {
      attemptedAtValue = data['attemptedAt'] as Timestamp;
    } else {
      if (kDebugMode) {
        print("Warning: 'attemptedAt' is not Timestamp. Defaulting to now.");
      }
      attemptedAtValue = Timestamp.now();
    }

    return QuizAttemptModel(
      id: doc.id,
      userId: userIdValue,
      quizId: quizIdValue,
      quizTitle: quizTitleValue,
      score: scoreValue,
      totalQuestions: totalQuestionsValue,
      attemptedAt: attemptedAtValue.toDate(),
      timeTakenSeconds: data['timeTakenSeconds'] as int?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'quizId': quizId,
      'quizTitle': quizTitle,
      'score': score,
      'totalQuestions': totalQuestions,
      'attemptedAt': Timestamp.fromDate(attemptedAt),
      'timeTakenSeconds': timeTakenSeconds,
    };
  }
}
