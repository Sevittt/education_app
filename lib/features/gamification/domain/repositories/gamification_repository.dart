import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart';

abstract class GamificationRepository {
  Future<void> updateStreak(String userId);

  /// XP miqdorini server belgilaydi va bir kontent uchun bir marta beradi.
  /// [targetId] — kontent ID'si (quiz, video, maqola, dars yoki kurs);
  /// [courseId] faqat `lesson_completed` uchun kerak.
  Future<void> awardPoints({
    required String actionType,
    required String targetId,
    String? courseId,
    bool speedBonus = false,
  });
  Future<int> calculateQuizScore({required bool isCorrect, required int timeTakenSeconds});
  Stream<List<AppUser>> getLeaderboard({int limit = 20});
  Stream<List<AppUser>> getLeaderboardByRegion({required String regionId, int limit = 20});
  Stream<List<AppUser>> getLeaderboardByCourtType({required String regionId, required String courtTypeId, int limit = 20});
  Stream<List<AppUser>> getLeaderboardByCourt({required String courtId, int limit = 20});
}
