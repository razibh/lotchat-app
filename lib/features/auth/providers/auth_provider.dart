import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/user_models.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/constants/app_constants.dart';
class AuthProvider extends ChangeNotifier {
  // Constructor
  AuthProvider() {
    initialize();
  }

  // Services
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  // User data
  User? _currentUser;
  String? _token;
  String? _refreshToken;

  // State
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  String? get token => _token;
  String? get refreshToken => _refreshToken;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null && _token != null;

  // Role checks
  bool get isHost => _currentUser?.role == UserRole.host;
  bool get isAgency => _currentUser?.role == UserRole.agency;
  bool get isCountryManager => _currentUser?.role == UserRole.countryManager;
  bool get isCoinSeller => _currentUser?.role == UserRole.coinSeller;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isUser => _currentUser?.role == UserRole.user;

  // Initialize auth provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadSavedAuthData();
      _isInitialized = true;
      _error = null;
    } catch (e) {
      _error = 'Failed to initialize auth: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load saved auth data from storage
  Future<void> _loadSavedAuthData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Load token using direct strings
      _token = prefs.getString('token');

      // Load refresh token
      _refreshToken = prefs.getString('refresh_token');

      // Load user
      final String? userJson = prefs.getString('user');
      if (userJson != null) {
        _currentUser = User.fromJson(jsonDecode(userJson));
      }

      debugPrint('Auth data loaded successfully');
    } catch (e) {
      debugPrint('Error loading auth data: $e');
      await _clearAuthData();
    }
  }

  // Save auth data to storage
  Future<void> _saveAuthData({
    required User user,
    required String token,
    String? refreshToken,
  }) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('user', jsonEncode(user.toJson()));
      await prefs.setString('token', token);
      if (refreshToken != null) {
        await prefs.setString('refresh_token', refreshToken);
      }

      debugPrint('Auth data saved successfully');
    } catch (e) {
      debugPrint('Error saving auth data: $e');
    }
  }

  // Clear auth data from storage
  Future<void> _clearAuthData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.remove('user');
      await prefs.remove('token');
      await prefs.remove('refresh_token');

      debugPrint('Auth data cleared');
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
    }
  }

  // Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validate input
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }

      // Demo login for testing (replace with actual API call)
      await Future.delayed(const Duration(seconds: 1));

      User user;
      String token;
      String newRefreshToken;

      if (email == 'admin@test.com' && password == 'admin123') {
        user = User.admin(
          id: '1',
          email: email,
          name: 'Admin User',
          username: 'admin',
        );
        token = 'admin_token_123';
        newRefreshToken = 'admin_refresh_123';
      } else if (email == 'manager@test.com' && password == 'manager123') {
        user = User.countryManager(
          id: '2',
          email: email,
          name: 'Country Manager',
          username: 'country_manager',
          countryId: 'bd',
        );
        token = 'manager_token_123';
        newRefreshToken = 'manager_refresh_123';
      } else if (email == 'agency@test.com' && password == 'agency123') {
        user = User.agency(
          id: '3',
          email: email,
          name: 'Agency Owner',
          username: 'agency_owner',
          countryId: 'bd',
          agencyId: 'ag_001',
        );
        token = 'agency_token_123';
        newRefreshToken = 'agency_refresh_123';
      } else if (email == 'seller@test.com' && password == 'seller123') {
        user = User.coinSeller(
          id: '4',
          email: email,
          name: 'Coin Seller',
          username: 'coin_seller',
          countryId: 'bd',
          sellerId: 'seller_001',
        );
        token = 'seller_token_123';
        newRefreshToken = 'seller_refresh_123';
      } else if (email == 'host@test.com' && password == 'host123') {
        user = User.host(
          id: '5',
          email: email,
          name: 'Live Host',
          username: 'live_host',
          countryId: 'bd',
          agencyId: 'ag_001',
        );
        token = 'host_token_123';
        newRefreshToken = 'host_refresh_123';
      } else if (email == 'user@test.com' && password == 'user123') {
        user = User.regular(
          id: '6',
          email: email,
          name: 'Regular User',
          username: 'regular_user',
          countryId: 'bd',
        );
        token = 'user_token_123';
        newRefreshToken = 'user_refresh_123';
      } else {
        throw Exception('Invalid email or password');
      }

      // Save auth data
      _currentUser = user;
      _token = token;
      _refreshToken = newRefreshToken;

      await _saveAuthData(
        user: user,
        token: token,
        refreshToken: newRefreshToken,
      );

      _error = null;
      return true;

    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Login error: $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String username,
    required String countryId,
    UserRole role = UserRole.user,
    Map<String, dynamic>? metadata,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validate input
      if (email.isEmpty || password.isEmpty || name.isEmpty || username.isEmpty) {
        throw Exception('All fields are required');
      }

      if (password.length < AppConstants.minPasswordLength) {
        throw Exception('Password must be at least ${AppConstants.minPasswordLength} characters');
      }

      if (username.length < AppConstants.minUsernameLength) {
        throw Exception('Username must be at least ${AppConstants.minUsernameLength} characters');
      }

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Create user based on role
      User user;
      final String token = 'new_token_${DateTime.now().millisecondsSinceEpoch}';
      final String newRefreshToken = 'refresh_${DateTime.now().millisecondsSinceEpoch}';

      switch (role) {
        case UserRole.agency:
          user = User.agency(
            id: 'new_${DateTime.now().millisecondsSinceEpoch}',
            email: email,
            name: name,
            username: username,
            countryId: countryId,
            agencyId: metadata?['agencyId'],
          );
          break;
        case UserRole.coinSeller:
          user = User.coinSeller(
            id: 'new_${DateTime.now().millisecondsSinceEpoch}',
            email: email,
            name: name,
            username: username,
            countryId: countryId,
            sellerId: metadata?['sellerId'],
          );
          break;
        case UserRole.host:
          user = User.host(
            id: 'new_${DateTime.now().millisecondsSinceEpoch}',
            email: email,
            name: name,
            username: username,
            countryId: countryId,
            agencyId: metadata?['agencyId'],
          );
          break;
        default:
          user = User.regular(
            id: 'new_${DateTime.now().millisecondsSinceEpoch}',
            email: email,
            name: name,
            username: username,
            countryId: countryId,
          );
          break;
      }

      // Save auth data
      _currentUser = user;
      _token = token;
      _refreshToken = newRefreshToken;

      await _saveAuthData(
        user: user,
        token: token,
        refreshToken: newRefreshToken,
      );

      _error = null;
      return true;

    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Registration error: $_error');
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
      // Clear local data
      _currentUser = null;
      _token = null;
      _refreshToken = null;

      await _clearAuthData();

      _error = null;

    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh token
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Update token
      _token = 'new_token_${DateTime.now().millisecondsSinceEpoch}';

      // Save new token
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);

      return true;

    } catch (e) {
      debugPrint('Token refresh error: $e');
      return false;
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? username,
    String? avatar,
    String? bio,
    Map<String, dynamic>? metadata,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Update local user
      _currentUser = _currentUser!.copyWith(
        name: name,
        username: username,
        avatar: avatar,
        bio: bio,
        metadata: metadata,
      );

      // Save updated user
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(_currentUser!.toJson()));

      return true;

    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validate new password
      if (newPassword.length < AppConstants.minPasswordLength) {
        throw Exception('New password must be at least ${AppConstants.minPasswordLength} characters');
      }

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      return true;

    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Forgot password
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      return true;

    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset password
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validate new password
      if (newPassword.length < AppConstants.minPasswordLength) {
        throw Exception('Password must be at least ${AppConstants.minPasswordLength} characters');
      }

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      return true;

    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verify email
  Future<bool> verifyEmail(String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Update user verification status
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(isVerified: true);

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(_currentUser!.toJson()));
      }

      return true;

    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if user has permission
  bool hasPermission(List<UserRole> allowedRoles) {
    if (_currentUser == null) return false;
    return allowedRoles.contains(_currentUser!.role);
  }

  // Get user's home route based on role
  String getHomeRoute() {
    if (_currentUser == null) return '/login';
    return _currentUser!.homeRoute;
  }

  // Update user data (for real-time updates)
  void updateUserData(User updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Check if token is valid (not expired)
  bool isTokenValid() {
    return _token != null;
  }

  // Get auth headers for API calls
  Map<String, String> getAuthHeaders() {
    if (_token == null) return {};
    return {
      'Authorization': 'Bearer $_token',
      'Content-Type': 'application/json',
    };
  }

  // Demo accounts for testing
  List<Map<String, dynamic>> getDemoAccounts() {
    return [
      {
        'role': 'Admin',
        'email': 'admin@test.com',
        'password': 'admin123',
        'color': Colors.red,
      },
      {
        'role': 'Country Manager',
        'email': 'manager@test.com',
        'password': 'manager123',
        'color': Colors.purple,
      },
      {
        'role': 'Agency Owner',
        'email': 'agency@test.com',
        'password': 'agency123',
        'color': Colors.blue,
      },
      {
        'role': 'Coin Seller',
        'email': 'seller@test.com',
        'password': 'seller123',
        'color': Colors.orange,
      },
      {
        'role': 'Host',
        'email': 'host@test.com',
        'password': 'host123',
        'color': Colors.pink,
      },
      {
        'role': 'Regular User',
        'email': 'user@test.com',
        'password': 'user123',
        'color': Colors.green,
      },
    ];
  }
}