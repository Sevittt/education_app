import 'package:flutter/foundation.dart';
import 'package:sud_qollanma/core/services/sync/outbox_action_model.dart';
import 'package:sud_qollanma/core/services/sync/sync_worker.dart';
import 'package:sud_qollanma/features/news/data/datasources/news_local_datasource.dart';
import 'package:sud_qollanma/features/news/data/datasources/news_remote_datasource.dart';
import 'package:sud_qollanma/features/news/data/models/news_model.dart';
import 'package:sud_qollanma/features/news/domain/entities/news_entity.dart';
import 'package:sud_qollanma/features/news/domain/repositories/news_repository.dart';
import 'package:uuid/uuid.dart';

/// [NewsRepository] ning oflayn-birinchi (Local-first) amalga oshirilishi.
///
/// Asosiy qoidalar:
/// 1. **O'qish:** UI har doim mahalliy Drift bazasidagi oqimni kuzatadi.
///    Tarmoq ma'lumotlari avval bazaga yoziladi, UI esa avtomatik yangilanadi.
/// 2. **Yozish:** Har qanday mutatsiya (qo'shish, tahrirlash, o'chirish)
///    avval mahalliy bazaga yoziladi. Xuddi shu tranzaksiyada Outbox amali ham
///    navbatga qo'yiladi. [SyncWorker] fon rejimida Firestore-ga yuklaydi.
class NewsRepositoryImpl implements NewsRepository {
  final NewsLocalDataSource _localDataSource;
  final NewsRemoteDataSource _remoteDataSource;
  final SyncWorker _syncWorker;
  final Uuid _uuid;

  /// Oxirgi incremental sinxronizatsiya vaqtini xotirada saqlaymiz.
  /// Keyingi bosqichda bu [SharedPreferences] ga ko'chiriladi.
  DateTime _lastSyncTime = DateTime.fromMillisecondsSinceEpoch(0);

  NewsRepositoryImpl({
    required NewsLocalDataSource localDataSource,
    required NewsRemoteDataSource remoteDataSource,
    required SyncWorker syncWorker,
    Uuid? uuid,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _syncWorker = syncWorker,
        _uuid = uuid ?? const Uuid();

  @override
  Stream<List<NewsEntity>> getNewsStream({int limit = 10}) {
    // 1. Fon rejimida serverdan yangilanishlarni yuklash
    _fetchAndCacheRemoteNews(limit: limit);

    // 2. UI har doim faqat local oqimni kuzatadi (reaktiv)
    return _localDataSource.watchNews(limit: limit).map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }

  @override
  Future<void> addNews(NewsEntity news) async {
    // 1. Yangi UUID generatsiya qilish (Firestore Document ID bo'ladi)
    final newsId = news.id.isEmpty ? _uuid.v4() : news.id;

    final newsModel = NewsLocalModel.fromEntity(
      NewsEntity(
        id: newsId,
        title: news.title,
        source: news.source,
        url: news.url,
        publicationDate: news.publicationDate,
        imageUrl: news.imageUrl,
      ),
    );

    // 2. Outbox amali yaratish
    final outboxAction = NewsLocalDataSourceImpl.buildOutboxAction(
      newsId: newsId,
      type: OutboxActionType.create,
      payload: newsModel.toFirestorePayload(),
    );

    // 3. Atomik tranzaksiya: local + outbox birgalikda yoziladi
    await _localDataSource.saveNewsAndQueueAction(newsModel, outboxAction);

    // 4. Sinxronizatsiyani ishga tushirish (tarmoq bo'lsa darhol yuklaydi)
    _syncWorker.triggerSync();
  }

  @override
  Future<void> updateNews(NewsEntity news) async {
    final newsModel = NewsLocalModel.fromEntity(news);

    final outboxAction = NewsLocalDataSourceImpl.buildOutboxAction(
      newsId: news.id,
      type: OutboxActionType.update,
      payload: newsModel.toFirestorePayload(),
    );

    await _localDataSource.saveNewsAndQueueAction(newsModel, outboxAction);
    _syncWorker.triggerSync();
  }

  @override
  Future<void> deleteNews(String newsId) async {
    final outboxAction = NewsLocalDataSourceImpl.buildOutboxAction(
      newsId: newsId,
      type: OutboxActionType.delete,
    );

    await _localDataSource.deleteNewsAndQueueAction(newsId, outboxAction);
    _syncWorker.triggerSync();
  }

  // --- Xususiy yordamchi metodlar ---

  /// Serverdan yangilanishlarni yuklash va mahalliy bazaga saqlash.
  /// Bu metod UI-ni bloklamaydi (await qilinmaydi).
  void _fetchAndCacheRemoteNews({int limit = 20}) {
    _doFetchAndCache(limit: limit).catchError((e) {
      // Tarmoq xatolari UI-ni to'xtatmasligi kerak, faqat logga yoziladi
      debugPrint('[NewsRepository] Server yangilanishlarini yuklashda xato: $e');
    });
  }

  Future<void> _doFetchAndCache({int limit = 20}) async {
    try {
      List<NewsLocalModel> remoteNews;

      if (_lastSyncTime.millisecondsSinceEpoch == 0) {
        // Birinchi ishga tushirishda to'liq yuklash
        remoteNews = await _remoteDataSource.fetchLatestNews(limit: limit);
      } else {
        // Keyingi ishlashlarda faqat yangilangan ma'lumotlarni yuklash
        remoteNews = await _remoteDataSource.fetchNewsUpdatedSince(_lastSyncTime);
      }

      if (remoteNews.isNotEmpty) {
        await _localDataSource.saveNewsFromRemote(remoteNews);
        _lastSyncTime = DateTime.now();
        debugPrint('[NewsRepository] ${remoteNews.length} ta yangilik kesh qilindi.');
      }
    } catch (e) {
      rethrow;
    }
  }
}
