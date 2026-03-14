import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/logger_service.dart';

class SecureStorageService {
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();
  static final SecureStorageService _instance = SecureStorageService._internal();

  final LoggerService _logger = ServiceLocator().get<LoggerService>();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Write data
  Future<bool> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      return true;
    } catch (e) {
      _logger.error('Failed to write secure data for key: $key', error: e);
      return false;
    }
  }

  // Read data
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      _logger.error('Failed to read secure data for key: $key', error: e);
      return null;
    }
  }

  // Delete data
  Future<bool> delete(String key) async {
    try {
      await _storage.delete(key: key);
      return true;
    } catch (e) {
      _logger.error('Failed to delete secure data for key: $key', error: e);
      return false;
    }
  }

  // Check if key exists
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      _logger.error('Failed to check key: $key', error: e);
      return false;
    }
  }

  // Read all
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      _logger.error('Failed to read all secure data', error: e);
      return <String, String>{};
    }
  }

  // Delete all
  Future<bool> deleteAll() async {
    try {
      await _storage.deleteAll();
      return true;
    } catch (e) {
      _logger.error('Failed to delete all secure data', error: e);
      return false;
    }
  }

  // ==================== AUTH TOKEN ====================
  Future<bool> saveAuthToken(String token) async {
    return write('auth_token', token);
  }

  Future<String?> getAuthToken() async {
    return read('auth_token');
  }

  Future<bool> removeAuthToken() async {
    return delete('auth_token');
  }

  // ==================== REFRESH TOKEN ====================
  Future<bool> saveRefreshToken(String token) async {
    return write('refresh_token', token);
  }

  Future<String?> getRefreshToken() async {
    return read('refresh_token');
  }

  Future<bool> removeRefreshToken() async {
    return delete('refresh_token');
  }

  // ==================== USER CREDENTIALS ====================
  Future<bool> saveUserCredentials({
    required String email,
    required String password,
  }) async {
    try {
      await write('user_email', email);
      await write('user_password', password);
      return true;
    } catch (e) {
      _logger.error('Failed to save user credentials', error: e);
      return false;
    }
  }

  Future<Map<String, String>?> getUserCredentials() async {
    try {
      final String? email = await read('user_email');
      final String? password = await read('user_password');
      if (email != null && password != null) {
        return <String, String>{'email': email, 'password': password};
      }
      return null;
    } catch (e) {
      _logger.error('Failed to get user credentials', error: e);
      return null;
    }
  }

  Future<bool> removeUserCredentials() async {
    try {
      await delete('user_email');
      await delete('user_password');
      return true;
    } catch (e) {
      _logger.error('Failed to remove user credentials', error: e);
      return false;
    }
  }
}