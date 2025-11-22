// lib/models/users.dart
// This file now contains a simplified User model and a basic AuthService
// without Firebase dependencies.

// Define UserRole enum - this should be the single source of truth for UserRole
enum UserRole {
  xodim,
  ekspert,
  admin,
  teacher,
  student,
  // Add other roles as needed
}

// Helper to convert string to UserRole and vice-versa
UserRole stringToUserRole(String? roleString) {
  if (roleString == null) {
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

String userRoleToString(UserRole? role) {
  return role?.toString().split('.').last ?? 'xodim';
}

class AppUser {
  final String id; // This should be Firebase UID
  String name;
  String? email;
  String? username;
  UserRole role;
  String? profilePictureUrl;
  String? bio;
  DateTime? registrationDate;
  DateTime? lastLogin;
  int xp;
  String level;

  // Existing constructor
  AppUser({
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
  });

  // Create a AppUser object from a Firestore map
  factory AppUser.fromMap(Map<String, dynamic> map, String documentId) {
    return AppUser(
      id: documentId, // Use documentId as the User's id (which is Firebase UID)
      name: map['name'] ?? '',
      email: map['email'] as String?,
      username: map['username'] as String?,
      role: stringToUserRole(map['role'] as String?),
      profilePictureUrl: map['profilePictureUrl'] as String?,
      bio: map['bio'] as String?,
      registrationDate:
          map['registrationDate'] != null
              ? DateTime.tryParse(map['registrationDate'] as String)
              : null,
      lastLogin:
          map['lastLogin'] != null
              ? DateTime.tryParse(map['lastLogin'] as String)
              : null,
      xp: map['xp'] ?? 0,
      level: map['level'] ?? 'Boshlang\'ich',
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
    };
  }

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
    );
  }

  // Helper to calculate level based on XP
  static String getLevelFromXP(int xp) {
    if (xp >= 1000) return 'Ekspert';
    if (xp >= 500) return 'Yuqori';
    if (xp >= 100) return 'O\'rta';
    return 'Boshlang\'ich';
  }
}
