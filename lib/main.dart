import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/user_models.dart';

class AuthProvider extends ChangeNotifier {

  AuthProvider() {
    initialize();
  }
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isInitialized => _isInitialized;

  // Role checks
  bool get isHost => _currentUser?.role == UserRole.host;
  bool get isAgency => _currentUser?.role == UserRole.agency;
  bool get isCountryManager => _currentUser?.role == UserRole.countryManager;
  bool get isCoinSeller => _currentUser?.role == UserRole.coinSeller;
  bool get isAdmin => _currentUser?.role == UserRole.admin;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadSavedUser();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadSavedUser() async {
    try {
      final userJson = await _storageService.getUser();
      if (userJson != null) {
        _currentUser = User.fromJson(userJson);
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Demo login for testing
      await Future.delayed(const Duration(seconds: 1));
      
      if (email == 'admin@test.com' && password == 'admin123') {
        _currentUser = User.admin(
          id: '1',
          email: email,
          name: 'Admin User',
        );
      } else if (email == 'manager@test.com' && password == 'manager123') {
        _currentUser = User.countryManager(
          id: '2',
          email: email,
          name: 'Country Manager',
          countryId: 'bd',
        );
      } else if (email == 'agency@test.com' && password == 'agency123') {
        _currentUser = User.agency(
          id: '3',
          email: email,
          name: 'Agency Owner',
          countryId: 'bd',
          agencyId: 'ag_001',
        );
      } else if (email == 'seller@test.com' && password == 'seller123') {
        _currentUser = User.coinSeller(
          id: '4',
          email: email,
          name: 'Coin Seller',
          countryId: 'bd',
          sellerId: 'seller_001',
        );
      } else if (email == 'host@test.com' && password == 'host123') {
        _currentUser = User.host(
          id: '5',
          email: email,
          name: 'Live Host',
          countryId: 'bd',
          agencyId: 'ag_001',
        );
      } else {
        _error = 'Invalid email or password';
        return false;
      }

      // Save user to storage
      await _storageService.saveUser(_currentUser!.toJson());
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storageService.clearUser();
      _currentUser = null;
    } catch (e) {
      debugPrint('Error logging out: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  bool hasPermission(List<UserRole> allowedRoles) {
    if (_currentUser == null) return false;
    return allowedRoles.contains(_currentUser!.role);
  }
}