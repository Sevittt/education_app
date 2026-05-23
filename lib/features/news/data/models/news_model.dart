import 'package:drift/drift.dart';
import 'package:sud_qollanma/core/database/app_database.dart';
import 'package:sud_qollanma/features/news/domain/entities/news_entity.dart';

/// [NewsEntity] uchun ma'lumot qatlami modeli (DTO).
///
/// Bu klass domen ([NewsEntity]), masofaviy manba (Firestore JSON) va lokal
/// baza (Drift [NewsTable]) o'rtasidagi o'tkazishlarni markazlashtiradi.
/// Ilgari Isar `@collection` (NewsIsarModel) bo'lgan; endi oddiy DTO-ga
/// aylantirildi va lokal saqlash Drift jadvali orqali amalga oshiriladi.
class NewsLocalModel {
  final String id;
  final String title;
  final String source;
  final String url;
  final DateTime? publicationDate;
  final String? imageUrl;

  const NewsLocalModel({
    required this.id,
    required this.title,
    required this.source,
    required this.url,
    this.publicationDate,
    this.imageUrl,
  });

  /// [NewsEntity] dan [NewsLocalModel] yaratish.
  factory NewsLocalModel.fromEntity(NewsEntity entity) {
    return NewsLocalModel(
      id: entity.id,
      title: entity.title,
      source: entity.source,
      url: entity.url,
      publicationDate: entity.publicationDate,
      imageUrl: entity.imageUrl,
    );
  }

  /// Drift jadvalidan o'qilgan qator ([NewsTableData]) dan model yaratish.
  factory NewsLocalModel.fromTable(NewsTableData row) {
    return NewsLocalModel(
      id: row.id,
      title: row.title,
      source: row.source,
      url: row.url,
      publicationDate: row.publicationDate,
      imageUrl: row.imageUrl,
    );
  }

  /// [NewsLocalModel] ni [NewsEntity] ga o'tkazish.
  NewsEntity toEntity() {
    return NewsEntity(
      id: id,
      title: title,
      source: source,
      url: url,
      publicationDate: publicationDate,
      imageUrl: imageUrl,
    );
  }

  /// Drift jadvaliga yozish uchun [NewsTableCompanion] ga o'tkazish.
  NewsTableCompanion toCompanion() {
    return NewsTableCompanion.insert(
      id: id,
      title: title,
      source: source,
      url: url,
      publicationDate: Value(publicationDate),
      imageUrl: Value(imageUrl),
    );
  }

  /// Firestore-ga yuborish uchun JSON payload yaratish.
  Map<String, dynamic> toFirestorePayload() {
    return {
      'title': title,
      'source': source,
      'url': url,
      'publicationDate': publicationDate?.toUtc().toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
}
