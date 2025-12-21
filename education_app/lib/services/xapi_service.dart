import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/xapi/xapi_statement.dart';
import 'gamification_service.dart';

class XApiService {
  // Singleton pattern
  static final XApiService _instance = XApiService._internal();
  factory XApiService() => _instance;
  XApiService._internal();

  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('learning_records');

  /// The core method to record an xAPI statement.
  /// Handles offline persistence automatically via Firestore SDK.
  Future<void> recordStatement(XApiStatement statement) async {
    try {
      // 1. Record to Cloud Firestore (LRS)
      await _collection.add(statement.toJson());
      
      // 2. Trigger Gamification Engine
      // Fire and forget (don't await) to keep UI snappy? 
      // User requested "Update XApiService to trigger...", usually implies synchronous or immediate follow-up.
      // But let's await it to ensure data consistency for tests.
      try {
        await GamificationService().processXApiEvent(statement);
      } catch (e) {
        print('Gamification Engine Error: $e');
      }

    } catch (e) {
      // In a real production app, we might log this to Crashlytics.
      print('Error recording xAPI statement: $e');
    }
  }

  // --- Helper Methods (Public API) ---

  /// Tracks when a user completes a video.
  Future<void> trackVideoWatched({
    required String videoId,
    required String title,
    required Duration duration,
  }) async {
    final actor = _getCurrentActor();
    
    final statement = XApiStatement(
      actor: actor,
      verb: XApiVerbs.experienced, // or 'completed' depending on strictness
      object: XApiObject(
        id: videoId, // e.g. "https://sudqollanma.uz/video/VIDEO_ID"
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

    await recordStatement(statement);
  }

  /// Tracks quiz completion with score.
  Future<void> trackQuizCompleted({
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

    await recordStatement(statement);
  }

  /// Tracks simulator step interactions.
  Future<void> trackSimulatorInteraction({
    required String stepId,
    required String action, // e.g. "clicked_button_A"
    required bool isCorrect,
  }) async {
    final actor = _getCurrentActor();
    
    final statement = XApiStatement(
      actor: actor,
      verb: XApiVerbs.interact,
      object: XApiObject(
        id: stepId, // e.g. "https://sudqollanma.uz/sim/file-claim/step-3"
        definition: {
          'type': 'http://adlnet.gov/expapi/activities/simulation',
          'description': {'en-US': 'Simulator Step Interaction'},
        },
      ),
      result: XApiResult(
        success: isCorrect,
        extensions: {
          'https://sudqollanma.uz/xapi/extension/action': action,
        },
      ),
      timestamp: DateTime.now(),
    );

    await recordStatement(statement);
  }

  // --- Internal Helpers ---

  XApiActor _getCurrentActor() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // CRITICAL: We use mailto:UID@sudqollanma.uz so GamificationService 
      // can reliably extract the Firestore Document ID (UID).
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

  /// Formats Duration to ISO 8601 string (e.g. PT4M5S).
  String _formatDuration(Duration duration) {
    // Simple formatter for PT[H]H[M]M[S]S
    // Note: A robust implementation might use specific library, but manual is fine.
    if (duration.inSeconds == 0) return 'PT0S';
    
    var str = 'PT';
    if (duration.inHours > 0) str += '${duration.inHours}H';
    if (duration.inMinutes % 60 > 0) str += '${duration.inMinutes % 60}M';
    if (duration.inSeconds % 60 > 0) str += '${duration.inSeconds % 60}S';
    
    return str == 'PT' ? 'PT0S' : str;
  }
}
