import 'dart:async';
import 'package:firebase_auth_platform_interface/src/firebase_auth_exception.dart';
import 'package:firebase_auth_platform_interface/src/providers/phone_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/models/user_model.dart';
import '../../../core/di/service_locator.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = ServiceLocator().get<AuthService>();
  final DatabaseService _databaseService = ServiceLocator().get<DatabaseService>();
  final StorageService _storageService = ServiceLocator().get<StorageService>();
  final AnalyticsService _analyticsService = ServiceLocator().get<AnalyticsService>();
  final NotificationService _notificationService = ServiceLocator().get<NotificationService>();

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;
  StreamSubscription? _authStateSubscription;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;

  // Initialize
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user is already logged in
      final bool isLoggedIn = _storageService.isLoggedIn();
      
      if (isLoggedIn) {
        final userId = await _storageService.getUserId();
        if (userId != null) {
          await loadUser(userId);
        }
      }

      // Listen to auth state changes
      _authStateSubscription = _authService.authStateChanges.listen((user) {
        if (user == null) {
          _handleLogout();
        }
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user
  Future<void> loadUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _databaseService.getUser(userId);
      _isAuthenticated = _currentUser != null;
      
      if (_isAuthenticated) {
        // Save to storage
        await _storageService.saveUser(_currentUser!);
        
        // Set analytics user
        await _analyticsService.setUserId(userId);
        await _analyticsService.setUserProperties(_currentUser!);
        
        // Update FCM token
        await _notificationService.updateFCMToken(userId);
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login with email
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final UserModel? user = await _authService.loginWithEmail(
        email: email,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
        
        // Save to storage
        await _storageService.saveUser(user);
        await _storageService.setLoggedIn(true);
        
        // Track analytics
        await _analyticsService.trackLogin('email');
        await _analyticsService.setUserId(user.uid);
        await _analyticsService.setUserProperties(user);

        return true;
      } else {
        _error = 'Invalid email or password';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login with Google
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final UserModel? user = await _authService.signInWithGoogle();

      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
        
        // Save to storage
        await _storageService.saveUser(user);
        await _storageService.setLoggedIn(true);
        
        // Track analytics
        await _analyticsService.trackLogin('google');
        await _analyticsService.setUserId(user.uid);
        await _analyticsService.setUserProperties(user);

        return true;
      } else {
        _error = 'Google sign in failed';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
    required String username,
    required String phone,
    required String country,
    required String region,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final UserModel? user = await _authService.signUpWithEmail(
        email: email,
        password: password,
        username: username,
        phone: phone,
        country: country,
        region: region,
      );

      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
        
        // Save to storage
        await _storageService.saveUser(user);
        await _storageService.setLoggedIn(true);
        
        // Track analytics
        await _analyticsService.trackSignUp('email');
        await _analyticsService.setUserId(user.uid);
        await _analyticsService.setUserProperties(user);

        return true;
      } else {
        _error = 'Registration failed';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login with phone
  Future<void> loginWithPhone(
    String phoneNumber,
    Function(String verificationId) codeSent,
    Function(String error) errorCallback,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signInWithPhone(
        phoneNumber,
        (PhoneAuthCredential verificationId, _) {
          codeSent(verificationId);
        },
        (FirebaseAuthException error) {
          errorCallback(error.toString());
        },
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verify OTP
  Future<bool> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final UserModel? user = await _authService.verifyOTP(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
        
        // Save to storage
        await _storageService.saveUser(user);
        await _storageService.setLoggedIn(true);
        
        // Track analytics
        await _analyticsService.trackLogin('phone');
        await _analyticsService.setUserId(user.uid);
        await _analyticsService.setUserProperties(user);

        return true;
      } else {
        _error = 'Invalid OTP';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      await _handleLogout();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Handle logout
  Future<void> _handleLogout() async {
    // Clear analytics
    await _analyticsService.reset();
    
    // Clear storage
    await _storageService.clearUserData();
    
    // Reset state
    _currentUser = null;
    _isAuthenticated = false;
  }

  // Update profile
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.updateUser(_currentUser!.uid, updates);
      
      // Update local user
      _currentUser = await _databaseService.getUser(_currentUser!.uid);
      await _storageService.saveUser(_currentUser!);
      
      // Update analytics
      await _analyticsService.setUserProperties(_currentUser!);

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update coins
  Future<void> updateCoins(int amount) async {
    if (_currentUser == null) return;

    _currentUser!.coins += amount;
    notifyListeners();

    // Save to database
    await _databaseService.updateUser(_currentUser!.uid, <String, dynamic>{
      'coins': _currentUser!.coins,
    });
  }

  // Update diamonds
  Future<void> updateDiamonds(int amount) async {
    if (_currentUser == null) return;

    _currentUser!.diamonds += amount;
    notifyListeners();

    // Save to database
    await _databaseService.updateUser(_currentUser!.uid, <String, dynamic>{
      'diamonds': _currentUser!.diamonds,
    });
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}