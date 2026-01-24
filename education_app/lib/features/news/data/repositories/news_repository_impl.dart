import 'package:sud_qollanma/features/news/data/datasources/news_remote_datasource.dart';
import 'package:sud_qollanma/features/news/domain/entities/news_entity.dart';
import 'package:sud_qollanma/features/news/domain/repositories/news_repository.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;

  NewsRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<NewsEntity>> getNewsStream({int limit = 10}) {
    // Models are Entities, so this cast works due to inheritance in Dart List not being covariant 
    // Wait, List<NewsModel> is not List<NewsEntity>. Use map.
    return remoteDataSource.getNewsStream(limit: limit);
  }

  @override
  Future<void> addNews(NewsEntity news) => remoteDataSource.addNews(news);

  @override
  Future<void> updateNews(NewsEntity news) => remoteDataSource.updateNews(news);

  @override
  Future<void> deleteNews(String newsId) => remoteDataSource.deleteNews(newsId);
}
