import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF8B5CF6); // Purple
  static const Color secondary = Color(0xFFEC4899); // Pink
  static const Color accent = Color(0xFF3B82F6); // Blue

  // Background Colors
  static const Color background = Color(0xFF1a1a2e);
  static const Color surface = Color(0xFF16213e);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textHint = Color(0xFF64748B);
  static const Color textPrimaryLight = Color(0xFF1F2937);
  static const Color textSecondaryLight = Color(0xFF6B7280);

  // Status Colors
  static const Color success = Color(0xFF10B981); // Green
  static const Color error = Color(0xFFEF4444); // Red
  static const Color warning = Color(0xFFF59E0B); // Orange
  static const Color info = Color(0xFF3B82F6); // Blue

  // Tier Colors - 🟢 Fixed: এগুলো Color type, Gradient না
  static const Color vip = Color(0xFFFBBF24); // Gold
  static const Color svip = Color(0xFF8B5CF6); // Purple (or any color)

  // Room Colors
  static const Color seatEmpty = Color(0xFF334155);
  static const Color seatOccupied = Color(0xFF8B5CF6);
  static const Color seatSpeaking = Color(0xFF10B981);

  // VIP/SVIP Badge Colors
  static const Color vipBadge = Color(0xFFFBBF24); // Gold
  static const Color vipBadgeLight = Color(0xFFFCD34D);
  static const Color vipBadgeDark = Color(0xFFB45309);

  static const Color svipBadge = Color(0xFF8B5CF6); // Purple
  static const Color svipBadgeLight = Color(0xFFA78BFA);
  static const Color svipBadgeDark = Color(0xFF6D28D9);

  // Gradient Presets - 🟢 আলাদা variable
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
  );

  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF5F5F5), Colors.white],
  );

  static const LinearGradient vipGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
  );

  static const LinearGradient svipGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
  );

  // Chat Bubble Colors
  static const Color myMessage = Color(0xFF8B5CF6);
  static const Color otherMessage = Color(0xFF334155);

  // Button Colors
  static const Color buttonPrimary = Color(0xFF8B5CF6);
  static const Color buttonSecondary = Color(0xFF334155);
  static const Color buttonDisabled = Color(0xFF64748B);

  // Border Colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);

  // Overlay Colors
  static Color overlayLight = Colors.white.withValues(alpha: 0.1);
  static Color overlayDark = Colors.black.withValues(alpha: 0.5);
  static Color overlayMedium = Colors.black.withValues(alpha: 0.3);

  // Shadow Colors
  static Color shadowLight = Colors.black.withValues(alpha: 0.1);
  static Color shadowMedium = Colors.black.withValues(alpha: 0.2);
  static Color shadowDark = Colors.black.withValues(alpha: 0.3);

  // Opacity Methods
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  // Color Brightness Methods
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  // Theme Helpers
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color getScaffoldBackground(BuildContext context) {
    return isDark(context) ? background : backgroundLight;
  }

  static Color getSurfaceColor(BuildContext context) {
    return isDark(context) ? surface : surfaceLight;
  }

  static Color getTextPrimary(BuildContext context) {
    return isDark(context) ? textPrimary : textPrimaryLight;
  }

  static Color getTextSecondary(BuildContext context) {
    return isDark(context) ? textSecondary : textSecondaryLight;
  }
}