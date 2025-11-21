// lib/models/auth_notifier.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:sud_qollanma/services/auth_service.dart';
import 'package:sud_qollanma/services/profile_service.dart';
import 'users.dart';

class AuthNotifier with ChangeNotifier {
  final AuthService _authService;
  final ProfileService _profileService; // --- NEW ---
  firebase_auth.User? _currentUser;
  User? _appUser;
  bool _isLoading = false;
  String? _errorMessage;

  // --- MODIFIED: Constructor now accepts ProfileService ---
  AuthNotifier(this._authService, this._profileService) {
    _authService.authStateChanges.listen(_onAuthStateChanged);
    // --- MODIFIED: Check current user on init ---
    _currentUser = _authService.currentUser;
    if (_currentUser != null) {
      _loadUserProfile(_currentUser!.uid);
    }
  }

  // --- Getters ---
  firebase_auth.User? get currentUser => _currentUser;
  User? get appUser => _appUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // --- MODIFIED: Simplified user profile loading ---
  Future<void> _loadUserProfile(String uid) async {
    try {
      // Use ProfileService to get the user profile
      _appUser = await _profileService.getUserProfile(uid);
    } catch (e) {
      _appUser = null;
    }
    notifyListeners();
  }

  // --- MODIFIED: Simplified auth state change handler ---
  void _onAuthStateChanged(firebase_auth.User? user) {
    _currentUser = user;
    _isLoading = false;
    _clearError();

    if (user == null) {
      // This handles sign-out.
      _appUser = null;
    } else if (_appUser == null || _appUser!.id != user.uid) {
      // This handles the initial app load where a user is already signed in.
      _loadUserProfile(user.uid);
    }
    notifyListeners();
  }

  // --- NEW: Sign in with Google Notifier Method ---
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    try {
      final appUser = await _authService.signInWithGoogle();
      if (appUser != null) {
        _appUser = appUser; // Set the user
        _setLoading(false);
        return true;
      } else {
        // User cancelled the flow
        _setLoading(false);
        return false;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setErrorMessage(e.message ?? 'An unknown error occurred.');
      _setLoading(false);
      return false;
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }
  // --- END NEW ---

  // --- OLD SIGN IN (Reverted to primary) ---
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (user != null) {
        _appUser = user;
      } else {
        throw Exception('Failed to load user profile after sign-in.');
      }
      _setLoading(false);
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setErrorMessage(e.message ?? 'An unknown error occurred.');
      _setLoading(false);
      return false;
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // --- MODIFIED: Replaced signUp with a cleaner register method ---
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final appUser = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      if (appUser != null) {
        _appUser = appUser; // --- NEW: Set user immediately after registration
        _setLoading(false);
        return true;
      } else {
        _setErrorMessage('Registration failed.');
        _setLoading(false);
        return false;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      // --- MODIFIED: Removed username error check ---
      if (e.code == 'email-already-in-use') {
        _setErrorMessage('This email is already in use by another account.');
      } else {
        _setErrorMessage(e.message ?? 'An unknown error occurred.');
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    // The listener _onAuthStateChanged will be triggered by this
    // and will set _currentUser and _appUser to null.
    await _authService.signOut();
    _setLoading(false);
  }

  Future<bool> updateUserProfileData(User userProfileToSave) async {
    if (_currentUser == null) {
      _setErrorMessage("User not authenticated.");
      return false;
    }
    _setLoading(true);
    _clearError();
    try {
      // Use the service to update the profile
      await _profileService.updateCurrentUserProfile(userProfileToSave);
      await _currentUser?.updateDisplayName(userProfileToSave.name);

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
    // The stream controller within AuthService will handle closing.
    super.dispose();
  }
}
