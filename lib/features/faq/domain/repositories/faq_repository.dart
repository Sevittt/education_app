import '../entities/faq_entity.dart';

abstract class FaqRepository {
  // Read
  Stream<List<FaqEntity>> getAllFaqs();
  Stream<List<FaqEntity>> getFaqsByCategory(FaqCategory category);
  Stream<List<FaqEntity>> getFaqsBySystem(String systemId);
  Future<FaqEntity?> getFaqById(String id);
  Future<List<FaqEntity>> searchFaqs(String query);
  Future<List<FaqEntity>> getFaqsByIds(List<String> ids);
  Future<int> getTotalFaqsCount();
  Future<List<FaqEntity>> getMostViewedFaqs({int limit = 10});
  Future<List<FaqEntity>> getMostHelpfulFaqs({int limit = 10});

  // Write
  Future<String?> createFaq(FaqEntity faq);
  Future<void> updateFaq(FaqEntity faq);
  Future<void> deleteFaq(String id);

  // Counters
  Future<void> incrementViewCount(String id);
  Future<void> incrementHelpfulCount(String id);
  Future<void> decrementHelpfulCount(String id);
}
