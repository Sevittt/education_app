import '../repositories/gamification_repository.dart';

export 'get_leaderboard_by_region.dart';
export 'get_leaderboard_by_court_type.dart';
export 'get_leaderboard_by_court.dart';

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
    required String actionType,
    required String targetId,
    String? courseId,
    bool speedBonus = false,
  }) async {
    return repository.awardPoints(
      actionType: actionType,
      targetId: targetId,
      courseId: courseId,
      speedBonus: speedBonus,
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
