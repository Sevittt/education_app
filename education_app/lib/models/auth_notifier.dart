import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import 'users.dart'; // Bizning Custom User modelimiz

class AuthNotifier with ChangeNotifier {
  final AuthService _authService;
  final ProfileService _profileService;
  
  firebase_auth.User? _currentUser; // Firebase User
  AppUser? _appUser; // Bizning Custom User
  
  bool _isLoading = false;
  String? _errorMessage;

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
    } else {
      await _loadUserProfile(user.uid);
    }
    _setLoading(false);
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      _appUser = await _profileService.getUserProfile(uid);
    } catch (e) {
      _setErrorMessage('Profilni yuklashda xatolik: $e');
      _appUser = null;
    }
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
}
