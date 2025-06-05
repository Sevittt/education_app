// lib/services/news_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import '../models/news.dart';

class NewsService {
  final CollectionReference _newsCollection = FirebaseFirestore.instance
      .collection('news');

  /// Fetches a live stream of news articles, ordered by publication date (newest first).
  Stream<List<News>> getNewsStream({int limit = 10}) {
    return _newsCollection
        .orderBy('publicationDate', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            try {
              return News.fromFirestore(doc);
            } catch (e) {
              if (kDebugMode) {
                print(
                  "Error parsing News from Firestore doc ID ${doc.id}: $e. Skipping this item.",
                );
              }
              // To make the stream more resilient, we can return a specific type or null
              // and filter it out, or handle it in the UI. For now, rethrowing
              // will make the StreamBuilder's error handler catch it.
              // If News.fromFirestore can throw, this is one place to catch it.
              // However, if News.fromFirestore handles its own errors and returns valid objects or defaults,
              // this catch might not be strictly necessary here unless the snapshot itself is the issue.
              rethrow;
            }
          }).toList();
        })
        .handleError((error) {
          // Handle errors from the stream itself (e.g., permission denied)
          if (kDebugMode) {
            print("Error in getNewsStream: $error");
          }
          // Propagate the error to the StreamBuilder
          throw error;
        });
  }

  // --- Optional: Methods for Admin to Add/Edit/Delete News ---
  // These would typically be used in an admin panel part of your app.

  Future<void> addNews(News newsItem) async {
    try {
      // If using FieldValue.serverTimestamp() for publicationDate on add:
      // Map<String, dynamic> newsData = newsItem.toFirestore();
      // newsData['publicationDate'] = FieldValue.serverTimestamp(); // Overwrite if you want server time
      // await _newsCollection.add(newsData);

      // If publicationDate is set by client (as in current News model toFirestore):
      await _newsCollection.add(newsItem.toFirestore());
    } catch (e) {
      if (kDebugMode) {
        print("Error adding news item: $e");
      }
      rethrow;
    }
  }

  Future<void> updateNews(String newsId, News newsItem) async {
    try {
      await _newsCollection.doc(newsId).update(newsItem.toFirestore());
    } catch (e) {
      if (kDebugMode) {
        print("Error updating news item $newsId: $e");
      }
      rethrow;
    }
  }

  Future<void> deleteNews(String newsId) async {
    try {
      await _newsCollection.doc(newsId).delete();
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting news item $newsId: $e");
      }
      rethrow;
    }
  }
}
