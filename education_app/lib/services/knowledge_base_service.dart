// lib/services/knowledge_base_service.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/knowledge_article.dart';

/// Knowledge Base Service
/// 
/// Bu service barcha bilimlar bazasi operatsiyalarini boshqaradi:
/// - Maqolalarni olish, yaratish, yangilash, o'chirish
/// - PDF fayllarni yuklash va storage'dan o'chirish
/// - View va helpful counter'larni boshqarish
/// - Qidiruv va filtrlash
class KnowledgeBaseService {
  // Firestore collection reference
  final CollectionReference<Map<String, dynamic>> _articlesCollection =
      FirebaseFirestore.instance.collection('knowledge_articles');
  
  // Firebase Storage reference
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ==========================================
  // READ OPERATIONS (Olish)
  // ==========================================

  /// Barcha maqolalarni stream orqali olish
  /// 
  /// Real-time yangilanishlar uchun Stream ishlatamiz
  /// UI automatic yangilanadi
  Stream<List<KnowledgeArticle>> getAllArticles() {
    return _articlesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => KnowledgeArticle.fromFirestore(doc))
          .toList();
    });
  }

  /// Kategoriya bo'yicha maqolalar
  Stream<List<KnowledgeArticle>> getArticlesByCategory(
    ArticleCategory category,
  ) {
    return _articlesCollection
        .where('category', isEqualTo: category.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => KnowledgeArticle.fromFirestore(doc))
          .toList();
    });
  }

  /// Tizim bo'yicha maqolalar
  Stream<List<KnowledgeArticle>> getArticlesBySystem(String systemId) {
    return _articlesCollection
        .where('systemId', isEqualTo: systemId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => KnowledgeArticle.fromFirestore(doc))
          .toList();
    });
  }

  /// Pinned (muhim) maqolalar
  Stream<List<KnowledgeArticle>> getPinnedArticles() {
    return _articlesCollection
        .where('isPinned', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => KnowledgeArticle.fromFirestore(doc))
          .toList();
    });
  }

  /// Bitta maqolani ID bo'yicha olish
  Future<KnowledgeArticle?> getArticleById(String id) async {
    try {
      final doc = await _articlesCollection.doc(id).get();
      if (!doc.exists) return null;
      return KnowledgeArticle.fromFirestore(doc);
    } catch (e) {
      print('Error getting article: $e');
      return null;
    }
  }

  /// Qidiruv funksiyasi
  /// 
  /// IMPORTANT: Firestore'da full-text search yo'q!
  /// Bu simple search - title va tags bo'yicha
  /// Production uchun Algolia yoki Elasticsearch kerak bo'ladi
  Future<List<KnowledgeArticle>> searchArticles(String query) async {
    try {
      if (query.isEmpty) return [];

      final queryLower = query.toLowerCase();

      // Barcha maqolalarni olamiz (kichik database uchun OK)
      final snapshot = await _articlesCollection.get();
      
      final articles = snapshot.docs
          .map((doc) => KnowledgeArticle.fromFirestore(doc))
          .where((article) {
            // Title yoki tags'da qidiramiz
            final titleMatch = article.title.toLowerCase().contains(queryLower);
            final tagsMatch = article.tags.any(
              (tag) => tag.toLowerCase().contains(queryLower),
            );
            final descMatch = article.description.toLowerCase().contains(queryLower);
            
            return titleMatch || tagsMatch || descMatch;
          })
          .toList();

      return articles;
    } catch (e) {
      print('Error searching articles: $e');
      return [];
    }
  }

  // ==========================================
  // WRITE OPERATIONS (Yozish)
  // ==========================================

  /// Yangi maqola yaratish
  Future<String?> createArticle(KnowledgeArticle article) async {
    try {
      final docRef = await _articlesCollection.add(article.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating article: $e');
      return null;
    }
  }

  /// Maqolani yangilash
  Future<bool> updateArticle(String id, KnowledgeArticle article) async {
    try {
      await _articlesCollection.doc(id).update(article.toFirestore());
      return true;
    } catch (e) {
      print('Error updating article: $e');
      return false;
    }
  }

  /// Maqolani o'chirish (PDF bilan birga)
  Future<bool> deleteArticle(String id) async {
    try {
      // Avval maqolani olamiz (PDF URL kerak)
      final article = await getArticleById(id);
      
      // Agar PDF bor bo'lsa, uni ham o'chiramiz
      if (article?.pdfUrl != null && article!.pdfUrl!.isNotEmpty) {
        await deletePDF(article.pdfUrl!);
      }
      
      // Maqolani o'chiramiz
      await _articlesCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting article: $e');
      return false;
    }
  }

  // ==========================================
  // COUNTER OPERATIONS (Hisoblagichlar)
  // ==========================================

  /// Ko'rilganlar sonini oshirish
  /// 
  /// Firestore transaction ishlatamiz - race condition'dan himoya
  Future<void> incrementViews(String articleId) async {
    try {
      final docRef = _articlesCollection.doc(articleId);
      
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;
        
        final currentViews = (snapshot.data()?['views'] as num?)?.toInt() ?? 0;
        transaction.update(docRef, {'views': currentViews + 1});
      });
    } catch (e) {
      print('Error incrementing views: $e');
    }
  }

  /// "Foydali" sonini oshirish
  Future<void> incrementHelpful(String articleId) async {
    try {
      final docRef = _articlesCollection.doc(articleId);
      
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;
        
        final currentHelpful = 
            (snapshot.data()?['helpful'] as num?)?.toInt() ?? 0;
        transaction.update(docRef, {'helpful': currentHelpful + 1});
      });
    } catch (e) {
      print('Error incrementing helpful: $e');
    }
  }

  /// "Foydali" sonini kamaytirish (agar user undo qilsa)
  Future<void> decrementHelpful(String articleId) async {
    try {
      final docRef = _articlesCollection.doc(articleId);
      
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;
        
        final currentHelpful = 
            (snapshot.data()?['helpful'] as num?)?.toInt() ?? 0;
        if (currentHelpful > 0) {
          transaction.update(docRef, {'helpful': currentHelpful - 1});
        }
      });
    } catch (e) {
      print('Error decrementing helpful: $e');
    }
  }

  // ==========================================
  // PDF OPERATIONS (PDF bilan ishlash)
  // ==========================================

  /// PDF faylni Firebase Storage'ga yuklash
  /// 
  /// Returns: Download URL yoki null (xato bo'lsa)
  Future<String?> uploadPDF(File file, String articleId) async {
    try {
      // Storage path: pdfs/articles/{articleId}/{filename}
      final fileName = file.path.split('/').last;
      final storageRef = _storage.ref().child('pdfs/articles/$articleId/$fileName');
      
      // Yuklash
      final uploadTask = await storageRef.putFile(file);
      
      // Download URL olish
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading PDF: $e');
      return null;
    }
  }

  /// PDF faylni Storage'dan o'chirish
  Future<bool> deletePDF(String pdfUrl) async {
    try {
      // URL'dan storage reference olish
      final ref = _storage.refFromURL(pdfUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting PDF: $e');
      return false;
    }
  }

  // ==========================================
  // BULK OPERATIONS (Ko'plab operatsiyalar)
  // ==========================================

  /// Ko'p maqolalarni bir vaqtda olish
  Future<List<KnowledgeArticle>> getArticlesByIds(List<String> ids) async {
    try {
      if (ids.isEmpty) return [];
      
      // Firestore'da 'in' query 10 ta elementgacha
      // Agar ko'p bo'lsa, batch'larga bo'lish kerak
      final List<KnowledgeArticle> articles = [];
      
      // 10 tadan bo'lik qilamiz
      for (int i = 0; i < ids.length; i += 10) {
        final batch = ids.skip(i).take(10).toList();
        final snapshot = await _articlesCollection
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        
        articles.addAll(
          snapshot.docs.map((doc) => KnowledgeArticle.fromFirestore(doc)),
        );
      }
      
      return articles;
    } catch (e) {
      print('Error getting articles by IDs: $e');
      return [];
    }
  }

  // ==========================================
  // STATISTICS (Statistika)
  // ==========================================

  /// Jami maqolalar soni
  Future<int> getTotalArticlesCount() async {
    try {
      final snapshot = await _articlesCollection.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting total count: $e');
      return 0;
    }
  }

  /// Eng ko'p ko'rilgan maqolalar (Top 10)
  Future<List<KnowledgeArticle>> getMostViewedArticles({int limit = 10}) async {
    try {
      final snapshot = await _articlesCollection
          .orderBy('views', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => KnowledgeArticle.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting most viewed: $e');
      return [];
    }
  }

  /// Eng foydali maqolalar
  Future<List<KnowledgeArticle>> getMostHelpfulArticles({int limit = 10}) async {
    try {
      final snapshot = await _articlesCollection
          .orderBy('helpful', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => KnowledgeArticle.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting most helpful: $e');
      return [];
    }
  }
}
