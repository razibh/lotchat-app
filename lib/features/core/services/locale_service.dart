import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/logger_service.dart';

class LocaleService {
  factory LocaleService() => _instance;
  LocaleService._internal();
  static final LocaleService _instance = LocaleService._internal();

  final LoggerService _logger = ServiceLocator().get<LoggerService>();
  
  static const String _localeKey = 'app_locale';
  Locale _currentLocale = const Locale('en');
  
  final List<Locale> _supportedLocales = const <>[
    Locale('en', 'US'), // English
    Locale('es', 'ES'), // Spanish
    Locale('fr', 'FR'), // French
    Locale('de', 'DE'), // German
    Locale('it', 'IT'), // Italian
    Locale('pt', 'PT'), // Portuguese
    Locale('ru', 'RU'), // Russian
    Locale('zh', 'CN'), // Chinese
    Locale('ja', 'JP'), // Japanese
    Locale('ko', 'KR'), // Korean
    Locale('ar', 'SA'), // Arabic
    Locale('hi', 'IN'), // Hindi
    Locale('bn', 'BD'), // Bengali
  ];

  Locale get currentLocale => _currentLocale;
  List<Locale> get supportedLocales => _supportedLocales;

  // Initialize
  Future<void> initialize() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String languageCode = prefs.getString(_localeKey) ?? 'en';
      final String countryCode = _getCountryCode(languageCode);
      _currentLocale = Locale(languageCode, countryCode);
      _logger.info('Locale loaded: $_currentLocale');
    } catch (e) {
      _logger.error('Failed to load locale', error: e);
    }
  }

  String _getCountryCode(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'US';
      case 'es':
        return 'ES';
      case 'fr':
        return 'FR';
      case 'de':
        return 'DE';
      case 'it':
        return 'IT';
      case 'pt':
        return 'PT';
      case 'ru':
        return 'RU';
      case 'zh':
        return 'CN';
      case 'ja':
        return 'JP';
      case 'ko':
        return 'KR';
      case 'ar':
        return 'SA';
      case 'hi':
        return 'IN';
      case 'bn':
        return 'BD';
      default:
        return 'US';
    }
  }

  // Set locale
  Future<bool> setLocale(String languageCode) async {
    try {
      final String countryCode = _getCountryCode(languageCode);
      _currentLocale = Locale(languageCode, countryCode);
      
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, languageCode);
      
      _logger.info('Locale changed to: $_currentLocale');
      return true;
    } catch (e) {
      _logger.error('Failed to set locale', error: e);
      return false;
    }
  }

  // Get language name
  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'it':
        return 'Italiano';
      case 'pt':
        return 'Português';
      case 'ru':
        return 'Русский';
      case 'zh':
        return '中文';
      case 'ja':
        return '日本語';
      case 'ko':
        return '한국어';
      case 'ar':
        return 'العربية';
      case 'hi':
        return 'हिन्दी';
      case 'bn':
        return 'বাংলা';
      default:
        return 'English';
    }
  }

  // Get language flag
  String getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸';
      case 'es':
        return '🇪🇸';
      case 'fr':
        return '🇫🇷';
      case 'de':
        return '🇩🇪';
      case 'it':
        return '🇮🇹';
      case 'pt':
        return '🇵🇹';
      case 'ru':
        return '🇷🇺';
      case 'zh':
        return '🇨🇳';
      case 'ja':
        return '🇯🇵';
      case 'ko':
        return '🇰🇷';
      case 'ar':
        return '🇸🇦';
      case 'hi':
        return '🇮🇳';
      case 'bn':
        return '🇧🇩';
      default:
        return '🇺🇸';
    }
  }

  // Get RTL status
  bool get isRtl {
    return _currentLocale.languageCode == 'ar';
  }

  // Get text direction
  TextDirection get textDirection {
    return isRtl ? TextDirection.rtl : TextDirection.ltr;
  }

  // Get all languages
  List<Map<String, String>> getAllLanguages() {
    return _supportedLocales.map((Locale locale) {
      return <String, >{
        'code': locale.languageCode,
        'name': getLanguageName(locale.languageCode),
        'flag': getLanguageFlag(locale.languageCode),
        'native': _getNativeName(locale.languageCode),
      };
    }).toList();
  }

  String _getNativeName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'it':
        return 'Italiano';
      case 'pt':
        return 'Português';
      case 'ru':
        return 'Русский';
      case 'zh':
        return '中文';
      case 'ja':
        return '日本語';
      case 'ko':
        return '한국어';
      case 'ar':
        return 'العربية';
      case 'hi':
        return 'हिन्दी';
      case 'bn':
        return 'বাংলা';
      default:
        return 'English';
    }
  }
}