import '../repositories/gamification_repository.dart';
import '../../../auth/domain/entities/app_user.dart';

class GetLeaderboardByRegion {
  final GamificationRepository repository;

  GetLeaderboardByRegion(this.repository);

  Stream<List<AppUser>> call({required String regionId, int limit = 20}) {
    return repository.getLeaderboardByRegion(regionId: regionId, limit: limit);
  }
}
