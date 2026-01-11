import '../entities/video_entity.dart';
import '../entities/article_entity.dart';

/// Abstract Repository Contract for the Library Feature.
/// 
/// This defines the interface that the Data Layer must implement.
/// The Presentation Layer depends on this contract, NOT the implementation.
abstract class LibraryRepository {
  // --- Videos ---
  Future<List<VideoEntity>> getVideos();
  Future<VideoEntity?> getVideoById(String id);
  Stream<List<VideoEntity>> watchVideos();
  Future<void> incrementVideoViews(String id);
  Future<void> incrementVideoLikes(String id);
  Future<void> decrementVideoLikes(String id);

  // --- Articles ---
  Future<List<ArticleEntity>> getArticles();
  Future<ArticleEntity?> getArticleById(String id);
  Stream<List<ArticleEntity>> watchArticles();
  Future<void> incrementArticleViews(String id);
  Future<void> incrementArticleHelpful(String id);
  Future<void> decrementArticleHelpful(String id);
  
  // --- Search ---
  Future<List<VideoEntity>> searchVideos(String query);
  Future<List<ArticleEntity>> searchArticles(String query);
}
