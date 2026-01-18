import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  
  Future<AppUser?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required UserRole role,
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
}
