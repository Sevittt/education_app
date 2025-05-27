// lib/services/resource_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/resource.dart'; // Make sure this path is correct

class ResourceService {
  final CollectionReference<Map<String, dynamic>> _resourcesCollection =
      FirebaseFirestore.instance.collection('resources');

  Stream<List<Resource>> getResources() {
    return _resourcesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Resource.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  Future<void> addResource(Resource resource) async {
    // Add your Firestore or local logic here
    await FirebaseFirestore.instance
        .collection('resources')
        .add(resource.toMap());
  }

  Future<void> updateResource(Resource resource) {
    return _resourcesCollection.doc(resource.id).update(resource.toMap());
  }

  Future<void> deleteResource(String resourceId) {
    return _resourcesCollection.doc(resourceId).delete();
  }
}
