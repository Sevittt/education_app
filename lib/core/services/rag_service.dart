import 'dart:async';
import 'package:sud_qollanma/features/search/data/datasources/search_remote_datasource.dart';
import 'local_rag_service.dart';
import 'logger_service.dart';
import 'wiki_service.dart';

class RagService {
  final SearchRemoteDataSource _search;
  final WikiService _wiki;
  final LocalRagService? _localRag;

  RagService(this._search, this._wiki, [this._localRag]);

  /// Kontekst qidiruv zanjiri:
  ///   1. WikiService → slug bo'yicha tezkor lookup
  ///   2. LocalRagService → EmbeddingGemma-2 & Drift lokal vektor / semantik qidiruv
  ///   3. Topilmasa: rag_chunks Firebase Vector Search (remote fallback)
  ///   4. Natija bor bo'lsa: fon rejimida wiki sahifa yaratiladi
  Future<String> retrieveContext(String query, {int limit = 5}) async {
    if (query.trim().isEmpty) return '';

    // 1. Wiki qatlami
    try {
      final wikiContext = await _wiki.search(query);
      if (wikiContext != null && wikiContext.isNotEmpty) {
        return wikiContext;
      }
    } catch (e, stack) {
      LoggerService()
          .recordError(e, stack, reason: 'RagService: wiki search failed');
    }

    // 2. Lokal RAG (EmbeddingGemma-2 va Drift SQLite)
    if (_localRag != null) {
      try {
        final localContext =
            await _localRag!.getGroundingContext(query, limit: limit);
        if (localContext.isNotEmpty) {
          LoggerService().log(
              'RagService: retrieved from LocalRagService (${localContext.length} chars)');
          return localContext;
        }
      } catch (e, stack) {
        LoggerService().recordError(e, stack,
            reason: 'RagService: LocalRagService failed');
      }
    }

    // 3. Masofaviy RAG fallback (Firebase Vector Search)
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

      // 3. Fon rejimida wiki sahifa yaratish
      if (context.isNotEmpty) {
        unawaited(_wiki.buildPage(query, context));
      }

      return context;
    } catch (e, stack) {
      LoggerService()
          .recordError(e, stack, reason: 'RagService: retrieveContext failed');
      return '';
    }
  }
}
