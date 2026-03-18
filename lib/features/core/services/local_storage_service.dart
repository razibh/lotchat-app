import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/models/user_models.dart';

class LocalStorageService {
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();
  static final LocalStorageService _instance = LocalStorageService._internal();

  final LoggerService _logger = ServiceLocator().get<LoggerService>();

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Initialize
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      _logger.info('Local storage service initialized');
    } catch (e) {
      _logger.error('Failed to initialize local storage', error: e);
    }
  }

  // ==================== STRING ====================
  Future<bool> setString(String key, String value) async {
    try {
      return await _prefs.setString(key, value);
    } catch (e) {
      _logger.error('Failed to set string for key: $key', error: e);
      return false;
    }
  }

  String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (e) {
      _logger.error('Failed to get string for key: $key', error: e);
      return null;
    }
  }

  // ==================== BOOL ====================
  Future<bool> setBool(String key, bool value) async {
    try {
      return await _prefs.setBool(key, value);
    } catch (e) {
      _logger.error('Failed to set bool for key: $key', error: e);
      return false;
    }
  }

  bool? getBool(String key) {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      _logger.error('Failed to get bool for key: $key', error: e);
      return null;
    }
  }

  // ==================== INT ====================
  Future<bool> setInt(String key, int value) async {
    try {
      return await _prefs.setInt(key, value);
    } catch (e) {
      _logger.error('Failed to set int for key: $key', error: e);
      return false;
    }
  }

  int? getInt(String key) {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      _logger.error('Failed to get int for key: $key', error: e);
      return null;
    }
  }

  // ==================== DOUBLE ====================
  Future<bool> setDouble(String key, double value) async {
    try {
      return await _prefs.setDouble(key, value);
    } catch (e) {
      _logger.error('Failed to set double for key: $key', error: e);
      return false;
    }
  }

  double? getDouble(String key) {
    try {
      return _prefs.getDouble(key);
    } catch (e) {
      _logger.error('Failed to get double for key: $key', error: e);
      return null;
    }
  }

  // ==================== STRING LIST ====================
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      return await _prefs.setStringList(key, value);
    } catch (e) {
      _logger.error('Failed to set string list for key: $key', error: e);
      return false;
    }
  }

  List<String>? getStringList(String key) {
    try {
      return _prefs.getStringList(key);
    } catch (e) {
      _logger.error('Failed to get string list for key: $key', error: e);
      return null;
    }
  }

  // ==================== OBJECT ====================
  Future<bool> setObject(String key, Map<String, dynamic> value) async {
    try {
      final String jsonString = jsonEncode(value);
      return await _prefs.setString(key, jsonString);
    } catch (e) {
      _logger.error('Failed to set object for key: $key', error: e);
      return false;
    }
  }

  Map<String, dynamic>? getObject(String key) {
    try {
      final String? jsonString = _prefs.getString(key);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      _logger.error('Failed to get object for key: $key', error: e);
      return null;
    }
  }

  // ==================== USER DATA ====================
  Future<bool> saveUser(User user) async { // UserModel এর পরিবর্তে User
    try {
      return await setObject('user', user.toJson());
    } catch (e) {
      _logger.error('Failed to save user', error: e);
      return false;
    }
  }

  User? getUser() { // UserModel এর পরিবর্তে User
    try {
      final Map<String, dynamic>? userData = getObject('user');
      if (userData != null) {
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      _logger.error('Failed to get user', error: e);
      return null;
    }
  }

  // ==================== AUTH TOKEN ====================
  Future<bool> saveAuthToken(String token) async {
    return setString('auth_token', token);
  }

  String? getAuthToken() {
    return getString('auth_token');
  }

  Future<bool> removeAuthToken() async {
    return remove('auth_token');
  }

  // ==================== REMOVE ====================
  Future<bool> remove(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e) {
      _logger.error('Failed to remove key: $key', error: e);
      return false;
    }
  }

  // ==================== CLEAR ====================
  Future<bool> clear() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      _logger.error('Failed to clear storage', error: e);
      return false;
    }
  }

  // ==================== CHECK KEY ====================
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  // ==================== GET ALL KEYS ====================
  Set<String> getKeys() {
    return _prefs.getKeys();
  }

  // ==================== IS INITIALIZED ====================
  bool get isInitialized => _isInitialized;
}