
import 'package:sud_qollanma/core/constants/gamification_rules.dart';
import '../datasources/gamification_remote_datasource.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/repositories/gamification_repository.dart';

class GamificationRepositoryImpl implements GamificationRepository {
  final GamificationRemoteDataSource _remoteDataSource;

  GamificationRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> updateStreak(String userId) async {
    return _remoteDataSource.updateStreak(userId);
  }

  @override
  Future<void> awardPoints({
    required String userId,
    required int points,
    required String actionType,
    String? description,
    String? contentId,
  }) async {
    return _remoteDataSource.awardPoints(
      userId: userId,
      points: points,
      actionType: actionType,
      description: description,
      contentId: contentId,
    );
  }

  @override
  Future<int> calculateQuizScore({required bool isCorrect, required int timeTakenSeconds}) async {
     if (!isCorrect) return 0;
    
    int points = GamificationRules.xpQuizBase;
    
    // speed bonus (within 5 seconds)
    if (timeTakenSeconds <= 5) {
      points += GamificationRules.xpSpeedBonus;
    }
    
    return points;
  }

  @override
  Stream<List<AppUser>> getLeaderboard({int limit = 20}) {
    return _remoteDataSource.getLeaderboard(limit: limit);
  }

  @override
  Stream<List<AppUser>> getLeaderboardByRegion({required String regionId, int limit = 20}) {
    return _remoteDataSource.getLeaderboardByRegion(regionId: regionId, limit: limit);
  }

  @override
  Stream<List<AppUser>> getLeaderboardByCourtType({required String regionId, required String courtTypeId, int limit = 20}) {
    return _remoteDataSource.getLeaderboardByCourtType(regionId: regionId, courtTypeId: courtTypeId, limit: limit);
  }

  @override
  Stream<List<AppUser>> getLeaderboardByCourt({required String courtId, int limit = 20}) {
    return _remoteDataSource.getLeaderboardByCourt(courtId: courtId, limit: limit);
  }
}
