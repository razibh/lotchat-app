import 'package:flutter/material.dart';
import '../models/user_models.dart' as app; // 🟢 alias ব্যবহার
import '../services/database_service.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();

  app.User? _currentUser; // 🟢 app.User ব্যবহার
  bool _isLoading = false;
  String? _error;

  app.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUser(String uid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _databaseService.getUser(uid); // 🟢 app.User রিটার্ন করবে
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
      await _databaseService.updateUser(_currentUser!.id, data); // 🟢 uid এর পরিবর্তে id
      await loadUser(_currentUser!.id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCoins(int amount) async {
    if (_currentUser == null) return;

    final int newCoins = _currentUser!.coins + amount;
    await updateUser({'coins': newCoins});
  }

  Future<void> updateDiamonds(int amount) async {
    if (_currentUser == null) return;

    final int newDiamonds = _currentUser!.diamonds + amount;
    await updateUser({'diamonds': newDiamonds});
  }

  Future<void> updateTier(int tierIndex) async { // 🟢 UserTier enum নেই, index ব্যবহার
    if (_currentUser == null) return;
    await updateUser({'tier': tierIndex});
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}