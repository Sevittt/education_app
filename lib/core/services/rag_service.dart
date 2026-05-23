import 'package:sud_qollanma/features/search/data/datasources/search_remote_datasource.dart';
import 'logger_service.dart';

class RagService {
  final SearchRemoteDataSource _search;

  RagService(this._search);

  /// Queries vector search and returns a formatted context string.
  /// Returns empty string if nothing found or on error (graceful fallback).
  Future<String> retrieveContext(String query, {int limit = 5}) async {
    if (query.trim().isEmpty) return '';

    try {
      final results = await _search.searchVectorQuery(query, limit: limit);

      if (results.isEmpty) {
        LoggerService().log('RagService: no results for "$query"');
        return '';
      }

      final buffer = StringBuffer();
      for (int i = 0; i < results.length; i++) {
        final item = results[i];
        final text = item.text.trim();
        if (text.isEmpty) continue;

        final label = item.title.isNotEmpty ? item.title : 'Hujjat ${i + 1}';
        buffer.writeln('[$label]');
        buffer.writeln(text);
        buffer.writeln();
      }

      final context = buffer.toString().trim();
      LoggerService().log(
          'RagService: retrieved ${results.length} chunks (${context.length} chars)');
      return context;
    } catch (e, stack) {
      LoggerService().recordError(e, stack, reason: 'RagService: retrieveContext failed');
      return '';
    }
  }
}
