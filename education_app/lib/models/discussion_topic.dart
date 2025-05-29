// lib/models/discussion_topic.dart

class DiscussionTopic {
  final String id;
  // Make title and content non-final if you want to modify them directly,
  // or use copyWith to create new instances with changes.
  // For this example, we'll assume they can be part of a new instance via copyWith.
  final String title;
  final String content;
  final String authorName; // <-- Add this line
  final String authorId;
  final DateTime createdAt;

  final List<String> commentIds; // Keep this if you manage comments separately
  final int commentCount;

  DiscussionTopic({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.authorId,
    required this.createdAt,
    this.commentIds = const [],
    required this.commentCount,
  });

  // fromMap and toMap methods (keep them if you have them)
  factory DiscussionTopic.fromMap(String id, Map<String, dynamic> map) {
    return DiscussionTopic(
      id: id,
      title: map['title'] as String,
      content: map['content'] as String,
      authorName: map['authorName'] as String, // <-- add this
      authorId: map['authorId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      commentIds: List<String>.from(map['commentIds'] ?? []),
      commentCount: map['commentCount'] as int, // <-- add this
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'createdAt': createdAt.toIso8601String(),
      'commentIds': commentIds,
    };
  }

  // copyWith method to create a new instance with updated values
  DiscussionTopic copyWith({
    String? id,
    String? title,
    String? content,
    String? authorName,
    String? authorId,
    DateTime? createdAt,
    List<String>? commentIds,
    int? commentCount,
  }) {
    return DiscussionTopic(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorName: authorName ?? this.authorName,
      authorId: authorId ?? this.authorId,
      createdAt: createdAt ?? this.createdAt,
      commentIds: commentIds ?? this.commentIds,
      commentCount: commentCount ?? this.commentCount,
    );
  }
}
