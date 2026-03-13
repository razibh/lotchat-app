import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'theme_mode';
  
  // Save theme mode
  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  // Load theme mode
  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_themeKey) ?? 0;
    return ThemeMode.values[index];
  }

  // Get system theme
  static ThemeMode getSystemTheme() {
    return ThemeMode.system;
  }

  // Check if dark mode is enabled
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // Get theme name
  static String getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  // Get theme icon
  static IconData getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.sunny;
      case ThemeMode.dark:
        return Icons.nightlight_round;
      case ThemeMode.system:
        return Icons.brightness_4;
    }
  }

  // Toggle theme
  static ThemeMode toggleTheme(ThemeMode current) {
    switch (current) {
      case ThemeMode.light:
        return ThemeMode.dark;
      case ThemeMode.dark:
        return ThemeMode.system;
      case ThemeMode.system:
        return ThemeMode.light;
    }
  }

  // Get theme colors
  static Map<String, Color> getThemeColors(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return <String, >{
        'background': const Color(0xFF1a1a2e),
        'surface': const Color(0xFF16213e),
        'card': const Color(0xFF1E293B),
        'text': Colors.white,
        'textSecondary': Colors.white70,
        'textHint': Colors.white38,
      };
    } else {
      return <String, >{
        'background': const Color(0xFFF5F5F5),
        'surface': Colors.white,
        'card': Colors.white,
        'text': const Color(0xFF1F2937),
        'textSecondary': const Color(0xFF6B7280),
        'textHint': const Color(0xFF9CA3AF),
      };
    }
  }
}

// Theme Provider for state management
class ThemeProvider extends ChangeNotifier {

  ThemeProvider() {
    _loadTheme();
  }
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> _loadTheme() async {
    _themeMode = await ThemeService.loadThemeMode();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await ThemeService.saveThemeMode(mode);
      notifyListeners();
    }
  }

  void toggleTheme() {
    setThemeMode(ThemeService.toggleTheme(_themeMode));
  }
}

// Theme Helper Widget
class ThemeBuilder extends StatelessWidget {

  const ThemeBuilder({Key? key, required this.builder}) : super(key: key);
  final Widget Function(BuildContext context, ThemeMode themeMode) builder;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, provider, child) {
        return builder(context, provider.themeMode);
      },
    );
  }
}