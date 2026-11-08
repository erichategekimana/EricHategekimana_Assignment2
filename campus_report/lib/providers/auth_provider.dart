import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _firebaseUser;
  UserModel? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEmailVerified = false;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<UserModel?>? _profileSubscription;

  AuthProvider() {
    _initAuthListener();
  }

  User? get firebaseUser => _firebaseUser;
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isEmailVerified => _isEmailVerified;
  bool get isStaff => _userProfile?.isStaff ?? false;

  /// Listen to Firebase Auth state changes and subscribe to live Firestore user profile
void _initAuthListener() {
    _authSubscription = _authService.authStateChanges.listen((User? user) async {
      _firebaseUser = user;
      await _profileSubscription?.cancel();

      if (user != null) {
        _isEmailVerified = user.emailVerified;
        // Make sure the Firestore user document exists if rules blocked it earlier
        try {
          _userProfile = await _authService.ensureUserProfileExists(user);
        } catch (_) {}

        _profileSubscription = _authService.streamUserProfile(user.uid).listen(
          (profile) {
            if (profile != null) {
              _userProfile = profile;
              notifyListeners();
            }
          },
          onError: (_) {},
        );
      } else {
        _userProfile = null;
        _isEmailVerified = false;
      }
      notifyListeners();
    });
  }

  /// Register a new ALU student/staff account
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String department,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _userProfile = await _authService.registerUser(
        name: name,
        email: email,
        password: password,
        department: department,
      );
      _isEmailVerified = _authService.currentUser?.emailVerified ?? false;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e.code, e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Registration failed. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  /// Sign in existing user
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _userProfile = await _authService.signIn(
        email: email,
        password: password,
      );
      _isEmailVerified = await _authService.checkEmailVerified();
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e.code, e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Sign-in failed. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  /// Refresh email verification status from Firebase
  Future<bool> checkEmailVerified() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _isEmailVerified = await _authService.checkEmailVerified();
      _setLoading(false);
      return _isEmailVerified;
    } catch (e) {
      _errorMessage = 'Could not verify status. Try again shortly.';
      _setLoading(false);
      return false;
    }
  }

  /// Resend verification email link
  Future<bool> resendVerificationEmail() async {
    _errorMessage = null;
    try {
      await _authService.resendVerificationEmail();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e.code, e.message);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Could not resend verification email.';
      notifyListeners();
      return false;
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    await _authService.signOut();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _mapFirebaseError(String code, String? fallback) {
    switch (code) {
      case 'email-already-in-use':
        return 'This ALU email is already registered.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'weak-password':
        return 'Password is too weak (minimum 6 characters).';
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      default:
        return fallback ?? 'Authentication error occurred.';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _profileSubscription?.cancel();
    super.dispose();
  }
}