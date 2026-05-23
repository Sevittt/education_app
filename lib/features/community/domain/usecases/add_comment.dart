// lib/features/community/domain/usecases/add_comment.dart
import '../repositories/community_repository.dart';

class AddComment {
  final CommunityRepository repository;

  AddComment(this.repository);

  Future<void> call({
    required String topicId,
    required String content,
    required String userId,
    required String userName,
    String? userProfilePic,
  }) {
    return repository.addComment(
      topicId: topicId,
      content: content,
      userId: userId,
      userName: userName,
      userProfilePic: userProfilePic,
    );
  }
}
