import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/users.dart';
import '../models/xapi/xapi_statement.dart'; 
import '../config/gamification_rules.dart';

class GamificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'users';

  // Singleton pattern
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  /// ENGINE: Calculates XP for a quiz question based on correctness and speed
  int calculateQuizScore(bool isCorrect, int timeTakenSeconds) {
    if (!isCorrect) return 0;
    
    int points = GamificationRules.xpQuizBase;
    
    // speed bonus (within 5 seconds)
    if (timeTakenSeconds <= 5) {
      points += GamificationRules.xpSpeedBonus;
    }
    
    return points;
  }

  /// ENGINE: Daily Streak Logic (Duolingo style)
  Future<void> checkAndUpdateStreak(String userId) async {
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

  /// ENGINE: Central method to process xAPI statements and award tailored XP
  Future<void> processXApiEvent(XApiStatement statement) async {
    final userId = statement.actor.mbox.replaceAll('mailto:', '');

    if (userId.isEmpty) {
      print('GamificationEngine: No userId found in statement.');
      return;
    }
    
    // We need to fetch the user by email/username if it's not a UID
    // For now, let's assume valid UID is passed mostly, or handle lookup later.
    // In our XApiService, we put "mailto:email" or "mailto:no-email-UID".
    // This is Tricky. 
    // Optimization: XApiService should probably pass UID separately or we strictly use UID in Account.
    // Let's rely on the Helper awardPoints for now if ID is tricky, BUT 
    // let's try to extract ID if it's "no-email-UID".
    
    // 1. Extract UID from mbox (format: mailto:UID@sudqollanma.uz)
    String finalUserId = userId;
    if (userId.contains('@')) {
        // Extract what's before @ and after mailto:
        finalUserId = userId.split('@')[0];
    }
    
    // Safety check: ensure we aren't using a placeholder
    if (finalUserId == 'guest') {
        print('GamificationEngine: Skipping reward for guest user.');
        return;
    }

    // Determine Action and XP based on Rules
    int pointsToAward = 0;
    String actionType = 'unknown';
    String description = '';

    final verbId = statement.verb.id; // e.g. http://adlnet.gov/expapi/verbs/completed
    final activityType = statement.object.definition['type'] as String?;

    // 1. Video Watch
    if (activityType == 'http://adlnet.gov/expapi/activities/video') {
        if (verbId.endsWith('completed') || verbId.endsWith('experienced')) {
            pointsToAward = GamificationRules.xpVideoComplete;
            actionType = 'video_watched';
            description = 'Watched video';
        }
    }
    // 2. Quiz Completion
    else if (activityType == 'http://adlnet.gov/expapi/activities/assessment') {
            // Quiz base score is already calculated or we replace it
            pointsToAward = GamificationRules.xpQuizPass;
            actionType = 'quiz_passed';
            description = 'Passed quiz';
            
            // Check for Perfect Score Bonus
            final rawScore = statement.result?.score?['raw'];
            if (rawScore == 100) {
                 pointsToAward += GamificationRules.xpQuizPerfect;
                 actionType = 'quiz_aced'; // Special action for gatekeeper
                 description += ' (Perfect Score!)';
            }
            
            // Speed Bonus from result.duration (ISO 8601 like PT4S)
            final durationStr = statement.result?.duration; // e.g., "PT4S"
            if (durationStr != null && durationStr.startsWith('PT')) {
               final secondsStr = durationStr.substring(2).replaceAll('S', '');
               final seconds = int.tryParse(secondsStr);
               if (seconds != null && seconds <= 5) {
                   pointsToAward += GamificationRules.xpSpeedBonus;
                   description += ' (Speed Bonus!)';
               }
            }
        }
    // 3. Article Read/Scroll
    else if (activityType == 'http://adlnet.gov/expapi/activities/article') {
        if (verbId.endsWith('completed')) {
            pointsToAward = GamificationRules.xpArticleScroll;
            actionType = 'article_read';
            description = 'Read article';
        }
    }
    // 4. Simulation
    else if (activityType == 'http://adlnet.gov/expapi/activities/simulation') {
        if (verbId.endsWith('performed') || verbId.endsWith('completed')) {
             pointsToAward = GamificationRules.xpSimComplete;
             actionType = 'simulation_completed'; // Triggers Gatekeeper
             description = 'Completed simulation';
        } else if (verbId.endsWith('interacted')) {
             pointsToAward = GamificationRules.xpSimInteraction;
             actionType = 'simulation_interaction';
             description = 'Simulation interaction';
        }
    }

    if (pointsToAward > 0) {
        print('GamificationEngine: Awarding $pointsToAward XP for $actionType to user $finalUserId');
        await awardPoints(
            userId: finalUserId,
            points: pointsToAward,
            actionType: actionType,
            description: description,
        );
    } else {
        print('GamificationEngine: No points awarded for activity $activityType, verb $verbId');
    }
  }

  /// Legacy helper for direct calls (still used by VideoPlayerScreen)
  /// Now reinforced with Gatekeeper Logic
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
      
      // We could also log the action to a subcollection 'xp_history' here
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
        return AppUser.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}
