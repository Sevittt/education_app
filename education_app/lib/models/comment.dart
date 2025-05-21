// lib/models/comment.dart

// import 'package:flutter/material.dart'; // Import for @required if using

class Comment {
  final String id;
  final String topicId; // Link back to the discussion topic
  final String authorId;
  final String content; // The content of the comment
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.topicId,
    required this.authorId,
    required this.content,
    required this.createdAt,
  });

  // Optional: fromMap and toMap methods
  factory Comment.fromMap(String id, Map<String, dynamic> map) {
    return Comment(
      id: id,
      topicId: map['topicId'] as String,
      authorId: map['authorId'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'topicId': topicId,
      'authorId': authorId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
