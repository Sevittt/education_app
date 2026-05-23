// lib/features/community/domain/entities/comment.dart
import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final String id;
  final String topicId;
  final String authorId;
  final String authorName;
  final String? authorProfilePicUrl;
  final String content;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.topicId,
    required this.authorId,
    required this.authorName,
    this.authorProfilePicUrl,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        topicId,
        authorId,
        authorName,
        authorProfilePicUrl,
        content,
        createdAt,
      ];
}
