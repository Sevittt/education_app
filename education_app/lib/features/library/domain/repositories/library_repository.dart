import '../entities/video_entity.dart';
import '../entities/article_entity.dart';
import '../entities/resource_entity.dart';

/// Abstract Repository Contract for the Library Feature.
///
/// This defines the interface that the Data Layer must implement.
/// The Presentation Layer depends on this contract, NOT the implementation.
abstract class LibraryRepository {
  // --- Videos: Read ---
  Future<List<VideoEntity>> getVideos();
  Future<VideoEntity?> getVideoById(String id);
  Stream<List<VideoEntity>> watchVideos();
  Future<void> incrementVideoViews(String id);
  Future<void> incrementVideoLikes(String id);
  Future<void> decrementVideoLikes(String id);

  // --- Videos: CRUD ---
  Future<String> createVideo(VideoEntity video);
  Future<void> updateVideo(String id, VideoEntity video);
  Future<void> deleteVideo(String id);
  String getYoutubeThumbnail(String youtubeId);
  Future<List<VideoEntity>> searchVideos(String query);
  Future<List<VideoEntity>> getVideosBySystem(String systemId);

  // --- Articles: Read ---
  Future<List<ArticleEntity>> getArticles();
  Future<ArticleEntity?> getArticleById(String id);
  Stream<List<ArticleEntity>> watchArticles();
  Future<void> incrementArticleViews(String id);
  Future<void> incrementArticleHelpful(String id);
  Future<void> decrementArticleHelpful(String id);

  // --- Articles: CRUD ---
  Future<String> createArticle(ArticleEntity article);
  Future<void> updateArticle(String id, ArticleEntity article);
  Future<void> deleteArticle(String id);
  Future<List<ArticleEntity>> searchArticles(String query);
  Future<List<ArticleEntity>> getArticlesBySystem(String systemId);

  // --- Search ---
  // Future<List<VideoEntity>> searchVideos(String query); // Moved to Videos: CRUD
  // Future<List<ArticleEntity>> searchArticles(String query); // Moved to Articles: CRUD

  // --- Resources: Read ---
  Future<List<ResourceEntity>> getResources();
  Stream<List<ResourceEntity>> watchResources();
  Stream<List<ResourceEntity>> watchResourcesByAuthor(String authorId);
  Future<bool> isResourceBookmarked(String id);
  Future<List<String>> getBookmarkedResourceIds();

  // --- Resources: CRUD ---
  Future<String> createResource(ResourceEntity resource);
  Future<void> updateResource(String id, ResourceEntity resource);
  Future<void> deleteResource(String id);
  Future<void> toggleResourceBookmark(String id);
}
