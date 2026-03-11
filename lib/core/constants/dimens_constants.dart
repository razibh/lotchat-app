import 'package:flutter/material.dart';

class Dimens {
  // Padding
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 12.0;
  static const double paddingL = 16.0;
  static const double paddingXL = 20.0;
  static const double paddingXXL = 24.0;
  static const double paddingXXXL = 32.0;
  
  // Margin
  static const double marginXS = 4.0;
  static const double marginS = 8.0;
  static const double marginM = 12.0;
  static const double marginL = 16.0;
  static const double marginXL = 20.0;
  static const double marginXXL = 24.0;
  
  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusCircle = 999.0;
  
  // Icon Sizes
  static const double iconXS = 12.0;
  static const double iconS = 16.0;
  static const double iconM = 20.0;
  static const double iconL = 24.0;
  static const double iconXL = 28.0;
  static const double iconXXL = 32.0;
  static const double iconXXXL = 40.0;
  
  // Avatar Sizes
  static const double avatarXS = 24.0;
  static const double avatarS = 32.0;
  static const double avatarM = 40.0;
  static const double avatarL = 50.0;
  static const double avatarXL = 60.0;
  static const double avatarXXL = 80.0;
  static const double avatarXXXL = 100.0;
  
  // Font Sizes
  static const double fontXS = 10.0;
  static const double fontS = 12.0;
  static const double fontM = 14.0;
  static const double fontL = 16.0;
  static const double fontXL = 18.0;
  static const double fontXXL = 20.0;
  static const double fontXXXL = 24.0;
  static const double fontDisplay = 32.0;
  
  // Button Sizes
  static const double buttonHeightS = 36.0;
  static const double buttonHeightM = 44.0;
  static const double buttonHeightL = 52.0;
  static const double buttonWidthMin = 80.0;
  
  // AppBar
  static const double appBarHeight = 56.0;
  static const double bottomNavBarHeight = 60.0;
  
  // Card Sizes
  static const double cardWidth = 160.0;
  static const double cardHeight = 200.0;
  static const double cardImageHeight = 120.0;
  
  // Image Sizes
  static const double imageThumbnail = 100.0;
  static const double imageSmall = 200.0;
  static const double imageMedium = 300.0;
  static const double imageLarge = 400.0;
  
  // Dividers
  static const double dividerThin = 0.5;
  static const double dividerNormal = 1.0;
  static const double dividerThick = 2.0;
  
  // Elevation
  static const double elevationNone = 0.0;
  static const double elevationXS = 1.0;
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  
  // Screen Size Helpers
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  
  static bool isSmallScreen(BuildContext context) => screenWidth(context) < 360;
  static bool isMediumScreen(BuildContext context) => screenWidth(context) >= 360 && screenWidth(context) < 600;
  static bool isLargeScreen(BuildContext context) => screenWidth(context) >= 600;
}