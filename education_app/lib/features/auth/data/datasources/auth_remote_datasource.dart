import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sud_qollanma/features/auth/data/models/app_user_model.dart';
import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart';


abstract class AuthRemoteDataSource {
  Stream<AppUserModel?> get authStateChanges;
  Future<AppUserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  });
  Future<AppUserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<AppUserModel?> signInWithGoogle();
  Future<void> signOut();
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<AppUserModel?> getCurrentUser();
  Future<String?> getEmailFromUsername(String username);
  Future<bool> isUsernameUnique(String username);
  Stream<List<AppUserModel>> getAllUsersStream();
  Future<void> updateUserProfile(AppUserModel user);
  Stream<AppUserModel?> getUserProfileStream(String uid);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  @override
  Stream<AppUserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      try {
        final doc = await _usersCollection.doc(firebaseUser.uid).get();
        if (doc.exists && doc.data() != null) {
          return AppUserModel.fromMap(doc.data()!, firebaseUser.uid);
        }
      } catch (e) {
        if (kDebugMode) print("Error fetching user profile in authState: $e");
      }
      return null;
    });
  }

  @override
  Future<AppUserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        await firebaseUser.updateDisplayName(name);

        final newUser = AppUserModel(
          id: firebaseUser.uid,
          name: name,
          email: email,
          role: role,
          registrationDate: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        await _usersCollection.doc(firebaseUser.uid).set(newUser.toMap());
        
        // Streak check moved to UseCase
        
        return newUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("FirebaseAuthException during registration: ${e.message}");
      }
      rethrow;
    }
  }

  @override
  Future<AppUserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Streak check moved to UseCase
        
        return await _getUserProfile(firebaseUser.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(
            'Firebase Auth Exception during sign in: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<AppUserModel?> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _firebaseAuth.signInWithCredential(credential);
      }

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) throw Exception('Sign in with Google failed.');

      final docSnapshot = await _usersCollection.doc(firebaseUser.uid).get();

      if (docSnapshot.exists) {
        await _usersCollection.doc(firebaseUser.uid).update({
          'lastLogin': DateTime.now().toIso8601String(),
        });
        
        // Streak check moved to UseCase
        
        return await _getUserProfile(firebaseUser.uid);
      } else {
        final newUser = AppUserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'New User',
          email: firebaseUser.email,
          role: UserRole.xodim,
          profilePictureUrl: firebaseUser.photoURL,
          registrationDate: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        await _usersCollection.doc(firebaseUser.uid).set(newUser.toMap());
        
        // Streak check moved to UseCase
        
        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("FirebaseAuthException during Google sign in: ${e.message}");
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No user signed in');
    if (user.email == null) throw Exception('User email not found');

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  @override
  Future<AppUserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return await _getUserProfile(user.uid);
    }
    return null;
  }

  Future<AppUserModel?> _getUserProfile(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUserModel.fromMap(doc.data()!, uid);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print("Error fetching user profile: $e");
      return null;
    }
  }

  @override
  Future<String?> getEmailFromUsername(String username) async {
    try {
      final querySnapshot = await _usersCollection
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) return null;
      return querySnapshot.docs.first.data()['email'] as String?;
    } catch (e) {
      if (kDebugMode) print("Error getEmailFromUsername: $e");
      return null;
    }
  }

  @override
  Future<bool> isUsernameUnique(String username) async {
    try {
      final querySnapshot = await _usersCollection
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<List<AppUserModel>> getAllUsersStream() {
    return _usersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppUserModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Future<void> updateUserProfile(AppUserModel user) async {
    await _usersCollection.doc(user.id).update(user.toMap());
  }

  @override
  Stream<AppUserModel?> getUserProfileStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return AppUserModel.fromMap(doc.data()!, uid);
      }
      return null;
    });
  }
}
