import '../../../../features/auth/domain/entities/app_user.dart';
import '../repositories/gamification_repository.dart';

class GetLeaderboard {
  final GamificationRepository repository;

  GetLeaderboard(this.repository);

  Stream<List<AppUser>> call({int limit = 20}) {
    return repository.getLeaderboard(limit: limit);
  }
}
