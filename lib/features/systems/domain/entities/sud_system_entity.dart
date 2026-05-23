import 'package:equatable/equatable.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';

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
  String getDisplayName(AppLocalizations l10n) {
    switch (this) {
      case SystemCategory.primary:
        return l10n.sysCatPrimary; // Ensure these keys exist in l10n
      case SystemCategory.secondary:
        return l10n.sysCatSecondary;
      case SystemCategory.support:
        return l10n.sysCatSupport;
    }
  }
}

extension SystemStatusExtension on SystemStatus {
  String getDisplayName(AppLocalizations l10n) {
    switch (this) {
      case SystemStatus.active:
        return l10n.sysStatusActive;
      case SystemStatus.maintenance:
        return l10n.sysStatusMaintenance;
      case SystemStatus.deprecated:
        return l10n.sysStatusDeprecated;
      case SystemStatus.offline:
        return l10n.sysStatusOffline;
    }
  }
}

class SudSystemEntity extends Equatable {
  final String id;
  final String name;
  final String fullName;
  final String url;
  final String? logoUrl;
  final String description;
  final String? loginGuideId;
  final String? videoGuideId;
  final List<String> faqIds;
  final SystemCategory category;
  final SystemStatus status;
  final String? loginGuideUrl;
  final String? videoGuideUrl;
  final String? supportEmail;
  final String? supportPhone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SudSystemEntity({
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
    this.loginGuideUrl,
    this.videoGuideUrl,
    this.supportEmail,
    this.supportPhone,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullUrl => url.startsWith('http') ? url : 'https://$url';
  bool get isActive => status == SystemStatus.active;

  @override
  List<Object?> get props => [
        id,
        name,
        fullName,
        url,
        logoUrl,
        description,
        loginGuideId,
        videoGuideId,
        loginGuideUrl,
        videoGuideUrl,
        faqIds,
        category,
        status,
        supportEmail,
        supportPhone,
        createdAt,
        updatedAt,
      ];
}
