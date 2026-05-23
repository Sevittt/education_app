// lib/features/community/domain/entities/discussion_topic.dart
import 'package:equatable/equatable.dart';

class DiscussionTopic extends Equatable {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final int commentCount;

  const DiscussionTopic({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.commentCount,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        authorId,
        authorName,
        createdAt,
        commentCount,
      ];
}
