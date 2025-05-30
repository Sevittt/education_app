// lib/services/resource_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
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
            // This map is for each DocumentSnapshot in the QuerySnapshot's docs list
            try {
              // Explicitly cast doc.data() to the expected Map type.
              // This helps catch issues if Firestore returns a different map structure.
              final data = doc.data() as Map<String, dynamic>?;

              // It's crucial that Resource.fromMap can handle a potentially null 'data'.
              // Or, ensure 'data' is never null if your Firestore rules/data guarantees it.
              if (data == null) {
                // This case should ideally not happen if the document exists.
                // If it does, it might indicate a problem with the document itself.
                // Depending on your needs, you might throw an error or return a placeholder.
                // For now, let's throw to make it visible in the error handling.
                throw Exception(
                  "Document data is null for resource ID ${doc.id}",
                );
              }
              return Resource.fromMap(doc.id, data);
            } catch (e) {
              // Rethrow the error so it can be caught by .handleError or the StreamBuilder
              rethrow;
            }
          }).toList();
        })
        .handleError((error) {
          // This makes the error flow to StreamBuilder's snapshot.error
          // You could also transform it into a Stream.error(CustomException(error))
          throw error;
        });
  }

  // ... other methods (addResource, updateResource, deleteResource) ...
  // Remember to make addResource consistent:
  Future<void> addResource(Resource resource) async {
    try {
      await _resourcesCollection.add(
        resource.toMap(),
      ); // Using _resourcesCollection
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateResource(Resource resource) async {
    try {
      await _resourcesCollection.doc(resource.id).update(resource.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteResource(String resourceId) async {
    try {
      await _resourcesCollection.doc(resourceId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
