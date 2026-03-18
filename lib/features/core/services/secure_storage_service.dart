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
      return {};
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
        return {'email': email, 'password': password};
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

  // ==================== BIOMETRIC TOKEN ====================
  Future<bool> saveBiometricToken(String token) async {
    return write('biometric_token', token);
  }

  Future<String?> getBiometricToken() async {
    return read('biometric_token');
  }

  Future<bool> removeBiometricToken() async {
    return delete('biometric_token');
  }

  // ==================== DEVICE ID ====================
  Future<bool> saveDeviceId(String deviceId) async {
    return write('device_id', deviceId);
  }

  Future<String?> getDeviceId() async {
    return read('device_id');
  }

  Future<bool> removeDeviceId() async {
    return delete('device_id');
  }

  // ==================== PIN CODE ====================
  Future<bool> savePinCode(String pin) async {
    return write('pin_code', pin);
  }

  Future<String?> getPinCode() async {
    return read('pin_code');
  }

  Future<bool> removePinCode() async {
    return delete('pin_code');
  }

  // ==================== SESSION DATA ====================
  Future<bool> saveSessionData(Map<String, String> data) async {
    try {
      for (final entry in data.entries) {
        await write('session_${entry.key}', entry.value);
      }
      return true;
    } catch (e) {
      _logger.error('Failed to save session data', error: e);
      return false;
    }
  }

  Future<Map<String, String>> getSessionData() async {
    try {
      final allData = await readAll();
      final sessionData = <String, String>{};

      for (final entry in allData.entries) {
        if (entry.key.startsWith('session_')) {
          final key = entry.key.substring(8);
          sessionData[key] = entry.value;
        }
      }

      return sessionData;
    } catch (e) {
      _logger.error('Failed to get session data', error: e);
      return {};
    }
  }

  Future<bool> clearSessionData() async {
    try {
      final allData = await readAll();
      for (final key in allData.keys) {
        if (key.startsWith('session_')) {
          await delete(key);
        }
      }
      return true;
    } catch (e) {
      _logger.error('Failed to clear session data', error: e);
      return false;
    }
  }

  // ==================== UTILITY METHODS ====================

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Clear all user data (logout)
  Future<bool> clearAllUserData() async {
    try {
      await removeAuthToken();
      await removeRefreshToken();
      await removeUserCredentials();
      await removeBiometricToken();
      await removePinCode();
      await clearSessionData();
      return true;
    } catch (e) {
      _logger.error('Failed to clear all user data', error: e);
      return false;
    }
  }

  // Get storage size info
  Future<int> getStorageSize() async {
    try {
      final allData = await readAll();
      int size = 0;
      for (final entry in allData.entries) {
        size += entry.key.length + (entry.value?.length ?? 0);
      }
      return size;
    } catch (e) {
      _logger.error('Failed to get storage size', error: e);
      return 0;
    }
  }
}