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
      role: role ?? this.role,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bio: bio ?? this.bio,
      registrationDate: registrationDate ?? this.registrationDate,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

// The AuthService below is the non-Firebase version.
// We will primarily use the Firebase-based AuthService from 'lib/services/auth_service.dart'
// for actual authentication, but this User model is what we'll adapt for Firestore profile data.

class AuthService {
  User? _currentUser;

  Stream<User?> get authStateChanges async* {
    await Future.delayed(const Duration(milliseconds: 50));
    yield _currentUser;
  }

  User? get currentUser => _currentUser;

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    if (email == "test@example.com" && password == "password") {
      _currentUser = User(
        id: 'u2',
        name: 'Samadov Ubaydulla',
        email: 'samadov@example.com',
        role: UserRole.xodim, // O'ZGARISH: Standart rol 'xodim'
        profilePictureUrl: 'assets/images/my_pic.jpg',
        lastLogin: DateTime.now(),
        registrationDate: DateTime.now().subtract(const Duration(days: 10)),
      );
      return _currentUser;
    }
    throw Exception("Invalid credentials (dummy check)");
  }

  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    _currentUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      role: UserRole.xodim, // O'ZGARISH: Standart rol 'xodim'
      registrationDate: DateTime.now(),
      lastLogin: DateTime.now(),
    );
    return _currentUser;
  }

  Future<void> signOut() async {
    _currentUser = null;
  }

  Future<void> updateUserProfile(User updatedUser) async {
    if (_currentUser != null && _currentUser!.id == updatedUser.id) {
      _currentUser = updatedUser;
    } else {
      throw Exception("User not found or ID mismatch for local update.");
    }
  }
}

// --- Additional UserModel for other use cases (e.g., simple user info) ---
class UserModel {
  final String uid;
  final String email;
  String firstName;
  String lastName;

  UserModel({
    required this.uid,
    required this.email,
    this.firstName = '',
    this.lastName = '',
  });

  // Factory constructor to create a UserModel from a map (e.g., from Firestore)
  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
    );
  }

  // Method to convert a UserModel to a map (e.g., for writing to Firestore)
  Map<String, dynamic> toMap() {
    return {'email': email, 'firstName': firstName, 'lastName': lastName};
  }
}
