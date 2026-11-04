import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/video_watch_progress.dart';

/// users/{uid}/video_progress/{videoId} — oxirgi joy va ko'rilgan oraliqlar.
/// Foydalanuvchi boshqa qurilmada ham shu joydan davom ettiradi.
class VideoProgressRemoteSource {
  final FirebaseFirestore _db;

  VideoProgressRemoteSource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String uid, String videoId) =>
      _db.collection('users').doc(uid).collection('video_progress').doc(videoId);

  static bool _isValidId(String videoId) =>
      videoId.isNotEmpty && !videoId.contains('/');

  /// Hali ko'rilmagan bo'lsa bo'sh progress qaytaradi.
  Future<VideoWatchProgress> get(String uid, String videoId) async {
    if (!_isValidId(videoId)) return const VideoWatchProgress();
    final snap = await _doc(uid, videoId).get();
    final data = snap.data();
    return data == null ? const VideoWatchProgress() : VideoWatchProgress.fromMap(data);
  }

  Future<void> save(String uid, String videoId, VideoWatchProgress progress) async {
    if (!_isValidId(videoId)) return;
    await _doc(uid, videoId).set({
      ...progress.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
