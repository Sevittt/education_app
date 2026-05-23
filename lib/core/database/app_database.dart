import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Yangiliklar (news) jadvali.
///
/// Birlamchi kalit sifatida Firestore Document ID bilan aynan mos keluvchi
/// UUID [id] (String) ishlatiladi. Bu oflayn-birinchi arxitekturada
/// mijoz tomonida generatsiya qilingan ID-larni server bilan to'g'ridan-to'g'ri
/// moslashtirish imkonini beradi.
class NewsTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get source => text()();
  TextColumn get url => text()();
  DateTimeColumn get publicationDate => dateTime().nullable()();
  TextColumn get imageUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Outbox (sinxronizatsiya navbati) jadvali.
///
/// Oflayn rejimda bajarilgan amallar (create / update / delete) FIFO tartibida
/// shu yerga yoziladi. [SyncWorker] navbatni o'qib Firestore-ga idempotent
/// tarzda yuklaydi va muvaffaqiyatli amallarni o'chiradi.
class OutboxActionsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityCollection => text()();
  TextColumn get entityId => text()();

  /// Amal turi matn ko'rinishida saqlanadi: 'create' | 'update' | 'delete'.
  TextColumn get actionType => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
}

/// Ilovaning lokal SQLite ma'lumotlar bazasi (Drift orqali boshqariladi).
///
/// Yangi jadval qo'shilganda [DriftDatabase] ro'yxatiga va kerak bo'lsa
/// [schemaVersion] / [migration] ga ham qo'shilishi lozim.
@DriftDatabase(tables: [NewsTable, OutboxActionsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  // --- News so'rovlari ---

  /// Nashr sanasi bo'yicha teskari tartibda yangiliklar oqimini kuzatadi.
  /// Bazaga har qanday yozuv bo'lganda oqim avtomatik yangilanadi.
  Stream<List<NewsTableData>> watchNews({int limit = 20}) {
    return (select(newsTable)
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.publicationDate,
                  mode: OrderingMode.desc,
                ),
          ])
          ..limit(limit))
        .watch();
  }

  /// Bitta yangilikni UUID orqali yuklash.
  Future<NewsTableData?> getNewsById(String id) {
    return (select(newsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Yangilik va Outbox amalini bitta atomik tranzaksiyada saqlaydi.
  Future<void> saveNewsAndQueueAction(
    NewsTableCompanion news,
    OutboxActionsTableCompanion action,
  ) {
    return transaction(() async {
      await into(newsTable).insertOnConflictUpdate(news);
      await into(outboxActionsTable).insert(action);
    });
  }

  /// Serverdan kelgan yangiliklarni ommaviy ravishda saqlaydi
  /// (mavjudlari yangilanadi, yangilari qo'shiladi).
  Future<void> saveNewsFromRemote(List<NewsTableCompanion> newsList) {
    if (newsList.isEmpty) return Future.value();
    return transaction(() async {
      for (final news in newsList) {
        await into(newsTable).insertOnConflictUpdate(news);
      }
    });
  }

  /// Yangilikni o'chiradi va o'chirish amalini Outbox navbatiga qo'shadi
  /// (bitta atomik tranzaksiyada).
  Future<void> deleteNewsAndQueueAction(
    String newsId,
    OutboxActionsTableCompanion action,
  ) {
    return transaction(() async {
      await (delete(newsTable)..where((t) => t.id.equals(newsId))).go();
      await into(outboxActionsTable).insert(action);
    });
  }

  // --- Outbox so'rovlari ---

  /// Navbatdagi eng qadimgi (FIFO) va hali "dead letter" bo'lmagan
  /// (retryCount < 5) amalni qaytaradi.
  Future<OutboxActionsTableData?> getOldestPendingAction() {
    return (select(outboxActionsTable)
          ..where((t) => t.retryCount.isSmallerThanValue(5))
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.createdAt,
                  mode: OrderingMode.asc,
                ),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Berilgan [id] li Outbox amalini navbatdan o'chiradi.
  Future<void> deleteOutboxAction(int id) {
    return (delete(outboxActionsTable)..where((t) => t.id.equals(id))).go();
  }

  /// Outbox amalini yangilaydi (masalan retryCount va lastError).
  /// [action.id] aniqlangan bo'lishi shart.
  Future<void> updateOutboxAction(OutboxActionsTableCompanion action) {
    return (update(outboxActionsTable)
          ..where((t) => t.id.equals(action.id.value)))
        .write(action);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'sud_qollanma_local.db'));
    return NativeDatabase.createInBackground(file);
  });
}
