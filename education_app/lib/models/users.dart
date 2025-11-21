// lib/models/users.dart
// This file now contains a simplified User model and a basic AuthService
// without Firebase dependencies.

// Define UserRole enum - this should be the single source of truth for UserRole
// O'ZGARISH: Eski rollar olib tashlandi
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
    return UserRole.xodim; // O'ZGARISH: Standart rol 'xodim'
  }
  try {
    return UserRole.values.firstWhere(
      (e) =>
          e.toString().split('.').last.toLowerCase() ==
          roleString.toLowerCase(),
      orElse: () => UserRole.xodim, // O'ZGARISH: Standart rol 'xodim'
    );
  } catch (e) {
    return UserRole.xodim; // O'ZGARISH: Standart rol 'xodim'
  }
}

String userRoleToString(UserRole? role) {
  return role?.toString().split('.').last ??
      'xodim'; // O'ZGARISH: Standart rol 'xodim'
}

class User {
  final String id; // This should be Firebase UID
  String name;
  String? email;
  String? username; // --- NEW ---
  UserRole role;
  String? profilePictureUrl;
  String? bio;
  DateTime? registrationDate;
  DateTime? lastLogin;

  // Existing constructor
  User({
    required this.id,
    required this.name,
    this.email,
    this.username, // --- NEW ---
    required this.role,
    this.profilePictureUrl,
    this.bio,
    this.registrationDate,
    this.lastLogin,
  });

  // Getters that were present in the profile_edit_screen.dart's version of User
  // but might conflict if firebase_auth.User is also in scope with the same names.
  // For clarity, if these are intended to be different from firebase_auth.User properties,
  // ensure distinct naming or clear context.
  // For now, assuming these are the fields of this custom User model.
  String? get photoURL => profilePictureUrl; // Example mapping if needed
  String? get displayName => name; // Example mapping if needed

  // Convert User object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id':
          id, // Good to store it in the document too, though doc ID is the UID
      'name': name,
      'email': email,
      'username': username, // --- NEW ---
      'role': userRoleToString(role), // Store enum as string
      'profilePictureUrl': profilePictureUrl,
      'bio': bio,
      'registrationDate':
          registrationDate
              ?.toIso8601String(), // O'ZGARISH: toIso8601String bo'lishi kerak
      'lastLogin':
          lastLogin
              ?.toIso8601String(), // O'ZGARISH: toIso8601String bo'lishi kerak
    };
  }

  // Create a User object from a Firestore map
  factory User.fromMap(Map<String, dynamic> map, String documentId) {
    return User(
      id: documentId, // Use documentId as the User's id (which is Firebase UID)
      name: map['name'] ?? '',
      email: map['email'] as String?,
      username: map['username'] as String?, // --- NEW ---
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
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? username,
    UserRole? role,
    String? profilePictureUrl,
    String? bio,
    DateTime? registrationDate,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      role: role ?? this.role,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bio: bio ?? this.bio,
      registrationDate: registrationDate ?? this.registrationDate,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
