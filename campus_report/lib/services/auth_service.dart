import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel> registerUser({
    required String name,
    required String email,
    required String password,
    required String department,
  }) async {
    final cleanEmail = email.replaceAll(' ', '').toLowerCase();

    final credential = await _auth.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('User registration failed.');
    }

    // Update displayName on Firebase Auth User as backup
    await user.updateDisplayName(name.trim());

    final userModel = UserModel(
      uid: user.uid,
      name: name.trim(),
      email: cleanEmail,
      role: 'student',
      department: department.trim(),
      campusLocation: 'Kigali, Rwanda',
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toMap());

    // Send verification email in background
    user.sendEmailVerification().catchError((_) {});

    return userModel;
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.replaceAll(' ', '').toLowerCase();

    final credential = await _auth.signInWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );

    final user = credential.user;
    if (user == null) return null;

    return await ensureUserProfileExists(user);
  }

  /// Ensures the Firestore user document exists (recovers if created while rules were locked)
  Future<UserModel> ensureUserProfileExists(User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }

    final fallbackProfile = UserModel(
      uid: user.uid,
      name: (user.displayName != null && user.displayName!.isNotEmpty)
          ? user.displayName!
          : 'Eric Hategekimana',
      email: user.email ?? '',
      role: 'student',
      department: 'Software Engineering',
      campusLocation: 'Kigali, Rwanda',
      createdAt: DateTime.now(),
    );

    await docRef.set(fallbackProfile.toMap());
    return fallbackProfile;
  }

  Stream<UserModel?> streamUserProfile(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return UserModel.fromFirestore(doc);
        })
        .handleError(( _) => null);
  }

  /// Refresh token instead of native reload() to avoid Android API 36.1 GMS freeze
  Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // Force-refreshing the ID token updates email_verified claim without freezing GMS
      final tokenResult = await user.getIdTokenResult(true);
      final verifiedInClaim = tokenResult.claims?['email_verified'] == true;
      if (verifiedInClaim) {
        await ensureUserProfileExists(user);
        return true;
      }
      await user.reload();
      final isVerified = _auth.currentUser?.emailVerified ?? false;
      if (isVerified) {
        await ensureUserProfileExists(user);
      }
      return isVerified;
    } catch (_) {
      return _auth.currentUser?.emailVerified ?? false;
    }
  }

  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}