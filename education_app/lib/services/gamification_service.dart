import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/users.dart';

class GamificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'users';

  // Singleton pattern
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  /// Award points to a user for a specific action
  Future<void> awardPoints({
    required String userId,
    required int points,
    required String actionType,
    String? description,
  }) async {
    final userRef = _firestore.collection(_collectionName).doc(userId);

    return _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) return;

      final currentXP = (userDoc.data()?['xp'] as num?)?.toInt() ?? 0;
      final newXP = currentXP + points;
      final newLevel = AppUser.getLevelFromXP(newXP);

      transaction.update(userRef, {
        'xp': FieldValue.increment(points),
        'level': newLevel,
        // Optional: you could add a 'history' subcollection logic here if detailed logs are needed
      });
      
      // We could also log the action to a subcollection 'xp_history' here
      // but keeping it simple for now as per requirements.
    });
  }

  /// Get the leaderboard (Top 20 users by XP)
  Stream<List<AppUser>> getLeaderboard({int limit = 20}) {
    return _firestore
        .collection(_collectionName)
        .orderBy('xp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // We need to construct AppUser manually because standard fromFirestore 
        // might assume complete profile data which allows nulls, handled by our model.
        return AppUser.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Calculate level based on XP (Helper, though AppUser has static method too)
  String getLevel(int xp) {
    return AppUser.getLevelFromXP(xp);
  }
}
