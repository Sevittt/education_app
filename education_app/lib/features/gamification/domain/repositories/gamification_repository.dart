import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart';

abstract class GamificationRepository {
  Future<void> updateStreak(String userId);
  Future<void> awardPoints({
    required String userId,
    required int points,
    required String actionType,
    String? description,
  });
  Future<int> calculateQuizScore({required bool isCorrect, required int timeTakenSeconds});
  Stream<List<AppUser>> getLeaderboard({int limit = 20});
}
