import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../models/user_models.dart' as app;
import 'database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseService _databaseService = DatabaseService();

  // Auth state changes stream
  Stream<User?> get user => _auth.authStateChanges();

  // ✅ NEW: Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  // ✅ NEW: Stream user data
  Stream<DocumentSnapshot> streamUserData(String userId) {
    return _firestore.collection('users').doc(userId).snapshots();
  }

  // ✅ NEW: Update user's clan ID
  Future<void> updateUserClan(String userId, String? clanId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'clanId': clanId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating user clan: $e');
    }
  }

  // ✅ NEW: Update user online status
  Future<void> updateUserStatus(String userId, bool isOnline) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating user status: $e');
    }
  }

  // Sign up with email & password
  Future<app.User?> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String phone,
    required String country,
    required String region,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user == null) return null;

      final newUser = app.User(
        id: user.uid,
        username: username,
        email: email,
        name: username,
        role: app.UserRole.user,
        countryId: country,
        createdAt: DateTime.now(),
        phoneNumber: phone,
        coins: 1000,
        diamonds: 0,
      );

      await _databaseService.createUser(newUser);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.uid);
      await prefs.setBool('is_logged_in', true);

      return newUser;
    } catch (e) {
      debugPrint('Sign up error: $e');
      return null;
    }
  }

  // Login with email & password
  Future<app.User?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user == null) return null;

      final app.User? userData = await _databaseService.getUser(user.uid);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.uid);
      await prefs.setBool('is_logged_in', true);

      return userData;
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }

  // Login with Google
  Future<app.User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(credential);

      final User? user = result.user;
      if (user == null) return null;

      app.User? userData = await _databaseService.getUser(user.uid);

      if (userData == null) {
        userData = app.User(
          id: user.uid,
          username: user.displayName ?? 'User',
          email: user.email ?? '',
          name: user.displayName ?? 'User',
          role: app.UserRole.user,
          countryId: 'Unknown',
          createdAt: DateTime.now(),
          phoneNumber: user.phoneNumber ?? '',
          avatar: user.photoURL,
          coins: 1000,
          diamonds: 0,
        );
        await _databaseService.createUser(userData);
      }

      return userData;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      return null;
    }
  }

  // Login with phone
  Future<void> signInWithPhone(
      String phoneNumber,
      Function(PhoneAuthCredential) verificationCompleted,
      Function(FirebaseAuthException) verificationFailed,
      Function(String, int?) codeSent,
      Function(String) codeAutoRetrievalTimeout,
      ) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  // Verify OTP
  Future<app.User?> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final UserCredential result = await _auth.signInWithCredential(credential);

      final User? user = result.user;
      if (user == null) return null;

      app.User? userData = await _databaseService.getUser(user.uid);

      if (userData == null) {
        userData = app.User(
          id: user.uid,
          username: 'User${user.uid.substring(0, 5)}',
          email: '',
          name: 'User${user.uid.substring(0, 5)}',
          role: app.UserRole.user,
          countryId: 'Unknown',
          createdAt: DateTime.now(),
          phoneNumber: user.phoneNumber ?? '',
          coins: 1000,
          diamonds: 0,
        );
        await _databaseService.createUser(userData);
      }

      return userData;
    } catch (e) {
      debugPrint('OTP verification error: $e');
      return null;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.setBool('is_logged_in', false);
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      debugPrint('Password reset error: $e');
      return false;
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
    }
  }
}