import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_entity.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Stream<List<NotificationModel>> getUserNotifications(String userId);
  Future<NotificationModel?> getNotificationById(String id);
  Future<String?> createNotification(NotificationModel notification);
  Future<bool> markAsRead(String notificationId, String userId);
  Future<Map<String, dynamic>> markAllAsRead(String userId);
  Future<bool> deleteNotification(String id);
  Future<int> getTotalNotificationsCount();
  Future<int> getActiveNotificationsCount();
  Future<int> cleanExpiredNotifications();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final CollectionReference<Map<String, dynamic>> _notificationsCollection =
      FirebaseFirestore.instance.collection('notifications');

  @override
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _notificationsCollection
        .where('targetAudience', whereIn: ['all', userId])
        .orderBy('sentAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .where((notification) {
            return !notification.isExpired;
          })
          .toList();
    });
  }

  @override
  Future<NotificationModel?> getNotificationById(String id) async {
    try {
      final doc = await _notificationsCollection.doc(id).get();
      if (!doc.exists) return null;
      return NotificationModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Error getting notification: $e');
    }
  }

  @override
  Future<String?> createNotification(NotificationModel notification) async {
    try {
      // Use toFirestore from Model
      final docRef = await _notificationsCollection.add(notification.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating notification: $e');
      return null;
    }
  }

  @override
  Future<bool> markAsRead(String notificationId, String userId) async {
    try {
      final docRef = _notificationsCollection.doc(notificationId);
      
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;
        
        final data = snapshot.data();
        final readBy = List<String>.from(data?['readBy'] ?? []);
        
        if (!readBy.contains(userId)) {
          readBy.add(userId);
          transaction.update(docRef, {'readBy': readBy});
        }
      });
      
      return true;
    } catch (e) {
      print('Error marking as read: $e');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> markAllAsRead(String userId) async {
    try {
      final notificationsSnapshot = await _notificationsCollection
          .where('targetAudience', whereIn: ['all', userId])
          .get();

      final batch = FirebaseFirestore.instance.batch();
      bool hasUpdates = false;

      for (var doc in notificationsSnapshot.docs) {
        final data = doc.data();
        final readBy = List<String>.from(data['readBy'] ?? []);

        if (!readBy.contains(userId)) {
          readBy.add(userId);
          batch.update(doc.reference, {'readBy': readBy});
          hasUpdates = true;
        }
      }

      if (hasUpdates) {
        await batch.commit();
      }
      
      return {'success': true};
    } catch (e) {
      print('Error marking all as read: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  @override
  Future<bool> deleteNotification(String id) async {
    try {
      await _notificationsCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  @override
  Future<int> getTotalNotificationsCount() async {
    try {
      final snapshot = await _notificationsCollection.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting total count: $e');
      return 0;
    }
  }

  @override
  Future<int> getActiveNotificationsCount() async {
    try {
      final now = Timestamp.now();
      final snapshot = await _notificationsCollection
          .where('expiresAt', isGreaterThan: now)
          .count()
          .get();
      
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting active count: $e');
      return 0;
    }
  }

  @override
  Future<int> cleanExpiredNotifications() async {
    try {
      final now = Timestamp.now();
      final snapshot = await _notificationsCollection
          .where('expiresAt', isLessThan: now)
          .get();
      
      int deletedCount = 0;
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
        deletedCount++;
      }
      
      return deletedCount;
    } catch (e) {
      print('Error cleaning expired notifications: $e');
      return 0;
    }
  }
}
