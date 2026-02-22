// lib/features/community/domain/usecases/get_topics.dart
import '../entities/discussion_topic.dart';
import '../repositories/community_repository.dart';

class GetTopics {
  final CommunityRepository repository;

  GetTopics(this.repository);

  Stream<List<DiscussionTopic>> call() {
    return repository.getTopics();
  }
}
