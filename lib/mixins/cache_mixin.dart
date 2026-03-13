import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

mixin CacheMixin {
  late SharedPreferences _prefs;

  Future<void> initCache() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save data with expiration
  Future<void> setWithExpiry(String key, dynamic value, Duration expiry) async {
    final Map<String, dynamic> data = <String, dynamic>{
      'value': value,
      'expiry': DateTime.now().add(expiry).millisecondsSinceEpoch,
    };
    await _prefs.setString(key, jsonEncode(data));
  }

  // Get data with expiration check
  T? getWithExpiry<T>(String key) {
    final String? jsonString = _prefs.getString(key);
    if (jsonString == null) return null;

    try {
      final data = jsonDecode(jsonString);
      final int expiry = data['expiry'] as int;
      
      if (DateTime.now().millisecondsSinceEpoch > expiry) {
        _prefs.remove(key);
        return null;
      }

      return data['value'] as T;
    } catch (e) {
      return null;
    }
  }

  // Save simple data
  Future<void> setData(String key, dynamic value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    }
  }

  // Get data
  T? getData<T>(String key) {
    final value = _prefs.get(key);
    if (value == null) return null;
    return value as T;
  }

  // Remove data
  Future<void> removeData(String key) async {
    await _prefs.remove(key);
  }

  // Clear all cache
  Future<void> clearCache() async {
    await _prefs.clear();
  }

  // Check if key exists
  bool hasKey(String key) {
    return _prefs.containsKey(key);
  }
}