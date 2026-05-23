import 'package:sud_qollanma/features/news/domain/entities/news_entity.dart';

abstract class NewsRepository {
  Stream<List<NewsEntity>> getNewsStream({int limit = 10});
  Future<void> addNews(NewsEntity news);
  Future<void> updateNews(NewsEntity news);
  Future<void> deleteNews(String newsId);
}
