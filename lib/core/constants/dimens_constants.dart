import 'package:flutter/material.dart';

class Dimens {
  // Padding
  static const double paddingXS = 4;
  static const double paddingS = 8;
  static const double paddingM = 12;
  static const double paddingL = 16;
  static const double paddingXL = 20;
  static const double paddingXXL = 24;
  static const double paddingXXXL = 32;
  
  // Margin
  static const double marginXS = 4;
  static const double marginS = 8;
  static const double marginM = 12;
  static const double marginL = 16;
  static const double marginXL = 20;
  static const double marginXXL = 24;
  
  // Border Radius
  static const double radiusXS = 4;
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 20;
  static const double radiusXXL = 24;
  static const double radiusCircle = 999;
  
  // Icon Sizes
  static const double iconXS = 12;
  static const double iconS = 16;
  static const double iconM = 20;
  static const double iconL = 24;
  static const double iconXL = 28;
  static const double iconXXL = 32;
  static const double iconXXXL = 40;
  
  // Avatar Sizes
  static const double avatarXS = 24;
  static const double avatarS = 32;
  static const double avatarM = 40;
  static const double avatarL = 50;
  static const double avatarXL = 60;
  static const double avatarXXL = 80;
  static const double avatarXXXL = 100;
  
  // Font Sizes
  static const double fontXS = 10;
  static const double fontS = 12;
  static const double fontM = 14;
  static const double fontL = 16;
  static const double fontXL = 18;
  static const double fontXXL = 20;
  static const double fontXXXL = 24;
  static const double fontDisplay = 32;
  
  // Button Sizes
  static const double buttonHeightS = 36;
  static const double buttonHeightM = 44;
  static const double buttonHeightL = 52;
  static const double buttonWidthMin = 80;
  
  // AppBar
  static const double appBarHeight = 56;
  static const double bottomNavBarHeight = 60;
  
  // Card Sizes
  static const double cardWidth = 160;
  static const double cardHeight = 200;
  static const double cardImageHeight = 120;
  
  // Image Sizes
  static const double imageThumbnail = 100;
  static const double imageSmall = 200;
  static const double imageMedium = 300;
  static const double imageLarge = 400;
  
  // Dividers
  static const double dividerThin = 0.5;
  static const double dividerNormal = 1;
  static const double dividerThick = 2;
  
  // Elevation
  static const double elevationNone = 0;
  static const double elevationXS = 1;
  static const double elevationS = 2;
  static const double elevationM = 4;
  static const double elevationL = 8;
  
  // Screen Size Helpers
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  
  static bool isSmallScreen(BuildContext context) => screenWidth(context) < 360;
  static bool isMediumScreen(BuildContext context) => screenWidth(context) >= 360 && screenWidth(context) < 600;
  static bool isLargeScreen(BuildContext context) => screenWidth(context) >= 600;
}