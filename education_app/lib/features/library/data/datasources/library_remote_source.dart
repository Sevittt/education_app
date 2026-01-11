import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/video_model.dart';
import '../models/article_model.dart';

/// Remote Data Source for Library Feature.
/// 
/// Handles all direct Firebase Firestore interactions.
/// This is the ONLY place where Firebase logic should exist for the Library feature.
class LibraryRemoteSource {
  final CollectionReference<Map<String, dynamic>> _videosCollection =
      FirebaseFirestore.instance.collection('video_tutorials');
  
  final CollectionReference<Map<String, dynamic>> _articlesCollection =
      FirebaseFirestore.instance.collection('knowledge_base');

  // ==========================================
  // VIDEO OPERATIONS
  // ==========================================

  /// Get all videos as a Stream.
  Stream<List<VideoModel>> watchVideos() {
    return _videosCollection
        .orderBy('order')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => VideoModel.fromFirestore(doc)).toList());
  }

  /// Get all videos as a Future.
  Future<List<VideoModel>> getVideos() async {
    final snapshot = await _videosCollection
        .orderBy('order')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => VideoModel.fromFirestore(doc)).toList();
  }

  /// Get a single video by ID.
  Future<VideoModel?> getVideoById(String id) async {
    final doc = await _videosCollection.doc(id).get();
    if (!doc.exists) return null;
    return VideoModel.fromFirestore(doc);
  }

  /// Increment video views using a transaction.
  Future<void> incrementVideoViews(String id) async {
    final docRef = _videosCollection.doc(id);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final currentViews = (snapshot.data()?['views'] as num?)?.toInt() ?? 0;
      transaction.update(docRef, {'views': currentViews + 1});
    });
  }

  /// Increment video likes.
  Future<void> incrementVideoLikes(String id) async {
    final docRef = _videosCollection.doc(id);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final currentLikes = (snapshot.data()?['likes'] as num?)?.toInt() ?? 0;
      transaction.update(docRef, {'likes': currentLikes + 1});
    });
  }

  /// Decrement video likes.
  Future<void> decrementVideoLikes(String id) async {
    final docRef = _videosCollection.doc(id);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final currentLikes = (snapshot.data()?['likes'] as num?)?.toInt() ?? 0;
      if (currentLikes > 0) {
        transaction.update(docRef, {'likes': currentLikes - 1});
      }
    });
  }

  /// Search videos by title or tags.
  Future<List<VideoModel>> searchVideos(String query) async {
    // Firestore doesn't have native full-text search, so we fetch and filter.
    final snapshot = await _videosCollection.get();
    final lowerQuery = query.toLowerCase();
    return snapshot.docs
        .map((doc) => VideoModel.fromFirestore(doc))
        .where((video) =>
            video.title.toLowerCase().contains(lowerQuery) ||
            video.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)))
        .toList();
  }

  // ==========================================
  // ARTICLE OPERATIONS
  // ==========================================

  /// Get all articles as a Stream.
  Stream<List<ArticleModel>> watchArticles() {
    return _articlesCollection
        .orderBy('isPinned', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ArticleModel.fromFirestore(doc)).toList());
  }

  /// Get all articles as a Future.
  Future<List<ArticleModel>> getArticles() async {
    final snapshot = await _articlesCollection
        .orderBy('isPinned', descending: true)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => ArticleModel.fromFirestore(doc)).toList();
  }

  /// Get a single article by ID.
  Future<ArticleModel?> getArticleById(String id) async {
    final doc = await _articlesCollection.doc(id).get();
    if (!doc.exists) return null;
    return ArticleModel.fromFirestore(doc);
  }

  /// Increment article views.
  Future<void> incrementArticleViews(String id) async {
    final docRef = _articlesCollection.doc(id);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final currentViews = (snapshot.data()?['views'] as num?)?.toInt() ?? 0;
      transaction.update(docRef, {'views': currentViews + 1});
    });
  }

  /// Increment article helpful count.
  Future<void> incrementArticleHelpful(String id) async {
    final docRef = _articlesCollection.doc(id);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final currentHelpful = (snapshot.data()?['helpful'] as num?)?.toInt() ?? 0;
      transaction.update(docRef, {'helpful': currentHelpful + 1});
    });
  }

  /// Decrement article helpful count.
  Future<void> decrementArticleHelpful(String id) async {
    final docRef = _articlesCollection.doc(id);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final currentHelpful = (snapshot.data()?['helpful'] as num?)?.toInt() ?? 0;
      if (currentHelpful > 0) {
        transaction.update(docRef, {'helpful': currentHelpful - 1});
      }
    });
  }

  /// Search articles by title or tags.
  Future<List<ArticleModel>> searchArticles(String query) async {
    final snapshot = await _articlesCollection.get();
    final lowerQuery = query.toLowerCase();
    return snapshot.docs
        .map((doc) => ArticleModel.fromFirestore(doc))
        .where((article) =>
            article.title.toLowerCase().contains(lowerQuery) ||
            article.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)))
        .toList();
  }

  // ==========================================
  // VIDEO CRUD OPERATIONS (Admin)
  // ==========================================

  /// Create a new video.
  Future<String> createVideo(Map<String, dynamic> data) async {
    final docRef = await _videosCollection.add(data);
    return docRef.id;
  }

  /// Update an existing video.
  Future<void> updateVideo(String id, Map<String, dynamic> data) async {
    await _videosCollection.doc(id).update(data);
  }

  /// Delete a video.
  Future<void> deleteVideo(String id) async {
    await _videosCollection.doc(id).delete();
  }

  // ==========================================
  // ARTICLE CRUD OPERATIONS (Admin)
  // ==========================================

  /// Create a new article.
  Future<String> createArticle(Map<String, dynamic> data) async {
    final docRef = await _articlesCollection.add(data);
    return docRef.id;
  }

  /// Update an existing article.
  Future<void> updateArticle(String id, Map<String, dynamic> data) async {
    await _articlesCollection.doc(id).update(data);
  }

  /// Delete an article.
  Future<void> deleteArticle(String id) async {
    await _articlesCollection.doc(id).delete();
  }
}
