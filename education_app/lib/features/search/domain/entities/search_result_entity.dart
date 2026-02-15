/// Enum for search result categories.
enum SearchResultType {
  system,
  article,
  video,
  faq,
}

/// Domain Entity representing a single search result with relevance scoring.
class SearchResultEntity {
  final String id;
  final String title;
  final String description;
  final SearchResultType type;
  final double score;
  final String? systemId;
  final List<String> tags;

  /// Whether this result was added via semantic linking (not direct match).
  final bool isSemanticLink;

  const SearchResultEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.score = 0.0,
    this.systemId,
    this.tags = const [],
    this.isSemanticLink = false,
  });

  /// Create a copy with a different score or semantic flag.
  SearchResultEntity copyWith({
    double? score,
    bool? isSemanticLink,
  }) {
    return SearchResultEntity(
      id: id,
      title: title,
      description: description,
      type: type,
      score: score ?? this.score,
      systemId: systemId,
      tags: tags,
      isSemanticLink: isSemanticLink ?? this.isSemanticLink,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SearchResultEntity && other.id == id && other.type == type;

  @override
  int get hashCode => Object.hash(id, type);
}
