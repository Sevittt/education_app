// lib/services/video_tutorial_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/video_tutorial.dart';

/// Video Tutorial Service
/// 
/// YouTube video qo'llanmalarni boshqarish uchun
class VideoTutorialService {
  final CollectionReference<Map<String, dynamic>> _videosCollection =
      FirebaseFirestore.instance.collection('video_tutorials');
  
  final CollectionReference<Map<String, dynamic>> _progressCollection =
      FirebaseFirestore.instance.collection('user_progress');

  // ==========================================
  // READ OPERATIONS
  // ==========================================

  /// Barcha videolarni olish
  Stream<List<VideoTutorial>> getAllVideos() {
    return _videosCollection
        .orderBy('order')  // Playlist tartibi bo'yicha
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => VideoTutorial.fromFirestore(doc))
          .toList();
    });
  }

  /// Kategoriya bo'yicha videolar
  Stream<List<VideoTutorial>> getVideosByCategory(String category) {
    return _videosCollection
        .where('category', isEqualTo: category)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => VideoTutorial.fromFirestore(doc))
          .toList();
    });
  }

  /// Tizim bo'yicha videolar
  Stream<List<VideoTutorial>> getVideosBySystem(String systemId) {
    return _videosCollection
        .where('systemId', isEqualTo: systemId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => VideoTutorial.fromFirestore(doc))
          .toList();
    });
  }

  /// Bitta videoni olish
  Future<VideoTutorial?> getVideoById(String id) async {
    try {
      final doc = await _videosCollection.doc(id).get();
      if (!doc.exists) return null;
      return VideoTutorial.fromFirestore(doc);
    } catch (e) {
      print('Error getting video: $e');
      return null;
    }
  }

  /// YouTube thumbnail URL olish
  /// 
  /// YouTube thumbnail'lar uchun pattern:
  /// https://img.youtube.com/vi/{VIDEO_ID}/maxresdefault.jpg
  String getYoutubeThumbnail(String youtubeId, {String quality = 'maxresdefault'}) {
    // Quality options: maxresdefault, hqdefault, mqdefault, sddefault
    return 'https://img.youtube.com/vi/$youtubeId/$quality.jpg';
  }

  // ==========================================
  // WRITE OPERATIONS
  // ==========================================

  /// Yangi video qo'shish
  Future<String?> createVideo(VideoTutorial video) async {
    try {
      final docRef = await _videosCollection.add(video.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating video: $e');
      return null;
    }
  }

  /// Videoni yangilash
  Future<bool> updateVideo(String id, VideoTutorial video) async {
    try {
      await _videosCollection.doc(id).update(video.toFirestore());
      return true;
    } catch (e) {
      print('Error updating video: $e');
      return false;
    }
  }

  /// Videoni o'chirish
  Future<bool> deleteVideo(String id) async {
    try {
      await _videosCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting video: $e');
      return false;
    }
  }

  // ==========================================
  // PROGRESS TRACKING
  // ==========================================

  /// Video ko'rish progressini saqlash
  /// 
  /// progress: 0.0 - 1.0 (0% - 100%)
  Future<void> saveProgress(String userId, String videoId, double progress) async {
    try {
      final progressDoc = _progressCollection.doc(userId);
      
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(progressDoc);
        
        List<Map<String, dynamic>> watchedVideos = [];
        
        if (snapshot.exists) {
          final data = snapshot.data();
          watchedVideos = List<Map<String, dynamic>>.from(
            data?['watchedVideos'] ?? [],
          );
        }
        
        // Agar bu video allaqachon ro'yxatda bo'lsa, yangilaymiz
        final existingIndex = watchedVideos.indexWhere(
          (v) => v['videoId'] == videoId,
        );
        
        if (existingIndex != -1) {
          watchedVideos[existingIndex]['progress'] = progress;
          watchedVideos[existingIndex]['watchedAt'] = Timestamp.now();
        } else {
          watchedVideos.add({
            'videoId': videoId,
            'progress': progress,
            'watchedAt': Timestamp.now(),
          });
        }
        
        transaction.set(progressDoc, {
          'watchedVideos': watchedVideos,
          'lastActivity': Timestamp.now(),
        }, SetOptions(merge: true));
      });
    } catch (e) {
      print('Error saving progress: $e');
    }
  }

  /// Foydalanuvchining progress'ini olish
  Future<double> getProgress(String userId, String videoId) async {
    try {
      final doc = await _progressCollection.doc(userId).get();
      if (!doc.exists) return 0.0;
      
      final data = doc.data();
      final watchedVideos = List<Map<String, dynamic>>.from(
        data?['watchedVideos'] ?? [],
      );
      
      final video = watchedVideos.firstWhere(
        (v) => v['videoId'] == videoId,
        orElse: () => {'progress': 0.0},
      );
      
      return (video['progress'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      print('Error getting progress: $e');
      return 0.0;
    }
  }

  /// Foydalanuvchi ko'rgan barcha videolar
  Future<List<Map<String, dynamic>>> getWatchedVideos(String userId) async {
    try {
      final doc = await _progressCollection.doc(userId).get();
      if (!doc.exists) return [];
      
      final data = doc.data();
      return List<Map<String, dynamic>>.from(data?['watchedVideos'] ?? []);
    } catch (e) {
      print('Error getting watched videos: $e');
      return [];
    }
  }

  // ==========================================
  // COUNTER OPERATIONS
  // ==========================================

  /// Ko'rilganlar sonini oshirish
  Future<void> incrementViews(String videoId) async {
    try {
      final docRef = _videosCollection.doc(videoId);
      
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;
        
        final currentViews = (snapshot.data()?['views'] as num?)?.toInt() ?? 0;
        transaction.update(docRef, {'views': currentViews + 1});
      });
    } catch (e) {
      print('Error incrementing views: $e');
    }
  }

  /// Like qo'shish
  Future<void> incrementLikes(String videoId) async {
    try {
      final docRef = _videosCollection.doc(videoId);
      
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;
        
        final currentLikes = (snapshot.data()?['likes'] as num?)?.toInt() ?? 0;
        transaction.update(docRef, {'likes': currentLikes + 1});
      });
    } catch (e) {
      print('Error incrementing likes: $e');
    }
  }

  /// Like olib tashlash
  Future<void> decrementLikes(String videoId) async {
    try {
      final docRef = _videosCollection.doc(videoId);
      
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;
        
        final currentLikes = (snapshot.data()?['likes'] as num?)?.toInt() ?? 0;
        if (currentLikes > 0) {
          transaction.update(docRef, {'likes': currentLikes - 1});
        }
      });
    } catch (e) {
      print('Error decrementing likes: $e');
    }
  }

  // ==========================================
  // STATISTICS
  // ==========================================

  /// Eng ko'p ko'rilgan videolar
  Future<List<VideoTutorial>> getMostViewedVideos({int limit = 10}) async {
    try {
      final snapshot = await _videosCollection
          .orderBy('views', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => VideoTutorial.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting most viewed videos: $e');
      return [];
    }
  }

  /// Jami videolar soni
  Future<int> getTotalVideosCount() async {
    try {
      final snapshot = await _videosCollection.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting total count: $e');
      return 0;
    }
  }
}
