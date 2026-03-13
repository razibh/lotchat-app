import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseService _databaseService = DatabaseService();

  // Auth state changes stream
  Stream<User?> get user => _auth.authStateChanges();

  // Sign up with email & password
  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String phone,
    required String country,
    required String region,
  }) async {
    try {
      // Create user in Firebase Auth
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user == null) return null;

      // Create user model
      final newUser = UserModel(
        uid: user.uid,
        username: username,
        email: email,
        phone: phone,
        country: country,
        region: region,
        coins: 1000, // Welcome bonus
        tier: UserTier.normal,
        lastActive: DateTime.now(),
      );

      // Save to Firestore
      await _databaseService.createUser(newUser);

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.uid);
      await prefs.setBool('is_logged_in', true);

      return newUser;
    } catch (e) {
      print('Sign up error: $e');
      return null;
    }
  }

  // Login with email & password
  Future<UserModel?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user == null) return null;

      // Get user data from Firestore
      final UserModel? userData = await _databaseService.getUser(user.uid);

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.uid);
      await prefs.setBool('is_logged_in', true);

      return userData;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // Login with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = 
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = 
          await _auth.signInWithCredential(credential);
      
      final user = result.user;
      if (user == null) return null;

      // Check if user exists in Firestore
      UserModel? userData = await _databaseService.getUser(user.uid);
      
      if (userData == null) {
        // New user - create profile
        userData = UserModel(
          uid: user.uid,
          username: user.displayName ?? 'User',
          email: user.email ?? '',
          phone: user.phoneNumber ?? '',
          photoURL: user.photoURL,
          country: 'Unknown',
          region: 'Unknown',
          coins: 1000,
          lastActive: DateTime.now(),
        );
        await _databaseService.createUser(userData);
      }

      return userData;
    } catch (e) {
      print('Google sign in error: $e');
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
  Future<UserModel?> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final result = 
          await _auth.signInWithCredential(credential);
      
      final user = result.user;
      if (user == null) return null;

      UserModel? userData = await _databaseService.getUser(user.uid);
      
      if (userData == null) {
        userData = UserModel(
          uid: user.uid,
          username: 'User${user.uid.substring(0, 5)}',
          email: '',
          phone: user.phoneNumber ?? '',
          country: 'Unknown',
          region: 'Unknown',
          coins: 1000,
          lastActive: DateTime.now(),
        );
        await _databaseService.createUser(userData);
      }

      return userData;
    } catch (e) {
      print('OTP verification error: $e');
      return null;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.setBool('is_logged_in', false);
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Password reset error: $e');
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
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
    }
  }
}