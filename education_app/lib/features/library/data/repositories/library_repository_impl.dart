import '../../domain/entities/video_entity.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/entities/resource_entity.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/library_remote_source.dart';
import '../datasources/library_local_source.dart';

/// Concrete implementation of LibraryRepository.
/// 
/// This class connects the Domain Layer to the Data Layer.
/// It uses LibraryRemoteSource for Firebase operations and LibraryLocalSource for bookmarks.
class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteSource _remoteSource;
  final LibraryLocalSource _localSource;

  LibraryRepositoryImpl({
    LibraryRemoteSource? remoteSource,
    LibraryLocalSource? localSource,
  })  : _remoteSource = remoteSource ?? LibraryRemoteSource(),
        _localSource = localSource ?? LibraryLocalSource();

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
  Future<List<VideoEntity>> getVideosBySystem(String systemId) async {
    return _remoteSource.getVideosBySystem(systemId);
  }

  @override
  Future<List<ArticleEntity>> searchArticles(String query) async {
    return _remoteSource.searchArticles(query);
  }

  @override
  Future<List<ArticleEntity>> getArticlesBySystem(String systemId) async {
    return _remoteSource.getArticlesBySystem(systemId);
  }

  // --- Video CRUD ---

  @override
  Future<String> createVideo(VideoEntity video) async {
    return _remoteSource.createVideo(_videoEntityToMap(video));
  }

  @override
  Future<void> updateVideo(String id, VideoEntity video) async {
    await _remoteSource.updateVideo(id, _videoEntityToMap(video));
  }

  @override
  Future<void> deleteVideo(String id) async {
    await _remoteSource.deleteVideo(id);
  }

  @override
  String getYoutubeThumbnail(String youtubeId) {
    return 'https://img.youtube.com/vi/$youtubeId/maxresdefault.jpg';
  }

  // --- Article CRUD ---

  @override
  Future<String> createArticle(ArticleEntity article) async {
    return _remoteSource.createArticle(_articleEntityToMap(article));
  }

  @override
  Future<void> updateArticle(String id, ArticleEntity article) async {
    await _remoteSource.updateArticle(id, _articleEntityToMap(article));
  }

  @override
  Future<void> deleteArticle(String id) async {
    await _remoteSource.deleteArticle(id);
  }

  // --- Helpers ---

  // ==========================================
  // RESOURCES
  // ==========================================

  @override
  Future<List<ResourceEntity>> getResources() async {
    return _remoteSource.getResources();
  }

  @override
  Stream<List<ResourceEntity>> watchResources() {
    return _remoteSource.watchResources();
  }

  @override
  Stream<List<ResourceEntity>> watchResourcesByAuthor(String authorId) {
    return _remoteSource.watchResourcesByAuthor(authorId);
  }

  @override
  Future<List<String>> getBookmarkedResourceIds() async {
    return _localSource.getBookmarkedResourceIds();
  }

  @override
  Future<bool> isResourceBookmarked(String id) async {
    return _localSource.isResourceBookmarked(id);
  }

  @override
  Future<void> toggleResourceBookmark(String id) async {
    await _localSource.toggleResourceBookmark(id);
  }

  @override
  Future<String> createResource(ResourceEntity resource) async {
    return _remoteSource.createResource(_resourceEntityToMap(resource));
  }

  @override
  Future<void> updateResource(String id, ResourceEntity resource) async {
    await _remoteSource.updateResource(id, _resourceEntityToMap(resource));
  }

  @override
  Future<void> deleteResource(String id) async {
    await _remoteSource.deleteResource(id);
  }

  // --- Helpers ---

  Map<String, dynamic> _videoEntityToMap(VideoEntity video) {
    return {
      'title': video.title,
      'description': video.description,
      'youtubeId': video.youtubeId,
      'duration': video.durationSeconds,
      'category': video.category,
      'systemId': video.systemId,
      'thumbnailUrl': video.thumbnailUrl,
      'tags': video.tags,
      'authorId': video.authorId,
      'authorName': video.authorName,
      'views': video.views,
      'likes': video.likes,
      'createdAt': video.createdAt,
      'order': video.order,
    };
  }

  Map<String, dynamic> _articleEntityToMap(ArticleEntity article) {
    return {
      'title': article.title,
      'description': article.description,
      'content': article.content,
      'pdfUrl': article.pdfUrl,
      'category': article.category,
      'systemId': article.systemId,
      'tags': article.tags,
      'authorId': article.authorId,
      'authorName': article.authorName,
      'views': article.views,
      'helpful': article.helpful,
      'createdAt': article.createdAt,
      'updatedAt': article.updatedAt,
      'isPinned': article.isPinned,
    };
  }

  Map<String, dynamic> _resourceEntityToMap(ResourceEntity resource) {
    return {
      'title': resource.title,
      'description': resource.description,
      'author': resource.author,
      'authorId': resource.authorId,
      'type': resource.type.toString().split('.').last,
      'url': resource.url,
      'createdAt': resource.createdAt,
    };
  }
}

