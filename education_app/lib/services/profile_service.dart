// lib/services/profile_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'users'; // Collection name for user profiles

  // Save or update user profile data
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection(_collectionPath)
          .doc(userId)
          .set(
            data,
            SetOptions(
              merge: true,
            ), // Use merge:true to update existing fields or create if not exists
          );
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user profile in Firestore: $e');
      }
      // Re-throw the exception to be handled by the caller
      rethrow;
    }
  }

  // Fetch user profile data
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(
    String userId,
  ) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> profileDoc =
          await _firestore.collection(_collectionPath).doc(userId).get();
      return profileDoc;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user profile from Firestore: $e');
      }
      // Re-throw the exception to be handled by the caller
      rethrow;
    }
  }

  // Optional: Stream for real-time profile updates (if needed elsewhere)
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserProfileStream(
    String userId,
  ) {
    return _firestore.collection(_collectionPath).doc(userId).snapshots();
  }
}
