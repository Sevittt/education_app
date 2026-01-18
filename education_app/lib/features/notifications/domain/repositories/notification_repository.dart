import '../entities/notification_entity.dart';


abstract class NotificationRepository {
  // Read
  Stream<List<NotificationEntity>> getUserNotifications(String userId);
  Stream<List<NotificationEntity>> getUnreadNotifications(String userId);
  Stream<int> getUnreadCount(String userId);
  Future<NotificationEntity?> getNotificationById(String id);

  // Write
  Future<String?> createNotification(NotificationEntity notification);
  Future<bool> markAsRead(String notificationId, String userId);
  Future<Map<String, dynamic>> markAllAsRead(String userId);
  Future<bool> deleteNotification(String id);
  Future<bool> sendBulkNotification({
    required String title,
    required String body,
    required NotificationType type,
    required List<String> userIds,
    String? relatedContentType,
    String? relatedContentId,
  });

  // Admin / Maintenance
  Future<int> getTotalNotificationsCount();
  Future<int> getActiveNotificationsCount();
  Future<int> cleanExpiredNotifications();
}
