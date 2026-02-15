import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/faq_entity.dart';
import '../models/faq_model.dart';

abstract class FaqRemoteDataSource {
  Stream<List<FaqModel>> getAllFaqs();
  Stream<List<FaqModel>> getFaqsByCategory(FaqCategory category);
  Stream<List<FaqModel>> getFaqsBySystem(String systemId);
  Future<FaqModel?> getFaqById(String id);
  Future<List<FaqModel>> searchFaqs(String query);
  Future<List<FaqModel>> getFaqsByIds(List<String> ids);
  Future<int> getTotalFaqsCount();
  Future<List<FaqModel>> getMostViewedFaqs({int limit = 10});
  Future<List<FaqModel>> getMostHelpfulFaqs({int limit = 10});
  
  Future<String?> createFaq(FaqModel faq);
  Future<void> updateFaq(FaqModel faq);
  Future<void> deleteFaq(String id);
  
  Future<void> incrementViewCount(String id);
  Future<void> incrementHelpfulCount(String id);
  Future<void> decrementHelpfulCount(String id);
}

class FaqRemoteDataSourceImpl implements FaqRemoteDataSource {
  final CollectionReference<Map<String, dynamic>> _faqsCollection =
      FirebaseFirestore.instance.collection('faq');

  @override
  Stream<List<FaqModel>> getAllFaqs() {
    return _faqsCollection
        .orderBy('order')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FaqModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Stream<List<FaqModel>> getFaqsByCategory(FaqCategory category) {
    return _faqsCollection
        .where('category', isEqualTo: category.name)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FaqModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Stream<List<FaqModel>> getFaqsBySystem(String systemId) {
    return _faqsCollection
        .where('systemId', isEqualTo: systemId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FaqModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<FaqModel?> getFaqById(String id) async {
    final doc = await _faqsCollection.doc(id).get();
    if (!doc.exists) return null;
    return FaqModel.fromFirestore(doc);
  }

  @override
  Future<List<FaqModel>> searchFaqs(String query) async {
    if (query.isEmpty) return [];

    final queryLower = query.toLowerCase();
    final snapshot = await _faqsCollection.get();
    
    return snapshot.docs
        .map((doc) => FaqModel.fromFirestore(doc))
        .where((faq) {
          final questionMatch = faq.question.toLowerCase().contains(queryLower);
          final answerMatch = faq.answer.toLowerCase().contains(queryLower);
          return questionMatch || answerMatch;
        })
        .toList();
  }

  @override
  Future<List<FaqModel>> getFaqsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    
    final List<FaqModel> faqs = [];
    
    for (int i = 0; i < ids.length; i += 10) {
      final batch = ids.skip(i).take(10).toList();
      final snapshot = await _faqsCollection
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      
      faqs.addAll(
        snapshot.docs.map((doc) => FaqModel.fromFirestore(doc)),
      );
    }
    
    return faqs;
  }

  @override
  Future<int> getTotalFaqsCount() async {
    final snapshot = await _faqsCollection.count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<List<FaqModel>> getMostViewedFaqs({int limit = 10}) async {
    final snapshot = await _faqsCollection
        .orderBy('viewCount', descending: true)
        .limit(limit)
        .get();
    
    return snapshot.docs
        .map((doc) => FaqModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<List<FaqModel>> getMostHelpfulFaqs({int limit = 10}) async {
    final snapshot = await _faqsCollection
        .orderBy('helpfulCount', descending: true)
        .limit(limit)
        .get();
    
    return snapshot.docs
        .map((doc) => FaqModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<String?> createFaq(FaqModel faq) async {
    final docRef = await _faqsCollection.add(faq.toFirestore());
    return docRef.id;
  }

  @override
  Future<void> updateFaq(FaqModel faq) async {
    await _faqsCollection.doc(faq.id).update(faq.toFirestore());
  }

  @override
  Future<void> deleteFaq(String id) async {
    await _faqsCollection.doc(id).delete();
  }

  @override
  Future<void> incrementViewCount(String id) async {
    final docRef = _faqsCollection.doc(id);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      
      final currentViews = (snapshot.data()?['viewCount'] as num?)?.toInt() ?? 0;
      transaction.update(docRef, {'viewCount': currentViews + 1});
    });
  }

  @override
  Future<void> incrementHelpfulCount(String id) async {
    final docRef = _faqsCollection.doc(id);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      
      final currentHelpful = (snapshot.data()?['helpfulCount'] as num?)?.toInt() ?? 0;
      transaction.update(docRef, {'helpfulCount': currentHelpful + 1});
    });
  }

  @override
  Future<void> decrementHelpfulCount(String id) async {
    final docRef = _faqsCollection.doc(id);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      
      final currentHelpful = (snapshot.data()?['helpfulCount'] as num?)?.toInt() ?? 0;
      if (currentHelpful > 0) {
        transaction.update(docRef, {'helpfulCount': currentHelpful - 1});
      }
    });
  }
}
