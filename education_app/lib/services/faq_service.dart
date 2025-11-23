// lib/services/faq_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/faq.dart';

/// FAQ Service
/// 
/// Ko'p so'raladigan savollarni boshqarish
class FAQService {
  final CollectionReference<Map<String, dynamic>> _faqsCollection =
      FirebaseFirestore.instance.collection('faqs');

  // ==========================================
  // READ OPERATIONS
  // ==========================================

  /// Barcha FAQ'larni olish (order bo'yicha)
  Stream<List<FAQ>> getAllFAQs() {
    return _faqsCollection
        .orderBy('order')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FAQ.fromFirestore(doc))
          .toList();
    });
  }

  /// Kategoriya bo'yicha FAQ'lar
  Stream<List<FAQ>> getFAQsByCategory(FAQCategory category) {
    return _faqsCollection
        .where('category', isEqualTo: category.name)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FAQ.fromFirestore(doc))
          .toList();
    });
  }

  /// Tizim bo'yicha FAQ'lar
  Stream<List<FAQ>> getFAQsBySystem(String systemId) {
    return _faqsCollection
        .where('systemId', isEqualTo: systemId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FAQ.fromFirestore(doc))
          .toList();
    });
  }

  /// Bitta FAQ olish
  Future<FAQ?> getFAQById(String id) async {
    try {
      final doc = await _faqsCollection.doc(id).get();
      if (!doc.exists) return null;
      return FAQ.fromFirestore(doc);
    } catch (e) {
      print('Error getting FAQ: $e');
      return null;
    }
  }

  /// FAQ qidiruv (savol va javobda)
  Future<List<FAQ>> searchFAQs(String query) async {
    try {
      if (query.isEmpty) return [];

      final queryLower = query.toLowerCase();
      final snapshot = await _faqsCollection.get();
      
      final faqs = snapshot.docs
          .map((doc) => FAQ.fromFirestore(doc))
          .where((faq) {
            final questionMatch = faq.question.toLowerCase().contains(queryLower);
            final answerMatch = faq.answer.toLowerCase().contains(queryLower);
            return questionMatch || answerMatch;
          })
          .toList();

      return faqs;
    } catch (e) {
      print('Error searching FAQs: $e');
      return [];
    }
  }

  /// Ko'p ID'lar bo'yicha FAQ'lar olish
  Future<List<FAQ>> getFAQsByIds(List<String> ids) async {
    try {
      if (ids.isEmpty) return [];
      
      final List<FAQ> faqs = [];
      
      // 10 tadan batch'larga bo'lamiz
      for (int i = 0; i < ids.length; i += 10) {
        final batch = ids.skip(i).take(10).toList();
        final snapshot = await _faqsCollection
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        
        faqs.addAll(
          snapshot.docs.map((doc) => FAQ.fromFirestore(doc)),
        );
      }
      
      return faqs;
    } catch (e) {
      print('Error getting FAQs by IDs: $e');
      return [];
    }
  }

  // ==========================================
  // WRITE OPERATIONS
  // ==========================================

  /// Yangi FAQ qo'shish
  Future<String?> createFAQ(FAQ faq) async {
    try {
      final docRef = await _faqsCollection.add(faq.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating FAQ: $e');
      return null;
    }
  }

  /// FAQ yangilash
  Future<bool> updateFAQ(String id, FAQ faq) async {
    try {
      await _faqsCollection.doc(id).update(faq.toFirestore());
      return true;
    } catch (e) {
      print('Error updating FAQ: $e');
      return false;
    }
  }

  /// FAQ o'chirish
  Future<bool> deleteFAQ(String id) async {
    try {
      await _faqsCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting FAQ: $e');
      return false;
    }
  }

  // ==========================================
  // COUNTER OPERATIONS
  // ==========================================

  /// Ko'rilganlar sonini oshirish
  Future<void> incrementViewCount(String faqId) async {
    try {
      final docRef = _faqsCollection.doc(faqId);
      
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;
        
        final currentViews = (snapshot.data()?['viewCount'] as num?)?.toInt() ?? 0;
        transaction.update(docRef, {'viewCount': currentViews + 1});
      });
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  /// "Foydali" sonini oshirish
  Future<void> incrementHelpfulCount(String faqId) async {
    try {
      final docRef = _faqsCollection.doc(faqId);
      
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;
        
        final currentHelpful = 
            (snapshot.data()?['helpfulCount'] as num?)?.toInt() ?? 0;
        transaction.update(docRef, {'helpfulCount': currentHelpful + 1});
      });
    } catch (e) {
      print('Error incrementing helpful count: $e');
    }
  }

  /// "Foydali" sonini kamaytirish
  Future<void> decrementHelpfulCount(String faqId) async {
    try {
      final docRef = _faqsCollection.doc(faqId);
      
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;
        
        final currentHelpful = 
            (snapshot.data()?['helpfulCount'] as num?)?.toInt() ?? 0;
        if (currentHelpful > 0) {
          transaction.update(docRef, {'helpfulCount': currentHelpful - 1});
        }
      });
    } catch (e) {
      print('Error decrementing helpful count: $e');
    }
  }

  // ==========================================
  // STATISTICS
  // ==========================================

  /// Jami FAQ'lar soni
  Future<int> getTotalFAQsCount() async {
    try {
      final snapshot = await _faqsCollection.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting total count: $e');
      return 0;
    }
  }

  /// Eng ko'p ko'rilgan FAQ'lar
  Future<List<FAQ>> getMostViewedFAQs({int limit = 10}) async {
    try {
      final snapshot = await _faqsCollection
          .orderBy('viewCount', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => FAQ.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting most viewed FAQs: $e');
      return [];
    }
  }

  /// Eng foydali FAQ'lar
  Future<List<FAQ>> getMostHelpfulFAQs({int limit = 10}) async {
    try {
      final snapshot = await _faqsCollection
          .orderBy('helpfulCount', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => FAQ.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting most helpful FAQs: $e');
      return [];
    }
  }
}
