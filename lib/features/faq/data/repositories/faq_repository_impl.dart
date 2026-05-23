import '../../domain/entities/faq_entity.dart';
import '../../domain/repositories/faq_repository.dart';
import '../datasources/faq_remote_datasource.dart';
import '../models/faq_model.dart';
import '../../../search/utils/search_indexer.dart';
import '../../../search/data/models/search_index_model.dart';

class FaqRepositoryImpl implements FaqRepository {
  final FaqRemoteDataSource remoteDataSource;
  final SearchIndexer _searchIndexer;

  FaqRepositoryImpl({
    required this.remoteDataSource,
    SearchIndexer? searchIndexer,
  }) : _searchIndexer = searchIndexer ?? SearchIndexer();

  @override
  Stream<List<FaqEntity>> getAllFaqs() => remoteDataSource.getAllFaqs();

  @override
  Stream<List<FaqEntity>> getFaqsByCategory(FaqCategory category) =>
      remoteDataSource.getFaqsByCategory(category);

  @override
  Stream<List<FaqEntity>> getFaqsBySystem(String systemId) =>
      remoteDataSource.getFaqsBySystem(systemId);

  @override
  Future<FaqEntity?> getFaqById(String id) => remoteDataSource.getFaqById(id);

  @override
  Future<List<FaqEntity>> searchFaqs(String query) =>
      remoteDataSource.searchFaqs(query);

  @override
  Future<List<FaqEntity>> getFaqsByIds(List<String> ids) =>
      remoteDataSource.getFaqsByIds(ids);

  @override
  Future<int> getTotalFaqsCount() => remoteDataSource.getTotalFaqsCount();

  @override
  Future<List<FaqEntity>> getMostViewedFaqs({int limit = 10}) =>
      remoteDataSource.getMostViewedFaqs(limit: limit);

  @override
  Future<List<FaqEntity>> getMostHelpfulFaqs({int limit = 10}) =>
      remoteDataSource.getMostHelpfulFaqs(limit: limit);

  @override
  Future<String?> createFaq(FaqEntity faq) async {
    final faqModel = FaqModel(
      id: faq.id,
      question: faq.question,
      answer: faq.answer,
      category: faq.category,
      systemId: faq.systemId,
      relatedArticles: faq.relatedArticles,
      relatedVideos: faq.relatedVideos,
      viewCount: faq.viewCount,
      helpfulCount: faq.helpfulCount,
      order: faq.order,
      createdAt: faq.createdAt,
      updatedAt: faq.updatedAt,
    );
    final id = await remoteDataSource.createFaq(faqModel);
    if (id != null) {
      await _searchIndexer.indexDocument(SearchIndexModel(
        id: 'faq_$id',
        title: faq.question,
        description: faq.answer,
        type: 'faq',
        text: '${faq.question}\n${faq.answer}',
        path: '/faq/$id',
        createdAt: faq.createdAt,
      ));
    }
    return id;
  }

  @override
  Future<void> updateFaq(FaqEntity faq) async {
    final faqModel = FaqModel(
      id: faq.id,
      question: faq.question,
      answer: faq.answer,
      category: faq.category,
      systemId: faq.systemId,
      relatedArticles: faq.relatedArticles,
      relatedVideos: faq.relatedVideos,
      viewCount: faq.viewCount,
      helpfulCount: faq.helpfulCount,
      order: faq.order,
      createdAt: faq.createdAt,
      updatedAt: faq.updatedAt,
    );
    await remoteDataSource.updateFaq(faqModel);
    await _searchIndexer.indexDocument(SearchIndexModel(
      id: 'faq_${faq.id}',
      title: faq.question,
      description: faq.answer,
      type: 'faq',
      text: '${faq.question}\n${faq.answer}',
      path: '/faq/${faq.id}',
      createdAt: faq.createdAt,
    ));
  }

  @override
  Future<void> deleteFaq(String id) async {
    await remoteDataSource.deleteFaq(id);
    await _searchIndexer.deleteDocument('faq_$id');
  }

  @override
  Future<void> incrementViewCount(String id) =>
      remoteDataSource.incrementViewCount(id);

  @override
  Future<void> incrementHelpfulCount(String id) =>
      remoteDataSource.incrementHelpfulCount(id);

  @override
  Future<void> decrementHelpfulCount(String id) =>
      remoteDataSource.decrementHelpfulCount(id);
}
