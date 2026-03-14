import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF8B5CF6); // Purple
  static const Color secondary = Color(0xFFEC4899); // Pink
  static const Color accent = Color(0xFF3B82F6); // Blue
  
  // Background Colors
  static const Color background = Color(0xFF1a1a2e);
  static const Color surface = Color(0xFF16213e);
  static const Color cardDark = Color(0xFF1E293B);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textHint = Color(0xFF64748B);
  
  // Status Colors
  static const Color success = Color(0xFF10B981); // Green
  static const Color error = Color(0xFFEF4444); // Red
  static const Color warning = Color(0xFFF59E0B); // Orange
  static const Color info = Color(0xFF3B82F6); // Blue
  
  // Tier Colors
  static const Color vip = Color(0xFFFBBF24); // Gold
  static const Color svip = LinearGradient( // Purple to Pink
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <>[Color(0xFF8B5CF6), Color(0xFFEC4899)],
  );
  
  // Room Colors
  static const Color seatEmpty = Color(0xFF334155);
  static const Color seatOccupied = Color(0xFF8B5CF6);
  static const Color seatSpeaking = Color(0xFF10B981);
  
  // Gradient Presets
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <>[primary, secondary],
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <>[Color(0xFF1a1a2e), Color(0xFF16213e)],
  );
  
  // Opacity Colors
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}