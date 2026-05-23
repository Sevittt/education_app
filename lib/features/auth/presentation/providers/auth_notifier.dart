import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart';
import 'package:sud_qollanma/features/auth/domain/repositories/auth_repository.dart';
import 'package:sud_qollanma/features/gamification/domain/usecases/gamification_usecases.dart';
import 'package:sud_qollanma/core/services/fcm_service.dart';

class AuthNotifier with ChangeNotifier {
  final AuthRepository _authRepository;
  final UpdateStreak _updateStreak;

  AppUser? _currentUser;

  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  StreamSubscription<AppUser?>? _userSubscription;

  AuthNotifier(this._authRepository, this._updateStreak) {
    _authRepository.authStateChanges.listen(_onAuthStateChanged);
  }

  // Getters
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
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
      _subscribeToUserProfile(user.id);
    }
    _isInitialized = true;
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
        try {
          await _updateStreak(appUser.id);
        } catch (e) {
          debugPrint('Streak update failed: $e');
        }
        try {
          await FcmService.instance.saveTokenForUser(appUser.id);
        } catch (e) {
          debugPrint('FCM token save failed: $e');
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
        try {
          await _updateStreak(appUser.id);
        } catch (e) {
          debugPrint('Streak update failed: $e');
        }
        try {
          await FcmService.instance.saveTokenForUser(appUser.id);
        } catch (e) {
          debugPrint('FCM token save failed: $e');
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
    required CourtRole role,
    String? courtId,
    String? courtName,
    String? courtTypeId,
    String? courtTypeName,
    String? regionId,
    String? regionName,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final appUser = await _authRepository.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: role,
        courtId: courtId,
        courtName: courtName,
        courtTypeId: courtTypeId,
        courtTypeName: courtTypeName,
        regionId: regionId,
        regionName: regionName,
      );
      if (appUser != null) {
        _currentUser = appUser;
        try {
          await _updateStreak(appUser.id);
        } catch (e) {
          debugPrint('Streak update failed: $e');
        }
        try {
          await FcmService.instance.saveTokenForUser(appUser.id);
        } catch (e) {
          debugPrint('FCM token save failed: $e');
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
    if (_currentUser != null) {
      try {
        await FcmService.instance.clearTokenForUser(_currentUser!.id);
      } catch (e) {
        debugPrint('FCM token clear failed: $e');
      }
    }
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

  Future<void> updateUserXP(int xpToAdd) async {
    if (_currentUser == null) return;

    final int currentXP = _currentUser!.xp;
    final int newXP = currentXP + xpToAdd;
    final String newLevel = AppUser.getLevelFromXP(newXP);

    // Optimistic update
    final updatedUser = _currentUser!.copyWith(xp: newXP, level: newLevel);
    _currentUser = updatedUser;
    notifyListeners();

    try {
      await _authRepository.updateUserXP(updatedUser.id, newXP, newLevel);
    } catch (e) {
      debugPrint("Error updating XP: $e");
    }
  }

  /// Updates the court selection for the current user (mandatory for existing users).
  Future<bool> updateUserCourt({
    required String courtId,
    required String courtName,
    required String courtTypeId,
    required String courtTypeName,
    required String regionId,
    required String regionName,
  }) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    _setErrorMessage(null);
    try {
      await _authRepository.updateUserCourt(
        userId: _currentUser!.id,
        courtId: courtId,
        courtName: courtName,
        courtTypeId: courtTypeId,
        courtTypeName: courtTypeName,
        regionId: regionId,
        regionName: regionName,
      );
      // Optimistic local update
      _currentUser = _currentUser!.copyWith(
        courtId: courtId,
        courtName: courtName,
        courtTypeId: courtTypeId,
        courtTypeName: courtTypeName,
        regionId: regionId,
        regionName: regionName,
      );
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setErrorMessage('Sudni saqlashda xatolik: $e');
      _setLoading(false);
      return false;
    }
  }
}
