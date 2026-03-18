import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/country_model.dart';

class CountryProvider extends ChangeNotifier {
  CountryProvider() {
    _init();
  }

  CountryModel? _selectedCountry; // 🟢 CountryModel ব্যবহার করুন
  List<CountryModel> _supportedCountries = []; // 🟢 List<CountryModel>
  bool _isLoading = false;
  String? _error;

  // Getters
  CountryModel? get selectedCountry => _selectedCountry; // 🟢 CountryModel
  List<CountryModel> get supportedCountries => _supportedCountries; // 🟢 List<CountryModel>
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasSelectedCountry => _selectedCountry != null;

  // All countries data
  final List<Map<String, String>> _allCountries = const [
    {'id': 'bd', 'name': 'Bangladesh', 'flag': '🇧🇩', 'code': 'BD', 'currency': 'BDT', 'currencySymbol': '৳', 'phoneCode': '+880'},
    {'id': 'in', 'name': 'India', 'flag': '🇮🇳', 'code': 'IN', 'currency': 'INR', 'currencySymbol': '₹', 'phoneCode': '+91'},
    {'id': 'pk', 'name': 'Pakistan', 'flag': '🇵🇰', 'code': 'PK', 'currency': 'PKR', 'currencySymbol': '₨', 'phoneCode': '+92'},
    {'id': 'np', 'name': 'Nepal', 'flag': '🇳🇵', 'code': 'NP', 'currency': 'NPR', 'currencySymbol': '₨', 'phoneCode': '+977'},
    {'id': 'lk', 'name': 'Sri Lanka', 'flag': '🇱🇰', 'code': 'LK', 'currency': 'LKR', 'currencySymbol': '₨', 'phoneCode': '+94'},
    {'id': 'us', 'name': 'United States', 'flag': '🇺🇸', 'code': 'US', 'currency': 'USD', 'currencySymbol': r'$', 'phoneCode': '+1'},
    {'id': 'gb', 'name': 'United Kingdom', 'flag': '🇬🇧', 'code': 'GB', 'currency': 'GBP', 'currencySymbol': '£', 'phoneCode': '+44'},
    {'id': 'ca', 'name': 'Canada', 'flag': '🇨🇦', 'code': 'CA', 'currency': 'CAD', 'currencySymbol': r'$', 'phoneCode': '+1'},
    {'id': 'au', 'name': 'Australia', 'flag': '🇦🇺', 'code': 'AU', 'currency': 'AUD', 'currencySymbol': r'$', 'phoneCode': '+61'},
    {'id': 'de', 'name': 'Germany', 'flag': '🇩🇪', 'code': 'DE', 'currency': 'EUR', 'currencySymbol': '€', 'phoneCode': '+49'},
    {'id': 'fr', 'name': 'France', 'flag': '🇫🇷', 'code': 'FR', 'currency': 'EUR', 'currencySymbol': '€', 'phoneCode': '+33'},
    {'id': 'jp', 'name': 'Japan', 'flag': '🇯🇵', 'code': 'JP', 'currency': 'JPY', 'currencySymbol': '¥', 'phoneCode': '+81'},
    {'id': 'cn', 'name': 'China', 'flag': '🇨🇳', 'code': 'CN', 'currency': 'CNY', 'currencySymbol': '¥', 'phoneCode': '+86'},
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
      // Convert map data to CountryModel objects
      _supportedCountries = _allCountries.map((Map<String, String> countryData) {
        return CountryModel(
          code: countryData['id']!,
          name: countryData['name']!,
          nativeName: countryData['name']!,
          phoneCode: countryData['phoneCode']!,
          flag: countryData['flag']!,
          continent: 'Asia', // Default value
          currency: countryData['currency']!,
          currencySymbol: countryData['currencySymbol']!,
          timezone: 'UTC', // Default value
          languages: ['en'], // Default value
          population: 0, // Default value
          area: 0, // Default value
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
      final String? countryCode = prefs.getString(AppConstants.prefCountry);

      if (countryCode != null) {
        _selectedCountry = getCountryByCode(countryCode);
      }
    } catch (e) {
      debugPrint('Error loading saved country: $e');
    }
    notifyListeners();
  }

  // Save selected country
  Future<bool> setSelectedCountry(String countryCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final CountryModel? country = getCountryByCode(countryCode);
      if (country == null) {
        throw Exception('Country not found');
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.prefCountry, countryCode);

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

  // Get country by code
  CountryModel? getCountryByCode(String code) {
    try {
      return _supportedCountries.firstWhere(
            (CountryModel country) => country.code.toLowerCase() == code.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Get country flag
  String getCountryFlag(String countryCode) {
    final CountryModel? country = getCountryByCode(countryCode);
    return country?.flag ?? '🌍';
  }

  // Get country name
  String getCountryName(String countryCode) {
    final CountryModel? country = getCountryByCode(countryCode);
    return country?.name ?? 'Unknown';
  }

  // Get currency symbol
  String getCurrencySymbol([String? countryCode]) {
    final String? code = countryCode ?? _selectedCountry?.code;
    if (code == null) return '৳';

    final CountryModel? country = getCountryByCode(code);
    return country?.currencySymbol ?? '৳';
  }

  // Get phone code
  String getPhoneCode([String? countryCode]) {
    final String? code = countryCode ?? _selectedCountry?.code;
    if (code == null) return '+880';

    final CountryModel? country = getCountryByCode(code);
    return country?.phoneCode ?? '+880';
  }

  // Format amount with currency
  String formatCurrency(double amount, [String? countryCode]) {
    final String symbol = getCurrencySymbol(countryCode);
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  // Get popular countries
  List<CountryModel> getPopularCountries() {
    const List<String> popularCodes = ['bd', 'in', 'pk', 'np', 'lk', 'us', 'gb', 'ae', 'sa'];
    return _supportedCountries
        .where((CountryModel country) => popularCodes.contains(country.code.toLowerCase()))
        .toList();
  }

  // Search countries
  List<CountryModel> searchCountries(String query) {
    if (query.isEmpty) return [];

    final String lowercaseQuery = query.toLowerCase();
    return _supportedCountries
        .where((CountryModel country) =>
    country.name.toLowerCase().contains(lowercaseQuery) ||
        country.code.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  // Check if country is supported
  bool isCountrySupported(String countryCode) {
    return _supportedCountries.any((CountryModel country) =>
    country.code.toLowerCase() == countryCode.toLowerCase());
  }
}