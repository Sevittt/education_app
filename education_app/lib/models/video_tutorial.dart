// lib/models/video_tutorial.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Video tutorial kategoriyalari
enum VideoCategory {
  beginner,      // Boshlang'ich
  intermediate,  // O'rta
  advanced,      // Ilg'or
}

extension VideoCategoryExtension on VideoCategory {
  String get displayName {
    switch (this) {
      case VideoCategory.beginner:
        return "Boshlang'ich";
      case VideoCategory.intermediate:
        return "O'rta Daraja";
      case VideoCategory.advanced:
        return "Ilg'or";
    }
  }
}

/// Video qo'llanmalar uchun model
/// 
/// YouTube video'larni ilovada ko'rsatish uchun ishlatiladi
class VideoTutorial {
  final String id;
  final String title;
  final String description;
  final String youtubeId;          // YouTube video ID (masalan: "dQw4w9WgXcQ")
  final int duration;              // Soniyalarda (masalan: 300 = 5 minut)
  final VideoCategory category;
  final String? systemId;          // Qaysi tizimga tegishli
  final String thumbnailUrl;       // YouTube thumbnail URL
  final List<String> tags;
  final String authorId;
  final String authorName;
  final int views;
  final int likes;
  final Timestamp createdAt;
  final int order;                 // Playlist'da ketma-ketlik

  VideoTutorial({
    required this.id,
    required this.title,
    required this.description,
    required this.youtubeId,
    required this.duration,
    required this.category,
    this.systemId,
    required this.thumbnailUrl,
    required this.tags,
    required this.authorId,
    required this.authorName,
    this.views = 0,
    this.likes = 0,
    required this.createdAt,
    this.order = 0,
  });

  /// Firestore'dan yaratish
  factory VideoTutorial.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return VideoTutorial(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      youtubeId: data['youtubeId'] ?? '',
      duration: (data['duration'] as num?)?.toInt() ?? 0,
      category: VideoCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => VideoCategory.beginner,
      ),
      systemId: data['systemId'],
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      views: (data['views'] as num?)?.toInt() ?? 0,
      likes: (data['likes'] as num?)?.toInt() ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      order: (data['order'] as num?)?.toInt() ?? 0,
    );
  }

  factory VideoTutorial.fromMap(Map<String, dynamic> data, String id) {
    return VideoTutorial(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      youtubeId: data['youtubeId'] ?? '',
      duration: (data['duration'] as num?)?.toInt() ?? 0,
      category: VideoCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => VideoCategory.beginner,
      ),
      systemId: data['systemId'],
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      views: (data['views'] as num?)?.toInt() ?? 0,
      likes: (data['likes'] as num?)?.toInt() ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      order: (data['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'youtubeId': youtubeId,
      'duration': duration,
      'category': category.name,
      'systemId': systemId,
      'thumbnailUrl': thumbnailUrl,
      'tags': tags,
      'authorId': authorId,
      'authorName': authorName,
      'views': views,
      'likes': likes,
      'createdAt': createdAt,
      'order': order,
    };
  }

  Map<String, dynamic> toMap() => toFirestore();

  /// YouTube embed URL yaratish
  String get youtubeEmbedUrl => 'https://www.youtube.com/embed/$youtubeId';

  /// YouTube watch URL
  String get youtubeWatchUrl => 'https://www.youtube.com/watch?v=$youtubeId';

  /// Davomiylikni formatlangan ko'rinishda qaytarish (5:30)
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  VideoTutorial copyWith({
    String? id,
    String? title,
    String? description,
    String? youtubeId,
    int? duration,
    VideoCategory? category,
    String? systemId,
    String? thumbnailUrl,
    List<String>? tags,
    String? authorId,
    String? authorName,
    int? views,
    int? likes,
    Timestamp? createdAt,
    int? order,
  }) {
    return VideoTutorial(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      youtubeId: youtubeId ?? this.youtubeId,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      systemId: systemId ?? this.systemId,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      tags: tags ?? this.tags,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      order: order ?? this.order,
    );
  }

  @override
  String toString() {
    return 'VideoTutorial(id: $id, title: $title, youtubeId: $youtubeId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VideoTutorial && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
