import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    super.level = 'levelBeginner',
    super.quizzesPassed = 0,
    super.totalQuizzesAced = 0,
    super.simulationsCompleted = 0,
    super.currentStreak = 0,
    super.lastLoginDate,
    super.fastestQuizTime,
    super.previousRank,
    super.notificationsEnabled = true,
    super.fcmToken,
    super.regionId,
    super.regionName,
    super.courtTypeId,
    super.courtTypeName,
    super.courtId,
    super.courtName,
    super.position,
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
      previousRank: user.previousRank,
      notificationsEnabled: user.notificationsEnabled,
      fcmToken: user.fcmToken,
      regionId: user.regionId,
      regionName: user.regionName,
      courtTypeId: user.courtTypeId,
      courtTypeName: user.courtTypeName,
      courtId: user.courtId,
      courtName: user.courtName,
      position: user.position,
    );
  }

  factory AppUserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AppUserModel(
      id: documentId,
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString(),
      username: map['username']?.toString(),
      role: stringToCourtRole(map['role']?.toString()),
      profilePictureUrl: map['profilePictureUrl']?.toString(),
      bio: map['bio']?.toString(),
      registrationDate: _parseDate(map['registrationDate']),
      lastLogin: _parseDate(map['lastLogin']),
      xp: _parseInt(map['xp']),
      level: _migrateLevel(map['level']?.toString()),
      quizzesPassed: _parseInt(map['quizzesPassed']),
      totalQuizzesAced: _parseInt(map['totalQuizzesAced']),
      simulationsCompleted: _parseInt(map['simulationsCompleted']),
      currentStreak: _parseInt(map['currentStreak']),
      lastLoginDate: _parseDate(map['lastLoginDate']),
      fastestQuizTime: _parseIntNull(map['fastestQuizTime']),
      previousRank: _parseIntNull(map['previousRank']),
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      fcmToken: map['fcmToken'] as String?,
      regionId: map['regionId'] as String?,
      regionName: map['regionName'] as String?,
      courtTypeId: map['courtTypeId'] as String?,
      courtTypeName: map['courtTypeName'] as String?,
      courtId: map['courtId'] as String?,
      courtName: map['courtName'] as String?,
      position: map['position'] as String?,
    );
  }

  static int? _parseIntNull(dynamic val) {
    if (val == null) return null;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val);
    return null;
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  static DateTime? _parseDate(dynamic dateVal) {
    if (dateVal == null) return null;
    if (dateVal is DateTime) return dateVal;
    if (dateVal is Timestamp) return dateVal.toDate();
    if (dateVal is int) {
      // Could be seconds or milliseconds. Assume milliseconds if very large.
      if (dateVal > 9999999999) {
        return DateTime.fromMillisecondsSinceEpoch(dateVal);
      }
      return DateTime.fromMillisecondsSinceEpoch(dateVal * 1000);
    }
    if (dateVal is String) return DateTime.tryParse(dateVal);
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'role': courtRoleToString(role),
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
      'previousRank': previousRank,
      'notificationsEnabled': notificationsEnabled,
      'fcmToken': fcmToken,
      'regionId': regionId,
      'regionName': regionName,
      'courtTypeId': courtTypeId,
      'courtTypeName': courtTypeName,
      'courtId': courtId,
      'courtName': courtName,
      'position': position,
    };
  }

  static CourtRole stringToCourtRole(String? roleString) {
    if (roleString == null) {
      return CourtRole.unknown;
    }

    final lowerRole = roleString.toLowerCase().trim();

    // --- Explicit admin mapping ---
    // Only the 'admin' string maps to full admin privileges.
    if (lowerRole == 'admin') {
      return CourtRole.admin;
    }

    // --- AKT xodimi / IT specialist mapping ---
    // These roles have learner-level access only, NOT admin.
    if (lowerRole == 'akt_xodimi' ||
        lowerRole == 'akt xodimi' ||
        lowerRole == 'ict_specialist') {
      return CourtRole.ict_specialist;
    }

    // --- Legacy role mappings ---
    if (lowerRole == 'ekspert' || lowerRole == 'teacher') {
      return CourtRole.judge;
    }
    if (lowerRole == 'xodim' ||
        lowerRole == 'student' ||
        lowerRole == 'tinglovchi') {
      return CourtRole.assistant;
    }

    // Try direct enum name match
    try {
      return CourtRole.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == lowerRole,
        orElse: () => CourtRole.unknown,
      );
    } catch (e) {
      return CourtRole.unknown;
    }
  }

  static String courtRoleToString(CourtRole? role) {
    if (role == null || role == CourtRole.unknown) {
      return 'unknown';
    }
    return role.toString().split('.').last;
  }

  /// Migrates legacy Uzbek-text level values stored in Firestore
  /// to the current localization key format used by [AppUser.getLevelFromXP].
  static String _migrateLevel(String? raw) {
    switch (raw) {
      case 'Boshlang\'ich':
      case 'Newbie':
      case 'levelBeginner':
        return 'levelBeginner';
      case 'O\'rta':
      case 'Intermediate':
      case 'levelIntermediate':
        return 'levelIntermediate';
      case 'Ilg\'or':
      case 'Yuqori':
      case 'Advanced':
      case 'levelAdvanced':
        return 'levelAdvanced';
      case 'Mutaxassis':
      case 'Specialist':
      case 'levelSpecialist':
        return 'levelSpecialist';
      case 'Ekspert':
      case 'Expert':
      case 'levelExpert':
        return 'levelExpert';
      case 'Usta (Master)':
      case 'Master':
      case 'levelMaster':
        return 'levelMaster';
      default:
        return 'levelBeginner';
    }
  }
}
