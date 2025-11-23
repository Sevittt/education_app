// lib/models/sud_system.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Tizim kategoriyalari
enum SystemCategory {
  primary,    // Asosiy tizimlar (edo, ms, jib)
  secondary,  // Qo'shimcha tizimlar
  support,    // Yordam tizimlari (ticket)
}

/// Tizim holati
enum SystemStatus {
  active,       // Faol
  maintenance,  // Texnik xizmat
  deprecated,   // Eski versiya
  offline,      // Ishlamayotgan
}

extension SystemCategoryExtension on SystemCategory {
  String get displayName {
    switch (this) {
      case SystemCategory.primary:
        return "Asosiy Tizimlar";
      case SystemCategory.secondary:
        return "Qo'shimcha Tizimlar";
      case SystemCategory.support:
        return "Yordam Tizimlari";
    }
  }
}

extension SystemStatusExtension on SystemStatus {
  String get displayName {
    switch (this) {
      case SystemStatus.active:
        return "Faol";
      case SystemStatus.maintenance:
        return "Texnik Xizmat";
      case SystemStatus.deprecated:
        return "Eski Versiya";
      case SystemStatus.offline:
        return "O'chirilgan";
    }
  }
}

/// Sud tizimlari uchun model
/// 
/// Har bir sud axborot tizimini ifodalaydi
class SudSystem {
  final String id;
  final String name;              // Qisqa nom: "EDO", "MS", "JIB"
  final String fullName;          // To'liq nom: "Elektron Hujjat Aylanish Tizimi"
  final String url;               // edo.sud.uz
  final String? logoUrl;          // Tizim logosi
  final String description;       // Tavsif
  final String? loginGuideId;     // Kirish qo'llanmasi (KnowledgeArticle ID)
  final String? videoGuideId;     // Video qo'llanma (VideoTutorial ID)
  final List<String> faqIds;      // Bog'liq FAQ ID'lar
  final SystemCategory category;
  final SystemStatus status;
  final String? supportEmail;     // Yordam email
  final String? supportPhone;     // Yordam telefon
  final Timestamp createdAt;
  final Timestamp updatedAt;

  SudSystem({
    required this.id,
    required this.name,
    required this.fullName,
    required this.url,
    this.logoUrl,
    required this.description,
    this.loginGuideId,
    this.videoGuideId,
    this.faqIds = const [],
    required this.category,
    this.status = SystemStatus.active,
    this.supportEmail,
    this.supportPhone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SudSystem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return SudSystem(
      id: doc.id,
      name: data['name'] ?? '',
      fullName: data['fullName'] ?? '',
      url: data['url'] ?? '',
      logoUrl: data['logoUrl'],
      description: data['description'] ?? '',
      loginGuideId: data['loginGuideId'],
      videoGuideId: data['videoGuideId'],
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
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  factory SudSystem.fromMap(Map<String, dynamic> data, String id) {
    return SudSystem(
      id: id,
      name: data['name'] ?? '',
      fullName: data['fullName'] ?? '',
      url: data['url'] ?? '',
      logoUrl: data['logoUrl'],
      description: data['description'] ?? '',
      loginGuideId: data['loginGuideId'],
      videoGuideId: data['videoGuideId'],
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
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
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
      'faqIds': faqIds,
      'category': category.name,
      'status': status.name,
      'supportEmail': supportEmail,
      'supportPhone': supportPhone,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Map<String, dynamic> toMap() => toFirestore();

  /// Full URL with https://
  String get fullUrl => 'https://$url';

  /// Tizim faolmi?
  bool get isActive => status == SystemStatus.active;

  SudSystem copyWith({
    String? id,
    String? name,
    String? fullName,
    String? url,
    String? logoUrl,
    String? description,
    String? loginGuideId,
    String? videoGuideId,
    List<String>? faqIds,
    SystemCategory? category,
    SystemStatus? status,
    String? supportEmail,
    String? supportPhone,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return SudSystem(
      id: id ?? this.id,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      url: url ?? this.url,
      logoUrl: logoUrl ?? this.logoUrl,
      description: description ?? this.description,
      loginGuideId: loginGuideId ?? this.loginGuideId,
      videoGuideId: videoGuideId ?? this.videoGuideId,
      faqIds: faqIds ?? this.faqIds,
      category: category ?? this.category,
      status: status ?? this.status,
      supportEmail: supportEmail ?? this.supportEmail,
      supportPhone: supportPhone ?? this.supportPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SudSystem(id: $id, name: $name, url: $url, status: ${status.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SudSystem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
