// lib/features/community/presentation/providers/community_provider.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/discussion_topic.dart';
import '../../domain/entities/comment.dart';
import '../../domain/usecases/get_topics.dart';
import '../../domain/usecases/create_topic.dart';
import '../../domain/usecases/add_comment.dart';
import '../../domain/repositories/community_repository.dart';

class CommunityProvider extends ChangeNotifier {
  final GetTopics _getTopics;
  final CreateTopic _createTopic;
  final AddComment _addComment;
  final CommunityRepository _repository; // Needed for delete and getComments

  CommunityProvider({
    required GetTopics getTopics,
    required CreateTopic createTopic,
    required AddComment addComment,
    required CommunityRepository repository,
  })  : _getTopics = getTopics,
        _createTopic = createTopic,
        _addComment = addComment,
        _repository = repository;

  // Streams
  Stream<List<DiscussionTopic>> get topicsStream => _getTopics();

  Stream<List<Comment>> getCommentsForTopic(String topicId) {
    return _repository.getCommentsForTopic(topicId);
  }

  // Actions
  Future<void> createTopic({
    required String title,
    required String content,
    required String userId,
    required String userName,
  }) async {
    await _createTopic(
      title: title,
      content: content,
      userId: userId,
      userName: userName,
    );
  }

  Future<void> updateTopic({
    required String topicId,
    required String title,
    required String content,
  }) async {
    await _repository.updateTopic(
      topicId: topicId,
      title: title,
      content: content,
    );
  }

  Future<void> addComment({
    required String topicId,
    required String content,
    required String userId,
    required String userName,
    String? userProfilePic,
  }) async {
    await _addComment(
      topicId: topicId,
      content: content,
      userId: userId,
      userName: userName,
      userProfilePic: userProfilePic,
    );
  }

  Future<void> deleteTopic(String topicId) async {
    await _repository.deleteTopic(topicId);
  }
}
