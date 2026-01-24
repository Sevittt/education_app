import 'package:sud_qollanma/features/faq/domain/repositories/faq_repository.dart';
import 'package:sud_qollanma/features/library/domain/repositories/library_repository.dart';
import 'package:sud_qollanma/features/systems/domain/repositories/systems_repository.dart';
import '../entities/search_result_entity.dart';

class SearchAll {
  final LibraryRepository libraryRepository;
  final SystemsRepository systemsRepository;
  final FaqRepository faqRepository;

  SearchAll({
    required this.libraryRepository,
    required this.systemsRepository,
    required this.faqRepository,
  });

  Future<List<SearchResultEntity>> call(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final lowerQuery = query.toLowerCase();

    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        libraryRepository.getArticles(),
        systemsRepository.getAllSystems().first, // Assuming it returns Stream
        libraryRepository.getVideos(),
        faqRepository.getAllFaqs().first, // Assuming it returns Stream
      ]);

      // Note: We need to cast or ensure types are correct. 
      // The repositories return Entities.
      final articles = results[0]; 
      final systems = results[1];
      final videos = results[2];
      final faqs = results[3];

      List<SearchResultEntity> searchResults = [];

      // Process Articles
      for (var article in articles as dynamic) {
        if (article.title.toLowerCase().contains(lowerQuery) ||
            article.description.toLowerCase().contains(lowerQuery)) {
          searchResults.add(SearchResultEntity(
            id: article.id,
            title: article.title,
            description: article.description,
            type: 'article',
            originalObject: article,
          ));
        }
      }

      // Process Systems
      for (var system in systems as dynamic) {
        if (system.name.toLowerCase().contains(lowerQuery) ||
            system.description.toLowerCase().contains(lowerQuery)) {
          searchResults.add(SearchResultEntity(
            id: system.id,
            title: system.name,
            description: system.description,
            type: 'system',
            originalObject: system,
          ));
        }
      }

      // Process Videos
      for (var video in videos as dynamic) {
        if (video.title.toLowerCase().contains(lowerQuery) ||
            video.description.toLowerCase().contains(lowerQuery)) {
          searchResults.add(SearchResultEntity(
            id: video.id,
            title: video.title,
            description: video.description,
            type: 'video',
            originalObject: video,
          ));
        }
      }

      // Process FAQs
      for (var faq in faqs as dynamic) {
        if (faq.question.toLowerCase().contains(lowerQuery) ||
            faq.answer.toLowerCase().contains(lowerQuery)) {
          searchResults.add(SearchResultEntity(
            id: faq.id,
            title: faq.question,
            description: faq.answer,
            type: 'faq',
            originalObject: faq,
          ));
        }
      }

      return searchResults;
    } catch (e) {
      print('Error in SearchAll UseCase: $e');
      return [];
    }
  }
}
