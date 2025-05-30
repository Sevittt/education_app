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
            // Assuming your DiscussionTopic.fromMap can handle a Firestore doc
            return DiscussionTopic.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();
        })
        .handleError((error) {
          // It's good practice to handle potential errors in the stream mapping
          return []; // Return an empty list or rethrow, depending on desired behavior
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
