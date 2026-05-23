import '../../domain/entities/search_result_entity.dart';

abstract class SearchRepository {
  /// Fetches vector search results for AI RAG via Cloud Function.
  Future<List<SearchResultEntity>> searchVectorQuery(String query,
      {int limit = 5});
}
