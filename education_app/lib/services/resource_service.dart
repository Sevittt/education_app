// lib/services/resource_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // --- ADDED ---
import '../models/resource.dart';

class ResourceService with ChangeNotifier { // --- ADDED ChangeNotifier ---
  final CollectionReference<Map<String, dynamic>> _resourcesCollection =
      FirebaseFirestore.instance.collection('resources');

  Stream<List<Resource>> getResources() {
    return _resourcesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          // This map is for the QuerySnapshot
          return snapshot.docs.map((doc) {
            // This map is for each DocumentSnapshot
            try {
              final data = doc.data() as Map<String, dynamic>?; // Good cast
              if (data == null) {
                // Good null check for data
                throw Exception(
                  "Document data is null for resource ID ${doc.id}",
                );
              }
              return Resource.fromMap(doc.id, data);
            } catch (e) {
              // Good: Rethrowing to be caught by .handleError or StreamBuilder
              if (kDebugMode) {
                print("Error mapping resource with ID ${doc.id}: $e");
              } // Added print for specific doc error
              rethrow;
            }
          }).toList();
        })
        .handleError((error) {
          // Good: Catches errors from the stream or mapping
          if (kDebugMode) {
            print("Error in getResources stream pipeline: $error");
          } // Added print for pipeline error
          throw error; // Rethrows to StreamBuilder
        });
  }

  // --- NEW METHOD ---
  /// Fetches a stream of resources created by a specific author.
  Stream<List<Resource>> getResourcesByAuthor(String authorId) {
    return _resourcesCollection
        .where('authorId', isEqualTo: authorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          // This map is for the QuerySnapshot
          return snapshot.docs.map((doc) {
            // This map is for each DocumentSnapshot
            try {
              final data = doc.data() as Map<String, dynamic>?; // Good cast
              if (data == null) {
                // Good null check for data
                throw Exception(
                  "Document data is null for resource ID ${doc.id}",
                );
              }
              return Resource.fromMap(doc.id, data);
            } catch (e) {
              // Good: Rethrowing to be caught by .handleError or StreamBuilder
              if (kDebugMode) {
                print("Error mapping resource with ID ${doc.id}: $e");
              } // Added print for specific doc error
              rethrow;
            }
          }).toList();
        })
        .handleError((error) {
          // Good: Catches errors from the stream or mapping
          if (kDebugMode) {
            print("Error in getResourcesByAuthor stream pipeline: $error");
          } // Added print for pipeline error
          throw error; // Rethrows to StreamBuilder
        });
  }
  // --- END NEW METHOD ---

  Future<void> addResource(Resource resource) async {
    try {
      await _resourcesCollection.add(
        // Good: Using _resourcesCollection consistently now
        resource.toMap(),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error adding resource: $e");
      } // Added print
      rethrow;
    }
  }

  Future<void> updateResource(Resource resource) async {
    try {
      await _resourcesCollection.doc(resource.id).update(resource.toMap());
    } catch (e) {
      if (kDebugMode) {
        print("Error updating resource ${resource.id}: $e");
      } // Added print
      rethrow;
    }
  }

  Future<void> deleteResource(String resourceId) async {
    try {
      await _resourcesCollection.doc(resourceId).delete();
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting resource $resourceId: $e");
      } // Added print
      rethrow;
    }
  }
  // --- BOOKMARK FUNCTIONALITY ---
  
  /// Resursni "Saqlanganlar" ro'yxatiga qo'shish yoki olib tashlash.
  ///
  /// Agar resurs avval saqlangan bo'lsa, u ro'yxatdan o'chiriladi.
  /// Agar saqlanmagan bo'lsa, ro'yxatga qo'shiladi.
  /// Natija mahalliy xotirada (`SharedPreferences`) saqlanadi.
  ///
  /// [resourceId] - Saqlanadigan yoki o'chiriladigan resursning ID raqami.
  Future<void> toggleBookmark(String resourceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> bookmarks =
          prefs.getStringList('bookmarked_resources') ?? [];

      if (bookmarks.contains(resourceId)) {
        bookmarks.remove(resourceId);
      } else {
        bookmarks.add(resourceId);
      }

      await prefs.setStringList('bookmarked_resources', bookmarks);
      notifyListeners(); // UI ni yangilash uchun
    } catch (e) {
      if (kDebugMode) {
        print("Error toggling bookmark for $resourceId: $e");
      }
      // Xatolik yuz berganda foydalanuvchiga bildirmaslik yoki log yozish mumkin
    }
  }

  /// Barcha saqlangan resurslarning ID larini olish.
  ///
  /// Bu metod sinxron ishlaydi deb taxmin qilinadi, lekin `SharedPreferences`
  /// asinxron bo'lgani uchun `Future` qaytaradi.
  Future<List<String>> getBookmarkedResourceIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('bookmarked_resources') ?? [];
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching bookmarked IDs: $e");
      }
      return [];
    }
  }

  /// Resursning saqlangan yoki saqlanmaganligini tekshirish.
  Future<bool> isBookmarked(String resourceId) async {
    final bookmarks = await getBookmarkedResourceIds();
    return bookmarks.contains(resourceId);
  }
}
