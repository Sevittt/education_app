import '../../domain/entities/video_entity.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/library_remote_source.dart';

/// Concrete implementation of LibraryRepository.
/// 
/// This class connects the Domain Layer to the Data Layer.
/// It uses LibraryRemoteSource for Firebase operations.
class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteSource _remoteSource;

  LibraryRepositoryImpl({LibraryRemoteSource? remoteSource})
      : _remoteSource = remoteSource ?? LibraryRemoteSource();

  // --- Videos ---
  
  @override
  Future<List<VideoEntity>> getVideos() async {
    return _remoteSource.getVideos();
  }

  @override
  Future<VideoEntity?> getVideoById(String id) async {
    return _remoteSource.getVideoById(id);
  }

  @override
  Stream<List<VideoEntity>> watchVideos() {
    return _remoteSource.watchVideos();
  }

  @override
  Future<void> incrementVideoViews(String id) async {
    await _remoteSource.incrementVideoViews(id);
  }

  @override
  Future<void> incrementVideoLikes(String id) async {
    await _remoteSource.incrementVideoLikes(id);
  }

  @override
  Future<void> decrementVideoLikes(String id) async {
    await _remoteSource.decrementVideoLikes(id);
  }

  // --- Articles ---

  @override
  Future<List<ArticleEntity>> getArticles() async {
    return _remoteSource.getArticles();
  }

  @override
  Future<ArticleEntity?> getArticleById(String id) async {
    return _remoteSource.getArticleById(id);
  }

  @override
  Stream<List<ArticleEntity>> watchArticles() {
    return _remoteSource.watchArticles();
  }

  @override
  Future<void> incrementArticleViews(String id) async {
    await _remoteSource.incrementArticleViews(id);
  }

  @override
  Future<void> incrementArticleHelpful(String id) async {
    await _remoteSource.incrementArticleHelpful(id);
  }

  @override
  Future<void> decrementArticleHelpful(String id) async {
    await _remoteSource.decrementArticleHelpful(id);
  }

  // --- Search ---

  @override
  Future<List<VideoEntity>> searchVideos(String query) async {
    return _remoteSource.searchVideos(query);
  }

  @override
  Future<List<ArticleEntity>> searchArticles(String query) async {
    return _remoteSource.searchArticles(query);
  }
}
