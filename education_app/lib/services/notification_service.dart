// lib/services/notification_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_notification.dart';

/// Notification Service
/// 
/// Push notifications, email va in-app xabarnomalarni boshqarish
/// 
/// IMPORTANT: 
/// - Push notifications uchun Firebase Cloud Messaging (FCM) kerak
/// - Email uchun SendGrid yoki Firebase Extensions kerak
/// - Bu basic implementation, keyinchalik kengaytiriladi
class NotificationService {
  final CollectionReference<Map<String, dynamic>> _notificationsCollection =
      FirebaseFirestore.instance.collection('notifications');

  // ==========================================
  // READ OPERATIONS
  // ==========================================

  /// Foydalanuvchi uchun xabarnomalar (o'qilmagan va o'qilgan)
  Stream<List<AppNotification>> getUserNotifications(String userId) {
    return _notificationsCollection
        .where('targetAudience', whereIn: ['all', userId])
        .orderBy('sentAt', descending: true)
        .limit(50)  // Oxirgi 50 ta
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AppNotification.fromFirestore(doc))
          .where((notification) {
            // Muddati o'tmagan xabarnomalarni ko'rsatamiz
            return !notification.isExpired;
          })
          .toList();
    });
  }

  /// Faqat o'qilmagan xabarnomalar
  Stream<List<AppNotification>> getUnreadNotifications(String userId) {
    return getUserNotifications(userId).map((notifications) {
      return notifications.where((n) => !n.isReadBy(userId)).toList();
    });
  }

  /// O'qilmagan xabarnomalar soni
  Stream<int> getUnreadCount(String userId) {
    return getUnreadNotifications(userId).map((list) => list.length);
  }

  /// Bitta xabarnoma
  Future<AppNotification?> getNotificationById(String id) async {
    try {
      final doc = await _notificationsCollection.doc(id).get();
      if (!doc.exists) return null;
      return AppNotification.fromFirestore(doc);
    } catch (e) {
      print('Error getting notification: $e');
      return null;
    }
  }

  // ==========================================
  // WRITE OPERATIONS
  // ==========================================

  /// In-app notification yaratish
  Future<String?> createNotification({
    required String title,
    required String body,
    required NotificationType type,
    TargetAudience targetAudience = TargetAudience.all,
    String? relatedContentType,
    String? relatedContentId,
    String? imageUrl,
    String? actionUrl,
    DateTime? expiresAt,
  }) async {
    try {
      final notification = AppNotification(
        id: '',  // Firestore avtomatik generate qiladi
        title: title,
        body: body,
        type: type,
        targetAudience: targetAudience,
        relatedContentType: relatedContentType,
        relatedContentId: relatedContentId,
        imageUrl: imageUrl,
        actionUrl: actionUrl,
        sentAt: Timestamp.now(),
        expiresAt: expiresAt != null ? Timestamp.fromDate(expiresAt) : null,
        readBy: [],
      );

      return await sendNotification(notification);
    } catch (e) {
      print('Error creating notification: $e');
      return null;
    }
  }

  /// Xabarnoma yuborish (Object orqali)
  Future<String?> sendNotification(AppNotification notification) async {
    try {
      final docRef = await _notificationsCollection.add(notification.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error sending notification: $e');
      return null;
    }
  }

  /// Xabarnomani o'qilgan deb belgilash
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

  /// Barcha xabarnomalarni o'qilgan deb belgilash (Batch Write)
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

  /// Xabarnomani o'chirish
  Future<bool> deleteNotification(String id) async {
    try {
      await _notificationsCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  // ==========================================
  // PUSH NOTIFICATIONS (FCM)
  // ==========================================

  /// Push notification yuborish
  /// 
  /// IMPORTANT: Bu method Firebase Cloud Functions'da ishlatilishi kerak!
  /// Client-side'dan yuborish xavfsiz emas.
  /// 
  /// Firebase Functions example:
  /// ```
  /// exports.sendPushNotification = functions.https.onCall(async (data, context) => {
  ///   const message = {
  ///     notification: { title: data.title, body: data.body },
  ///     topic: data.targetAudience
  ///   };
  ///   return admin.messaging().send(message);
  /// });
  /// ```
  Future<void> sendPushNotification({
    required String title,
    required String body,
    required String targetAudience,
    Map<String, String>? data,
  }) async {
    // TODO: Cloud Functions orqali implement qilish kerak
    print('Push notification yuborildi: $title');
    print('IMPORTANT: Bu client-side mock. Cloud Functions kerak!');
  }

  // ==========================================
  // EMAIL NOTIFICATIONS
  // ==========================================

  /// Email xabarnoma yuborish
  /// 
  /// IMPORTANT: Bu ham Cloud Functions orqali ishlatiladi
  /// 
  /// SendGrid yoki Resend.com ishlatish mumkin
  Future<void> sendEmailNotification({
    required String to,
    required String subject,
    required String body,
    String? htmlBody,
  }) async {
    // TODO: Cloud Functions + SendGrid/Resend
    print('Email yuborildi: $to - $subject');
    print('IMPORTANT: Bu client-side mock. Cloud Functions kerak!');
  }

  // ==========================================
  // BULK OPERATIONS
  // ==========================================

  /// Ko'p foydalanuvchilarga xabarnoma
  Future<bool> sendBulkNotification({
    required String title,
    required String body,
    required NotificationType type,
    required List<String> userIds,
    String? relatedContentType,
    String? relatedContentId,
  }) async {
    try {
      // Har bir foydalanuvchi uchun notification yaratamiz
      // IMPORTANT: Katta hajm uchun Cloud Functions ishlatish kerak!
      
      for (final _ in userIds) {
        await createNotification(
          title: title,
          body: body,
          type: type,
          targetAudience: TargetAudience.specific,
          relatedContentType: relatedContentType,
          relatedContentId: relatedContentId,
        );
      }
      
      return true;
    } catch (e) {
      print('Error sending bulk notification: $e');
      return false;
    }
  }

  // ==========================================
  // STATISTICS
  // ==========================================

  /// Jami xabarnomalar soni
  Future<int> getTotalNotificationsCount() async {
    try {
      final snapshot = await _notificationsCollection.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting total count: $e');
      return 0;
    }
  }

  /// Active (muddati o'tmagan) xabarnomalar soni
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

  // ==========================================
  // ADMIN FUNCTIONS
  // ==========================================

  /// Muddati o'tgan xabarnomalarni tozalash
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
