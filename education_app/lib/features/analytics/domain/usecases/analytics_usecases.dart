import 'package:firebase_auth/firebase_auth.dart';
import 'package:sud_qollanma/core/constants/gamification_rules.dart';
import '../repositories/analytics_repository.dart';
import '../entities/xapi_statement.dart';
import '../entities/xapi_actor.dart';
import '../../../gamification/domain/repositories/gamification_repository.dart';


class LogXApiStatement {
  final AnalyticsRepository analyticsRepository;
  final GamificationRepository gamificationRepository;

  LogXApiStatement(this.analyticsRepository, this.gamificationRepository);

  Future<void> call(XApiStatement statement) async {
    // 1. Record to Analytics (LRS)
    await analyticsRepository.recordStatement(statement);

    // 2. Process for Gamification
    try {
      await _processGamification(statement);
    } catch (e) {
      print('Gamification Engine Error: $e');
    }
  }

  Future<void> _processGamification(XApiStatement statement) async {
    // This logic mimics the GamificationService.processXApiEvent
    final userId = statement.actor.mbox.replaceAll('mailto:', '');
    if (userId.isEmpty) return;

    String finalUserId = userId;
    if (userId.contains('@')) {
        finalUserId = userId.split('@')[0];
    }
    
    if (finalUserId == 'guest') return;

    int pointsToAward = 0;
    String actionType = 'unknown';
    String description = '';

    final verbId = statement.verb.id; 
    final activityType = statement.object.definition['type'] as String?;

    if (activityType == 'http://adlnet.gov/expapi/activities/video') {
        if (verbId.endsWith('completed') || verbId.endsWith('experienced')) {
            pointsToAward = GamificationRules.xpVideoComplete;
            actionType = 'video_watched';
            description = 'Watched video';
        }
    } else if (activityType == 'http://adlnet.gov/expapi/activities/assessment') {
            pointsToAward = GamificationRules.xpQuizPass;
            actionType = 'quiz_passed';
            description = 'Passed quiz';
            
            final rawScore = statement.result?.score?['raw'];
            if (rawScore == 100) {
                 pointsToAward += GamificationRules.xpQuizPerfect;
                 actionType = 'quiz_aced';
                 description += ' (Perfect Score!)';
            }
            
            final durationStr = statement.result?.duration;
            if (durationStr != null && durationStr.startsWith('PT')) {
               final secondsStr = durationStr.substring(2).replaceAll('S', '');
               final seconds = int.tryParse(secondsStr);
               if (seconds != null && seconds <= 5) {
                   pointsToAward += GamificationRules.xpSpeedBonus;
                   description += ' (Speed Bonus!)';
               }
            }
    } else if (activityType == 'http://adlnet.gov/expapi/activities/article') {
        if (verbId.endsWith('completed')) {
            pointsToAward = GamificationRules.xpArticleScroll;
            actionType = 'article_read';
            description = 'Read article';
        }
    } else if (activityType == 'http://adlnet.gov/expapi/activities/simulation') {
        if (verbId.endsWith('performed') || verbId.endsWith('completed')) {
             pointsToAward = GamificationRules.xpSimComplete;
             actionType = 'simulation_completed';
             description = 'Completed simulation';
        } else if (verbId.endsWith('interacted')) {
             pointsToAward = GamificationRules.xpSimInteraction;
             actionType = 'simulation_interaction';
             description = 'Simulation interaction';
        }
    }

    if (pointsToAward > 0) {
        await gamificationRepository.awardPoints(
            userId: finalUserId,
            points: pointsToAward,
            actionType: actionType,
            description: description,
        );
    }
  }
}

class TrackVideoWatched {
  final LogXApiStatement logStatement;

  TrackVideoWatched(this.logStatement);

  Future<void> call({
    required String videoId,
    required String title,
    required Duration duration,
  }) async {
    final actor = _getCurrentActor();
    
    final statement = XApiStatement(
      actor: actor,
      verb: XApiVerbs.experienced,
      object: XApiObject(
        id: videoId,
        definition: {
          'type': 'http://adlnet.gov/expapi/activities/video',
          'name': {'en-US': title},
        },
      ),
      result: XApiResult(
        completion: true,
        duration: _formatDuration(duration),
        extensions: {
          'http://id.tincanapi.com/extension/duration-seconds': duration.inSeconds,
        },
      ),
      timestamp: DateTime.now(),
    );

    await logStatement(statement);
  }
  
  XApiActor _getCurrentActor() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return XApiActor(
        mbox: 'mailto:${user.uid}@sudqollanma.uz',
        name: user.displayName ?? 'User ${user.uid.substring(0, 5)}',
      );
    } else {
      return XApiActor(
        mbox: 'mailto:guest@sudqollanma.uz',
        name: 'Guest User',
      );
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds == 0) return 'PT0S';
    var str = 'PT';
    if (duration.inHours > 0) str += '${duration.inHours}H';
    if (duration.inMinutes % 60 > 0) str += '${duration.inMinutes % 60}M';
    if (duration.inSeconds % 60 > 0) str += '${duration.inSeconds % 60}S';
    return str == 'PT' ? 'PT0S' : str;
  }
}

class TrackQuizCompleted {
  final LogXApiStatement logStatement;

  TrackQuizCompleted(this.logStatement);

  Future<void> call({
    required String quizId,
    required String title,
    required double score, 
    required bool passed,
    int? timeTakenSeconds,
  }) async {
    final actor = _getCurrentActor();
    
    final statement = XApiStatement(
      actor: actor,
      verb: passed ? XApiVerbs.passed : XApiVerbs.failed,
      object: XApiObject(
        id: quizId,
        definition: {
          'type': 'http://adlnet.gov/expapi/activities/assessment',
          'name': {'en-US': title},
        },
      ),
      result: XApiResult(
        success: passed,
        completion: true,
        duration: timeTakenSeconds != null ? 'PT${timeTakenSeconds}S' : null,
        score: {
          'raw': score,
          'scaled': score / 100.0,
        },
      ),
      timestamp: DateTime.now(),
    );

    await logStatement(statement);
  }

  XApiActor _getCurrentActor() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return XApiActor(
        mbox: 'mailto:${user.uid}@sudqollanma.uz',
        name: user.displayName ?? 'User ${user.uid.substring(0, 5)}',
      );
    } else {
      return XApiActor(
        mbox: 'mailto:guest@sudqollanma.uz',
        name: 'Guest User',
      );
    }
  }
}
