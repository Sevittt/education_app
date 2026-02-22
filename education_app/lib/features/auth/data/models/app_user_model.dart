import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.id,
    required super.name,
    super.email,
    super.username,
    required super.role,
    super.profilePictureUrl,
    super.bio,
    super.registrationDate,
    super.lastLogin,
    super.xp = 0,
    super.level = 'Boshlang\'ich',
    super.quizzesPassed = 0,
    super.totalQuizzesAced = 0,
    super.simulationsCompleted = 0,
    super.currentStreak = 0,
    super.lastLoginDate,
    super.fastestQuizTime,
  });

  factory AppUserModel.fromEntity(AppUser user) {
    return AppUserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      username: user.username,
      role: user.role,
      profilePictureUrl: user.profilePictureUrl,
      bio: user.bio,
      registrationDate: user.registrationDate,
      lastLogin: user.lastLogin,
      xp: user.xp,
      level: user.level,
      quizzesPassed: user.quizzesPassed,
      totalQuizzesAced: user.totalQuizzesAced,
      simulationsCompleted: user.simulationsCompleted,
      currentStreak: user.currentStreak,
      lastLoginDate: user.lastLoginDate,
      fastestQuizTime: user.fastestQuizTime,
    );
  }

  factory AppUserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AppUserModel(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] as String?,
      username: map['username'] as String?,
      role: stringToUserRole(map['role'] as String?),
      profilePictureUrl: map['profilePictureUrl'] as String?,
      bio: map['bio'] as String?,
      registrationDate: map['registrationDate'] != null
          ? DateTime.tryParse(map['registrationDate'] as String)
          : null,
      lastLogin: map['lastLogin'] != null
          ? DateTime.tryParse(map['lastLogin'] as String)
          : null,
      xp: map['xp'] ?? 0,
      level: map['level'] ?? 'Boshlang\'ich',
      quizzesPassed: map['quizzesPassed'] ?? 0,
      totalQuizzesAced: map['totalQuizzesAced'] ?? 0,
      simulationsCompleted: map['simulationsCompleted'] ?? 0,
      currentStreak: map['currentStreak'] ?? 0,
      lastLoginDate: map['lastLoginDate'] != null
          ? DateTime.tryParse(map['lastLoginDate'] as String)
          : null,
      fastestQuizTime: map['fastestQuizTime'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'role': userRoleToString(role),
      'profilePictureUrl': profilePictureUrl,
      'bio': bio,
      'registrationDate': registrationDate?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'xp': xp,
      'level': level,
      'quizzesPassed': quizzesPassed,
      'totalQuizzesAced': totalQuizzesAced,
      'simulationsCompleted': simulationsCompleted,
      'currentStreak': currentStreak,
      'lastLoginDate': lastLoginDate?.toIso8601String(),
      'fastestQuizTime': fastestQuizTime,
    };
  }

  static UserRole stringToUserRole(String? roleString) {
    if (roleString == null) {
      return UserRole.xodim;
    }

    // Backward compatibility for legacy roles
    if (roleString.toLowerCase() == 'teacher') {
      return UserRole.ekspert;
    }
    if (roleString.toLowerCase() == 'student') {
      return UserRole.xodim;
    }

    try {
      return UserRole.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() ==
            roleString.toLowerCase(),
        orElse: () => UserRole.xodim,
      );
    } catch (e) {
      return UserRole.xodim;
    }
  }

  static String userRoleToString(UserRole? role) {
    return role?.toString().split('.').last ?? 'xodim';
  }
}
