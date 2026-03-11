import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUser(String uid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _databaseService.getUser(uid);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.updateUser(_currentUser!.uid, data);
      await loadUser(_currentUser!.uid);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCoins(int amount) async {
    if (_currentUser == null) return;

    final newCoins = _currentUser!.coins + amount;
    await updateUser({'coins': newCoins});
  }

  Future<void> updateDiamonds(int amount) async {
    if (_currentUser == null) return;

    final newDiamonds = _currentUser!.diamonds + amount;
    await updateUser({'diamonds': newDiamonds});
  }

  Future<void> updateTier(UserTier tier) async {
    if (_currentUser == null) return;
    await updateUser({'tier': tier.index});
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}