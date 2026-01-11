import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'dart:async'; // Added for StreamSubscription
import 'package:sud_qollanma/features/auth/data/datasources/auth_service.dart';
import 'package:sud_qollanma/services/profile_service.dart'; // Fixed path
import 'package:sud_qollanma/models/users.dart'; // Fixed path - Bizning Custom User modelimiz

class AuthNotifier with ChangeNotifier {
  final AuthService _authService;
  final ProfileService _profileService;
  
  firebase_auth.User? _currentUser; // Firebase User
  AppUser? _appUser; // Bizning Custom User
  
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<AppUser?>? _userSubscription; // Added subscription

  AuthNotifier(this._authService, this._profileService) {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  firebase_auth.User? get currentUser => _currentUser;
  AppUser? get appUser => _appUser;
  bool get isAuthenticated => _currentUser != null;

  // --- Helper Methods (Xatolikni tuzatish) ---
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _onAuthStateChanged(firebase_auth.User? user) async {
    _setLoading(true);
    _clearError();
    _currentUser = user;

    if (user == null) {
      _appUser = null;
      _userSubscription?.cancel(); // Cancel subscription on logout
    } else {
      // Use stream instead of one-time get
      _subscribeToUserProfile(user.uid);
    }
    _setLoading(false);
  }

  void _subscribeToUserProfile(String uid) {
    _userSubscription?.cancel(); // Cancel any existing subscription
    _userSubscription = _profileService.getUserProfileStream(uid).listen(
      (appUser) {
        _appUser = appUser;
        notifyListeners(); // Notify UI of updates (XP, Level, etc.)
      },
      onError: (e) {
        _setErrorMessage('Profilni yangilashda xatolik: $e');
      },
    );
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  // --- Google Sign In ---
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final appUser = await _authService.signInWithGoogle();
      if (appUser != null) {
        _appUser = appUser;
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setErrorMessage(e.message ?? 'Xatolik yuz berdi.');
      _setLoading(false);
      return false;
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // --- Email/Password Sign In ---
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final appUser = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (appUser != null) {
        _appUser = appUser;
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // --- Register ---
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final appUser = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      if (appUser != null) {
        _appUser = appUser;
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // --- Update Profile ---
  Future<bool> updateUserProfile(AppUser updatedUser) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      await _profileService.updateUserProfile(updatedUser);
      _appUser = updatedUser;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    await _authService.signOut();
    _setLoading(false);
  }

  // --- Change Password ---
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }
}
