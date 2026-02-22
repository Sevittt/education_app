// lib/features/community/domain/repositories/community_repository.dart
import '../entities/discussion_topic.dart';
import '../entities/comment.dart';

abstract class CommunityRepository {
  Stream<List<DiscussionTopic>> getTopics();
  
  Future<void> createTopic({
    required String title, 
    required String content, 
    required String userId, 
    required String userName
  });
  
  Future<void> deleteTopic(String topicId);
  
  Stream<List<Comment>> getCommentsForTopic(String topicId);
  
  Future<void> addComment({
    required String topicId,
    required String content,
    required String userId,
    required String userName,
    String? userProfilePic
  });
}
