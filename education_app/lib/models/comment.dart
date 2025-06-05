// lib/models/comment.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id; // Firestore document ID
  final String topicId;
  final String authorId;
  final String authorName; // Denormalized
  final String? authorProfilePicUrl; // Denormalized, optional
  final String content;
  final Timestamp createdAt; // Use Firestore Timestamp

  Comment({
    required this.id,
    required this.topicId,
    required this.authorId,
    required this.authorName,
    this.authorProfilePicUrl,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      topicId: data['topicId'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Unknown User',
      authorProfilePicUrl: data['authorProfilePicUrl'] as String?,
      content: data['content'] ?? '',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'topicId': topicId,
      'authorId': authorId,
      'authorName': authorName,
      'authorProfilePicUrl': authorProfilePicUrl,
      'content': content,
      'createdAt': createdAt, // Or FieldValue.serverTimestamp() on create
    };
  }
}
