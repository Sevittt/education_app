// lib/models/discussion_topic.dart

import 'package:cloud_firestore/cloud_firestore.dart';

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
    // Helper to safely get a string, providing a default if null
    String _getString(
      String key,
      String defaultValue, {
      bool isRequired = false,
    }) {
      var value = map[key];
      if (value == null) {
        if (isRequired) {
          throw FormatException("Missing required field '$key' for topic $id");
        }
        print(
          "Warning: Field '$key' is null for topic ID $id. Using default: '$defaultValue'",
        );
        return defaultValue;
      }
      if (value is String) return value;
      print(
        "Warning: Field '$key' is not a String for topic $id. Converting to string.",
      );
      return value.toString();
    }

    // Helper for int values
    int _getInt(String key, int defaultValue) {
      var value = map[key];
      if (value == null) {
        print(
          "Warning: Field '$key' is null for topic ID $id. Using default: $defaultValue",
        );
        return defaultValue;
      }
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value) ?? defaultValue;
      }
      return defaultValue;
    }

    // Handle createdAt with robust parsing
    DateTime createdAtDate;
    var createdAtValue = map['createdAt'];
    if (createdAtValue is Timestamp) {
      createdAtDate = createdAtValue.toDate();
    } else if (createdAtValue is String) {
      try {
        createdAtDate = DateTime.parse(createdAtValue);
      } catch (e) {
        print(
          "Warning: Invalid createdAt string format for topic $id. Using current date.",
        );
        createdAtDate = DateTime.now();
      }
    } else {
      print(
        "Warning: Missing or invalid createdAt for topic $id. Using current date.",
      );
      createdAtDate = DateTime.now();
    }

    // Handle commentIds with validation
    List<String> commentIdsList;
    try {
      var rawCommentIds = map['commentIds'];
      if (rawCommentIds == null) {
        commentIdsList = [];
      } else if (rawCommentIds is List) {
        commentIdsList = rawCommentIds.map((e) => e.toString()).toList();
      } else {
        print(
          "Warning: Invalid commentIds format for topic $id. Using empty list.",
        );
        commentIdsList = [];
      }
    } catch (e) {
      print("Error parsing commentIds for topic $id: $e");
      commentIdsList = [];
    }

    return DiscussionTopic(
      id: id,
      title: _getString('title', 'Untitled Topic', isRequired: true),
      content: _getString('content', 'No content available.', isRequired: true),
      authorName: _getString('authorName', 'Unknown Author', isRequired: true),
      authorId: _getString('authorId', 'unknown_author_id', isRequired: true),
      createdAt: createdAtDate,
      commentIds: commentIdsList,
      commentCount: _getInt('commentCount', 0),
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
