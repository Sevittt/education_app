import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../config/gamification_rules.dart';
import '../../../auth/data/models/app_user_model.dart'; // Import Model
import '../../../auth/domain/entities/app_user.dart';

abstract class GamificationRemoteDataSource {
  Future<void> updateStreak(String userId);
  Future<void> awardPoints({
    required String userId,
    required int points,
    required String actionType,
    String? description,
  });
  Stream<List<AppUser>> getLeaderboard({int limit = 20});
}

class GamificationRemoteDataSourceImpl implements GamificationRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'users';

  @override
  Future<void> updateStreak(String userId) async {
    final userRef = _firestore.collection(_collectionName).doc(userId);
    
    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) return;
      
      final data = userDoc.data()!;
      final lastLogin = data['lastLoginDate'] != null 
          ? DateTime.tryParse(data['lastLoginDate'] as String) 
          : null;
      int currentStreak = (data['currentStreak'] as num?)?.toInt() ?? 0;
      int currentXP = (data['xp'] as num?)?.toInt() ?? 0;
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      if (lastLogin == null) {
        // First time
        currentStreak = 1;
        currentXP += GamificationRules.xpLoginStreak;
      } else {
        final lastLoginDay = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);
        final difference = today.difference(lastLoginDay).inDays;
        
        if (difference == 1) {
          // Consecutive day
          currentStreak++;
          currentXP += GamificationRules.xpLoginStreak;
        } else if (difference > 1) {
          // Streak broken
          currentStreak = 1;
          currentXP += GamificationRules.xpLoginStreak;
        } else if (difference == 0) {
          // Already logged in today
          return;
        }
      }
      
      transaction.update(userRef, {
        'currentStreak': currentStreak,
        'xp': currentXP,
        'lastLoginDate': now.toIso8601String(),
      });
    });
  }

  @override
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

      final data = userDoc.data()!;
      int currentXP = (data['xp'] as num?)?.toInt() ?? 0;
      int quizzesPassed = (data['quizzesPassed'] as num?)?.toInt() ?? 0;
      int quizzesAced = (data['totalQuizzesAced'] as num?)?.toInt() ?? 0;
      int currentStreak = (data['currentStreak'] as num?)?.toInt() ?? 0;
      int simsCompleted = (data['simulationsCompleted'] as num?)?.toInt() ?? 0;

      // 1. Calculate New XP
      final newXP = currentXP + points;
      
      // 2. Update Counters based on Action Type
      if (actionType == 'quiz_passed') {
        quizzesPassed++;
      } else if (actionType == 'quiz_aced') {
        quizzesPassed++;
        quizzesAced++;
      } else if (actionType == 'simulation_completed') {
        simsCompleted++;
      }

      // 3. Gatekeeper Logic: Calculate new level
      final newLevel = GamificationRules.calculateLevel(
        xp: newXP, 
        quizzesPassed: quizzesPassed, 
        quizzesAced: quizzesAced,
        currentStreak: currentStreak,
        simulationsCompleted: simsCompleted
      );

      transaction.update(userRef, {
        'xp': newXP,
        'level': newLevel,
        'quizzesPassed': quizzesPassed,
        'totalQuizzesAced': quizzesAced,
        'simulationsCompleted': simsCompleted,
        'lastActivity': FieldValue.serverTimestamp(),
      });
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
}
