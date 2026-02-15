import 'package:flutter/foundation.dart';
import 'package:sud_qollanma/features/faq/domain/entities/faq_entity.dart';
import 'package:sud_qollanma/features/faq/domain/repositories/faq_repository.dart';
import 'package:sud_qollanma/features/library/domain/entities/article_entity.dart';
import 'package:sud_qollanma/features/library/domain/entities/video_entity.dart';
import 'package:sud_qollanma/features/library/domain/repositories/library_repository.dart';
import 'package:sud_qollanma/features/systems/domain/entities/sud_system_entity.dart';
import 'package:sud_qollanma/features/systems/domain/repositories/systems_repository.dart';
import '../entities/search_result_entity.dart';

/// Smart Global Search UseCase.
///
/// Queries multiple Firestore collections in parallel and applies
/// a scoring algorithm to rank results by relevance. Also resolves
/// semantic connections (e.g., a matched system → its related videos/articles).
class SearchAll {
  final LibraryRepository libraryRepository;
  final SystemsRepository systemsRepository;
  final FaqRepository faqRepository;

  SearchAll({
    required this.libraryRepository,
    required this.systemsRepository,
    required this.faqRepository,
  });

  /// Execute the search across all collections.
  Future<List<SearchResultEntity>> call(String query) async {
    if (query.trim().isEmpty) return [];

    final lowerQuery = query.toLowerCase().trim();
    final queryWords = lowerQuery.split(RegExp(r'\s+'));

    try {
      // Fetch all data sources in parallel
      final futures = await Future.wait([
        libraryRepository.getArticles(),
        libraryRepository.getVideos(),
        systemsRepository.getAllSystems().first,
        faqRepository.getAllFaqs().first,
      ]);

      final articles = futures[0] as List<ArticleEntity>;
      final videos = futures[1] as List<VideoEntity>;
      final systems = futures[2] as List<SudSystemEntity>;
      final faqs = futures[3] as List<FaqEntity>;

      final List<SearchResultEntity> results = [];
      final Set<String> matchedSystemIds = {};

      // --- Score and collect Systems ---
      for (final system in systems) {
        final score = _scoreSystem(system, lowerQuery, queryWords);
        if (score > 0) {
          matchedSystemIds.add(system.id);
          results.add(SearchResultEntity(
            id: system.id,
            title: system.name,
            description: system.description,
            type: SearchResultType.system,
            score: score,
            systemId: system.id,
            tags: [],
          ));
        }
      }

      // --- Score and collect Articles ---
      for (final article in articles) {
        final score = _scoreArticle(article, lowerQuery, queryWords);
        if (score > 0) {
          results.add(SearchResultEntity(
            id: article.id,
            title: article.title,
            description: article.description,
            type: SearchResultType.article,
            score: score,
            systemId: article.systemId,
            tags: article.tags,
          ));
        }
      }

      // --- Score and collect Videos ---
      for (final video in videos) {
        final score = _scoreVideo(video, lowerQuery, queryWords);
        if (score > 0) {
          results.add(SearchResultEntity(
            id: video.id,
            title: video.title,
            description: video.description,
            type: SearchResultType.video,
            score: score,
            systemId: video.systemId,
            tags: video.tags,
          ));
        }
      }

      // --- Score and collect FAQs ---
      for (final faq in faqs) {
        final score = _scoreFaq(faq, lowerQuery, queryWords);
        if (score > 0) {
          results.add(SearchResultEntity(
            id: faq.id,
            title: faq.question,
            description: faq.answer,
            type: SearchResultType.faq,
            score: score,
            systemId: faq.systemId,
            tags: [],
          ));
        }
      }

      // --- Semantic Connections: add related content for matched systems ---
      final existingIds = results.map((r) => '${r.type.name}:${r.id}').toSet();

      for (final systemId in matchedSystemIds) {
        // Find articles linked to this system
        for (final article in articles) {
          final key = '${SearchResultType.article.name}:${article.id}';
          if (article.systemId == systemId && !existingIds.contains(key)) {
            existingIds.add(key);
            results.add(SearchResultEntity(
              id: article.id,
              title: article.title,
              description: article.description,
              type: SearchResultType.article,
              score: 2.0, // Lower score for semantic links
              systemId: article.systemId,
              tags: article.tags,
              isSemanticLink: true,
            ));
          }
        }

        // Find videos linked to this system
        for (final video in videos) {
          final key = '${SearchResultType.video.name}:${video.id}';
          if (video.systemId == systemId && !existingIds.contains(key)) {
            existingIds.add(key);
            results.add(SearchResultEntity(
              id: video.id,
              title: video.title,
              description: video.description,
              type: SearchResultType.video,
              score: 2.0,
              systemId: video.systemId,
              tags: video.tags,
              isSemanticLink: true,
            ));
          }
        }

        // Find FAQs linked to this system
        for (final faq in faqs) {
          final key = '${SearchResultType.faq.name}:${faq.id}';
          if (faq.systemId == systemId && !existingIds.contains(key)) {
            existingIds.add(key);
            results.add(SearchResultEntity(
              id: faq.id,
              title: faq.question,
              description: faq.answer,
              type: SearchResultType.faq,
              score: 2.0,
              systemId: faq.systemId,
              tags: [],
              isSemanticLink: true,
            ));
          }
        }
      }

      // Sort by score descending
      results.sort((a, b) => b.score.compareTo(a.score));

      return results;
    } catch (e, stack) {
      debugPrint('Error in SearchAll UseCase: $e\n$stack');
      return [];
    }
  }

  // --- Scoring Helpers ---

  /// Score a system based on query match.
  double _scoreSystem(SudSystemEntity system, String query, List<String> words) {
    double score = 0;
    final name = system.name.toLowerCase();
    final fullName = system.fullName.toLowerCase();
    final desc = system.description.toLowerCase();

    // Exact name match → highest priority
    if (name == query || fullName == query) {
      score += 20;
    } else if (name.contains(query) || fullName.contains(query)) {
      score += 10;
    }

    // Word-level matching
    for (final word in words) {
      if (name.contains(word)) score += 5;
      if (fullName.contains(word)) score += 4;
      if (desc.contains(word)) score += 2;
    }

    return score;
  }

  /// Score an article based on query match.
  double _scoreArticle(ArticleEntity article, String query, List<String> words) {
    double score = 0;
    final title = article.title.toLowerCase();
    final desc = article.description.toLowerCase();
    final content = article.content.toLowerCase();

    // Exact title match
    if (title == query) {
      score += 20;
    } else if (title.contains(query)) {
      score += 10;
    }

    // Word-level matching
    for (final word in words) {
      if (title.contains(word)) score += 5;
      if (desc.contains(word)) score += 3;
      if (content.contains(word)) score += 1;
    }

    // Tag matching
    for (final tag in article.tags) {
      if (tag.toLowerCase().contains(query)) score += 4;
      for (final word in words) {
        if (tag.toLowerCase().contains(word)) score += 2;
      }
    }

    return score;
  }

  /// Score a video based on query match.
  double _scoreVideo(VideoEntity video, String query, List<String> words) {
    double score = 0;
    final title = video.title.toLowerCase();
    final desc = video.description.toLowerCase();

    if (title == query) {
      score += 20;
    } else if (title.contains(query)) {
      score += 10;
    }

    for (final word in words) {
      if (title.contains(word)) score += 5;
      if (desc.contains(word)) score += 3;
    }

    // Tag matching
    for (final tag in video.tags) {
      if (tag.toLowerCase().contains(query)) score += 4;
      for (final word in words) {
        if (tag.toLowerCase().contains(word)) score += 2;
      }
    }

    return score;
  }

  /// Score a FAQ based on query match.
  double _scoreFaq(FaqEntity faq, String query, List<String> words) {
    double score = 0;
    final question = faq.question.toLowerCase();
    final answer = faq.answer.toLowerCase();

    if (question == query) {
      score += 20;
    } else if (question.contains(query)) {
      score += 10;
    }

    for (final word in words) {
      if (question.contains(word)) score += 5;
      if (answer.contains(word)) score += 3;
    }

    return score;
  }
}
