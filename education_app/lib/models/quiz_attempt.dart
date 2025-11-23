// lib/models/quiz_attempt.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

class QuizAttempt {
  final String id;
  final String userId;
  final String quizId;
  final String quizTitle; // Added this field
  final int score;
  final int totalQuestions;
  final Timestamp attemptedAt;

  QuizAttempt({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.quizTitle, // Added this field
    required this.score,
    required this.totalQuestions,
    required this.attemptedAt,
  });

  factory QuizAttempt.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    // If data is null, the document might be empty or malformed.
    // Throw an exception as the object cannot be reliably created.
    if (data == null) {
      throw FormatException(
        "Error: Document data is null for QuizAttempt doc ID: ${doc.id}. Cannot create QuizAttempt object.",
      );
    }

    // Validate and extract 'userId'
    final String userIdValue = data['userId'] as String? ?? '';
    if (userIdValue.isEmpty) {
      // Depending on your app's requirements, you might want to throw an exception
      // if userId is critical and cannot be empty.
      if (kDebugMode) {
        print(
          "Warning: 'userId' is missing or empty for QuizAttempt doc ID: ${doc.id}.",
        );
      }
      // Example: throw FormatException("Missing 'userId' for QuizAttempt doc ID: ${doc.id}");
    }

    // Validate and extract 'quizId'
    final String quizIdValue = data['quizId'] as String? ?? '';
    if (quizIdValue.isEmpty) {
      if (kDebugMode) {
        print(
          "Warning: 'quizId' is missing or empty for QuizAttempt doc ID: ${doc.id}.",
        );
      }
      // Example: throw FormatException("Missing 'quizId' for QuizAttempt doc ID: ${doc.id}");
    }

    // Validate and extract 'quizTitle'
    final String quizTitleValue =
        data['quizTitle'] as String? ?? 'Unnamed Quiz';
    if (quizTitleValue == 'Unnamed Quiz' &&
        (data['quizTitle'] == null ||
            (data['quizTitle'] is String && data['quizTitle'].isEmpty))) {
      if (kDebugMode) {
        print(
          "Warning: 'quizTitle' is null or empty for QuizAttempt doc ID: ${doc.id}. Defaulting to 'Unnamed Quiz'.",
        );
      }
    }

    // Validate and extract 'score'
    int scoreValue;
    if (data['score'] is num) {
      scoreValue = (data['score'] as num).toInt();
    } else {
      if (kDebugMode) {
        print(
          "Warning: 'score' is missing or not a number for QuizAttempt doc ID: ${doc.id}. Defaulting to 0.",
        );
      }
      scoreValue = 0; // Default value, or consider throwing FormatException
      // Example: throw FormatException("Invalid or missing 'score' for QuizAttempt doc ID: ${doc.id}");
    }

    // Validate and extract 'totalQuestions'
    int totalQuestionsValue;
    if (data['totalQuestions'] is num) {
      totalQuestionsValue = (data['totalQuestions'] as num).toInt();
    } else {
      if (kDebugMode) {
        print(
          "Warning: 'totalQuestions' is missing or not a number for QuizAttempt doc ID: ${doc.id}. Defaulting to 0.",
        );
      }
      totalQuestionsValue =
          0; // Default value, or consider throwing FormatException
      // Example: throw FormatException("Invalid or missing 'totalQuestions' for QuizAttempt doc ID: ${doc.id}");
    }

    // Validate and extract 'attemptedAt'
    Timestamp attemptedAtValue;
    if (data['attemptedAt'] is Timestamp) {
      attemptedAtValue = data['attemptedAt'] as Timestamp;
    } else {
      if (kDebugMode) {
        print(
          "Warning: 'attemptedAt' field is not a Timestamp for QuizAttempt doc ID: ${doc.id}. "
          "Actual type: ${data['attemptedAt']?.runtimeType}, Value: ${data['attemptedAt']}. "
          "Defaulting to Timestamp.now().",
        );
      }
      attemptedAtValue =
          Timestamp.now(); // Fallback, or consider throwing FormatException
      // Example: throw FormatException("Invalid or missing 'attemptedAt' for QuizAttempt doc ID: ${doc.id}");
    }

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

  // --- NEW: fromMap factory ---
  factory QuizAttempt.fromMap(Map<String, dynamic> data, String id) {
    return QuizAttempt(
      id: id,
      userId: data['userId'] as String? ?? '',
      quizId: data['quizId'] as String? ?? '',
      quizTitle: data['quizTitle'] as String? ?? 'Unnamed Quiz',
      score: (data['score'] as num?)?.toInt() ?? 0,
      totalQuestions: (data['totalQuestions'] as num?)?.toInt() ?? 0,
      attemptedAt: data['attemptedAt'] as Timestamp? ?? Timestamp.now(),
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

  // --- NEW: toMap method ---
  Map<String, dynamic> toMap() {
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
