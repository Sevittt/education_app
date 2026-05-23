import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/search_index_model.dart';

class SearchRemoteDataSource {
  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;

  SearchRemoteDataSource({
    FirebaseFunctions? functions,
    FirebaseFirestore? firestore,
  })  : _functions = functions ?? FirebaseFunctions.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<SearchIndexModel>> searchVectorQuery(String query,
      {int limit = 5}) async {
    try {
      final callable =
          _functions.httpsCallable('ext-firestore-vector-search-queryCallable');
      final result = await callable.call({
        'query': query,
        'limit': limit,
      });

      final data = result.data;
      List<String> matchedIds = [];

      if (data is Map) {
        // Most common pattern: { "ids": ["id1", "id2"] }
        if (data.containsKey('ids')) {
          matchedIds = List<String>.from(data['ids'] as List);
        } else if (data.containsKey('data')) {
          // If the data itself is wrapped
          var innerData = data['data'];
          if (innerData is List) {
            matchedIds = innerData.map((e) => e.toString()).toList();
          }
        }
      } else if (data is List) {
        // Sometimes it directly returns a list of IDs
        if (data.isNotEmpty && data.first is String) {
          matchedIds = List<String>.from(data);
        }
      }

      if (matchedIds.isEmpty) {
        if (kDebugMode) {
          debugPrint('Vector search: no results. Raw data: $data');
        }
        return [];
      }

      // Fetch the actual documents from the rag_chunks collection
      final docs = await Future.wait(matchedIds
          .map((id) => _firestore.collection('rag_chunks').doc(id).get()));

      final results =
          docs.where((doc) => doc.exists && doc.data() != null).map((doc) {
        final data = doc.data()!;

        // Map 'content' to 'text' for AI context if 'text' is missing
        if (!data.containsKey('text') && data.containsKey('content')) {
          data['text'] = data['content'];
        }

        // Ensure type field exists
        if (!data.containsKey('type')) {
          data['type'] = 'article';
        }

        // Provide fallback title and description for RAG chunks if they are empty
        if ((data['title'] == null || data['title'].toString().isEmpty) &&
            data.containsKey('text')) {
          data['title'] = 'Bilimlar bazasi hujjati';
          String textContent = data['text'].toString();
          data['description'] = textContent.length > 100
              ? '${textContent.substring(0, 100)}...'
              : textContent;
        }

        return SearchIndexModel.fromMap(data, doc.id);
      }).toList();

      return results;
    } catch (e) {
      debugPrint('Error calling vector search function: $e');
      return [];
    }
  }
}
