import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../data/models/search_index_model.dart';

class SearchIndexer {
  final FirebaseFirestore _firestore;
  static const String _collectionPath = 'search_index';

  SearchIndexer({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> indexDocument(SearchIndexModel indexModel) async {
    try {
      await _firestore
          .collection(_collectionPath)
          .doc(indexModel.id)
          .set(indexModel.toMap());
      debugPrint('Indexed document to search_index: ${indexModel.id}');
    } catch (e) {
      debugPrint('Error indexing document: $e');
    }
  }

  Future<void> deleteDocument(String id) async {
    try {
      await _firestore.collection(_collectionPath).doc(id).delete();
      debugPrint('Deleted document from search_index: $id');
    } catch (e) {
      debugPrint('Error deleting index document: $e');
    }
  }
}
