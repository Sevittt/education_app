class SearchResultEntity {
  final String id;
  final String title;
  final String description;
  final String type; // 'article', 'video', 'system', 'faq'
  final dynamic originalObject;

  SearchResultEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.originalObject,
  });
}
