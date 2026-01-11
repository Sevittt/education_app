/// Domain Entity for Video Tutorials.
/// 
/// This is a pure Dart class with no Firebase dependencies.
/// It represents the core business data for a video.
class VideoEntity {
  final String id;
  final String title;
  final String description;
  final String youtubeId;
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

  const VideoEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.youtubeId,
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
  });

  /// YouTube embed URL
  String get youtubeEmbedUrl => 'https://www.youtube.com/embed/$youtubeId';

  /// YouTube watch URL
  String get youtubeWatchUrl => 'https://www.youtube.com/watch?v=$youtubeId';

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
