// lib/features/quiz/domain/entities/quiz_attempt.dart
import 'package:equatable/equatable.dart';

class QuizAttempt extends Equatable {
  final String id;
  final String userId;
  final String quizId;
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final DateTime attemptedAt;
  final int? timeTakenSeconds;

  const QuizAttempt({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.attemptedAt,
    this.timeTakenSeconds,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        quizId,
        quizTitle,
        score,
        totalQuestions,
        attemptedAt,
        timeTakenSeconds,
      ];
}
