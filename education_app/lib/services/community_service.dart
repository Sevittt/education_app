// lib/services/community_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/discussion_topic.dart';

class CommunityService {
  final CollectionReference _topicsCollection = FirebaseFirestore.instance
      .collection('discussion_topics');

  /// Creates a new discussion topic document in Firestore.
  Future<void> createTopic(DiscussionTopic topic) async {
    try {
      // Firestore will auto-generate an ID if you use .add()
      // If your topic model requires an ID upfront that you generate,
      // you'd use _topicsCollection.doc(topic.id).set(topic.toMap());
      await _topicsCollection.add(topic.toMap());
    } catch (e) {
      // Or use a proper logger
      rethrow;
    }
  }

  /// Fetches a live stream of all discussion topics, ordered by most recent.
  Stream<List<DiscussionTopic>> getTopics() {
    return _topicsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>?;
              if (data == null) {
                print(
                  "Warning: Document data is null for topic ID ${doc.id}. Skipping.",
                );
                throw Exception("Document data is null for topic ID ${doc.id}");
              }
              return DiscussionTopic.fromMap(doc.id, data);
            } catch (e) {
              print("Error mapping discussion topic with ID ${doc.id}: $e");
              rethrow;
            }
          }).toList();
        })
        .handleError((error) {
          print("Error in getTopics stream pipeline: $error");
          throw error;
        });
  }

  /// Updates an existing discussion topic in Firestore.
  Future<void> updateTopic(DiscussionTopic topic) async {
    try {
      await _topicsCollection.doc(topic.id).update(topic.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes a discussion topic from Firestore.
  Future<void> deleteTopic(String topicId) async {
    try {
      await _topicsCollection.doc(topicId).delete();
      // You might also want to delete associated comments here or use a Firebase Function for that.
    } catch (e) {
      rethrow;
    }
  }
}
