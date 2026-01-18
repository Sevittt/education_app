import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetUserNotifications {
  final NotificationRepository repository;
  GetUserNotifications(this.repository);
  Stream<List<NotificationEntity>> call(String userId) => repository.getUserNotifications(userId);
}

class GetUnreadCount {
  final NotificationRepository repository;
  GetUnreadCount(this.repository);
  Stream<int> call(String userId) => repository.getUnreadCount(userId);
}

class MarkNotificationAsRead {
  final NotificationRepository repository;
  MarkNotificationAsRead(this.repository);
  Future<bool> call(String notificationId, String userId) => repository.markAsRead(notificationId, userId);
}

class MarkAllNotificationsAsRead {
  final NotificationRepository repository;
  MarkAllNotificationsAsRead(this.repository);
  Future<Map<String, dynamic>> call(String userId) => repository.markAllAsRead(userId);
}

class CreateNotification {
  final NotificationRepository repository;
  CreateNotification(this.repository);
  Future<String?> call(NotificationEntity notification) => repository.createNotification(notification);
}

class DeleteNotification {
  final NotificationRepository repository;
  DeleteNotification(this.repository);
  Future<bool> call(String id) => repository.deleteNotification(id);
}

class SendBulkNotification {
  final NotificationRepository repository;
  SendBulkNotification(this.repository);
  Future<bool> call({
    required String title,
    required String body,
    required NotificationType type,
    required List<String> userIds,
    String? relatedContentType,
    String? relatedContentId,
  }) => repository.sendBulkNotification(
    title: title,
    body: body,
    type: type,
    userIds: userIds,
    relatedContentType: relatedContentType,
    relatedContentId: relatedContentId,
  );
}

class CleanExpiredNotifications {
  final NotificationRepository repository;
  CleanExpiredNotifications(this.repository);
  Future<int> call() => repository.cleanExpiredNotifications();
}
