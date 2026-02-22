// lib/features/quiz/domain/usecases/submit_quiz_attempt.dart
import '../entities/quiz_attempt.dart';
import '../repositories/quiz_repository.dart';
import '../../../analytics/domain/usecases/analytics_usecases.dart';

class SubmitQuizAttempt {
  final QuizRepository repository;
  final TrackQuizCompleted? trackQuizCompleted; 

  SubmitQuizAttempt(this.repository, {this.trackQuizCompleted});

  Future<void> call(QuizAttempt attempt) async {
    // 1. Save Attempt
    await repository.submitQuizAttempt(attempt);

    // 2. Track Analytics (Side Effect)
    if (trackQuizCompleted != null) {
      try {
        final double percentage = attempt.totalQuestions > 0
            ? (attempt.score / attempt.totalQuestions) * 100
            : 0.0;

        final bool passed = percentage >= 70.0;

        await trackQuizCompleted!(
          quizId: attempt.quizId,
          title: attempt.quizTitle,
          score: percentage,
          passed: passed,
          timeTakenSeconds: attempt.timeTakenSeconds,
        );
      } catch (e) {
        print("Analytics Error in SubmitQuizAttempt: $e");
      }
    }
  }
}
