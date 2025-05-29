// lib/services/profile_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart'; // For kDebugMode
import '../models/users.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final String _collectionPath = 'users';

  // --- UserModel-based: Get the current user's profile ---
  Future<UserModel?> getCurrentUserProfile() async {
    final firebase_auth.User? currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    try {
      final docSnapshot =
          await _firestore
              .collection(_collectionPath)
              .doc(currentUser.uid)
              .get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return UserModel.fromMap(docSnapshot.data()!, docSnapshot.id);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user profile: $e');
      }
    }
    return null;
  }

  // --- UserModel-based: Update the current user's profile ---
  Future<void> updateCurrentUserProfile(UserModel user) async {
    final firebase_auth.User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      await _firestore
          .collection(_collectionPath)
          .doc(currentUser.uid)
          .update(user.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user profile: $e');
      }
      rethrow;
    }
  }

  // --- Generic: Save or update any user profile data (by userId) ---
  Future<void> updateUserProfileById(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection(_collectionPath)
          .doc(userId)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user profile in Firestore: $e');
      }
      rethrow;
    }
  }

  // --- Generic: Fetch any user profile data (by userId) ---
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfileById(
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
      rethrow;
    }
  }

  // --- Optional: Stream for real-time profile updates (by userId) ---
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserProfileStream(
    String userId,
  ) {
    return _firestore.collection(_collectionPath).doc(userId).snapshots();
  }

  updateUserProfile(UserModel updatedUser) {}

  getUserProfile() {}
}
