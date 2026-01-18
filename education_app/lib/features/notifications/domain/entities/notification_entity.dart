import 'package:equatable/equatable.dart';

/// Xabarnoma turlari
enum NotificationType {
  update,         // Yangilanish haqida
  newContent,     // Yangi kontent qo'shildi
  announcement,   // E'lon
  reminder,       // Eslatma
  system,         // Tizim xabari
}

/// Kimga yuborilishi
enum TargetAudience {
  all,           // Hammaga
  beginner,      // Yangi xodimlarga
  akt,           // AKT xodimlarga
  specific,      // Maxsus ro'yxat
}

extension TargetAudienceExtension on TargetAudience {
  String get displayName {
    switch (this) {
      case TargetAudience.all:
        return "Barchaga";
      case TargetAudience.beginner:
        return "Yangi Xodimlarga";
      case TargetAudience.akt:
        return "AKT Xodimlariga";
      case TargetAudience.specific:
        return "Maxsus";
    }
  }
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.update:
        return "Yangilanish";
      case NotificationType.newContent:
        return "Yangi Kontent";
      case NotificationType.announcement:
        return "E'lon";
      case NotificationType.reminder:
        return "Eslatma";
      case NotificationType.system:
        return "Tizim Xabari";
    }
  }
  
  String get icon {
    switch (this) {
      case NotificationType.update:
        return "🔄";
      case NotificationType.newContent:
        return "📚";
      case NotificationType.announcement:
        return "📢";
      case NotificationType.reminder:
        return "⏰";
      case NotificationType.system:
        return "⚙️";
    }
  }
}

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final TargetAudience targetAudience;
  final String? relatedContentType;
  final String? relatedContentId;
  final String? imageUrl;
  final String? actionUrl;
  final DateTime sentAt;
  final DateTime? expiresAt;
  final List<String> readBy;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.targetAudience = TargetAudience.all,
    this.relatedContentType,
    this.relatedContentId,
    this.imageUrl,
    this.actionUrl,
    required this.sentAt,
    this.expiresAt,
    this.readBy = const [],
  });

  bool isReadBy(String userId) => readBy.contains(userId);

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get hasRelatedContent => 
      relatedContentType != null && relatedContentId != null;

  @override
  List<Object?> get props => [
    id, title, body, type, targetAudience, 
    relatedContentType, relatedContentId, 
    imageUrl, actionUrl, sentAt, expiresAt, readBy
  ];
}
