import 'package:sud_qollanma/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sud_qollanma/features/auth/data/models/app_user_model.dart';
import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart';
import 'package:sud_qollanma/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Stream<AppUser?> get authStateChanges {
    return _remoteDataSource.authStateChanges; // Covariance allow AppUserModel to stream as AppUser
  }

  @override
  Future<AppUser?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    return await _remoteDataSource.registerWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
      role: role,
    );
  }

  @override
  Future<AppUser?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _remoteDataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    return await _remoteDataSource.signInWithGoogle();
  }

  @override
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _remoteDataSource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    return await _remoteDataSource.getCurrentUser();
  }

  @override
  Future<String?> getEmailFromUsername(String username) async {
    return await _remoteDataSource.getEmailFromUsername(username);
  }

  @override
  Future<bool> isUsernameUnique(String username) async {
    return await _remoteDataSource.isUsernameUnique(username);
  }

  @override
  Stream<List<AppUser>> getAllUsersStream() {
    return _remoteDataSource.getAllUsersStream();
  }

  @override
  Future<void> updateUserProfile(AppUser user) async {
    // Convert Entity to Model for data source
    final userModel = AppUserModel.fromEntity(user);
    await _remoteDataSource.updateUserProfile(userModel);
  }

  @override
  Stream<AppUser?> getUserProfileStream(String uid) {
    return _remoteDataSource.getUserProfileStream(uid);
  }

  @override
  Future<void> updateUserXP(String userId, int newXP, String newLevel) async {
    await _remoteDataSource.updateUserXP(userId, newXP, newLevel);
  }

  @override
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    await _remoteDataSource.updateUserRole(userId, newRole);
  }
}
