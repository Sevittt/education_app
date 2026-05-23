import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sud_qollanma/features/news/data/models/news_model.dart';

/// Firestore bilan ishlashni ta'minlovchi masofaviy ma'lumot manbai interfeysi.
abstract class NewsRemoteDataSource {
  /// Firestore-dan oxirgi [limit] ta yangilikni bir martalik olish.
  Future<List<NewsLocalModel>> fetchLatestNews({int limit = 20});

  /// Muayyan [since] vaqtidan keyin yangilangan yangiliklar.
  /// Incremental sinxronizatsiya uchun ishlatiladi.
  Future<List<NewsLocalModel>> fetchNewsUpdatedSince(DateTime since);

  /// Yangilikni server-da saqlash.
  /// [newsId] - mijoz tomonida generatsiya qilingan UUID (Document ID).
  Future<void> saveNews(String newsId, Map<String, dynamic> payload);

  /// Yangilikni Firestore-dan o'chirish.
  Future<void> deleteNews(String newsId);
}

/// [NewsRemoteDataSource] ning Firestore asosidagi amalga oshirilishi.
///
/// Asosiy o'zgarish: yangilik yaratishda Firestore avtomatik ID generatsiyasi
/// ishlatilmaydi. Uning o'rniga mijoz tomonidan berilgan [newsId] (UUID)
/// to'g'ridan-to'g'ri Document ID sifatida ishlatiladi.
/// Bu oflayn-birinchi arxitektura uchun talab qilinadi.
class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final FirebaseFirestore _firestore;

  const NewsRemoteDataSourceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _newsCollection =>
      _firestore.collection('news');

  @override
  Future<List<NewsLocalModel>> fetchLatestNews({int limit = 20}) async {
    final snapshot = await _newsCollection
        .orderBy('publicationDate', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map(_docToModel).toList();
  }

  @override
  Future<List<NewsLocalModel>> fetchNewsUpdatedSince(DateTime since) async {
    // Incremental sinxronizatsiya: faqat so'nggi sana o'tgandan keyin
    // o'zgargan hujjatlarni yuklash
    final snapshot = await _newsCollection
        .where('updatedAt', isGreaterThan: Timestamp.fromDate(since))
        .orderBy('updatedAt', descending: false)
        .get();

    return snapshot.docs.map(_docToModel).toList();
  }

  @override
  Future<void> saveNews(String newsId, Map<String, dynamic> payload) async {
    // Idempotent yozish: set + merge:true
    // Agar tarmoq uzilishi sababli qayta yuborilsa ham, ma'lumot takrorlanmaydi
    await _newsCollection.doc(newsId).set(
      {
        ...payload,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> deleteNews(String newsId) async {
    await _newsCollection.doc(newsId).delete();
  }

  // --- Yordamchi metodlar ---

  NewsLocalModel _docToModel(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return NewsLocalModel(
      id: doc.id,
      title: data['title'] as String? ?? 'Sarlavhasiz',
      source: data['source'] as String? ?? 'Noma\'lum manba',
      url: data['url'] as String? ?? '',
      publicationDate: _parseDate(data['publicationDate']),
      imageUrl: data['imageUrl'] as String?,
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
