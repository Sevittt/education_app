import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/video_entity.dart';

/// Data Model for Video Tutorials.
/// 
/// Extends VideoEntity with Firebase-specific serialization logic.
class VideoModel extends VideoEntity {
  const VideoModel({
    required super.id,
    required super.title,
    required super.description,
    required super.youtubeId,
    required super.durationSeconds,
    required super.category,
    super.systemId,
    required super.thumbnailUrl,
    required super.tags,
    required super.authorId,
    required super.authorName,
    super.views = 0,
    super.likes = 0,
    required super.createdAt,
    super.order = 0,
  });

  /// Factory constructor from Map.
  factory VideoModel.fromMap(Map<String, dynamic> data, String id) {
    return VideoModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      youtubeId: data['youtubeId'] ?? '',
      durationSeconds: (data['duration'] as num?)?.toInt() ?? 0,
      category: data['category'] ?? 'beginner',
      systemId: data['systemId'],
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      views: (data['views'] as num?)?.toInt() ?? 0,
      likes: (data['likes'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(data['createdAt']?.toString() ?? '') ?? DateTime.now(),
      order: (data['order'] as num?)?.toInt() ?? 0,
    );
  }

  /// Factory constructor from Firestore DocumentSnapshot.
  factory VideoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VideoModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      youtubeId: data['youtubeId'] ?? '',
      durationSeconds: (data['duration'] as num?)?.toInt() ?? 0,
      category: data['category'] ?? 'beginner',
      systemId: data['systemId'],
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      views: (data['views'] as num?)?.toInt() ?? 0,
      likes: (data['likes'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      order: (data['order'] as num?)?.toInt() ?? 0,
    );
  }

  /// Convert to Firestore Map.
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'youtubeId': youtubeId,
      'duration': durationSeconds,
      'category': category,
      'systemId': systemId,
      'thumbnailUrl': thumbnailUrl,
      'tags': tags,
      'authorId': authorId,
      'authorName': authorName,
      'views': views,
      'likes': likes,
      'createdAt': Timestamp.fromDate(createdAt),
      'order': order,
    };
  }
}
