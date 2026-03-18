import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en', 'US');
  bool _isLoading = false;

  final List<Locale> _supportedLocales = const [
    Locale('en', 'US'), // English
    Locale('bn', 'BD'), // Bengali
    Locale('hi', 'IN'), // Hindi
    Locale('ur', 'PK'), // Urdu
    Locale('ne', 'NP'), // Nepali
    Locale('si', 'LK'), // Sinhala
    Locale('ar', 'AE'), // Arabic
  ];

  // Getters
  Locale get locale => _locale;
  List<Locale> get supportedLocales => _supportedLocales;
  bool get isLoading => _isLoading;

  LocaleProvider() {
    loadLocale();
  }

  Future<void> loadLocale() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String languageCode = prefs.getString('language_code') ?? 'en';
      final String countryCode = prefs.getString('country_code') ?? 'US';

      _locale = Locale(languageCode, countryCode);
    } catch (e) {
      debugPrint('Error loading locale: $e');
      _locale = const Locale('en', 'US');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', locale.languageCode);
      await prefs.setString('country_code', locale.countryCode ?? '');

      _locale = locale;
    } catch (e) {
      debugPrint('Error setting locale: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setLanguage(String languageCode, {String? countryCode}) async {
    final locale = Locale(languageCode, countryCode ?? '');
    await setLocale(locale);
  }

  String getCurrentLanguageName() {
    switch (_locale.languageCode) {
      case 'bn':
        return 'বাংলা';
      case 'hi':
        return 'हिन्दी';
      case 'ur':
        return 'اردو';
      case 'ne':
        return 'नेपाली';
      case 'si':
        return 'සිංහල';
      case 'ar':
        return 'العربية';
      default:
        return 'English';
    }
  }

  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'bn':
        return 'Bengali';
      case 'hi':
        return 'Hindi';
      case 'ur':
        return 'Urdu';
      case 'ne':
        return 'Nepali';
      case 'si':
        return 'Sinhala';
      case 'ar':
        return 'Arabic';
      default:
        return 'English';
    }
  }

  List<Map<String, dynamic>> getAvailableLanguages() {
    return [
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'bn', 'name': 'বাংলা', 'flag': '🇧🇩'},
      {'code': 'hi', 'name': 'हिन्दी', 'flag': '🇮🇳'},
      {'code': 'ur', 'name': 'اردو', 'flag': '🇵🇰'},
      {'code': 'ne', 'name': 'नेपाली', 'flag': '🇳🇵'},
      {'code': 'si', 'name': 'සිංහල', 'flag': '🇱🇰'},
      {'code': 'ar', 'name': 'العربية', 'flag': '🇦🇪'},
    ];
  }

  Future<void> resetToDefault() async {
    await setLocale(const Locale('en', 'US'));
  }
}