import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart';

abstract class GamificationRepository {
  Future<void> updateStreak(String userId);
  Future<void> awardPoints({
    required String userId,
    required int points,
    required String actionType,
    String? description,
    String? contentId,
  });
  Future<int> calculateQuizScore({required bool isCorrect, required int timeTakenSeconds});
  Stream<List<AppUser>> getLeaderboard({int limit = 20});
  Stream<List<AppUser>> getLeaderboardByRegion({required String regionId, int limit = 20});
  Stream<List<AppUser>> getLeaderboardByCourtType({required String regionId, required String courtTypeId, int limit = 20});
  Stream<List<AppUser>> getLeaderboardByCourt({required String courtId, int limit = 20});
}
