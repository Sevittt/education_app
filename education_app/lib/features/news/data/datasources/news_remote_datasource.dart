import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sud_qollanma/features/news/data/models/news_model.dart';
import 'package:sud_qollanma/features/news/domain/entities/news_entity.dart';

abstract class NewsRemoteDataSource {
  Stream<List<NewsModel>> getNewsStream({int limit = 10});
  Future<void> addNews(NewsEntity news);
  Future<void> updateNews(NewsEntity news);
  Future<void> deleteNews(String newsId);
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final CollectionReference _newsCollection = FirebaseFirestore.instance.collection('news');

  @override
  Stream<List<NewsModel>> getNewsStream({int limit = 10}) {
    return _newsCollection
        .orderBy('publicationDate', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => NewsModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<void> addNews(NewsEntity news) async {
    // Convert entity to model to access toFirestore
    final model = NewsModel(
      id: news.id, // ID handled by Firestore usually, but we keep structure
      title: news.title,
      source: news.source,
      url: news.url,
      imageUrl: news.imageUrl,
      publicationDate: news.publicationDate,
    );
    // Use .add so Firestore generates ID, ignore local ID if it's new
    await _newsCollection.add(model.toFirestore());
  }

  @override
  Future<void> updateNews(NewsEntity news) async {
     final model = NewsModel(
      id: news.id,
      title: news.title,
      source: news.source,
      url: news.url,
      imageUrl: news.imageUrl,
      publicationDate: news.publicationDate,
    );
    await _newsCollection.doc(news.id).update(model.toFirestore());
  }

  @override
  Future<void> deleteNews(String newsId) async {
    await _newsCollection.doc(newsId).delete();
  }
}
