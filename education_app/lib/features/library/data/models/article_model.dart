import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/article_entity.dart';

/// Data Model for Knowledge Articles.
/// 
/// Extends ArticleEntity with Firebase-specific serialization logic.
class ArticleModel extends ArticleEntity {
  const ArticleModel({
    required super.id,
    required super.title,
    required super.description,
    required super.content,
    super.pdfUrl,
    required super.category,
    super.systemId,
    required super.tags,
    required super.authorId,
    required super.authorName,
    super.views,
    super.helpful,
    required super.createdAt,
    required super.updatedAt,
    super.isPinned,
  });

  /// Factory constructor from Firestore DocumentSnapshot.
  factory ArticleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ArticleModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      content: data['content'] ?? '',
      pdfUrl: data['pdfUrl'],
      category: data['category'] ?? 'general',
      systemId: data['systemId'],
      tags: List<String>.from(data['tags'] ?? []),
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      views: (data['views'] as num?)?.toInt() ?? 0,
      helpful: (data['helpful'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPinned: data['isPinned'] ?? false,
    );
  }

  /// Convert to Firestore Map.
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'pdfUrl': pdfUrl,
      'category': category,
      'systemId': systemId,
      'tags': tags,
      'authorId': authorId,
      'authorName': authorName,
      'views': views,
      'helpful': helpful,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPinned': isPinned,
    };
  }
}
