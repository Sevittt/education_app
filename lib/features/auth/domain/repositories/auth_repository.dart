import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;

  Future<AppUser?> registerWithEmailAndPassword({
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
  });

  Future<AppUser?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AppUser?> signInWithGoogle();

  Future<void> signOut();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<AppUser?> getCurrentUser();

  Future<String?> getEmailFromUsername(String username);

  Future<bool> isUsernameUnique(String username);

  Stream<List<AppUser>> getAllUsersStream();

  Future<void> updateUserProfile(AppUser user);

  Stream<AppUser?> getUserProfileStream(String uid);

  Future<void> updateUserXP(String userId, int newXP, String newLevel);

  Future<void> updateCourtRole(String userId, CourtRole newRole);

  /// Updates the court/region selection for an existing user.
  Future<void> updateUserCourt({
    required String userId,
    required String courtId,
    required String courtName,
    required String courtTypeId,
    required String courtTypeName,
    required String regionId,
    required String regionName,
  });
}
