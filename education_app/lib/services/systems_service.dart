// lib/services/systems_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sud_system.dart';

/// Systems Service
/// 
/// Sud axborot tizimlarini boshqarish
class SystemsService {
  final CollectionReference<Map<String, dynamic>> _systemsCollection =
      FirebaseFirestore.instance.collection('systems');

  // ==========================================
  // READ OPERATIONS
  // ==========================================

  /// Barcha tizimlarni olish
  Stream<List<SudSystem>> getAllSystems() {
    return _systemsCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SudSystem.fromFirestore(doc))
          .toList();
    });
  }

  /// Kategoriya bo'yicha (primary, secondary, support)
  Stream<List<SudSystem>> getSystemsByCategory(SystemCategory category) {
    return _systemsCollection
        .where('category', isEqualTo: category.name)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SudSystem.fromFirestore(doc))
          .toList();
    });
  }

  /// Faqat faol tizimlar
  Stream<List<SudSystem>> getActiveSystems() {
    return _systemsCollection
        .where('status', isEqualTo: SystemStatus.active.name)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SudSystem.fromFirestore(doc))
          .toList();
    });
  }

  /// Bitta tizimni olish
  Future<SudSystem?> getSystemById(String id) async {
    try {
      final doc = await _systemsCollection.doc(id).get();
      if (!doc.exists) return null;
      return SudSystem.fromFirestore(doc);
    } catch (e) {
      print('Error getting system: $e');
      return null;
    }
  }

  /// Tizim bo'yicha barcha kontentni olish
  /// 
  /// Returns: {articles: [...], videos: [...], faqs: [...]}
  Future<Map<String, dynamic>> getSystemContent(String systemId) async {
    try {
      final system = await getSystemById(systemId);
      if (system == null) return {};

      // Parallel queries uchun Future.wait
      final results = await Future.wait([
        // Articles
        FirebaseFirestore.instance
            .collection('knowledge_articles')
            .where('systemId', isEqualTo: systemId)
            .get(),
        
        // Videos
        FirebaseFirestore.instance
            .collection('video_tutorials')
            .where('systemId', isEqualTo: systemId)
            .get(),
        
        // FAQs
        FirebaseFirestore.instance
            .collection('faqs')
            .where('systemId', isEqualTo: systemId)
            .get(),
      ]);

      return {
        'articles': results[0].docs.map((d) => d.data()).toList(),
        'videos': results[1].docs.map((d) => d.data()).toList(),
        'faqs': results[2].docs.map((d) => d.data()).toList(),
      };
    } catch (e) {
      print('Error getting system content: $e');
      return {};
    }
  }

  // ==========================================
  // WRITE OPERATIONS
  // ==========================================

  /// Yangi tizim qo'shish
  Future<String?> createSystem(SudSystem system) async {
    try {
      final docRef = await _systemsCollection.add(system.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating system: $e');
      return null;
    }
  }

  /// Tizimni yangilash
  Future<bool> updateSystem(String id, SudSystem system) async {
    try {
      await _systemsCollection.doc(id).update(system.toFirestore());
      return true;
    } catch (e) {
      print('Error updating system: $e');
      return false;
    }
  }

  /// Tizimni o'chirish
  Future<bool> deleteSystem(String id) async {
    try {
      await _systemsCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting system: $e');
      return false;
    }
  }

  /// Tizim statusini yangilash
  Future<bool> updateSystemStatus(String id, SystemStatus status) async {
    try {
      await _systemsCollection.doc(id).update({
        'status': status.name,
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      print('Error updating system status: $e');
      return false;
    }
  }

  // ==========================================
  // STATISTICS
  // ==========================================

  /// Jami tizimlar soni
  Future<int> getTotalSystemsCount() async {
    try {
      final snapshot = await _systemsCollection.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting total count: $e');
      return 0;
    }
  }

  /// Faol tizimlar soni
  Future<int> getActiveSystemsCount() async {
    try {
      final snapshot = await _systemsCollection
          .where('status', isEqualTo: SystemStatus.active.name)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting active count: $e');
      return 0;
    }
  }
}
