// lib/models/quiz_attempt.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

class QuizAttempt {
  final String id;
  final String userId;
  final String quizId;
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final Timestamp attemptedAt;

  QuizAttempt({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.attemptedAt,
  });

  factory QuizAttempt.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    // If data is null, something is very wrong with the document itself.
    if (data == null) {
      if (kDebugMode) {
        print("Error: Document data is null for QuizAttempt doc ID: ${doc.id}");
      }
      // Return a 'dummy' or throw an error, depending on how you want to handle this.
      // For now, let's create a fallback to prevent immediate crash, but this indicates bad data.
      return QuizAttempt(
        id: doc.id,
        userId: 'error_user_id',
        quizId: 'error_quiz_id',
        quizTitle: 'Error: Null Data',
        score: 0,
        totalQuestions: 0,
        attemptedAt: Timestamp.now(),
      );
    }

    Timestamp attemptedAtValue;
    if (data['attemptedAt'] is Timestamp) {
      attemptedAtValue = data['attemptedAt'];
    } else {
      if (kDebugMode) {
        print(
          "Warning: 'attemptedAt' field was not a Timestamp for doc ${doc.id}. Actual type: ${data['attemptedAt']?.runtimeType}, Value: ${data['attemptedAt']}. Defaulting to Timestamp.now().",
        );
      }
      attemptedAtValue = Timestamp.now();
    }

    String userIdValue = data['userId'] ?? '';
    if (userIdValue.isEmpty && kDebugMode) {}
    String quizIdValue = data['quizId'] ?? '';
    if (quizIdValue.isEmpty && kDebugMode) {}
    String quizTitleValue = data['quizTitle'] ?? 'Unnamed Quiz';
    if ((data['quizTitle'] == null || data['quizTitle'].isEmpty) &&
        kDebugMode) {}

    int scoreValue = 0;
    if (data['score'] is num) {
      scoreValue = data['score'].toInt();
    } else if (data['score'] != null && kDebugMode) {
    } else if (data['score'] == null && kDebugMode) {}

    int totalQuestionsValue = 0;
    if (data['totalQuestions'] is num) {
      totalQuestionsValue = data['totalQuestions'].toInt();
    } else if (data['totalQuestions'] != null && kDebugMode) {
    } else if (data['totalQuestions'] == null && kDebugMode) {}

    return QuizAttempt(
      id: doc.id,
      userId: userIdValue,
      quizId: quizIdValue,
      quizTitle: quizTitleValue,
      score: scoreValue,
      totalQuestions: totalQuestionsValue,
      attemptedAt: attemptedAtValue,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'quizId': quizId,
      'quizTitle': quizTitle,
      'score': score,
      'totalQuestions': totalQuestions,
      'attemptedAt': attemptedAt,
    };
  }
}
