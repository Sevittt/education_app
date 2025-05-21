// File: lib/models/users.dart
// This file now contains a simplified User model and a basic AuthService
// without Firebase dependencies.

// Define UserRole enum - this should be the single source of truth for UserRole
enum UserRole {
  student,
  teacher,
  admin,
  // Add other roles as needed
}

// Helper to convert string to UserRole and vice-versa
UserRole stringToUserRole(String? roleString) {
  if (roleString == null) return UserRole.student; // Default if null
  try {
    return UserRole.values.firstWhere(
      (e) =>
          e.toString().split('.').last.toLowerCase() ==
          roleString.toLowerCase(),
      orElse: () => UserRole.student, // Default if not found
    );
  } catch (e) {
    return UserRole.student; // Default on error
  }
}

String userRoleToString(UserRole? role) {
  return role?.toString().split('.').last ??
      'student'; // Default to 'student' string
}

class User {
  final String id; // Simple ID, not necessarily Firebase UID
  String name;
  String? email; // Optional
  UserRole role;
  String? profilePictureUrl; // Using the older field name
  String? bio; // Optional
  DateTime? registrationDate; // Optional
  DateTime? lastLogin; // Optional

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

  get photoURL => null;

  get displayName => null;

  // If you need to update user details locally, you might add a copyWith method:
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

// Basic AuthService without Firebase
// This is a placeholder. You'll need to adapt it to your app's pre-Firestore auth logic.
// For now, it will manage a single dummy user.
class AuthService {
  User? _currentUser;

  // Stream to notify about auth changes
  Stream<User?> get authStateChanges async* {
    // In a real pre-Firebase app, this might check shared_preferences
    await Future.delayed(
      const Duration(milliseconds: 50),
    ); // Simulate async check
    yield _currentUser;
  }

  User? get currentUser => _currentUser;

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    // Placeholder: In a real pre-Firebase app, you'd validate against local/dummy data
    // For now, let's assume a successful login with a dummy user if email matches.
    // IMPORTANT: This is NOT secure and only for reverting to a non-Firebase state.
    if (email == "test@example.com" && password == "password") {
      // Find the dummy user from dummy_data.dart or create one
      // This is a simplified example. You might need to fetch from your dummy_data.dart
      _currentUser = User(
        id: 'u2',
        name: 'Samadov Ubaydulla',
        email: 'samadov@example.com',
        role: UserRole.student,
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
    // Placeholder for registration without Firebase
    // You would typically add the user to your local list (e.g., in dummy_data or a local DB)
    print("Dummy registration for $name with email $email");
    _currentUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple unique ID
      name: name,
      email: email,
      role: UserRole.student, // Default role
      registrationDate: DateTime.now(),
      lastLogin: DateTime.now(),
    );
    // In a real scenario, you might add this newUser to a list in dummy_data.dart
    return _currentUser;
  }

  Future<void> signOut() async {
    _currentUser = null;
    // In a real pre-Firebase app, you might clear shared_preferences here
  }

  // This method would now update the user in a local state (e.g., AuthNotifier)
  // or a local list, not Firestore.
  Future<void> updateUserProfile(User updatedUser) async {
    if (_currentUser != null && _currentUser!.id == updatedUser.id) {
      _currentUser = updatedUser;
      // Notify listeners if using a state management solution like AuthNotifier
      print("User profile updated locally: ${updatedUser.name}");
    } else {
      throw Exception("User not found or ID mismatch for local update.");
    }
  }
}
