/// Domain Entity for Knowledge Articles.
/// 
/// This is a pure Dart class with no Firebase dependencies.
/// It represents the core business data for an article.
class ArticleEntity {
  final String id;
  final String title;
  final String description;
  final String content;
  final String? pdfUrl;
  final String category; // 'beginner', 'akt', 'system', 'auth', 'general'
  final String? systemId;
  final List<String> tags;
  final String authorId;
  final String authorName;
  final int views;
  final int helpful;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;

  const ArticleEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    this.pdfUrl,
    required this.category,
    this.systemId,
    required this.tags,
    required this.authorId,
    required this.authorName,
    this.views = 0,
    this.helpful = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ArticleEntity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
