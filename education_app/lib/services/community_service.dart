// lib/services/community_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/discussion_topic.dart';

class CommunityService {
  final CollectionReference _topicsCollection = FirebaseFirestore.instance
      .collection('discussion_topics');

  /// Creates a new discussion topic document in Firestore.
  Future<void> createTopic(DiscussionTopic topic) async {
    try {
      await _topicsCollection.add(topic.toMap());
    } catch (e) {
      rethrow; // Rethrow the error to be caught by the UI layer
    }
  }

  /// Fetches a live stream of all discussion topics, ordered by most recent.
  Stream<List<DiscussionTopic>> getTopics() {
    return _topicsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return DiscussionTopic.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();
        });
  }
}
