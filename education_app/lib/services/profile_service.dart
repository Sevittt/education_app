import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/users.dart';

class ProfileService {
  final CollectionReference<Map<String, dynamic>> _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // --- NEW: Username va Email metodlari (Login uchun) ---
  Future<String?> getEmailFromUsername(String username) async {
    try {
      final querySnapshot = await _usersCollection
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) return null;
      return querySnapshot.docs.first.data()['email'] as String?;
    } catch (e) {
      if (kDebugMode) print("Error getEmailFromUsername: $e");
      return null;
    }
  }

  Future<bool> isUsernameUnique(String username) async {
    try {
      final querySnapshot = await _usersCollection
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      return false;
    }
  }
  // --- END NEW ---

  // --- NEW: Admin Dashboard uchun hamma userlarni olish ---
  Stream<List<AppUser>> getAllUsersStream() {
    return _usersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppUser.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
  // --- END NEW ---

  Future<AppUser?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _usersCollection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromMap(doc.data()!, uid);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print("Error fetching user profile: $e");
      return null;
    }
  }

  Future<void> updateUserProfile(AppUser user) async {
    await _usersCollection.doc(user.id).update(user.toMap());
  }
}
