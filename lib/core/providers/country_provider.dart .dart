import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/country_models.dart';

class CountryProvider extends ChangeNotifier {

  CountryProvider() {
    _init();
  }
  Country? _selectedCountry;
  List<Country> _supportedCountries = <Country>[];
  bool _isLoading = false;
  String? _error;

  // Getters
  Country? get selectedCountry => _selectedCountry;
  List<Country> get supportedCountries => _supportedCountries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasSelectedCountry => _selectedCountry != null;

  // All countries data
  final List<Map<String, String>> _allCountries = const <Map<String, String>>[
    <String, String>{'id': 'bd', 'name': 'Bangladesh', 'flag': '🇧🇩', 'code': 'BD', 'currency': 'BDT', 'currencySymbol': '৳', 'phoneCode': '+880'},
    <String, String>{'id': 'in', 'name': 'India', 'flag': '🇮🇳', 'code': 'IN', 'currency': 'INR', 'currencySymbol': '₹', 'phoneCode': '+91'},
    <String, String>{'id': 'pk', 'name': 'Pakistan', 'flag': '🇵🇰', 'code': 'PK', 'currency': 'PKR', 'currencySymbol': '₨', 'phoneCode': '+92'},
    <String, String>{'id': 'np', 'name': 'Nepal', 'flag': '🇳🇵', 'code': 'NP', 'currency': 'NPR', 'currencySymbol': '₨', 'phoneCode': '+977'},
    <String, String>{'id': 'lk', 'name': 'Sri Lanka', 'flag': '🇱🇰', 'code': 'LK', 'currency': 'LKR', 'currencySymbol': '₨', 'phoneCode': '+94'},
    <String, String>{'id': 'mm', 'name': 'Myanmar', 'flag': '🇲🇲', 'code': 'MM', 'currency': 'MMK', 'currencySymbol': 'K', 'phoneCode': '+95'},
    <String, String>{'id': 'af', 'name': 'Afghanistan', 'flag': '🇦🇫', 'code': 'AF', 'currency': 'AFN', 'currencySymbol': '؋', 'phoneCode': '+93'},
    <String, String>{'id': 'ir', 'name': 'Iran', 'flag': '🇮🇷', 'code': 'IR', 'currency': 'IRR', 'currencySymbol': '﷼', 'phoneCode': '+98'},
    <String, String>{'id': 'sa', 'name': 'Saudi Arabia', 'flag': '🇸🇦', 'code': 'SA', 'currency': 'SAR', 'currencySymbol': '﷼', 'phoneCode': '+966'},
    <String, String>{'id': 'ae', 'name': 'UAE', 'flag': '🇦🇪', 'code': 'AE', 'currency': 'AED', 'currencySymbol': 'د.إ', 'phoneCode': '+971'},
    <String, String>{'id': 'qa', 'name': 'Qatar', 'flag': '🇶🇦', 'code': 'QA', 'currency': 'QAR', 'currencySymbol': '﷼', 'phoneCode': '+974'},
    <String, String>{'id': 'kw', 'name': 'Kuwait', 'flag': '🇰🇼', 'code': 'KW', 'currency': 'KWD', 'currencySymbol': 'د.ك', 'phoneCode': '+965'},
    <String, String>{'id': 'om', 'name': 'Oman', 'flag': '🇴🇲', 'code': 'OM', 'currency': 'OMR', 'currencySymbol': '﷼', 'phoneCode': '+968'},
    <String, String>{'id': 'bh', 'name': 'Bahrain', 'flag': '🇧🇭', 'code': 'BH', 'currency': 'BHD', 'currencySymbol': 'د.ب', 'phoneCode': '+973'},
    <String, String>{'id': 'jo', 'name': 'Jordan', 'flag': '🇯🇴', 'code': 'JO', 'currency': 'JOD', 'currencySymbol': 'د.ا', 'phoneCode': '+962'},
    <String, String>{'id': 'lb', 'name': 'Lebanon', 'flag': '🇱🇧', 'code': 'LB', 'currency': 'LBP', 'currencySymbol': 'ل.ل', 'phoneCode': '+961'},
    <String, String>{'id': 'ps', 'name': 'Palestine', 'flag': '🇵🇸', 'code': 'PS', 'currency': 'ILS', 'currencySymbol': '₪', 'phoneCode': '+970'},
    <String, String>{'id': 'iq', 'name': 'Iraq', 'flag': '🇮🇶', 'code': 'IQ', 'currency': 'IQD', 'currencySymbol': 'د.ع', 'phoneCode': '+964'},
    <String, String>{'id': 'sy', 'name': 'Syria', 'flag': '🇸🇾', 'code': 'SY', 'currency': 'SYP', 'currencySymbol': '£', 'phoneCode': '+963'},
    <String, String>{'id': 'ye', 'name': 'Yemen', 'flag': '🇾🇪', 'code': 'YE', 'currency': 'YER', 'currencySymbol': '﷼', 'phoneCode': '+967'},
    <String, String>{'id': 'eg', 'name': 'Egypt', 'flag': '🇪🇬', 'code': 'EG', 'currency': 'EGP', 'currencySymbol': '£', 'phoneCode': '+20'},
    <String, String>{'id': 'ly', 'name': 'Libya', 'flag': '🇱🇾', 'code': 'LY', 'currency': 'LYD', 'currencySymbol': 'ل.د', 'phoneCode': '+218'},
    <String, String>{'id': 'sd', 'name': 'Sudan', 'flag': '🇸🇩', 'code': 'SD', 'currency': 'SDG', 'currencySymbol': 'ج.س', 'phoneCode': '+249'},
    <String, String>{'id': 'ma', 'name': 'Morocco', 'flag': '🇲🇦', 'code': 'MA', 'currency': 'MAD', 'currencySymbol': 'د.م', 'phoneCode': '+212'},
    <String, String>{'id': 'dz', 'name': 'Algeria', 'flag': '🇩🇿', 'code': 'DZ', 'currency': 'DZD', 'currencySymbol': 'د.ج', 'phoneCode': '+213'},
    <String, String>{'id': 'tn', 'name': 'Tunisia', 'flag': '🇹🇳', 'code': 'TN', 'currency': 'TND', 'currencySymbol': 'د.ت', 'phoneCode': '+216'},
    <String, String>{'id': 'us', 'name': 'United States', 'flag': '🇺🇸', 'code': 'US', 'currency': 'USD', 'currencySymbol': r'$', 'phoneCode': '+1'},
    <String, String>{'id': 'gb', 'name': 'United Kingdom', 'flag': '🇬🇧', 'code': 'GB', 'currency': 'GBP', 'currencySymbol': '£', 'phoneCode': '+44'},
    <String, String>{'id': 'ca', 'name': 'Canada', 'flag': '🇨🇦', 'code': 'CA', 'currency': 'CAD', 'currencySymbol': r'$', 'phoneCode': '+1'},
    <String, String>{'id': 'au', 'name': 'Australia', 'flag': '🇦🇺', 'code': 'AU', 'currency': 'AUD', 'currencySymbol': r'$', 'phoneCode': '+61'},
    <String, String>{'id': 'de', 'name': 'Germany', 'flag': '🇩🇪', 'code': 'DE', 'currency': 'EUR', 'currencySymbol': '€', 'phoneCode': '+49'},
    <String, String>{'id': 'fr', 'name': 'France', 'flag': '🇫🇷', 'code': 'FR', 'currency': 'EUR', 'currencySymbol': '€', 'phoneCode': '+33'},
    <String, String>{'id': 'it', 'name': 'Italy', 'flag': '🇮🇹', 'code': 'IT', 'currency': 'EUR', 'currencySymbol': '€', 'phoneCode': '+39'},
    <String, String>{'id': 'es', 'name': 'Spain', 'flag': '🇪🇸', 'code': 'ES', 'currency': 'EUR', 'currencySymbol': '€', 'phoneCode': '+34'},
    <String, String>{'id': 'pt', 'name': 'Portugal', 'flag': '🇵🇹', 'code': 'PT', 'currency': 'EUR', 'currencySymbol': '€', 'phoneCode': '+351'},
    <String, String>{'id': 'nl', 'name': 'Netherlands', 'flag': '🇳🇱', 'code': 'NL', 'currency': 'EUR', 'currencySymbol': '€', 'phoneCode': '+31'},
    <String, String>{'id': 'be', 'name': 'Belgium', 'flag': '🇧🇪', 'code': 'BE', 'currency': 'EUR', 'currencySymbol': '€', 'phoneCode': '+32'},
    <String, String>{'id': 'ch', 'name': 'Switzerland', 'flag': '🇨🇭', 'code': 'CH', 'currency': 'CHF', 'currencySymbol': 'Fr', 'phoneCode': '+41'},
    <String, String>{'id': 'at', 'name': 'Austria', 'flag': '🇦🇹', 'code': 'AT', 'currency': 'EUR', 'currencySymbol': '€', 'phoneCode': '+43'},
    <String, String>{'id': 'se', 'name': 'Sweden', 'flag': '🇸🇪', 'code': 'SE', 'currency': 'SEK', 'currencySymbol': 'kr', 'phoneCode': '+46'},
    <String, String>{'id': 'no', 'name': 'Norway', 'flag': '🇳🇴', 'code': 'NO', 'currency': 'NOK', 'currencySymbol': 'kr', 'phoneCode': '+47'},
    <String, String>{'id': 'dk', 'name': 'Denmark', 'flag': '🇩🇰', 'code': 'DK', 'currency': 'DKK', 'currencySymbol': 'kr', 'phoneCode': '+45'},
    <String, String>{'id': 'fi', 'name': 'Finland', 'flag': '🇫🇮', 'code': 'FI', 'currency': 'EUR', 'currencySymbol': '€', 'phoneCode': '+358'},
    <String, String>{'id': 'ie', 'name': 'Ireland', 'flag': '🇮🇪', 'code': 'IE', 'currency': 'EUR', 'currencySymbol': '€', 'phoneCode': '+353'},
    <String, String>{'id': 'pl', 'name': 'Poland', 'flag': '🇵🇱', 'code': 'PL', 'currency': 'PLN', 'currencySymbol': 'zł', 'phoneCode': '+48'},
    <String, String>{'id': 'cz', 'name': 'Czech Republic', 'flag': '🇨🇿', 'code': 'CZ', 'currency': 'CZK', 'currencySymbol': 'Kč', 'phoneCode': '+420'},
    <String, String>{'id': 'hu', 'name': 'Hungary', 'flag': '🇭🇺', 'code': 'HU', 'currency': 'HUF', 'currencySymbol': 'Ft', 'phoneCode': '+36'},
    <String, String>{'id': 'ro', 'name': 'Romania', 'flag': '🇷🇴', 'code': 'RO', 'currency': 'RON', 'currencySymbol': 'lei', 'phoneCode': '+40'},
    <String, String>{'id': 'bg', 'name': 'Bulgaria', 'flag': '🇧🇬', 'code': 'BG', 'currency': 'BGN', 'currencySymbol': 'лв', 'phoneCode': '+359'},
    <String, String>{'id': 'gr', 'name': 'Greece', 'flag': '🇬🇷', 'code': 'GR', 'currency': 'EUR', 'currencySymbol': '€', 'phoneCode': '+30'},
    <String, String>{'id': 'tr', 'name': 'Turkey', 'flag': '🇹🇷', 'code': 'TR', 'currency': 'TRY', 'currencySymbol': '₺', 'phoneCode': '+90'},
    <String, String>{'id': 'ru', 'name': 'Russia', 'flag': '🇷🇺', 'code': 'RU', 'currency': 'RUB', 'currencySymbol': '₽', 'phoneCode': '+7'},
    <String, String>{'id': 'cn', 'name': 'China', 'flag': '🇨🇳', 'code': 'CN', 'currency': 'CNY', 'currencySymbol': '¥', 'phoneCode': '+86'},
    <String, String>{'id': 'jp', 'name': 'Japan', 'flag': '🇯🇵', 'code': 'JP', 'currency': 'JPY', 'currencySymbol': '¥', 'phoneCode': '+81'},
    <String, String>{'id': 'kr', 'name': 'South Korea', 'flag': '🇰🇷', 'code': 'KR', 'currency': 'KRW', 'currencySymbol': '₩', 'phoneCode': '+82'},
    <String, String>{'id': 'sg', 'name': 'Singapore', 'flag': '🇸🇬', 'code': 'SG', 'currency': 'SGD', 'currencySymbol': r'$', 'phoneCode': '+65'},
    <String, String>{'id': 'my', 'name': 'Malaysia', 'flag': '🇲🇾', 'code': 'MY', 'currency': 'MYR', 'currencySymbol': 'RM', 'phoneCode': '+60'},
    <String, String>{'id': 'th', 'name': 'Thailand', 'flag': '🇹🇭', 'code': 'TH', 'currency': 'THB', 'currencySymbol': '฿', 'phoneCode': '+66'},
    <String, String>{'id': 'vn', 'name': 'Vietnam', 'flag': '🇻🇳', 'code': 'VN', 'currency': 'VND', 'currencySymbol': '₫', 'phoneCode': '+84'},
    <String, String>{'id': 'ph', 'name': 'Philippines', 'flag': '🇵🇭', 'code': 'PH', 'currency': 'PHP', 'currencySymbol': '₱', 'phoneCode': '+63'},
    <String, String>{'id': 'id', 'name': 'Indonesia', 'flag': '🇮🇩', 'code': 'ID', 'currency': 'IDR', 'currencySymbol': 'Rp', 'phoneCode': '+62'},
  ];

  Future<void> _init() async {
    await loadSupportedCountries();
    await loadSavedCountry();
  }

  // Load all supported countries
  Future<void> loadSupportedCountries() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Convert map data to Country objects
      _supportedCountries = _allCountries.map((Map<String, String> countryData) {
        return Country(
          id: countryData['id']!,
          name: countryData['name']!,
          flag: countryData['flag']!,
          code: countryData['code']!,
          currency: countryData['currency']!,
          currencySymbol: countryData['currencySymbol']!,
          phoneCode: countryData['phoneCode']!,
        );
      }).toList();

      _error = null;
    } catch (e) {
      _error = 'Failed to load countries: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load saved country from SharedPreferences
  Future<void> loadSavedCountry() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? countryId = prefs.getString(AppConstants.prefCountry);
      
      if (countryId != null) {
        _selectedCountry = getCountryById(countryId);
      }
    } catch (e) {
      debugPrint('Error loading saved country: $e');
    }
    notifyListeners();
  }

  // Save selected country
  Future<bool> setSelectedCountry(String countryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final Country? country = getCountryById(countryId);
      if (country == null) {
        throw Exception('Country not found');
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.prefCountry, countryId);
      
      _selectedCountry = country;
      _error = null;
      
      return true;
    } catch (e) {
      _error = 'Failed to save country: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear selected country
  Future<void> clearSelectedCountry() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.prefCountry);
      _selectedCountry = null;
    } catch (e) {
      debugPrint('Error clearing country: $e');
    }
    notifyListeners();
  }

  // Get country by ID
  Country? getCountryById(String id) {
    try {
      return _supportedCountries.firstWhere(
        (Country country) => country.id == id,
        orElse: () => _supportedCountries.first,
      );
    } catch (e) {
      return null;
    }
  }

  // Get country by name
  Country? getCountryByName(String name) {
    try {
      return _supportedCountries.firstWhere(
        (Country country) => country.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Get country by code
  Country? getCountryByCode(String code) {
    try {
      return _supportedCountries.firstWhere(
        (Country country) => country.code.toLowerCase() == code.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Get country flag
  String getCountryFlag(String countryId) {
    final Country? country = getCountryById(countryId);
    return country?.flag ?? '🌍';
  }

  // Get country name
  String getCountryName(String countryId) {
    final Country? country = getCountryById(countryId);
    return country?.name ?? 'Unknown';
  }

  // Get currency symbol
  String getCurrencySymbol([String? countryId]) {
    final String? id = countryId ?? _selectedCountry?.id;
    if (id == null) return '৳';
    
    final Country? country = getCountryById(id);
    return country?.currencySymbol ?? '৳';
  }

  // Get phone code
  String getPhoneCode([String? countryId]) {
    final String? id = countryId ?? _selectedCountry?.id;
    if (id == null) return '+880';
    
    final Country? country = getCountryById(id);
    return country?.phoneCode ?? '+880';
  }

  // Format amount with currency
  String formatCurrency(double amount, [String? countryId]) {
    final String symbol = getCurrencySymbol(countryId);
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  // Get popular countries (for quick selection)
  List<Country> getPopularCountries() {
    const List<String> popularIds = <String>['bd', 'in', 'pk', 'np', 'lk', 'us', 'gb', 'ae', 'sa'];
    return _supportedCountries
        .where((Country country) => popularIds.contains(country.id))
        .toList();
  }

  // Get nearby countries based on selected country
  List<Country> getNearbyCountries() {
    if (_selectedCountry == null) return <Country>[];
    
    final var nearbyMap = <String, List<String>><String;
    final var List<String>><String, List<String>>{
      'bd': <String>['in', 'np', 'pk', 'lk'],
      'in': <String>['bd', 'np', 'pk', 'lk'],
      'pk': <String>['in', 'af', 'ir'],
      'np': <String>['in', 'bd'],
      'lk': <String>['in'],
      'ae': <String>['sa', 'qa', 'kw', 'om'],
      'sa': <String>['ae', 'qa', 'kw', 'ye'],
    };

    final nearbyIds = nearbyMap[_selectedCountry!.id] ?? <String>[];
    return _supportedCountries
        .where((Country country) => nearbyIds.contains(country.id))
        .toList();
  }

  // Validate phone number based on country
  bool isValidPhoneNumber(String phoneNumber, [String? countryId]) {
    final String? id = countryId ?? _selectedCountry?.id;
    if (id == null) return false;

    // Basic phone number validation patterns
    switch (id) {
      case 'bd':
        // Bangladesh: 11 digits, starts with 01
        return RegExp(r'^01[3-9]\d{8}$').hasMatch(phoneNumber);
      case 'in':
        // India: 10 digits
        return RegExp(r'^[6-9]\d{9}$').hasMatch(phoneNumber);
      case 'pk':
        // Pakistan: 11 digits, starts with 03
        return RegExp(r'^03\d{9}$').hasMatch(phoneNumber);
      case 'us':
      case 'ca':
        // US/Canada: 10 digits
        return RegExp(r'^\d{10}$').hasMatch(phoneNumber);
      default:
        // Default: at least 8 digits
        return RegExp(r'^\d{8,15}$').hasMatch(phoneNumber);
    }
  }

  // Get all countries as JSON (for API)
  List<Map<String, dynamic>> getCountriesJson() {
    return _supportedCountries.map((Country country) => country.toJson()).toList();
  }

  // Refresh countries data
  Future<void> refreshCountries() async {
    await loadSupportedCountries();
  }

  // Reset to default
  Future<void> resetToDefault() async {
    await clearSelectedCountry();
    // Optionally set default country (e.g., Bangladesh)
    // await setSelectedCountry('bd');
  }

  // Check if country is supported
  bool isCountrySupported(String countryId) {
    return _supportedCountries.any((Country country) => country.id == countryId);
  }

  // Get country suggestions based on query
  List<Country> searchCountries(String query) {
    if (query.isEmpty) return <Country>[];
    
    final String lowercaseQuery = query.toLowerCase();
    return _supportedCountries
        .where((Country country) =>
            country.name.toLowerCase().contains(lowercaseQuery) ||
            country.code.toLowerCase().contains(lowercaseQuery),)
        .toList();
  }
}

// Extension methods for Country
extension CountryExtension on Country {
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'flag': flag,
      'code': code,
      'currency': currency,
      'currencySymbol': currencySymbol,
      'phoneCode': phoneCode,
    };
  }

  static Country fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      name: json['name'],
      flag: json['flag'],
      code: json['code'],
      currency: json['currency'],
      currencySymbol: json['currencySymbol'],
      phoneCode: json['phoneCode'],
    );
  }
}