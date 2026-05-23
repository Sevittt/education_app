// lib/features/community/data/models/comment_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.topicId,
    required super.authorId,
    required super.authorName,
    super.authorProfilePicUrl,
    required super.content,
    required super.createdAt,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CommentModel(
      id: doc.id,
      topicId: data['topicId'] as String? ?? '',
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'Unknown',
      authorProfilePicUrl: data['authorProfilePicUrl'] as String?,
      content: data['content'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'topicId': topicId,
      'authorId': authorId,
      'authorName': authorName,
      'authorProfilePicUrl': authorProfilePicUrl,
      'content': content,
      'createdAt': createdAt,
    };
  }
}
