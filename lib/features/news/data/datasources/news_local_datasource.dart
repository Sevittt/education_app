import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:sud_qollanma/core/database/app_database.dart';
import 'package:sud_qollanma/core/services/sync/outbox_action_model.dart';
import 'package:sud_qollanma/features/news/data/models/news_model.dart';

/// Drift ([AppDatabase]) lokal ma'lumotlar bazasi bilan to'g'ridan-to'g'ri
/// ishlashni ta'minlovchi mahalliy ma'lumot manbai interfeysi.
abstract class NewsLocalDataSource {
  /// Mahalliy bazadan real-vaqtda yangiliklar oqimini kuzatadi.
  /// Bazaga har qanday yozuv bo'lganda, oqim avtomatik yangilanadi.
  Stream<List<NewsLocalModel>> watchNews({int limit = 20});

  /// Yangilikni va Outbox amalni bitta atomik tranzaksiyada saqlaydi.
  /// Tarmoq bo'lmasa ham, ma'lumot yo'qolmaydi.
  Future<void> saveNewsAndQueueAction(
    NewsLocalModel news,
    OutboxActionModel action,
  );

  /// Serverdan kelgan yangiliklar ro'yxatini localga ommaviy saqlaydi.
  /// Mavjud yozuvlar `insertOnConflictUpdate` orqali yangilanadi.
  Future<void> saveNewsFromRemote(List<NewsLocalModel> newsList);

  /// Berilgan [newsId] li yangilikni o'chiradi va o'chirish amalini navbatga qo'shadi.
  Future<void> deleteNewsAndQueueAction(
    String newsId,
    OutboxActionModel action,
  );

  /// Bitta yangilikni UUID orqali yuklash.
  Future<NewsLocalModel?> getNewsById(String id);
}

/// [NewsLocalDataSource] ning Drift asosidagi amalga oshirilishi.
class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  final AppDatabase _db;

  const NewsLocalDataSourceImpl(this._db);

  @override
  Stream<List<NewsLocalModel>> watchNews({int limit = 20}) {
    // Nashr sanasi bo'yicha teskari tartibda kuzatish (Drift oqimni darhol
    // birinchi natija bilan ishga tushiradi).
    return _db.watchNews(limit: limit).map(
          (rows) => rows.map(NewsLocalModel.fromTable).toList(),
        );
  }

  @override
  Future<void> saveNewsAndQueueAction(
    NewsLocalModel news,
    OutboxActionModel action,
  ) async {
    // Atomik tranzaksiya: yangilik va outbox amali bir vaqtda yoziladi.
    await _db.saveNewsAndQueueAction(
      news.toCompanion(),
      action.toInsertCompanion(),
    );
  }

  @override
  Future<void> saveNewsFromRemote(List<NewsLocalModel> newsList) async {
    if (newsList.isEmpty) return;
    await _db.saveNewsFromRemote(
      newsList.map((e) => e.toCompanion()).toList(),
    );
  }

  @override
  Future<void> deleteNewsAndQueueAction(
    String newsId,
    OutboxActionModel action,
  ) async {
    await _db.deleteNewsAndQueueAction(
      newsId,
      action.toInsertCompanion(),
    );
  }

  @override
  Future<NewsLocalModel?> getNewsById(String id) async {
    final row = await _db.getNewsById(id);
    return row == null ? null : NewsLocalModel.fromTable(row);
  }

  /// Server ma'lumotlarini local baza bilan birlashtirish (Incremental Sync).
  /// Bu metod tarmoqdan kelgan yangilanishlarni local bazaga qo'shadi,
  /// lekin faqat yangroq bo'lgan ma'lumotlarni yangilaydi.
  Future<void> mergeNewsFromRemote(List<NewsLocalModel> remoteNews) async {
    if (remoteNews.isEmpty) return;

    await _db.transaction(() async {
      for (final remote in remoteNews) {
        final localRow = await _db.getNewsById(remote.id);

        // Agar local yo'q yoki server versiyasi yangroq bo'lsa yangilash.
        if (localRow == null ||
            (remote.publicationDate != null &&
                localRow.publicationDate != null &&
                remote.publicationDate!.isAfter(localRow.publicationDate!))) {
          await _db
              .into(_db.newsTable)
              .insertOnConflictUpdate(remote.toCompanion());
        }
      }
    });
  }

  // --- Qo'shimcha yordamchi metodlar ---

  /// Yangilik uchun Outbox amali yaratuvchi factory.
  static OutboxActionModel buildOutboxAction({
    required String newsId,
    required OutboxActionType type,
    Map<String, dynamic>? payload,
  }) {
    return OutboxActionModel.create(
      entityCollection: 'news',
      entityId: newsId,
      actionType: type,
      payloadJson: payload != null ? jsonEncode(payload) : '{}',
    );
  }
}
