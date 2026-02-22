import 'package:flutter/material.dart';
import '../../domain/usecases/search_all.dart';
import '../../domain/entities/search_result_entity.dart';

class SearchNotifier extends ChangeNotifier {
  final SearchAll _searchAll;

  SearchNotifier({required SearchAll searchAll}) : _searchAll = searchAll;

  List<SearchResultEntity> _results = [];
  List<SearchResultEntity> get results => _results;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> search(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      _results = await _searchAll(query);
    } catch (e) {
      print('Search Error: $e');
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearResults() {
    _results = [];
    notifyListeners();
  }
}
