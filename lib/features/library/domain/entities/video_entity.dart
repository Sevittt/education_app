/// YouTube chapter / time code.
/// Firestore'da: timeCodes: [{time: 0, label: "Kirish"}, {time: 90, label: "Asosiy qism"}]
class VideoTimeCode {
  final int seconds;
  final String label;

  const VideoTimeCode({required this.seconds, required this.label});

  factory VideoTimeCode.fromMap(Map<String, dynamic> map) => VideoTimeCode(
        seconds: (map['time'] as num?)?.toInt() ?? 0,
        label: map['label'] as String? ?? '',
      );

  String get formatted {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

/// Domain Entity for Video Tutorials.
///
/// This is a pure Dart class with no Firebase dependencies.
/// It represents the core business data for a video.
class VideoEntity {
  final String id;
  final String title;
  final String description;
  final String? youtubeId;
  final String? videoUrl;
  final int durationSeconds;
  final String category; // 'beginner', 'intermediate', 'advanced'
  final String? systemId;
  final String thumbnailUrl;
  final List<String> tags;
  final String authorId;
  final String authorName;
  final int views;
  final int likes;
  final DateTime createdAt;
  final int order;
  // YouTube chapter markers: [{time: 0, label: "Kirish"}, ...]
  final List<VideoTimeCode> timeCodes;

  const VideoEntity({
    required this.id,
    required this.title,
    required this.description,
    this.youtubeId,
    this.videoUrl,
    required this.durationSeconds,
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
    this.timeCodes = const [],
  });

  /// YouTube embed URL
  String? get youtubeEmbedUrl => youtubeId != null ? 'https://www.youtube.com/embed/$youtubeId' : null;

  /// YouTube watch URL
  String? get youtubeWatchUrl => youtubeId != null ? 'https://www.youtube.com/watch?v=$youtubeId' : null;

  /// Formatted duration (e.g., "5:30")
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is VideoEntity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
