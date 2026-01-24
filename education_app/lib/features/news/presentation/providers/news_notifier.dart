import 'package:flutter/foundation.dart';
import 'package:sud_qollanma/features/news/domain/entities/news_entity.dart';
import 'package:sud_qollanma/features/news/domain/usecases/get_news_stream.dart';
import 'package:sud_qollanma/features/news/domain/usecases/news_crud_usecases.dart';

class NewsNotifier extends ChangeNotifier {
  final GetNewsStream getNewsStream;
  final AddNews addNewsUseCase;
  final UpdateNews updateNewsUseCase;
  final DeleteNews deleteNewsUseCase;

  NewsNotifier({
    required this.getNewsStream,
    required this.addNewsUseCase,
    required this.updateNewsUseCase,
    required this.deleteNewsUseCase,
  });

  Stream<List<NewsEntity>> get newsStream => getNewsStream();

  Future<void> addNews(NewsEntity news) async {
    await addNewsUseCase(news);
    notifyListeners();
  }

  Future<void> updateNews(NewsEntity news) async {
    await updateNewsUseCase(news);
    notifyListeners();
  }

  Future<void> deleteNews(String id) async {
    await deleteNewsUseCase(id);
    notifyListeners();
  }
}
