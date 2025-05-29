// lib/models/auth_notifier.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart' as auth_service;
import 'users.dart';

class AuthNotifier with ChangeNotifier {
  final auth_service.AuthService _authService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  fb_auth.User? _firebaseUser;
  User? _appUser;

  bool _isLoading = false;
  String? _errorMessage;

  // --- NEW: Temporary storage for sign-up details ---
  String? _pendingUserName;
  UserRole? _pendingUserRole;

  StreamSubscription<fb_auth.User?>? _authStateSubscription;

  // ... (Your existing getters) ...
  fb_auth.User? get currentUser => _firebaseUser;
  User? get appUser => _appUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _firebaseUser != null;

  AuthNotifier(this._authService) {
    // ... (Your existing constructor logic) ...
    _authStateSubscription = _authService.authStateChanges.listen(
      _onAuthStateChanged,
    );
    _firebaseUser = _authService.currentUser;
    if (_firebaseUser != null) {
      _loadUserProfile(_firebaseUser!.uid);
    }
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        _appUser = User.fromMap(docSnapshot.data()!, uid);
      } else {
        // --- UPDATED: Use pending details if available, otherwise default ---
        _appUser = User(
          id: uid,
          name: _pendingUserName ?? _firebaseUser?.displayName ?? 'New User',
          email: _firebaseUser?.email ?? '',
          role: _pendingUserRole ?? UserRole.student, // Use pending role!
          profilePictureUrl: _firebaseUser?.photoURL,
          registrationDate:
              _firebaseUser?.metadata.creationTime ?? DateTime.now(),
          lastLogin: _firebaseUser?.metadata.lastSignInTime ?? DateTime.now(),
        );

        if (_appUser != null) {
          await _firestore.collection('users').doc(uid).set(_appUser!.toMap());
          print(
            'New user profile created and saved to Firestore for UID: $uid',
          );
        }

        // Clear pending details after use
        _pendingUserName = null;
        _pendingUserRole = null;
      }
    } catch (e) {
      _appUser = null;
      print("Error loading or creating user profile: $e");
    }
    notifyListeners();
  }

  void _onAuthStateChanged(fb_auth.User? user) {
    // ... (existing logic) ...
    _firebaseUser = user;
    _isLoading = false;
    _errorMessage = null;

    if (user != null) {
      _loadUserProfile(user.uid);
    } else {
      _appUser = null;
      notifyListeners();
    }
  }

  // --- UPDATED: signUp method signature ---
  Future<bool> signUp(
    String email,
    String password,
    String name,
    UserRole role,
  ) async {
    _setLoading(true);
    _clearError();
    try {
      // --- NEW: Store name and role before calling Firebase ---
      _pendingUserName = name;
      _pendingUserRole = role;

      // The actual Firebase sign up still only needs email and password
      final fb_auth.User? user = await _authService.signUpWithEmailAndPassword(
        email,
        password,
      );

      // Also update the Firebase Auth profile immediately if possible
      if (user != null && user.displayName == null) {
        await user.updateProfile(displayName: name);
      }

      _setLoading(false);
      if (user != null) {
        return true;
      } else {
        _setErrorMessage('Sign up failed. Please try again.');
        // Clear pending details on failure
        _pendingUserName = null;
        _pendingUserRole = null;
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setErrorMessage(e.toString());
      // Clear pending details on failure
      _pendingUserName = null;
      _pendingUserRole = null;
      return false;
    }
  }

  // ... (Rest of your AuthNotifier code: signIn, signOut, helpers, dispose) ...
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      final fb_auth.User? user = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );
      _setLoading(false);
      if (user != null) {
        return true;
      } else {
        _setErrorMessage('Sign in failed. Please check your credentials.');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setErrorMessage(e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);

    await _authService.signOut();
    _setLoading(false);
  }

  Future<bool> updateUserProfileData(User userProfileToSave) async {
    if (_firebaseUser == null) {
      _setErrorMessage("User not authenticated.");
      return false;
    }
    _setLoading(true);
    _clearError();
    try {
      if (_firebaseUser!.displayName != userProfileToSave.name ||
          _firebaseUser!.photoURL != userProfileToSave.profilePictureUrl) {
        await _firebaseUser!.updateProfile(
          displayName: userProfileToSave.name,
          photoURL: userProfileToSave.profilePictureUrl,
        );
        _firebaseUser = _authService.currentUser;
      }

      await _firestore
          .collection('users')
          .doc(userProfileToSave.id)
          .set(userProfileToSave.toMap(), SetOptions(merge: true));

      _appUser = userProfileToSave;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setLoading(false);
      _setErrorMessage("Failed to update profile: ${e.toString()}");
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  register(String text, String text2) {}
}
