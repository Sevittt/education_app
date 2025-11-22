// lib/services/profile_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart'; // For kDebugMode
import '../models/users.dart'; // Your custom AppUser model (not AppUserModel)

class ProfileService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  // --- MODIFIED: Use a direct CollectionReference for consistency ---
  final CollectionReference<Map<String, dynamic>> _usersCollection;

  ProfileService()
    : _usersCollection = FirebaseFirestore.instance.collection('users');

  // --- Existing methods like getCurrentAppUserProfile, updateCurrentAppUserProfile, etc. ---
  // --- MODIFIED: Return the main 'AppUser' model for consistency ---
  Future<AppUser?> getCurrentAppUserProfile() async {
    final firebase_auth.AppUser? currentAppUser = _auth.currentAppUser;
    if (currentAppUser == null) return null;

    try {
      final docSnapshot = await _usersCollection.doc(currentAppUser.uid).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        // Use the main AppUser.fromMap factory
        return AppUser.fromMap(docSnapshot.data()!, docSnapshot.id);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user profile: $e');
      }
    }
    return null;
  }

  // Assuming your main AppUser model is 'AppUser' from '../models/users.dart'
  Future<void> updateCurrentAppUserProfile(AppUser user) async {
    // Changed AppUserModel to AppUser
    final firebase_auth.AppUser? currentAppUser = _auth.currentAppUser;
    if (currentAppUser == null) return;

    try {
      await _usersCollection
          .doc(currentAppUser.uid)
          .update(user.toMap()); // Assuming AppUser model has toMap
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user profile: $e');
      }
      rethrow;
    }
  }

  // --- NEW METHOD ---
  /// Fetches a user's profile by their UID.
  /// Returns a AppUser object, or null if the user doesn't exist or an error occurs.
  Future<AppUser?> getAppUserProfile(String uid) async {
    try {
      final docSnapshot = await _usersCollection.doc(uid).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return AppUser.fromMap(docSnapshot.data()!, docSnapshot.id);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user profile for UID $uid: $e');
      }
    }
    // Return null if user not found or if there was an error
    return null;
  }

  // --- NEW METHOD: Get all users for Admin ---
  /// Fetches a stream of all user profiles. Intended for admin use.
  Stream<List<AppUser>> getAllAppUsersStream() {
    return _usersCollection
        .orderBy('registrationDate', descending: true) // Example order
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  // Use your main 'AppUser.fromMap' factory
                  return AppUser.fromMap(doc.data(), doc.id);
                } catch (e) {
                  if (kDebugMode) {
                    print(
                      "Error parsing user from Firestore doc ID ${doc.id}: $e. Skipping.",
                    );
                  }
                  // Return a special error object or null and filter later, or rethrow.
                  // For now, let's ensure it fails gracefully or filters out.
                  // To allow filtering, map to nullable and then filter:
                  return null;
                }
              })
              .where((user) => user != null)
              .cast<AppUser>()
              .toList(); // Filter out nulls and cast
        })
        .handleError((error) {
          if (kDebugMode) {
            print("Error in getAllUsersStream: $error");
          }
          throw error; // Propagate error to StreamBuilder
        });
  }

  // --- Keep your other existing methods from ProfileService ---
  // Future<void> updateUserProfileById ...
  // Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfileById ...
  // Stream<DocumentSnapshot<Map<String, dynamic>>> getUserProfileStream ...
  // updateUserProfile(UserModel updatedUser) {} // This seems like a duplicate or should use User
  // getUserProfile() {} // This seems like a placeholder or incomplete
}
