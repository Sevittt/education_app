import 'package:sud_qollanma/features/news/domain/entities/news_entity.dart';
import 'package:sud_qollanma/features/news/domain/repositories/news_repository.dart';

class GetNewsStream {
  final NewsRepository repository;

  GetNewsStream(this.repository);

  Stream<List<NewsEntity>> call({int limit = 10}) {
    return repository.getNewsStream(limit: limit);
  }
}
