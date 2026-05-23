// lib/features/community/domain/usecases/update_topic.dart
import '../repositories/community_repository.dart';

class UpdateTopic {
  final CommunityRepository repository;

  UpdateTopic(this.repository);

  Future<void> call({
    required String topicId,
    required String title,
    required String content,
  }) {
    return repository.updateTopic(
      topicId: topicId,
      title: title,
      content: content,
    );
  }
}
