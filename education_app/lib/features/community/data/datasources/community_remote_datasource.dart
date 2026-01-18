// lib/features/community/data/datasources/community_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/topic_model.dart';
import '../models/comment_model.dart';

abstract class CommunityRemoteDataSource {
  Stream<List<TopicModel>> getTopics();
  Future<void> createTopic(Map<String, dynamic> data);
  Future<void> deleteTopic(String topicId);
  Stream<List<CommentModel>> getCommentsForTopic(String topicId);
  Future<void> addComment(String topicId, Map<String, dynamic> data);
}

class CommunityRemoteDataSourceImpl implements CommunityRemoteDataSource {
  final FirebaseFirestore _firestore;

  CommunityRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<TopicModel>> getTopics() {
    return _firestore
        .collection('discussion_topics')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TopicModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<void> createTopic(Map<String, dynamic> data) async {
    await _firestore.collection('discussion_topics').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'commentCount': 0,
    });
  }

  @override
  Future<void> deleteTopic(String topicId) async {
    await _firestore.collection('discussion_topics').doc(topicId).delete();
  }

  @override
  Stream<List<CommentModel>> getCommentsForTopic(String topicId) {
    return _firestore
        .collection('discussion_topics')
        .doc(topicId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<void> addComment(String topicId, Map<String, dynamic> data) async {
    final batch = _firestore.batch();
    
    // Add Comment
    final commentRef = _firestore
        .collection('discussion_topics')
        .doc(topicId)
        .collection('comments')
        .doc();
    
    batch.set(commentRef, {
      ...data,
      'topicId': topicId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update count
    final topicRef = _firestore.collection('discussion_topics').doc(topicId);
    batch.update(topicRef, {'commentCount': FieldValue.increment(1)});

    await batch.commit();
  }
}
