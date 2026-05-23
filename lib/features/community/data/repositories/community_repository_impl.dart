// lib/features/community/data/repositories/community_repository_impl.dart
import '../../domain/entities/discussion_topic.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasources/community_remote_datasource.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityRemoteDataSource remoteDataSource;

  CommunityRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<DiscussionTopic>> getTopics() {
    return remoteDataSource.getTopics();
  }

  @override
  Future<void> createTopic({
    required String title,
    required String content,
    required String userId,
    required String userName,
  }) async {
    final data = {
      'title': title,
      'content': content,
      'authorId': userId,
      'authorName': userName,
    };
    await remoteDataSource.createTopic(data);
  }

  @override
  Future<void> updateTopic({
    required String topicId,
    required String title,
    required String content,
  }) async {
    final data = {
      'title': title,
      'content': content,
    };
    await remoteDataSource.updateTopic(topicId, data);
  }

  @override
  Future<void> deleteTopic(String topicId) async {
    await remoteDataSource.deleteTopic(topicId);
  }

  @override
  Stream<List<Comment>> getCommentsForTopic(String topicId) {
    return remoteDataSource.getCommentsForTopic(topicId);
  }

  @override
  Future<void> addComment({
    required String topicId,
    required String content,
    required String userId,
    required String userName,
    String? userProfilePic,
  }) async {
    final data = {
      'authorId': userId,
      'authorName': userName,
      'content': content,
      if (userProfilePic != null) 'authorProfilePicUrl': userProfilePic,
    };
    await remoteDataSource.addComment(topicId, data);
  }
}
