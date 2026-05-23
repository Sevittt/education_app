import '../../domain/entities/search_result_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _remoteDataSource;

  SearchRepositoryImpl({SearchRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? SearchRemoteDataSource();

  @override
  Future<List<SearchResultEntity>> searchVectorQuery(String query,
      {int limit = 5}) async {
    final models =
        await _remoteDataSource.searchVectorQuery(query, limit: limit);

    return models.map((model) {
      SearchResultType type;
      switch (model.type) {
        case 'article':
          type = SearchResultType.article;
          break;
        case 'video':
          type = SearchResultType.video;
          break;
        case 'faq':
          type = SearchResultType.faq;
          break;
        case 'system':
          type = SearchResultType.system;
          break;
        case 'resource':
        default:
          type = SearchResultType.resource;
          break;
      }

      return SearchResultEntity(
        id: model.id,
        title: model.title,
        description: model.text, // Store the raw text for RAG usage
        type: type,
      );
    }).toList();
  }
}
