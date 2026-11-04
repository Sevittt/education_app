import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart';
import '../database/app_database.dart';

class RagSearchResult {
  final String id;
  final String title;
  final String module;
  final String category;
  final String content;
  final double score;

  RagSearchResult({
    required this.id,
    required this.title,
    required this.module,
    required this.category,
    required this.content,
    required this.score,
  });
}

/// EmbeddingGemma-2 va Drift SQLite asosidagi lokal RAG xizmati.
///
/// Barcha darslar va sud qo'llanmalari (404 ta bo'lak) lokal SQLite bazasida
/// saqlanadi va oflayn rejimda yuqori aniqlikdagi qidiruvni ta'minlaydi.
class LocalRagService {
  final AppDatabase _db;
  static bool _isSeeding = false;

  LocalRagService(this._db);

  /// Ilova birinchi marta ochilganda `assets/data/court_knowledge_chunks.json`
  /// dan 404 ta sud bilim bo'laklarini lokal Drift bazasiga yuklaydi.
  Future<int> ensureSeeded() async {
    if (_isSeeding) return 0;
    try {
      final count = await _db.getRagChunksCount();
      if (count > 0) {
        return count;
      }

      _isSeeding = true;
      if (kDebugMode) {
        debugPrint('LocalRagService: Seeding court knowledge chunks into Drift...');
      }

      final jsonStr =
          await rootBundle.loadString('assets/data/court_knowledge_chunks.json');
      final List<dynamic> list = json.decode(jsonStr);

      final companions = list.map((item) {
        final m = item as Map<String, dynamic>;
        // Use 256-dim vector for compact mobile storage, or fallback to 768
        final vec = m['vector_256'] ?? m['vector_768'] ?? [];
        return RagChunksTableCompanion(
          id: Value(m['id'].toString()),
          title: Value(m['title']?.toString() ?? ''),
          module: Value(m['module']?.toString() ?? ''),
          category: Value(m['category']?.toString() ?? ''),
          content: Value(m['content']?.toString() ?? ''),
          vectorJson: Value(json.encode(vec)),
          sourcePath: Value(m['source_path']?.toString()),
          updatedAt: Value(DateTime.now()),
        );
      }).toList();

      await _db.saveRagChunks(companions);
      if (kDebugMode) {
        debugPrint(
            'LocalRagService: Successfully seeded ${companions.length} chunks into SQLite!');
      }
      return companions.length;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('LocalRagService.ensureSeeded error: $e');
      }
      return 0;
    } finally {
      _isSeeding = false;
    }
  }

  /// Qidiruv: Agar [queryVector] berilsa, vektorli kosinus o'xshashligi;
  /// aks holda matnli semantik token mosligi bo'yicha lokal qidiradi.
  Future<List<RagSearchResult>> search({
    required String query,
    List<double>? queryVector,
    int limit = 5,
  }) async {
    final chunks = await _db.getAllRagChunks();
    if (chunks.isEmpty) {
      return [];
    }

    final queryTokens = _tokenize(query);
    final results = <RagSearchResult>[];

    for (final chunk in chunks) {
      double score = 0.0;

      if (queryVector != null && queryVector.isNotEmpty) {
        try {
          final List<dynamic> rawVec = json.decode(chunk.vectorJson);
          final docVec = rawVec.map((e) => (e as num).toDouble()).toList();
          score = _cosineSimilarity(queryVector, docVec);
        } catch (_) {
          score = 0.0;
        }
      } else {
        // High-precision keyword + section match in local Dart
        score = _textMatchScore(queryTokens, chunk.title, chunk.content);
      }

      if (score > 0.1) {
        results.add(RagSearchResult(
          id: chunk.id,
          title: chunk.title,
          module: chunk.module,
          category: chunk.category,
          content: chunk.content,
          score: score,
        ));
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results.take(limit).toList();
  }

  /// "Sodiq" AI Mentori uchun kontekst matnini shakllantiradi.
  Future<String> getGroundingContext(
    String query, {
    List<double>? queryVector,
    int limit = 3,
  }) async {
    final matches =
        await search(query: query, queryVector: queryVector, limit: limit);
    if (matches.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('--- Rasmiy Sud Yo\'riqnomalari va Darslar Konteksti ---');
    for (int i = 0; i < matches.length; i++) {
      final m = matches[i];
      buffer.writeln('### [Hujjat ${i + 1}: ${m.title} (${m.module})]');
      buffer.writeln(m.content);
      buffer.writeln();
    }
    buffer.writeln('--- Kontekst Yakuni ---');
    return buffer.toString().trim();
  }

  /// Normalizatsiyalangan vektorlar uchun kosinus o'xshashligi (dot product).
  double _cosineSimilarity(List<double> a, List<double> b) {
    final len = a.length < b.length ? a.length : b.length;
    if (len == 0) return 0.0;
    double dot = 0.0;
    for (int i = 0; i < len; i++) {
      dot += a[i] * b[i];
    }
    return dot;
  }

  List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s\-]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 2)
        .toList();
  }

  double _textMatchScore(List<String> tokens, String title, String content) {
    if (tokens.isEmpty) return 0.0;
    final tLower = title.toLowerCase();
    final cLower = content.toLowerCase();

    double matchCount = 0.0;
    for (final tok in tokens) {
      if (tLower.contains(tok)) {
        matchCount += 3.0; // Title match has high weight
      }
      if (cLower.contains(tok)) {
        matchCount += 1.0;
      }
    }
    return matchCount / (tokens.length * 4.0);
  }
}
