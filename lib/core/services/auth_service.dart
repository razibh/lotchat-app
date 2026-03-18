import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../models/user_models.dart' as app;
import 'database_service.dart';
import '../../../core/di/service_locator.dart';

class AuthService {
  final SupabaseClient _supabase = getService<SupabaseClient>();
  final DatabaseService _databaseService = DatabaseService();

  // Auth state changes stream
  Stream<AuthState> get user => _supabase.auth.onAuthStateChange;

  // Get current user
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  // ✅ Get user data from Supabase
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  // ✅ Stream user data (Realtime)
  Stream<Map<String, dynamic>?> streamUserData(String userId) {
    return _supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) => data.isNotEmpty ? data.first : null);
  }

  // ✅ Update user's clan ID
  Future<void> updateUserClan(String userId, String? clanId) async {
    try {
      await _supabase
          .from('users')
          .update({'clan_id': clanId, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', userId);
    } catch (e) {
      debugPrint('Error updating user clan: $e');
    }
  }

  // ✅ Update user online status
  Future<void> updateUserStatus(String userId, bool isOnline) async {
    try {
      await _supabase
          .from('users')
          .update({
        'is_online': isOnline,
        'last_seen': DateTime.now().toIso8601String(),
      })
          .eq('id', userId);
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
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'phone': phone,
          'country': country,
          'region': region,
        },
      );

      final User? user = response.user;
      if (user == null) return null;

      // Auto create profile via trigger or manual
      final newUser = app.User(
        id: user.id,
        username: username,
        email: email,
        name: username,
        role: app.UserRole.user,
        countryId: country,
        createdAt: DateTime.now(),
        phoneNumber: phone,
        coins: 1000,
        diamonds: 0,
        isOnline: true,
      );

      await _databaseService.createUser(newUser);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id);
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
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final User? user = response.user;
      if (user == null) return null;

      // Update online status
      await updateUserStatus(user.id, true);

      final app.User? userData = await _databaseService.getUser(user.id);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id);
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
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.lotchat://login-callback',
      );

      // OAuth flow - need to handle redirect
      // For now, check if session exists
      final session = _supabase.auth.currentSession;
      if (session == null) return null;

      final user = session.user;

      app.User? userData = await _databaseService.getUser(user.id);

      if (userData == null) {
        final metadata = user.userMetadata ?? {};
        userData = app.User(
          id: user.id,
          username: metadata['full_name'] ?? 'User',
          email: user.email ?? '',
          name: metadata['full_name'] ?? 'User',
          role: app.UserRole.user,
          countryId: 'Unknown',
          createdAt: DateTime.now(),
          phoneNumber: user.phone ?? '',
          avatar: user.userMetadata?['avatar_url'],
          coins: 1000,
          diamonds: 0,
          isOnline: true,
        );
        await _databaseService.createUser(userData);
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id);
      await prefs.setBool('is_logged_in', true);

      return userData;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      return null;
    }
  }

  // Login with phone (OTP)
  Future<void> signInWithPhone(String phoneNumber) async {
    try {
      await _supabase.auth.signInWithOtp(
        phone: phoneNumber,
      );
    } catch (e) {
      debugPrint('Phone sign in error: $e');
      rethrow;
    }
  }

  // Verify OTP
  Future<app.User?> verifyOTP({
    required String phone,
    required String token,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );

      final User? user = response.user;
      if (user == null) return null;

      app.User? userData = await _databaseService.getUser(user.id);

      if (userData == null) {
        userData = app.User(
          id: user.id,
          username: 'User${user.id.substring(0, 5)}',
          email: '',
          name: 'User${user.id.substring(0, 5)}',
          role: app.UserRole.user,
          countryId: 'Unknown',
          createdAt: DateTime.now(),
          phoneNumber: phone,
          coins: 1000,
          diamonds: 0,
          isOnline: true,
        );
        await _databaseService.createUser(userData);
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id);
      await prefs.setBool('is_logged_in', true);

      return userData;
    } catch (e) {
      debugPrint('OTP verification error: $e');
      return null;
    }
  }

  // Logout
  Future<void> signOut() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      await updateUserStatus(user.id, false);
    }

    await _supabase.auth.signOut();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.setBool('is_logged_in', false);
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      debugPrint('Password reset error: $e');
      return false;
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    final User? user = _supabase.auth.currentUser;
    if (user != null) {
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            if (displayName != null) 'full_name': displayName,
            if (photoURL != null) 'avatar_url': photoURL,
          },
        ),
      );

      // Update users table as well
      await _supabase
          .from('users')
          .update({
        if (displayName != null) 'name': displayName,
        if (photoURL != null) 'avatar': photoURL,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', user.id);
    }
  }
}