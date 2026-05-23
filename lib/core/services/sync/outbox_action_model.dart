import 'package:drift/drift.dart';
import 'package:sud_qollanma/core/database/app_database.dart';

/// Outbox (sinxronizatsiya navbati) amalining turi.
enum OutboxActionType {
  create,
  update,
  delete,
}

/// [String] (Drift `actionType` ustuni) va [OutboxActionType] o'rtasidagi
/// xavfsiz o'tkazishlar.
extension OutboxActionTypeX on OutboxActionType {
  /// Drift ustuniga yoziladigan matn ko'rinishi.
  String get asDbValue => name;

  /// Matndan [OutboxActionType] ni xavfsiz tiklash. Noma'lum qiymat
  /// kelganda standart sifatida [OutboxActionType.update] qaytariladi
  /// (idempotent set+merge eng xavfsiz tanlov).
  static OutboxActionType fromDbValue(String value) {
    return OutboxActionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OutboxActionType.update,
    );
  }
}

/// Oflayn rejimda bajarilgan amallarni ketma-ket (FIFO) navbatda saqlovchi
/// ma'lumot modeli (DTO).
///
/// Ilgari Isar `@collection` bo'lgan; endi oddiy DTO-ga aylantirildi va lokal
/// saqlash Drift [OutboxActionsTable] orqali amalga oshiriladi. Har qanday
/// ma'lumot o'zgarishi paytida bu model bir xil Drift tranzaksiyasi ichida
/// yozilishi shart (atomiklik).
///
/// [SyncWorker] bu navbatni o'qib, Firestore-ga idempotent tarzda yuklaydi.
class OutboxActionModel {
  /// Drift tomonidan avtomatik belgilanadigan ID.
  /// Hali bazaga yozilmagan (yangi) amalda `null` bo'ladi.
  final int? id;

  /// Hujjat tegishli bo'lgan Firestore kolleksiyasi nomi.
  /// Masalan: 'news', 'courses', 'users'
  final String entityCollection;

  /// Hujjatning UUID ko'rinishidagi identifikatori (Firestore Document ID bilan mos).
  final String entityId;

  /// Amal turi: yaratish, tahrirlash yoki o'chirish.
  final OutboxActionType actionType;

  /// Hujjat ma'lumotlarining JSON ko'rinishi (Firestore-ga yuboriladigan payload).
  /// Delete amallarida bu maydon bo'sh bo'lishi mumkin.
  final String payloadJson;

  /// Amal yaratilgan vaqt (FIFO tartibini ta'minlash uchun).
  final DateTime createdAt;

  /// Muvaffaqiyatsiz urinishlar soni (5 dan oshsa "dead letter" holatiga o'tadi).
  final int retryCount;

  /// So'nggi xato xabari (debugging uchun).
  final String? lastError;

  const OutboxActionModel({
    this.id,
    required this.entityCollection,
    required this.entityId,
    required this.actionType,
    required this.payloadJson,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
  });

  /// Qulay yaratuvchi factory konstruktor (yangi, hali yozilmagan amal uchun).
  factory OutboxActionModel.create({
    required String entityCollection,
    required String entityId,
    required OutboxActionType actionType,
    required String payloadJson,
  }) {
    return OutboxActionModel(
      entityCollection: entityCollection,
      entityId: entityId,
      actionType: actionType,
      payloadJson: payloadJson,
      createdAt: DateTime.now(),
      retryCount: 0,
    );
  }

  /// Drift jadvalidan o'qilgan qator ([OutboxActionsTableData]) dan model yaratish.
  factory OutboxActionModel.fromTable(OutboxActionsTableData row) {
    return OutboxActionModel(
      id: row.id,
      entityCollection: row.entityCollection,
      entityId: row.entityId,
      actionType: OutboxActionTypeX.fromDbValue(row.actionType),
      payloadJson: row.payloadJson,
      createdAt: row.createdAt,
      retryCount: row.retryCount,
      lastError: row.lastError,
    );
  }

  /// Drift jadvaliga YANGI qator qo'shish uchun companion
  /// ([id] avtomatik beriladi).
  OutboxActionsTableCompanion toInsertCompanion() {
    return OutboxActionsTableCompanion.insert(
      entityCollection: entityCollection,
      entityId: entityId,
      actionType: actionType.asDbValue,
      payloadJson: payloadJson,
      createdAt: createdAt,
      retryCount: Value(retryCount),
      lastError: Value(lastError),
    );
  }

  /// Mavjud qatorni yangilash uchun companion ([id] majburiy).
  OutboxActionsTableCompanion toUpdateCompanion() {
    return OutboxActionsTableCompanion(
      id: Value(id!),
      retryCount: Value(retryCount),
      lastError: Value(lastError),
    );
  }

  /// Ayrim maydonlarni o'zgartirib yangi nusxa qaytaradi.
  OutboxActionModel copyWith({
    int? retryCount,
    String? lastError,
  }) {
    return OutboxActionModel(
      id: id,
      entityCollection: entityCollection,
      entityId: entityId,
      actionType: actionType,
      payloadJson: payloadJson,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }
}
