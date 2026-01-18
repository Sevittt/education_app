import 'package:equatable/equatable.dart';

enum UserRole {
  xodim,
  ekspert,
  admin,
}

class AppUser extends Equatable {
  final String id;
  final String name;
  final String? email;
  final String? username;
  final UserRole role;
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
    this.level = 'Boshlang\'ich',
    this.quizzesPassed = 0,
    this.totalQuizzesAced = 0,
    this.simulationsCompleted = 0,
    this.currentStreak = 0,
    this.lastLoginDate,
    this.fastestQuizTime,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? username,
    UserRole? role,
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
      ];
}
