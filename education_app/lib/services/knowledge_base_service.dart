// lib/services/knowledge_base_service.dart
// LEGACY FACADE - Wraps the new LibraryRemoteSource for backward compatibility.
// TODO: Migrate all consumers to use LibraryProvider directly, then delete this file.

import 'package:sud_qollanma/features/library/data/datasources/library_remote_source.dart';
import 'package:sud_qollanma/features/library/data/models/article_model.dart';
import 'package:sud_qollanma/models/knowledge_article.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KnowledgeBaseService {
  final LibraryRemoteSource _remoteSource = LibraryRemoteSource();

  /// Barcha maqolalarni olish (Stream)
  Stream<List<KnowledgeArticle>> getAllArticles() {
    return _remoteSource.watchArticles().map((articles) => articles.map(_toKnowledgeArticle).toList());
  }

  /// Kategoriya bo'yicha maqolalar
  Stream<List<KnowledgeArticle>> getArticlesByCategory(ArticleCategory category) {
    return _remoteSource.watchArticles().map((articles) =>
        articles.where((a) => a.category == category.name).map(_toKnowledgeArticle).toList());
  }

  /// Bitta maqolani olish
  Future<KnowledgeArticle?> getArticleById(String id) async {
    final model = await _remoteSource.getArticleById(id);
    return model != null ? _toKnowledgeArticle(model) : null;
  }

  /// Qidirish
  Future<List<KnowledgeArticle>> searchArticles(String query) async {
    final results = await _remoteSource.searchArticles(query);
    return results.map(_toKnowledgeArticle).toList();
  }

  /// Ko'rilganlar sonini oshirish
  Future<void> incrementViews(String articleId) async {
    await _remoteSource.incrementArticleViews(articleId);
  }

  /// Foydali deb belgilash
  Future<void> incrementHelpful(String articleId) async {
    await _remoteSource.incrementArticleHelpful(articleId);
  }

  /// Foydali belgisini olib tashlash
  Future<void> decrementHelpful(String articleId) async {
    await _remoteSource.decrementArticleHelpful(articleId);
  }

  // --- Helper: Convert ArticleModel to legacy KnowledgeArticle ---
  KnowledgeArticle _toKnowledgeArticle(ArticleModel model) {
    return KnowledgeArticle(
      id: model.id,
      title: model.title,
      description: model.description,
      content: model.content,
      pdfUrl: model.pdfUrl,
      category: ArticleCategory.values.firstWhere(
        (e) => e.name == model.category,
        orElse: () => ArticleCategory.general,
      ),
      systemId: model.systemId,
      tags: model.tags,
      authorId: model.authorId,
      authorName: model.authorName,
      views: model.views,
      helpful: model.helpful,
      createdAt: Timestamp.fromDate(model.createdAt),
      updatedAt: Timestamp.fromDate(model.updatedAt),
      isPinned: model.isPinned,
    );
  }

  // --- Admin CRUD Operations ---

  /// Create a new article
  Future<String> createArticle(KnowledgeArticle article) async {
    return await _remoteSource.createArticle(article.toMap());
  }

  /// Update an existing article
  /// Update an existing article (accepts id and article for backward compatibility)
  Future<void> updateArticle(String id, KnowledgeArticle article) async {
    await _remoteSource.updateArticle(id, article.toMap());
  }

  /// Delete an article
  Future<void> deleteArticle(String id) async {
    await _remoteSource.deleteArticle(id);
  }

  /// Upload a PDF file to Firebase Storage
  /// Returns the download URL of the uploaded file
  Future<String> uploadPDF(dynamic file, String articleId) async {
    // For web compatibility, this method is a placeholder.
    // In a full implementation, use firebase_storage package.
    // For now, return empty string as PDF upload is not yet migrated
    throw UnimplementedError('PDF upload needs firebase_storage package migration');
  }
}
