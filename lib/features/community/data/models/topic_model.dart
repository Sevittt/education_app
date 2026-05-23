// lib/features/community/data/models/topic_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/discussion_topic.dart';

class TopicModel extends DiscussionTopic {
  const TopicModel({
    required super.id,
    required super.title,
    required super.content,
    required super.authorId,
    required super.authorName,
    required super.createdAt,
    required super.commentCount,
  });

  factory TopicModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TopicModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'Anonymous',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      commentCount: data['commentCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt, // Note: Usually serverTimestamp is used on create
      'commentCount': commentCount,
    };
  }
}
