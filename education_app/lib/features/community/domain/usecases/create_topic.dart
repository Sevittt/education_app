// lib/features/community/domain/usecases/create_topic.dart
import '../repositories/community_repository.dart';

class CreateTopic {
  final CommunityRepository repository;

  CreateTopic(this.repository);

  Future<void> call({
    required String title,
    required String content,
    required String userId,
    required String userName,
  }) {
    return repository.createTopic(
      title: title,
      content: content,
      userId: userId,
      userName: userName,
    );
  }
}
