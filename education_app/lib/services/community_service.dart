// lib/services/community_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/discussion_topic.dart';
import '../models/comment.dart'; // Import the Comment model

class CommunityService {
  final CollectionReference _topicsCollection = FirebaseFirestore.instance
      .collection('discussion_topics');

  // --- Existing Topic Methods ---
  // Future<void> createTopic(DiscussionTopic topic) async {
  //   try {
  //     await _topicsCollection.add(topic.toMap());
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("Error creating topic: $e");
  //     }
  //     rethrow;
  //   }
  // }

  Future<void> createTopic(
    String title,
    String content,
    String userId,
    String userName,
  ) async {
    try {
      final newTopic = {
        'title': title,
        'content': content,
        'authorId': userId,
        'authorName': userName,
        'commentCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _topicsCollection.add(newTopic);
    } catch (e) {
      if (kDebugMode) {
        print("Error creating topic: $e");
      }
      rethrow;
    }
  }

  Stream<List<DiscussionTopic>> getTopics() {
    return _topicsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>?;
              if (data == null) {
                throw Exception("Document data is null for topic ID ${doc.id}");
              }
              return DiscussionTopic.fromMap(doc.id, data);
            } catch (e) {
              if (kDebugMode) {
                print("Error mapping discussion topic with ID ${doc.id}: $e");
              }
              // Consider returning a placeholder or an error state object
              // For now, rethrowing will make the StreamBuilder show an error
              rethrow;
            }
          }).toList();
        })
        .handleError((error) {
          if (kDebugMode) {
            print("Error in getTopics stream pipeline: $error");
          }
          throw error;
        });
  }

  Future<void> updateTopic(DiscussionTopic topic) async {
    try {
      await _topicsCollection.doc(topic.id).update(topic.toMap());
    } catch (e) {
      if (kDebugMode) {
        print("Error updating topic ${topic.id}: $e");
      }
      rethrow;
    }
  }

  Future<void> deleteTopic(String topicId) async {
    try {
      await _topicsCollection.doc(topicId).delete();
      // Note: Deleting a topic here does NOT automatically delete its comments subcollection.
      // This requires a Cloud Function or client-side batch delete.
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting topic ${topicId}: $e");
      }
      rethrow;
    }
  }

  // --- NEW Comment Methods ---

  /// Adds a comment to a specific discussion topic.
  /// Comments will be stored in a subcollection named 'comments' under each topic.
  Future<void> addComment(String topicId, Comment comment) async {
    try {
      // Add the comment to the subcollection
      await _topicsCollection
          .doc(topicId)
          .collection('comments')
          .add(comment.toFirestore());

      // Increment the commentCount on the parent topic document
      await _topicsCollection.doc(topicId).update({
        'commentCount': FieldValue.increment(1),
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error adding comment to topic $topicId: $e");
      }
      rethrow;
    }
  }

  /// Fetches a live stream of comments for a specific discussion topic.
  Stream<List<Comment>> getCommentsForTopic(String topicId) {
    return _topicsCollection
        .doc(topicId)
        .collection('comments')
        .orderBy('createdAt', descending: false) // Show oldest comments first
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            try {
              return Comment.fromFirestore(doc);
            } catch (e) {
              if (kDebugMode) {
                print(
                  "Error parsing comment from Firestore doc ID ${doc.id} for topic $topicId: $e. Skipping this item.",
                );
              }
              // Return a special error object or null if you want to filter them out later.
              // For simplicity here, we'll let it fail loudly if Comment.fromFirestore throws,
              // or filter out if fromFirestore can return null on error.
              // If fromFirestore throws, the main stream's .handleError below will catch it.
              rethrow; // Or handle more gracefully by returning a placeholder/null
            }
          }).toList();
        })
        .handleError((error) {
          if (kDebugMode) {
            print(
              "Error in getCommentsForTopic stream for topic ID $topicId: $error",
            );
          }
          // Propagate the error to the StreamBuilder
          throw error;
        });
  }
}
