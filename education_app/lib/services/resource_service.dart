// lib/services/resource_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/resource.dart';

class ResourceService {
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
}
