// lib/models/app_notification.dart

import 'package:cloud_firestore/cloud_firestore.dart';

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

/// In-app notification model
/// 
/// Ilovodagi xabarnomalar uchun
class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final TargetAudience targetAudience;
  final String? relatedContentType;    // "article", "video", "system", "faq"
  final String? relatedContentId;       // Bog'liq kontent ID
  final String? imageUrl;              // Xabarnoma rasmi (optional)
  final String? actionUrl;             // Bosilganda qayerga olib boradi
  final Timestamp sentAt;
  final Timestamp? expiresAt;          // Qachongacha ko'rsatiladi
  final List<String> readBy;           // Kim o'qigani (userID'lar)

  AppNotification({
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

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AppNotification(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => NotificationType.system,
      ),
      targetAudience: TargetAudience.values.firstWhere(
        (e) => e.name == data['targetAudience'],
        orElse: () => TargetAudience.all,
      ),
      relatedContentType: data['relatedContentType'],
      relatedContentId: data['relatedContentId'],
      imageUrl: data['imageUrl'],
      actionUrl: data['actionUrl'],
      sentAt: data['sentAt'] ?? Timestamp.now(),
      expiresAt: data['expiresAt'],
      readBy: List<String>.from(data['readBy'] ?? []),
    );
  }

  factory AppNotification.fromMap(Map<String, dynamic> data, String id) {
    return AppNotification(
      id: id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => NotificationType.system,
      ),
      targetAudience: TargetAudience.values.firstWhere(
        (e) => e.name == data['targetAudience'],
        orElse: () => TargetAudience.all,
      ),
      relatedContentType: data['relatedContentType'],
      relatedContentId: data['relatedContentId'],
      imageUrl: data['imageUrl'],
      actionUrl: data['actionUrl'],
      sentAt: data['sentAt'] ?? Timestamp.now(),
      expiresAt: data['expiresAt'],
      readBy: List<String>.from(data['readBy'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'type': type.name,
      'targetAudience': targetAudience.name,
      'relatedContentType': relatedContentType,
      'relatedContentId': relatedContentId,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'sentAt': sentAt,
      'expiresAt': expiresAt,
      'readBy': readBy,
    };
  }

  Map<String, dynamic> toMap() => toFirestore();

  /// Foydalanuvchi bu xabarnomani o'qiganmi?
  bool isReadBy(String userId) => readBy.contains(userId);

  /// Xabarnoma muddati o'tganmi?
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!.toDate());
  }

  /// Bog'liq kontent bormi?
  bool get hasRelatedContent => 
      relatedContentType != null && relatedContentId != null;

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    TargetAudience? targetAudience,
    String? relatedContentType,
    String? relatedContentId,
    String? imageUrl,
    String? actionUrl,
    Timestamp? sentAt,
    Timestamp? expiresAt,
    List<String>? readBy,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      targetAudience: targetAudience ?? this.targetAudience,
      relatedContentType: relatedContentType ?? this.relatedContentType,
      relatedContentId: relatedContentId ?? this.relatedContentId,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      sentAt: sentAt ?? this.sentAt,
      expiresAt: expiresAt ?? this.expiresAt,
      readBy: readBy ?? this.readBy,
    );
  }

  @override
  String toString() {
    return 'AppNotification(id: $id, title: $title, type: ${type.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
