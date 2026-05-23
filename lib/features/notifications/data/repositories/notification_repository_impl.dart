import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<NotificationEntity>> getUserNotifications(String userId) {
    return remoteDataSource.getUserNotifications(userId);
  }

  @override
  Stream<List<NotificationEntity>> getUnreadNotifications(String userId) {
    return remoteDataSource.getUserNotifications(userId).map((notifications) {
      return notifications.where((n) => !n.isReadBy(userId)).toList();
    });
  }

  @override
  Stream<int> getUnreadCount(String userId) {
    return getUnreadNotifications(userId).map((list) => list.length);
  }

  @override
  Future<NotificationEntity?> getNotificationById(String id) {
    return remoteDataSource.getNotificationById(id);
  }

  @override
  Future<String?> createNotification(NotificationEntity notification) {
    // Convert Entity to Model for data source
    // Since Entity doesn't have clone/copy, we reconstruct Model
    final model = NotificationModel(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      type: notification.type,
      targetAudience: notification.targetAudience,
      relatedContentType: notification.relatedContentType,
      relatedContentId: notification.relatedContentId,
      imageUrl: notification.imageUrl,
      actionUrl: notification.actionUrl,
      sentAt: notification.sentAt,
      expiresAt: notification.expiresAt,
      readBy: notification.readBy,
    );
    return remoteDataSource.createNotification(model);
  }

  @override
  Future<bool> markAsRead(String notificationId, String userId) {
    return remoteDataSource.markAsRead(notificationId, userId);
  }

  @override
  Future<Map<String, dynamic>> markAllAsRead(String userId) {
    return remoteDataSource.markAllAsRead(userId);
  }

  @override
  Future<bool> deleteNotification(String id) {
    return remoteDataSource.deleteNotification(id);
  }

  @override
  Future<bool> sendBulkNotification({
    required String title,
    required String body,
    required NotificationType type,
    required List<String> userIds,
    String? relatedContentType,
    String? relatedContentId,
  }) async {
    try {
      for (final _ in userIds) {
        await createNotification(
          NotificationEntity(
            id: '',
            title: title,
            body: body,
            type: type,
            targetAudience: TargetAudience.specific,
            relatedContentType: relatedContentType,
            relatedContentId: relatedContentId,
            sentAt: DateTime.now(),
            // No expiresAt default for now
          ),
        );
      }
      return true;
    } catch (e) {
      print('Error sending bulk notification: $e');
      return false;
    }
  }

  @override
  Future<int> getTotalNotificationsCount() => remoteDataSource.getTotalNotificationsCount();

  @override
  Future<int> getActiveNotificationsCount() => remoteDataSource.getActiveNotificationsCount();

  @override
  Future<int> cleanExpiredNotifications() => remoteDataSource.cleanExpiredNotifications();
}
