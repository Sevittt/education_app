import 'package:flutter/material.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/notification_usecases.dart';

class NotificationNotifier extends ChangeNotifier {
  final GetUserNotifications _getUserNotifications;
  final GetUnreadCount _getUnreadCount;
  final MarkNotificationAsRead _markNotificationAsRead;
  final MarkAllNotificationsAsRead _markAllNotificationsAsRead;
  final CreateNotification _createNotification;
  final DeleteNotification _deleteNotification;
  final SendBulkNotification _sendBulkNotification;
  final CleanExpiredNotifications _cleanExpiredNotifications;

  NotificationNotifier({
    required GetUserNotifications getUserNotifications,
    required GetUnreadCount getUnreadCount,
    required MarkNotificationAsRead markNotificationAsRead,
    required MarkAllNotificationsAsRead markAllNotificationsAsRead,
    required CreateNotification createNotification,
    required DeleteNotification deleteNotification,
    required SendBulkNotification sendBulkNotification,
    required CleanExpiredNotifications cleanExpiredNotifications,
  }) : _getUserNotifications = getUserNotifications,
       _getUnreadCount = getUnreadCount,
       _markNotificationAsRead = markNotificationAsRead,
       _markAllNotificationsAsRead = markAllNotificationsAsRead,
       _createNotification = createNotification,
       _deleteNotification = deleteNotification,
       _sendBulkNotification = sendBulkNotification,
       _cleanExpiredNotifications = cleanExpiredNotifications;

  Stream<List<NotificationEntity>> getUserNotifications(String userId) {
    return _getUserNotifications(userId);
  }

  Stream<int> getUnreadCount(String userId) {
    return _getUnreadCount(userId);
  }

  Future<void> markAsRead(String notificationId, String userId) async {
    await _markNotificationAsRead(notificationId, userId);
    notifyListeners();
  }

  Future<void> markAllAsRead(String userId) async {
    await _markAllNotificationsAsRead(userId);
    notifyListeners();
  }

  Future<String?> createNotification(NotificationEntity notification) async {
    final result = await _createNotification(notification);
    notifyListeners();
    return result;
  }

  Future<void> deleteNotification(String id) async {
    await _deleteNotification(id);
    notifyListeners();
  }

  Future<bool> sendBulkNotification({
    required String title,
    required String body,
    required NotificationType type,
    required List<String> userIds,
    String? relatedContentType,
    String? relatedContentId,
  }) async {
    final result = await _sendBulkNotification(
      title: title,
      body: body,
      type: type,
      userIds: userIds,
      relatedContentType: relatedContentType,
      relatedContentId: relatedContentId,
    );
    notifyListeners();
    return result;
  }

  Future<int> cleanExpiredNotifications() async {
    final result = await _cleanExpiredNotifications();
    notifyListeners();
    return result;
  }
}
