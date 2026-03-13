import 'package:flutter/material.dart';

class FontConstants {
  // Font Families
  static const String poppins = 'Poppins';
  static const String roboto = 'Roboto';
  static const String inter = 'Inter';
  static const String montserrat = 'Montserrat';
  static const String openSans = 'OpenSans';
  static const String lato = 'Lato';
  static const String raleway = 'Raleway';
  static const String nunito = 'Nunito';

  // Font Weights
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // Text Styles
  static const TextStyle displayLarge = TextStyle(
    fontFamily: poppins,
    fontSize: 32,
    fontWeight: bold,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: poppins,
    fontSize: 28,
    fontWeight: bold,
    letterSpacing: -0.5,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: poppins,
    fontSize: 24,
    fontWeight: bold,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: poppins,
    fontSize: 22,
    fontWeight: semiBold,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: poppins,
    fontSize: 20,
    fontWeight: semiBold,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: poppins,
    fontSize: 18,
    fontWeight: semiBold,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: poppins,
    fontSize: 16,
    fontWeight: bold,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: poppins,
    fontSize: 14,
    fontWeight: bold,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: poppins,
    fontSize: 12,
    fontWeight: bold,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: poppins,
    fontSize: 16,
    fontWeight: regular,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: poppins,
    fontSize: 14,
    fontWeight: regular,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: poppins,
    fontSize: 12,
    fontWeight: regular,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: poppins,
    fontSize: 14,
    fontWeight: medium,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: poppins,
    fontSize: 12,
    fontWeight: medium,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: poppins,
    fontSize: 10,
    fontWeight: medium,
  );

  // Button Styles
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: poppins,
    fontSize: 16,
    fontWeight: semiBold,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: poppins,
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0.25,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: poppins,
    fontSize: 12,
    fontWeight: medium,
  );

  // Caption Styles
  static const TextStyle caption = TextStyle(
    fontFamily: poppins,
    fontSize: 12,
    fontWeight: regular,
    color: Colors.grey,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: poppins,
    fontSize: 10,
    fontWeight: regular,
    letterSpacing: 1.5,
  );

  // Digital/Numbers Style
  static const TextStyle digital = TextStyle(
    fontFamily: roboto,
    fontSize: 14,
    fontWeight: bold,
  );

  // App Specific Styles
  static const TextStyle appTitle = TextStyle(
    fontFamily: poppins,
    fontSize: 24,
    fontWeight: bold,
    letterSpacing: 1,
  );

  static const TextStyle appSubtitle = TextStyle(
    fontFamily: poppins,
    fontSize: 16,
    fontWeight: regular,
    color: Colors.grey,
  );

  static const TextStyle navLabel = TextStyle(
    fontFamily: poppins,
    fontSize: 12,
    fontWeight: medium,
  );

  static const TextStyle badgeLabel = TextStyle(
    fontFamily: poppins,
    fontSize: 10,
    fontWeight: bold,
  );

  static const TextStyle priceLabel = TextStyle(
    fontFamily: roboto,
    fontSize: 16,
    fontWeight: bold,
    color: Colors.green,
  );

  static const TextStyle usernameStyle = TextStyle(
    fontFamily: poppins,
    fontSize: 14,
    fontWeight: medium,
  );

  static const TextStyle timestampStyle = TextStyle(
    fontFamily: poppins,
    fontSize: 10,
    fontWeight: regular,
    color: Colors.grey,
  );

  static const TextStyle messageStyle = TextStyle(
    fontFamily: poppins,
    fontSize: 14,
    fontWeight: regular,
  );

  static const TextStyle giftNameStyle = TextStyle(
    fontFamily: poppins,
    fontSize: 12,
    fontWeight: bold,
  );

  static const TextStyle roomNameStyle = TextStyle(
    fontFamily: poppins,
    fontSize: 16,
    fontWeight: bold,
  );

  static const TextStyle viewerCountStyle = TextStyle(
    fontFamily: roboto,
    fontSize: 12,
    fontWeight: medium,
    color: Colors.grey,
  );
}

// Font Weight Extensions
extension FontWeightExtension on FontWeight {
  static const FontWeight w100 = FontWeight.w100;
  static const FontWeight w200 = FontWeight.w200;
  static const FontWeight w300 = FontWeight.w300;
  static const FontWeight w400 = FontWeight.w400;
  static const FontWeight w500 = FontWeight.w500;
  static const FontWeight w600 = FontWeight.w600;
  static const FontWeight w700 = FontWeight.w700;
  static const FontWeight w800 = FontWeight.w800;
  static const FontWeight w900 = FontWeight.w900;
}

// Font Size Extensions
class FontSizes {
  static const double xs = 10;
  static const double sm = 12;
  static const double base = 14;
  static const double lg = 16;
  static const double xl = 18;
  static const double xxl = 20;
  static const double xxxl = 24;
  static const double display = 32;
}