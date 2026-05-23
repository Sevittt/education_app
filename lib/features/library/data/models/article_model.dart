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
    super.views = 0,
    super.helpful = 0,
    required super.createdAt,
    required super.updatedAt,
    super.isPinned = false,
  });

  /// Factory constructor from Map.
  factory ArticleModel.fromMap(Map<String, dynamic> data, String id) {
    // Provide fallbacks for RAG vector search documents that only contain 'text'
    final String contentText = data['content'] ?? data['text'] ?? '';
    final String titleText =
        data['title'] != null && data['title'].toString().isNotEmpty
            ? data['title']
            : 'Bilimlar bazasi hujjati';

    return ArticleModel(
      id: id,
      title: titleText,
      description: data['description'] ?? '',
      content: contentText,
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
          : DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
              DateTime.now(),
      updatedAt: (data['updatedAt'] is Timestamp)
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(data['updatedAt']?.toString() ?? '') ??
              DateTime.now(),
      isPinned: data['isPinned'] ?? false,
    );
  }

  factory ArticleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Provide fallbacks for RAG vector search documents that only contain 'text'
    final String contentText = data['content'] ?? data['text'] ?? '';
    final String titleText =
        data['title'] != null && data['title'].toString().isNotEmpty
            ? data['title']
            : 'Bilimlar bazasi hujjati';

    return ArticleModel(
      id: doc.id,
      title: titleText,
      description: data['description'] ?? '',
      content: contentText,
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
