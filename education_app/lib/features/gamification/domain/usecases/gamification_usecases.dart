import '../repositories/gamification_repository.dart';

class UpdateStreak {
  final GamificationRepository repository;

  UpdateStreak(this.repository);

  Future<void> call(String userId) async {
    return repository.updateStreak(userId);
  }
}

class AwardPoints {
  final GamificationRepository repository;

  AwardPoints(this.repository);

  Future<void> call({
    required String userId,
    required int points,
    required String actionType,
    String? description,
  }) async {
    return repository.awardPoints(
      userId: userId,
      points: points,
      actionType: actionType,
      description: description,
    );
  }
}

class CalculateQuizScore {
  final GamificationRepository repository;

  CalculateQuizScore(this.repository);

  Future<int> call({required bool isCorrect, required int timeTakenSeconds}) async {
    return repository.calculateQuizScore(isCorrect: isCorrect, timeTakenSeconds: timeTakenSeconds);
  }
}
