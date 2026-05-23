import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sud_qollanma/features/systems/domain/entities/sud_system_entity.dart';

class SudSystemModel extends SudSystemEntity {
  const SudSystemModel({
    required super.id,
    required super.name,
    required super.fullName,
    required super.url,
    super.logoUrl,
    required super.description,
    super.loginGuideId,
    super.videoGuideId,
    super.loginGuideUrl,
    super.videoGuideUrl,
    super.faqIds,
    required super.category,
    super.status,
    super.supportEmail,
    super.supportPhone,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SudSystemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SudSystemModel(
      id: doc.id,
      name: data['name'] ?? '',
      fullName: data['fullName'] ?? '',
      url: data['url'] ?? '',
      logoUrl: data['logoUrl'],
      description: data['description'] ?? '',
      loginGuideId: data['loginGuideId'],
      videoGuideId: data['videoGuideId'],
      loginGuideUrl: data['loginGuideUrl'],
      videoGuideUrl: data['videoGuideUrl'],
      faqIds: List<String>.from(data['faqIds'] ?? []),
      category: SystemCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => SystemCategory.primary,
      ),
      status: SystemStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => SystemStatus.active,
      ),
      supportEmail: data['supportEmail'],
      supportPhone: data['supportPhone'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'fullName': fullName,
      'url': url,
      'logoUrl': logoUrl,
      'description': description,
      'loginGuideId': loginGuideId,
      'videoGuideId': videoGuideId,
      'loginGuideUrl': loginGuideUrl,
      'videoGuideUrl': videoGuideUrl,
      'faqIds': faqIds,
      'category': category.name,
      'status': status.name,
      'supportEmail': supportEmail,
      'supportPhone': supportPhone,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
