// lib/services/video_tutorial_service.dart
// LEGACY FACADE - Wraps the new LibraryRemoteSource for backward compatibility.
// TODO: Migrate all consumers to use LibraryProvider directly, then delete this file.

import 'package:sud_qollanma/features/library/data/datasources/library_remote_source.dart';
import 'package:sud_qollanma/features/library/data/models/video_model.dart';
import 'package:sud_qollanma/models/video_tutorial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoTutorialService {
  final LibraryRemoteSource _remoteSource = LibraryRemoteSource();

  /// Barcha videolarni olish (Stream)
  Stream<List<VideoTutorial>> getAllVideos() {
    return _remoteSource.watchVideos().map((videos) => videos.map(_toVideoTutorial).toList());
  }

  /// Kategoriya bo'yicha videolar
  Stream<List<VideoTutorial>> getVideosByCategory(String category) {
    return _remoteSource.watchVideos().map((videos) =>
        videos.where((v) => v.category == category).map(_toVideoTutorial).toList());
  }

  /// Bitta videoni olish
  Future<VideoTutorial?> getVideoById(String id) async {
    final model = await _remoteSource.getVideoById(id);
    return model != null ? _toVideoTutorial(model) : null;
  }

  /// Ko'rilganlar sonini oshirish
  Future<void> incrementViews(String videoId) async {
    await _remoteSource.incrementVideoViews(videoId);
  }

  /// Like qo'shish
  Future<void> incrementLikes(String videoId) async {
    await _remoteSource.incrementVideoLikes(videoId);
  }

  /// Like olib tashlash
  Future<void> decrementLikes(String videoId) async {
    await _remoteSource.decrementVideoLikes(videoId);
  }

  // --- Helper: Convert VideoModel to legacy VideoTutorial ---
  VideoTutorial _toVideoTutorial(VideoModel model) {
    return VideoTutorial(
      id: model.id,
      title: model.title,
      description: model.description,
      youtubeId: model.youtubeId,
      duration: model.durationSeconds,
      category: VideoCategory.values.firstWhere(
        (e) => e.name == model.category,
        orElse: () => VideoCategory.beginner,
      ),
      systemId: model.systemId,
      thumbnailUrl: model.thumbnailUrl,
      tags: model.tags,
      authorId: model.authorId,
      authorName: model.authorName,
      views: model.views,
      likes: model.likes,
      createdAt: Timestamp.fromDate(model.createdAt),
      order: model.order,
    );
  }

  // --- Admin CRUD Operations ---

  /// Create a new video
  Future<String> createVideo(VideoTutorial video) async {
    return await _remoteSource.createVideo(video.toMap());
  }

  /// Update an existing video
  /// Update an existing video (accepts id and video for backward compatibility)
  Future<void> updateVideo(String id, VideoTutorial video) async {
    await _remoteSource.updateVideo(id, video.toMap());
  }

  /// Delete a video
  Future<void> deleteVideo(String id) async {
    await _remoteSource.deleteVideo(id);
  }

  /// Get YouTube thumbnail URL from video ID
  String getYoutubeThumbnail(String youtubeId) {
    return 'https://img.youtube.com/vi/$youtubeId/maxresdefault.jpg';
  }
}
