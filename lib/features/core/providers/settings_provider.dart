import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {

  SettingsProvider() {
    _loadSettings();
  }
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _language = 'en';

  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  String get language => _language;

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notifications') ?? true;
    _soundEnabled = prefs.getBool('sound') ?? true;
    _vibrationEnabled = prefs.getBool('vibration') ?? true;
    _language = prefs.getString('language') ?? 'en';
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', _notificationsEnabled);
    notifyListeners();
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound', _soundEnabled);
    notifyListeners();
  }

  Future<void> toggleVibration() async {
    _vibrationEnabled = !_vibrationEnabled;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibration', _vibrationEnabled);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    notifyListeners();
  }
}