import 'package:flutter/material.dart';
import '../../domain/usecases/search_all.dart';
import '../../domain/entities/search_result_entity.dart';

/// State management for the Global Search feature.
///
/// Maintains a cached list of all results and supports client-side
/// type filtering without re-fetching from the database.
class SearchNotifier extends ChangeNotifier {
  final SearchAll _searchAll;

  SearchNotifier({required SearchAll searchAll}) : _searchAll = searchAll;

  // --- Private state ---
  List<SearchResultEntity> _allResults = [];
  SearchResultType? _activeFilter;
  bool _isLoading = false;
  String? _error;
  String _lastQuery = '';

  // --- Public getters ---
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get lastQuery => _lastQuery;
  SearchResultType? get activeFilter => _activeFilter;

  /// Returns filtered + sorted results based on the active filter.
  List<SearchResultEntity> get results {
    if (_activeFilter == null) return _allResults;
    return _allResults.where((r) => r.type == _activeFilter).toList();
  }

  /// Direct results (not semantically linked).
  List<SearchResultEntity> get directResults =>
      results.where((r) => !r.isSemanticLink).toList();

  /// Semantically linked results (related content).
  List<SearchResultEntity> get semanticResults =>
      results.where((r) => r.isSemanticLink).toList();

  /// Count of results per type (for filter chip badges).
  Map<SearchResultType, int> get typeCounts {
    final counts = <SearchResultType, int>{};
    for (final result in _allResults) {
      counts[result.type] = (counts[result.type] ?? 0) + 1;
    }
    return counts;
  }

  // --- Actions ---

  /// Execute a search query across all collections.
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      clearResults();
      return;
    }

    _isLoading = true;
    _error = null;
    _lastQuery = query;
    notifyListeners();

    try {
      _allResults = await _searchAll(query);
    } catch (e) {
      debugPrint('Search Error: $e');
      _error = e.toString();
      _allResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set or clear the active type filter (client-side, no re-fetch).
  void setFilter(SearchResultType? type) {
    _activeFilter = type;
    notifyListeners();
  }

  /// Clear all results and filters.
  void clearResults() {
    _allResults = [];
    _activeFilter = null;
    _error = null;
    _lastQuery = '';
    notifyListeners();
  }
}
