import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum CourtRole {
  judge,
  assistant,
  chancellery,
  archive,
  // ignore: constant_identifier_names
  ict_specialist, // AKT xodimi (IT xodimi) — faqat o'quvchi huquqlari
  // ignore: constant_identifier_names
  admin, // Tizim admini — to'liq Admin Panel kirish huquqi
  unknown
}

class AppUser extends Equatable {
  final String id;
  final String name;
  final String? email;
  final String? username;
  final CourtRole role;
  final String? profilePictureUrl;
  final String? bio;
  final DateTime? registrationDate;
  final DateTime? lastLogin;
  final int xp;
  final String level;
  final int quizzesPassed;
  final int totalQuizzesAced;
  final int simulationsCompleted;
  final int currentStreak;
  final DateTime? lastLoginDate;
  final int? fastestQuizTime;
  final int? previousRank;
  final bool notificationsEnabled;
  final String? fcmToken;

  // --- Court/Region fields (added for regional leaderboard support) ---
  final String? regionId;      // e.g. 'andijon_viloyati'
  final String? regionName;    // e.g. 'Andijon viloyati'
  final String? courtTypeId;   // e.g. 'jib'
  final String? courtTypeName; // e.g. 'Jinoyat ishlari bo\'yicha sudlar (JIB)'
  final String? courtId;       // e.g. 'andijon_viloyati_andijon_tuman_sudi'
  final String? courtName;     // e.g. 'Andijon tuman sudi'
  final String? position;      // e.g. 'Sudya', 'Devonxona mudiri'

  /// Returns true if the user has already selected their court.
  bool get hasCourtSelected => courtId != null && courtId!.isNotEmpty;

  /// Returns true only for system administrators (role == admin).
  /// AKT xodimi (ict_specialist) does NOT have admin access.
  bool get isAdmin => role == CourtRole.admin;

  const AppUser({
    required this.id,
    required this.name,
    this.email,
    this.username,
    required this.role,
    this.profilePictureUrl,
    this.bio,
    this.registrationDate,
    this.lastLogin,
    this.xp = 0,
    this.level = 'levelBeginner',
    this.quizzesPassed = 0,
    this.totalQuizzesAced = 0,
    this.simulationsCompleted = 0,
    this.currentStreak = 0,
    this.lastLoginDate,
    this.fastestQuizTime,
    this.previousRank,
    this.notificationsEnabled = true,
    this.fcmToken,
    this.regionId,
    this.regionName,
    this.courtTypeId,
    this.courtTypeName,
    this.courtId,
    this.courtName,
    this.position,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? username,
    CourtRole? role,
    String? profilePictureUrl,
    String? bio,
    DateTime? registrationDate,
    DateTime? lastLogin,
    int? xp,
    String? level,
    int? quizzesPassed,
    int? totalQuizzesAced,
    int? simulationsCompleted,
    int? currentStreak,
    DateTime? lastLoginDate,
    int? fastestQuizTime,
    int? previousRank,
    bool? notificationsEnabled,
    String? fcmToken,
    String? regionId,
    String? regionName,
    String? courtTypeId,
    String? courtTypeName,
    String? courtId,
    String? courtName,
    String? position,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      role: role ?? this.role,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bio: bio ?? this.bio,
      registrationDate: registrationDate ?? this.registrationDate,
      lastLogin: lastLogin ?? this.lastLogin,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      quizzesPassed: quizzesPassed ?? this.quizzesPassed,
      totalQuizzesAced: totalQuizzesAced ?? this.totalQuizzesAced,
      simulationsCompleted: simulationsCompleted ?? this.simulationsCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      fastestQuizTime: fastestQuizTime ?? this.fastestQuizTime,
      previousRank: previousRank ?? this.previousRank,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      fcmToken: fcmToken ?? this.fcmToken,
      regionId: regionId ?? this.regionId,
      regionName: regionName ?? this.regionName,
      courtTypeId: courtTypeId ?? this.courtTypeId,
      courtTypeName: courtTypeName ?? this.courtTypeName,
      courtId: courtId ?? this.courtId,
      courtName: courtName ?? this.courtName,
      position: position ?? this.position,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        username,
        role,
        profilePictureUrl,
        bio,
        registrationDate,
        lastLogin,
        xp,
        level,
        quizzesPassed,
        totalQuizzesAced,
        simulationsCompleted,
        currentStreak,
        lastLoginDate,
        fastestQuizTime,
        previousRank,
        notificationsEnabled,
        fcmToken,
        regionId,
        regionName,
        courtTypeId,
        courtTypeName,
        courtId,
        courtName,
        position,
      ];
  /// XP thresholds for each level:
  ///   0–99    → Boshlang'ich (Beginner)
  ///   100–499 → O'rta (Intermediate)
  ///   500–999 → Ilg'or (Advanced)
  ///   1000–1999 → Mutaxassis (Specialist)
  ///   2000–4999 → Ekspert (Expert)
  ///   5000+   → Usta/Master (Master)
  static String getLevelFromXP(int xp) {
    if (xp >= 5000) return 'levelMaster';
    if (xp >= 2000) return 'levelExpert';
    if (xp >= 1000) return 'levelSpecialist';
    if (xp >= 500) return 'levelAdvanced';
    if (xp >= 100) return 'levelIntermediate';
    return 'levelBeginner';
  }

  static int xpToNextLevel(int xp) {
    if (xp >= 5000) return 0; // Max level
    if (xp >= 2000) return 5000 - xp;
    if (xp >= 1000) return 2000 - xp;
    if (xp >= 500) return 1000 - xp;
    if (xp >= 100) return 500 - xp;
    return 100 - xp;
  }

  /// Calculates the progress (0.0 to 1.0) towards the next level.
  static double getLevelProgress(int xp) {
    if (xp >= 5000) return 1.0;
    
    int currentLevelBaseXp = 0;
    int nextLevelMaxXp = 100;

    if (xp >= 2000) {
      currentLevelBaseXp = 2000;
      nextLevelMaxXp = 5000;
    } else if (xp >= 1000) {
      currentLevelBaseXp = 1000;
      nextLevelMaxXp = 2000;
    } else if (xp >= 500) {
      currentLevelBaseXp = 500;
      nextLevelMaxXp = 1000;
    } else if (xp >= 100) {
      currentLevelBaseXp = 100;
      nextLevelMaxXp = 500;
    }

    final xpInCurrentLevel = xp - currentLevelBaseXp;
    final totalXpForCurrentLevel = nextLevelMaxXp - currentLevelBaseXp;
    return (xpInCurrentLevel / totalXpForCurrentLevel).clamp(0.0, 1.0);
  }
}

extension AppUserLevelExt on String {
  /// Returns the localized label for the level.
  String get levelLabel {
    switch (this) {
      case 'levelMaster':
        return 'Usta';
      case 'levelExpert':
        return 'Ekspert';
      case 'levelSpecialist':
        return 'Mutaxassis';
      case 'levelAdvanced':
        return 'Ilg\'or';
      case 'levelIntermediate':
        return 'O\'rta';
      case 'levelBeginner':
      default:
        return 'Boshlang\'ich';
    }
  }

  /// Returns the UI badge icon string for the level.
  String get levelBadge {
    switch (this) {
      case 'levelMaster':
        return '👑';
      case 'levelExpert':
        return '✦';
      case 'levelSpecialist':
        return '◈';
      case 'levelAdvanced':
        return '★';
      case 'levelIntermediate':
        return '●';
      case 'levelBeginner':
      default:
        return '○';
    }
  }

  /// Returns the color associated with the level.
  Color get levelColor {
    switch (this) {
      case 'levelMaster':
        return const Color(0xFFC9A84C); // AppColors.amber
      case 'levelExpert':
        return const Color(0xFF27AE7A); // AppColors.success
      case 'levelSpecialist':
        return const Color(0xFF0284C7); // AppColors.info
      case 'levelAdvanced':
        return const Color(0xFFFBBF24); // AppColors.goldPodium
      case 'levelIntermediate':
        return const Color(0xFFCBD5E1); // AppColors.silverPodium
      case 'levelBeginner':
      default:
        return const Color(0xFFCD853F); // AppColors.bronzePodium
    }
  }
}
