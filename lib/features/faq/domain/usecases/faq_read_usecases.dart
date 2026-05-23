import '../entities/faq_entity.dart';
import '../repositories/faq_repository.dart';

class GetFaqs {
  final FaqRepository repository;
  GetFaqs(this.repository);

  Stream<List<FaqEntity>> call() => repository.getAllFaqs();
}

class GetFaqsByCategory {
  final FaqRepository repository;
  GetFaqsByCategory(this.repository);

  Stream<List<FaqEntity>> call(FaqCategory category) => 
      repository.getFaqsByCategory(category);
}

class GetFaqsBySystem {
  final FaqRepository repository;
  GetFaqsBySystem(this.repository);

  Stream<List<FaqEntity>> call(String systemId) => 
      repository.getFaqsBySystem(systemId);
}

class GetFaqById {
  final FaqRepository repository;
  GetFaqById(this.repository);

  Future<FaqEntity?> call(String id) => repository.getFaqById(id);
}

class SearchFaqs {
  final FaqRepository repository;
  SearchFaqs(this.repository);

  Future<List<FaqEntity>> call(String query) => repository.searchFaqs(query);
}

class GetMostViewedFaqs {
  final FaqRepository repository;
  GetMostViewedFaqs(this.repository);

  Future<List<FaqEntity>> call({int limit = 10}) => 
      repository.getMostViewedFaqs(limit: limit);
}

class GetMostHelpfulFaqs {
  final FaqRepository repository;
  GetMostHelpfulFaqs(this.repository);

  Future<List<FaqEntity>> call({int limit = 10}) => 
      repository.getMostHelpfulFaqs(limit: limit);
}
