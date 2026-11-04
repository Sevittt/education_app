import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../auth/data/models/app_user_model.dart'; // Import Model
import '../../../auth/domain/entities/app_user.dart';

abstract class GamificationRemoteDataSource {
  Future<void> updateStreak(String userId);
  Future<void> awardPoints({
    required String actionType,
    required String targetId,
    String? courseId,
    bool speedBonus = false,
  });
  Stream<List<AppUser>> getLeaderboard({int limit = 20});
  Stream<List<AppUser>> getLeaderboardByRegion({required String regionId, int limit = 20});
  Stream<List<AppUser>> getLeaderboardByCourtType({required String regionId, required String courtTypeId, int limit = 20});
  Stream<List<AppUser>> getLeaderboardByCourt({required String courtId, int limit = 20});
}

/// XP va streak serverda (Cloud Functions: awardXp, updateStreak) hisoblanadi.
/// firestore.rules users hujjatidagi xp/level/hisoblagichlarni clientga yozdirmaydi.
class GamificationRemoteDataSourceImpl implements GamificationRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final String _collectionName = 'users';

  GamificationRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions =
            functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');

  /// [userId] e'tiborga olinmaydi: server chaqiruvchining auth uid'ini ishlatadi.
  @override
  Future<void> updateStreak(String userId) async {
    await _functions.httpsCallable('updateStreak').call<void>();
  }

  /// XP miqdorini server [actionType] va kontent bo'yicha o'zi belgilaydi;
  /// bir kontent uchun mukofot faqat bir marta beriladi.
  @override
  Future<void> awardPoints({
    required String actionType,
    required String targetId,
    String? courseId,
    bool speedBonus = false,
  }) async {
    await _functions.httpsCallable('awardXp').call<void>({
      'action': actionType,
      'targetId': targetId,
      if (courseId != null) 'courseId': courseId,
      if (speedBonus) 'speedBonus': true,
    });
  }

  @override
  Stream<List<AppUser>> getLeaderboard({int limit = 20}) {
    return _firestore
        .collection(_collectionName)
        .orderBy('xp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppUserModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Stream<List<AppUser>> getLeaderboardByRegion({required String regionId, int limit = 20}) {
    return _firestore
        .collection(_collectionName)
        .where('regionId', isEqualTo: regionId)
        .orderBy('xp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AppUserModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  @override
  Stream<List<AppUser>> getLeaderboardByCourtType({required String regionId, required String courtTypeId, int limit = 20}) {
    return _firestore
        .collection(_collectionName)
        .where('regionId', isEqualTo: regionId)
        .where('courtTypeId', isEqualTo: courtTypeId)
        .orderBy('xp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AppUserModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  @override
  Stream<List<AppUser>> getLeaderboardByCourt({required String courtId, int limit = 20}) {
    return _firestore
        .collection(_collectionName)
        .where('courtId', isEqualTo: courtId)
        .orderBy('xp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AppUserModel.fromMap(doc.data(), doc.id)).toList();
    });
  }
}
