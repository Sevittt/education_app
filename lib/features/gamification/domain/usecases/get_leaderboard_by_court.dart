import '../repositories/gamification_repository.dart';
import '../../../auth/domain/entities/app_user.dart';

class GetLeaderboardByCourt {
  final GamificationRepository repository;

  GetLeaderboardByCourt(this.repository);

  Stream<List<AppUser>> call({required String courtId, int limit = 20}) {
    return repository.getLeaderboardByCourt(courtId: courtId, limit: limit);
  }
}
