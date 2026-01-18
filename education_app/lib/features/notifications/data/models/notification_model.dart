import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.type,
    super.targetAudience,
    super.relatedContentType,
    super.relatedContentId,
    super.imageUrl,
    super.actionUrl,
    required super.sentAt,
    super.expiresAt,
    super.readBy,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return NotificationModel(
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
      sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
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
      'sentAt': Timestamp.fromDate(sentAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'readBy': readBy,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    TargetAudience? targetAudience,
    String? relatedContentType,
    String? relatedContentId,
    String? imageUrl,
    String? actionUrl,
    DateTime? sentAt,
    DateTime? expiresAt,
    List<String>? readBy,
  }) {
    return NotificationModel(
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
}
