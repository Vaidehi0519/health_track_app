import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_track_app/core/session_store.dart';
import 'package:health_track_app/domain/models/user_profile.dart';

class AuthRepository {
  AuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore,
       _googleSignIn = googleSignIn;

  final firebase_auth.FirebaseAuth? _firebaseAuth;
  final FirebaseFirestore? _firestore;
  final GoogleSignIn? _googleSignIn;

  firebase_auth.FirebaseAuth get _auth =>
      _firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  GoogleSignIn get _google => _googleSignIn ?? GoogleSignIn.instance;

  Future<UserProfile?> currentUserProfile() async {
    if (Firebase.apps.isEmpty) return null;
    final user = _auth.currentUser;
    if (user == null) return null;
    return _loadOrCreateProfile(user);
  }

  Future<UserProfile> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final profile = await _loadOrCreateProfile(credential.user);
      await SessionStore.setLoggedIn(true);
      return profile;
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(_authMessage(error));
    }
  }

  Future<UserProfile> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String gender,
  }) async {
    if (name.trim().length < 3) {
      throw const AuthException('Enter your full name.');
    }
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name.trim());
      final profile = UserProfile.demo().copyWith(
        uid: credential.user?.uid,
        name: name.trim(),
        email: email.trim(),
        gender: gender,
        avatarSeed: _initials(name),
      );
      await _saveProfile(profile);
      await SessionStore.setLoggedIn(true);
      return profile;
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(_authMessage(error));
    }
  }

  Future<UserProfile> signInWithGoogle() async {
    try {
      if (!_google.supportsAuthenticate()) {
        throw const AuthException(
          'Google sign-in needs the platform sign-in button on this target.',
        );
      }
      final account = await _google.authenticate();
      final authentication = account.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        idToken: authentication.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final profile = await _loadOrCreateProfile(userCredential.user);
      await SessionStore.setLoggedIn(true);
      return profile;
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(_authMessage(error));
    } on GoogleSignInException catch (error) {
      throw AuthException(error.description ?? 'Google sign-in was cancelled.');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(_authMessage(error));
    }
  }

  Future<void> signOut() async {
    if (Firebase.apps.isNotEmpty) {
      await _auth.signOut();
      await _google.signOut();
    }
    await SessionStore.setLoggedIn(false);
  }

  Future<void> updateProfile(UserProfile profile) => _saveProfile(profile);

  Future<UserProfile> _loadOrCreateProfile(firebase_auth.User? user) async {
    if (user == null) {
      throw const AuthException('Authentication failed. Please try again.');
    }

    final doc = _db.collection('users').doc(user.uid);
    final snapshot = await doc.get();
    if (snapshot.exists && snapshot.data() != null) {
      return UserProfile.fromJson(snapshot.data()!);
    }

    final displayName = user.displayName?.trim();
    final profile = UserProfile.demo().copyWith(
      uid: user.uid,
      name: displayName == null || displayName.isEmpty
          ? 'Health User'
          : displayName,
      email: user.email ?? '',
      avatarSeed: _initials(displayName ?? 'Health User'),
    );
    await _saveProfile(profile);
    return profile;
  }

  Future<void> _saveProfile(UserProfile profile) {
    return _db
        .collection('users')
        .doc(profile.uid)
        .set(profile.toJson(), SetOptions(merge: true));
  }

  String _authMessage(firebase_auth.FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-email' => 'Enter a valid email address.',
      'user-disabled' => 'This account has been disabled.',
      'user-not-found' => 'No account exists for this email.',
      'wrong-password' || 'invalid-credential' => 'Invalid email or password.',
      'email-already-in-use' => 'An account already exists for this email.',
      'weak-password' => 'Choose a stronger password.',
      'network-request-failed' =>
        'Check your internet connection and try again.',
      _ => error.message ?? 'Authentication failed. Please try again.',
    };
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'HU';
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
