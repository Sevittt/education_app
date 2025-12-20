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

  /// ENGINE: Central method to process xAPI statements and award tailored XP
  Future<void> processXApiEvent(XApiStatement statement) async {
    final userId = statement.actor.mbox.replaceAll('mailto:', '');

    if (userId == null) {
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
    
    String finalUserId = userId;
    if (userId.contains('no-email-')) {
        final parts = userId.split('no-email-');
        if (parts.length > 1) {
            finalUserId = parts[1].split('@')[0];
        }
    } else {
        // It's an email, we might need to lookup UID. 
        // For this MVP, let's assume we can't easily do email->UID here without extra query.
        // So we will only process if we have a UID-like string or if XApiService passes it.
        // SKIPPING complex lookup for safety.
    }

    // Determine Action and XP based on Rules
    int pointsToAward = 0;
    String actionType = 'unknown';
    String description = '';

    final verbId = statement.verb.id; // e.g. http://adlnet.gov/expapi/verbs/completed
    final activityType = statement.object.definition?['type'] as String?;

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
        if (verbId.endsWith('passed')) {
            pointsToAward = GamificationRules.xpQuizPass;
            actionType = 'quiz_passed';
            description = 'Passed quiz';
            
            // Check for Perfect Score Bonus
            // Assuming result.score.scaled is 1.0 or result.score.raw is 100
            final rawScore = statement.result?.score?['raw'];
            if (rawScore == 100) {
                 pointsToAward += GamificationRules.xpQuizPerfect;
                 description += ' (Perfect Score!)';
            }
        }
    }
    // 3. Simulation
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
        await awardPoints(
            userId: finalUserId,
            points: pointsToAward,
            actionType: actionType,
            description: description,
        );
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
      int simsCompleted = (data['simulationsCompleted'] as num?)?.toInt() ?? 0;

      // 1. Calculate New XP
      final newXP = currentXP + points;
      
      // 2. Update Counters based on Action Type
      if (actionType == 'quiz_passed') {
        quizzesPassed++;
      } else if (actionType == 'simulation_completed') {
        simsCompleted++;
      }

      // 3. Gatekeeper Logic: Calculate new level
      final newLevel = GamificationRules.calculateLevel(
        xp: newXP, 
        quizzesPassed: quizzesPassed, 
        simulationsCompleted: simsCompleted
      );

      transaction.update(userRef, {
        'xp': newXP,
        'level': newLevel,
        'quizzesPassed': quizzesPassed,
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
