import 'package:flutter/material.dart';
import '../../domain/entities/video_entity.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/entities/resource_entity.dart';
import '../../domain/repositories/library_repository.dart';
import '../../data/repositories/library_repository_impl.dart';

/// Provider for Library Feature State Management.
/// 
/// This class manages state for both Videos and Articles.
/// It depends on the LibraryRepository interface, not the implementation.
class LibraryProvider extends ChangeNotifier {
  final LibraryRepository _repository;

  LibraryProvider({LibraryRepository? repository})
      : _repository = repository ?? LibraryRepositoryImpl();

  // --- State ---
  List<VideoEntity> _videos = [];
  List<ArticleEntity> _articles = [];
  List<ResourceEntity> _resources = [];
  bool _isLoading = false;
  String? _error;

  // --- Getters ---
  List<VideoEntity> get videos => _videos;
  List<ArticleEntity> get articles => _articles;
  List<ResourceEntity> get resources => _resources;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // --- Video Actions ---

  Future<void> loadVideos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _videos = await _repository.getVideos();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void watchVideos() {
    _repository.watchVideos().listen(
      (videos) {
        _videos = videos;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<void> incrementVideoViews(String id) async {
    await _repository.incrementVideoViews(id);
  }

  // --- Article Actions ---

  Future<void> loadArticles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _articles = await _repository.getArticles();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void watchArticles() {
    _repository.watchArticles().listen(
      (articles) {
        _articles = articles;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<void> incrementArticleViews(String id) async {
    await _repository.incrementArticleViews(id);
  }

  // --- Search ---

  Future<List<VideoEntity>> searchVideos(String query) async {
    return _repository.searchVideos(query);
  }

  Future<List<ArticleEntity>> searchArticles(String query) async {
    return _repository.searchArticles(query);
  }

  Future<List<VideoEntity>> getVideosBySystem(String systemId) async {
    return _repository.getVideosBySystem(systemId);
  }

  Future<List<ArticleEntity>> getArticlesBySystem(String systemId) async {
    return _repository.getArticlesBySystem(systemId);
  }

  // --- Video CRUD ---

  Future<String> createVideo(VideoEntity video) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final id = await _repository.createVideo(video);
      await loadVideos(); // Refresh list
      return id;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateVideo(String id, VideoEntity video) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.updateVideo(id, video);
      await loadVideos(); // Refresh list
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteVideo(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteVideo(id);
      _videos.removeWhere((v) => v.id == id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  String getYoutubeThumbnail(String youtubeId) {
    return _repository.getYoutubeThumbnail(youtubeId);
  }

  Future<VideoEntity?> getVideoById(String id) async {
    return _repository.getVideoById(id);
  }

  // --- Article CRUD ---

  Future<String> createArticle(ArticleEntity article) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final id = await _repository.createArticle(article);
      await loadArticles(); // Refresh list
      return id;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateArticle(String id, ArticleEntity article) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.updateArticle(id, article);
      await loadArticles(); // Refresh list
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteArticle(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteArticle(id);
      _articles.removeWhere((a) => a.id == id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<ArticleEntity?> getArticleById(String id) async {
    return _repository.getArticleById(id);
  }

  Future<void> incrementArticleHelpful(String id) async {
    await _repository.incrementArticleHelpful(id);
  }

  Future<void> decrementArticleHelpful(String id) async {
    await _repository.decrementArticleHelpful(id);
  }

  Future<void> incrementVideoLikes(String id) async {
    await _repository.incrementVideoLikes(id);
  }

  Future<void> decrementVideoLikes(String id) async {
    await _repository.decrementVideoLikes(id);
  }

  // --- Resource Actions ---

  Future<void> loadResources() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _resources = await _repository.getResources();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void watchResources() {
    _repository.watchResources().listen(
      (resources) {
        _resources = resources;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  // --- Resource CRUD ---

  Future<String> createResource(ResourceEntity resource) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final id = await _repository.createResource(resource);
      await loadResources();
      return id;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateResource(String id, ResourceEntity resource) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.updateResource(id, resource);
      await loadResources();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteResource(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteResource(id);
      _resources.removeWhere((r) => r.id == id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // --- Resource Bookmarks ---

  Future<void> toggleResourceBookmark(String id) async {
    await _repository.toggleResourceBookmark(id);
    notifyListeners(); // Force rebuild
  }

  Future<bool> isResourceBookmarked(String id) async {
    return _repository.isResourceBookmarked(id);
  }

  Future<List<String>> getBookmarkedResourceIds() async {
    return _repository.getBookmarkedResourceIds();
  }

  // --- Streams for UI (e.g. Dashboard) ---
  Stream<List<ResourceEntity>> get resourcesStream => _repository.watchResources();
  
  Stream<List<ResourceEntity>> watchResourcesByAuthor(String authorId) {
    return _repository.watchResourcesByAuthor(authorId);
  }
}
