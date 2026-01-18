import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart';
import 'package:sud_qollanma/features/auth/domain/repositories/auth_repository.dart';
import 'package:sud_qollanma/features/gamification/domain/usecases/gamification_usecases.dart';

class AuthNotifier with ChangeNotifier {
  final AuthRepository _authRepository;
  final UpdateStreak _updateStreak;
  
  AppUser? _currentUser;
  
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<AppUser?>? _userSubscription;

  AuthNotifier(this._authRepository, this._updateStreak) {
    _authRepository.authStateChanges.listen(_onAuthStateChanged);
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AppUser? get appUser => _currentUser;
  AppUser? get currentUser => _currentUser; // Alias for legacy support
  bool get isAuthenticated => _currentUser != null;

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

  void _onAuthStateChanged(AppUser? user) {
    _setLoading(true);
    _clearError();
    _currentUser = user;

    if (user == null) {
      _userSubscription?.cancel();
    } else {
      // Subscribe to real-time updates for the logged in user
      _subscribeToUserProfile(user.id);
    }
    _setLoading(false);
  }

  void _subscribeToUserProfile(String uid) {
    _userSubscription?.cancel();
    _userSubscription = _authRepository.getUserProfileStream(uid).listen(
      (appUser) {
        if (appUser != null) {
          _currentUser = appUser;
          notifyListeners();
        }
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

  // --- Methods ---

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final appUser = await _authRepository.signInWithGoogle();
      if (appUser != null) {
        _currentUser = appUser;
        // Trigger streak update
        try {
          await _updateStreak(appUser.id);
        } catch (e) {
          debugPrint('Streak update failed: $e');
        }
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

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final appUser = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (appUser != null) {
        _currentUser = appUser;
        // Trigger streak update
        try {
          await _updateStreak(appUser.id);
        } catch (e) {
          debugPrint('Streak update failed: $e');
        }
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

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final appUser = await _authRepository.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      if (appUser != null) {
        _currentUser = appUser;
        // Trigger streak update
        try {
          await _updateStreak(appUser.id);
        } catch (e) {
          debugPrint('Streak update failed: $e');
        }
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

  Future<bool> updateUserProfile(AppUser updatedUser) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      await _authRepository.updateUserProfile(updatedUser);
      _currentUser = updatedUser;
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
    await _authRepository.signOut();
    _setLoading(false);
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      await _authRepository.changePassword(
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
