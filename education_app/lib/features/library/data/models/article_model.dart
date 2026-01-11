import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/article_entity.dart';

/// Data Model for Knowledge Articles.
/// 
/// Extends ArticleEntity with Firebase-specific serialization logic.
class ArticleModel extends ArticleEntity {
  const ArticleModel({
    required String id,
    required String title,
    required String description,
    required String content,
    String? pdfUrl,
    required String category,
    String? systemId,
    required List<String> tags,
    required String authorId,
    required String authorName,
    int views = 0,
    int helpful = 0,
    required DateTime createdAt,
    required DateTime updatedAt,
    bool isPinned = false,
  }) : super(
          id: id,
          title: title,
          description: description,
          content: content,
          pdfUrl: pdfUrl,
          category: category,
          systemId: systemId,
          tags: tags,
          authorId: authorId,
          authorName: authorName,
          views: views,
          helpful: helpful,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isPinned: isPinned,
        );

  /// Factory constructor from Map.
  factory ArticleModel.fromMap(Map<String, dynamic> data, String id) {
    return ArticleModel(
      id: id,
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
      createdAt: (data['createdAt'] is Timestamp) 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(data['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: (data['updatedAt'] is Timestamp)
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(data['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      isPinned: data['isPinned'] ?? false,
    );
  }

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
