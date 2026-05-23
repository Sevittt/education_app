import 'package:sud_qollanma/core/database/app_database.dart';

/// Drift ([AppDatabase]) ma'lumotlar bazasini boshqaruvchi yagona (Singleton)
/// xizmat.
///
/// Drift bazasi `LazyDatabase` orqali birinchi murojaatda dangasa (lazy) tarzda
/// ochiladi, shuning uchun [init] majburiy emas; ammo Isar bilan mosligini
/// (API compatibility) saqlash uchun saqlab qolingan va `main.dart` da
/// chaqiriladi.
class DriftDatabaseService {
  static DriftDatabaseService? _instance;
  static AppDatabase? _db;

  DriftDatabaseService._internal();

  /// [DriftDatabaseService] ning yagona nusxasini qaytaradi.
  static DriftDatabaseService get instance {
    _instance ??= DriftDatabaseService._internal();
    return _instance!;
  }

  /// Ishga tushirilgan [AppDatabase] misolini qaytaradi (lazy init).
  AppDatabase get db {
    _db ??= AppDatabase();
    return _db!;
  }

  /// Bazani oldindan tayyorlaydi. Drift dangasa ochilgani uchun bu yerda
  /// faqat misol yaratiladi (haqiqiy ulanish birinchi so'rovda amalga oshadi).
  Future<void> init() async {
    _db ??= AppDatabase();
  }

  /// Bazani yopadi (odatda test muhitida yoki ilovadan chiqishda ishlatiladi).
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
