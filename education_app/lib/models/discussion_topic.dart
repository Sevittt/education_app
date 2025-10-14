// lib/models/discussion_topic.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class DiscussionTopic {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final List<String> commentIds;
  final int commentCount;

  DiscussionTopic({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.commentIds,
    required this.commentCount,
  });

  DiscussionTopic copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    DateTime? createdAt,
    List<String>? commentIds,
    int? commentCount,
  }) {
    return DiscussionTopic(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      commentIds: commentIds ?? this.commentIds,
      commentCount: commentCount ?? this.commentCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'commentCount': commentCount,
      'createdAt': createdAt,
    };
  }

  factory DiscussionTopic.fromMap(String id, Map<String, dynamic> map) {
    return DiscussionTopic(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      commentIds:
          (map['commentIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[],
      commentCount: map['commentCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
