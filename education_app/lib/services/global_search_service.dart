import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sud_qollanma/models/search_result.dart';
import 'package:sud_qollanma/services/faq_service.dart';
import 'package:sud_qollanma/services/systems_service.dart';
import 'package:sud_qollanma/features/library/data/repositories/library_repository_impl.dart';
import 'package:sud_qollanma/features/library/data/datasources/library_remote_source.dart';
import 'package:sud_qollanma/features/library/domain/entities/article_entity.dart';
import 'package:sud_qollanma/features/library/domain/entities/video_entity.dart';

class GlobalSearchService {
  // Using Repository Implementation directly as this is a Service
  // In a full clean architecture, this might be a UseCase
  final LibraryRepositoryImpl _libraryRepository = LibraryRepositoryImpl(
    remoteSource: LibraryRemoteSource(),
  );
  
  final SystemsService _systemsService = SystemsService();
  final FAQService _faqService = FAQService();

  Future<List<SearchResult>> searchAll(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final lowerQuery = query.toLowerCase();

    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        _libraryRepository.getArticles(),
        _systemsService.getAllSystems().first,
        _libraryRepository.getVideos(),
        _faqService.getAllFAQs().first,
      ]);

      final articles = results[0] as List<ArticleEntity>;
      final systems = results[1] as List<dynamic>;
      final videos = results[2] as List<VideoEntity>;
      final faqs = results[3] as List<dynamic>;

      List<SearchResult> searchResults = [];

      // Process Articles
      for (var article in articles) {
        if (article.title.toLowerCase().contains(lowerQuery) ||
            article.description.toLowerCase().contains(lowerQuery)) {
          searchResults.add(SearchResult(
            id: article.id,
            title: article.title,
            description: article.description,
            type: 'article',
            originalObject: article,
          ));
        }
      }

      // Process Systems
      for (var system in systems) {
        if (system.name.toLowerCase().contains(lowerQuery) ||
            system.description.toLowerCase().contains(lowerQuery)) {
          searchResults.add(SearchResult(
            id: system.id,
            title: system.name,
            description: system.description,
            type: 'system',
            originalObject: system,
          ));
        }
      }

      // Process Videos
      for (var video in videos) {
        if (video.title.toLowerCase().contains(lowerQuery) ||
            video.description.toLowerCase().contains(lowerQuery)) {
          searchResults.add(SearchResult(
            id: video.id,
            title: video.title,
            description: video.description,
            type: 'video',
            originalObject: video,
          ));
        }
      }

      // Process FAQs
      for (var faq in faqs) {
        if (faq.question.toLowerCase().contains(lowerQuery) ||
            faq.answer.toLowerCase().contains(lowerQuery)) {
          searchResults.add(SearchResult(
            id: faq.id,
            title: faq.question,
            description: faq.answer, // Using answer as description
            type: 'faq',
            originalObject: faq,
          ));
        }
      }

      return searchResults;
    } catch (e) {
      print('Error in Global Search: $e');
      return [];
    }
  }
}
