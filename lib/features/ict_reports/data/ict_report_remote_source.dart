import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sud_qollanma/features/faq/data/models/faq_model.dart';
import 'package:sud_qollanma/features/faq/domain/entities/faq_entity.dart';
import '../domain/entities/ict_report.dart';

/// ict_reports kolleksiyasi bilan ishlaydi.
/// Ro'yxatlar client tomonda saralanadi (yozuvlar soni kam, composite indeks shart emas).
class IctReportRemoteSource {
  final FirebaseFirestore _db;

  IctReportRemoteSource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reports =>
      _db.collection('ict_reports');

  Future<void> submit(IctReport report) async {
    await _reports.add(report.toCreateMap());
  }

  /// AKT xodimining o'z yozuvlari, eng yangisi birinchi.
  Stream<List<IctReport>> watchMine(String uid) {
    return _reports
        .where('authorId', isEqualTo: uid)
        .snapshots()
        .map(_toSortedList);
  }

  /// Admin uchun holat bo'yicha.
  Stream<List<IctReport>> watchByStatus(IctReportStatus status) {
    return _reports
        .where('status', isEqualTo: status.name)
        .snapshots()
        .map(_toSortedList);
  }

  /// Faqat ko'rib chiqilmagan yozuvni muallif o'chira oladi (rules ham shuni tekshiradi).
  Future<void> deletePending(String id) async {
    await _reports.doc(id).delete();
  }

  /// FAQ yaratadi va yozuvni tasdiqlangan deb belgilaydi — bitta batch'da.
  /// Tizim tanlangan bo'lsa, FAQ shu tizimning faqIds ro'yxatiga ham qo'shiladi.
  Future<String> approveAsFaq({
    required IctReport report,
    required String question,
    required String answer,
    required FaqCategory category,
    String? systemId,
    required String adminId,
  }) async {
    final batch = _db.batch();
    final faqRef = _db.collection('faqs').doc();
    final now = DateTime.now();

    batch.set(
      faqRef,
      FaqModel(
        id: faqRef.id,
        question: question,
        answer: answer,
        category: category,
        systemId: systemId,
        createdAt: now,
        updatedAt: now,
      ).toFirestore(),
    );
    batch.update(_reports.doc(report.id), {
      'status': IctReportStatus.approved.name,
      'faqId': faqRef.id,
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': adminId,
    });
    if (systemId != null) {
      batch.update(_db.collection('systems').doc(systemId), {
        'faqIds': FieldValue.arrayUnion([faqRef.id]),
      });
    }

    await batch.commit();
    return faqRef.id;
  }

  Future<void> reject({
    required String reportId,
    required String comment,
    required String adminId,
  }) async {
    await _reports.doc(reportId).update({
      'status': IctReportStatus.rejected.name,
      'adminComment': comment,
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': adminId,
    });
  }

  List<IctReport> _toSortedList(QuerySnapshot<Map<String, dynamic>> snap) {
    final reports =
        snap.docs.map((d) => IctReport.fromMap(d.id, d.data())).toList();
    reports.sort((a, b) {
      // createdAt hali server tomonidan yozilmagan (yangi) yozuv tepada
      final ad = a.createdAt, bd = b.createdAt;
      if (ad == null && bd == null) return 0;
      if (ad == null) return -1;
      if (bd == null) return 1;
      return bd.compareTo(ad);
    });
    return reports;
  }
}
