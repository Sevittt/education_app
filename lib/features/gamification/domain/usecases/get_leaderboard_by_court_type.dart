import '../repositories/gamification_repository.dart';
import '../../../auth/domain/entities/app_user.dart';

class GetLeaderboardByCourtType {
  final GamificationRepository repository;

  GetLeaderboardByCourtType(this.repository);

  Stream<List<AppUser>> call({required String regionId, required String courtTypeId, int limit = 20}) {
    return repository.getLeaderboardByCourtType(regionId: regionId, courtTypeId: courtTypeId, limit: limit);
  }
}
