import 'package:sud_qollanma/features/news/domain/entities/news_entity.dart';
import 'package:sud_qollanma/features/news/domain/repositories/news_repository.dart';

class AddNews {
  final NewsRepository repository;
  AddNews(this.repository);
  Future<void> call(NewsEntity news) => repository.addNews(news);
}

class UpdateNews {
  final NewsRepository repository;
  UpdateNews(this.repository);
  Future<void> call(NewsEntity news) => repository.updateNews(news);
}

class DeleteNews {
  final NewsRepository repository;
  DeleteNews(this.repository);
  Future<void> call(String newsId) => repository.deleteNews(newsId);
}
