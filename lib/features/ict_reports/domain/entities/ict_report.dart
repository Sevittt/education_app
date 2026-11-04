import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sud_qollanma/features/faq/domain/entities/faq_entity.dart';

/// AKT xodimining muammo va yechim haqidagi yozuvi.
/// Firestore: ict_reports/{id}. Admin ko'rib chiqadi va tasdiqlasa FAQ'ga nashr qiladi.
enum IctReportStatus { pending, approved, rejected }

extension IctReportStatusX on IctReportStatus {
  String get label {
    switch (this) {
      case IctReportStatus.pending:
        return 'Ko\'rib chiqilmoqda';
      case IctReportStatus.approved:
        return 'FAQ\'ga nashr qilindi';
      case IctReportStatus.rejected:
        return 'Rad etildi';
    }
  }

  static IctReportStatus parse(String? value) => IctReportStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => IctReportStatus.pending,
      );
}

class IctReport {
  // firestore.rules dagi cheklovlar bilan bir xil
  static const int maxProblemLength = 200;
  static const int maxTextLength = 5000;

  final String id;
  final String authorId;
  final String authorName;
  final String? courtName;
  final String? regionName;
  final String? systemId;
  final String? systemName;
  final FaqCategory category;
  final String problem;
  final String description;
  final String solution;
  final IctReportStatus status;
  final String? adminComment;
  final String? faqId;
  final DateTime? createdAt;
  final DateTime? reviewedAt;

  const IctReport({
    this.id = '',
    required this.authorId,
    required this.authorName,
    this.courtName,
    this.regionName,
    this.systemId,
    this.systemName,
    required this.category,
    required this.problem,
    this.description = '',
    required this.solution,
    this.status = IctReportStatus.pending,
    this.adminComment,
    this.faqId,
    this.createdAt,
    this.reviewedAt,
  });

  factory IctReport.fromMap(String id, Map<String, dynamic> data) {
    return IctReport(
      id: id,
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? '',
      courtName: data['courtName'] as String?,
      regionName: data['regionName'] as String?,
      systemId: data['systemId'] as String?,
      systemName: data['systemName'] as String?,
      category: FaqCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => FaqCategory.technical,
      ),
      problem: data['problem'] as String? ?? '',
      description: data['description'] as String? ?? '',
      solution: data['solution'] as String? ?? '',
      status: IctReportStatusX.parse(data['status'] as String?),
      adminComment: data['adminComment'] as String?,
      faqId: data['faqId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      reviewedAt: (data['reviewedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Yangi yozuv uchun maydonlar (rules ruxsat bergan ro'yxat bilan bir xil).
  Map<String, dynamic> toCreateMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      if (courtName != null) 'courtName': courtName,
      if (regionName != null) 'regionName': regionName,
      if (systemId != null) 'systemId': systemId,
      if (systemName != null) 'systemName': systemName,
      'category': category.name,
      'problem': problem,
      'description': description,
      'solution': solution,
      'status': IctReportStatus.pending.name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
