import 'package:shared_preferences/shared_preferences.dart';

class CountryHelper {
  static const String _selectedCountryKey = 'selected_country';

  static Future<void> setSelectedCountry(String countryId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedCountryKey, countryId);
  }

  static Future<String?> getSelectedCountry() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedCountryKey);
  }

  static Future<void> clearSelectedCountry() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedCountryKey);
  }

  static String getCountryCode(String countryId) {
    switch (countryId) {
      case 'bd':
        return '+880';
      case 'in':
        return '+91';
      case 'pk':
        return '+92';
      case 'np':
        return '+977';
      case 'lk':
        return '+94';
      default:
        return '+880';
    }
  }

  static String getCurrency(String countryId) {
    switch (countryId) {
      case 'bd':
        return 'BDT';
      case 'in':
        return 'INR';
      case 'pk':
        return 'PKR';
      case 'np':
        return 'NPR';
      case 'lk':
        return 'LKR';
      default:
        return 'BDT';
    }
  }
}