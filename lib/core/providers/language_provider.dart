import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/logger_service.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _prefKey = 'app_language';

  final LoggerService _logger = ServiceLocator.instance.get<LoggerService>();

  Locale _locale = const Locale('en', '');
  bool _isLoading = false;

  // Getters
  Locale get locale => _locale;
  bool get isLoading => _isLoading;

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('bn', ''), // Bengali
  ];

  LanguageProvider() {
    _loadSavedLanguage();
  }

  // Load saved language preference
  Future<void> _loadSavedLanguage() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_prefKey) ?? 'en';

      _locale = _getLocaleFromCode(languageCode);
      _logger.debug('Loaded language: $languageCode');
    } catch (e, stackTrace) {
      _logger.error('Failed to load language preference', error: e, stackTrace: stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  // Change language
  Future<void> changeLanguage(String languageCode) async {
    if (_locale.languageCode == languageCode) return;

    _setLoading(true);
    try {
      final newLocale = _getLocaleFromCode(languageCode);

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, languageCode);

      _locale = newLocale;
      _logger.debug('Language changed to: $languageCode');

      notifyListeners();
    } catch (e, stackTrace) {
      _logger.error('Failed to change language', error: e, stackTrace: stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  // Toggle between English and Bengali
  Future<void> toggleLanguage() async {
    final newCode = _locale.languageCode == 'en' ? 'bn' : 'en';
    await changeLanguage(newCode);
  }

  // Get locale from language code
  Locale _getLocaleFromCode(String code) {
    switch (code) {
      case 'bn':
        return const Locale('bn', '');
      case 'en':
      default:
        return const Locale('en', '');
    }
  }

  // Get current language name
  String get currentLanguageName {
    switch (_locale.languageCode) {
      case 'bn':
        return 'বাংলা';
      case 'en':
      default:
        return 'English';
    }
  }

  // Get all available languages
  List<Map<String, dynamic>> get availableLanguages => [
    {
      'code': 'en',
      'name': 'English',
      'localName': 'English',
    },
    {
      'code': 'bn',
      'name': 'Bengali',
      'localName': 'বাংলা',
    },
  ];

  // Check if RTL language
  bool get isRtl => false; // English and Bengali are both LTR

  // Reset to default (English)
  Future<void> resetToDefault() async {
    await changeLanguage('en');
  }

  // Helper method
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Dispose
  @override
  void dispose() {
    super.dispose();
  }
}