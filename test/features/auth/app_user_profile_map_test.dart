import 'package:flutter_test/flutter_test.dart';
import 'package:sud_qollanma/features/auth/data/models/app_user_model.dart';
import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart';

void main() {
  test('toProfileMap rol, XP va hisoblagichlarni yozmaydi', () {
    const user = AppUserModel(
      id: 'u1',
      name: 'Ali',
      role: CourtRole.admin,
      xp: 9999,
      level: 'levelMaster',
      quizzesPassed: 10,
      currentStreak: 30,
      fcmToken: 'token',
    );

    final map = user.toProfileMap();

    const protectedFields = [
      'role', 'xp', 'level', 'quizzesPassed', 'totalQuizzesAced',
      'simulationsCompleted', 'currentStreak', 'lastLoginDate',
      'previousRank', 'fastestQuizTime', 'awardedContentIds', 'lastActivity',
      'id', 'email', 'fcmToken', 'telegram_id',
    ];
    for (final field in protectedFields) {
      expect(map.containsKey(field), isFalse, reason: field);
    }
    expect(map['name'], 'Ali');
  });

  test("telegram_id faqat o'qiladi: toMap ga yozilmaydi", () {
    final user = AppUserModel.fromMap(
      {'name': 'Ali', 'role': 'judge', 'telegram_id': 123456789},
      'u1',
    );
    expect(user.telegramId, '123456789');
    expect(user.toMap().containsKey('telegram_id'), isFalse);
    expect(user.toProfileMap().containsKey('telegram_id'), isFalse);
  });
}
