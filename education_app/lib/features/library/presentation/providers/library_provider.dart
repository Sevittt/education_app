import 'package:flutter/material.dart';
import '../../domain/entities/video_entity.dart';
import '../../domain/entities/article_entity.dart';
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
  bool _isLoading = false;
  String? _error;

  // --- Getters ---
  List<VideoEntity> get videos => _videos;
  List<ArticleEntity> get articles => _articles;
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
}
