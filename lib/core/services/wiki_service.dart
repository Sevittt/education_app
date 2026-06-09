import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ai_service.dart';
import 'logger_service.dart';

/// LLM Wiki qatlami.
///
/// Firestore kolleksiyasi: wiki_pages
/// Har bir hujjat maydoni:
///   - slug:         String  — so'rovdan hosil qilingan kalit (id sifatida ishlatiladi)
///   - title:        String  — mavzu nomi
///   - content:      String  — Gemini yozgan markdown matn
///   - source_query: String  — qaysi savoldan yaratilgan
///   - hit_count:    int     — necha marta ishlatilgan (analytics)
///   - created_at:   Timestamp
class WikiService {
  final AiService _aiService;
  final FirebaseFirestore _firestore;

  static const String _collection = 'wiki_pages';

  WikiService(this._aiService, {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// So'rovga mos wiki sahifani qidiradi.
  ///
  /// Topilsa — markdown kontekst satrini qaytaradi.
  /// Topilmasa — null qaytaradi (RAG fallback uchun).
  Future<String?> search(String query) async {
    if (query.trim().isEmpty) return null;

    final slug = _buildSlug(query);
    try {
      final doc = await _firestore.collection(_collection).doc(slug).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final content = data['content'] as String? ?? '';
        if (content.isNotEmpty) {
          LoggerService().log('Wiki hit → "$slug"');
          unawaited(_incrementHit(slug));
          return content;
        }
      }
    } catch (e, stack) {
      LoggerService()
          .recordError(e, stack, reason: 'WikiService: search failed for "$slug"');
    }
    LoggerService().log('Wiki miss → RAG fallback for "$query"');
    return null;
  }

  /// RAG kontekstidan fon rejimida wiki sahifa yaratadi.
  ///
  /// Duplicate oldini olish: agar slug allaqachon mavjud bo'lsa, qaytib ketadi.
  /// [unawaited()] bilan chaqirilishi kerak — foydalanuvchi kutmasin.
  Future<void> buildPage(String query, String ragContext) async {
    if (query.trim().isEmpty || ragContext.trim().isEmpty) return;

    final slug = _buildSlug(query);
    try {
      final existing = await _firestore.collection(_collection).doc(slug).get();
      if (existing.exists) {
        LoggerService().log('WikiService: "$slug" allaqachon mavjud, o\'tkazib yuborildi');
        return;
      }

      final prompt = _buildPrompt(query, ragContext);
      final content = await _aiService.generateContent(prompt);
      if (content == null || content.trim().isEmpty) return;

      await _firestore.collection(_collection).doc(slug).set({
        'slug': slug,
        'title': query,
        'content': content.trim(),
        'source_query': query,
        'hit_count': 0,
        'created_at': FieldValue.serverTimestamp(),
      });

      LoggerService().log('WikiService: yangi sahifa yaratildi → "$slug"');
    } catch (e, stack) {
      LoggerService()
          .recordError(e, stack, reason: 'WikiService: buildPage failed for "$slug"');
    }
  }

  Future<void> _incrementHit(String slug) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(slug)
          .update({'hit_count': FieldValue.increment(1)});
    } catch (e, stack) {
      LoggerService()
          .recordError(e, stack, reason: 'WikiService: incrementHit failed');
    }
  }

  /// So'rovdan slug hosil qiladi.
  ///
  /// Misol: "E-IMZO drayveri muammolari" → "e-imzo-drayveri-muammolari"
  String _buildSlug(String text) {
    return text
        .toLowerCase()
        .replaceAll("o'", 'o')
        .replaceAll("g'", 'g')
        .replaceAll(RegExp(r"[^a-z0-9а-я\-]"), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '')
        .substring(0, text.length.clamp(0, 80));
  }

  String _buildPrompt(String topic, String ragContext) {
    final ctx = ragContext.length > 4000
        ? ragContext.substring(0, 4000)
        : ragContext;

    return """
Quyidagi sud tizimi IT qo'llanmasi matnlaridan "$topic" mavzusida wiki sahifa yoz.
FAQAT berilgan manbada bor narsani yoz, o'ylab topma.

Tuzilma:
## $topic
### Asosiy tushuntirish
### Qadamlar (agar amaliy jarayon bo'lsa)
### Tez-tez uchraydigan muammolar va yechimlari
### Bog'liq mavzular

Til: O'zbek (lotin)
Uslub: Qisqa, aniq, sud xodimlariga tushunarli
Hajm: 300-600 so'z

Manbalar:
$ctx
""";
  }
}
