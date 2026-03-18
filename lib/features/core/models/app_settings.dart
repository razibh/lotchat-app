import 'package:flutter/material.dart';

class AppSettings {
  // App Info
  static const String appName = 'LotChat';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String appPackageName = 'com.lotchat.app';

  // API Settings
  static const String apiBaseUrl = 'https://api.lotchat.com/v1';
  static const String socketUrl = 'wss://socket.lotchat.com';
  static const String cdnUrl = 'https://cdn.lotchat.com';

  // API Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  static const Duration socketTimeout = Duration(minutes: 1);

  // Retry Settings
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  // Pagination Settings
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache Settings
  static const Duration cacheDuration = Duration(hours: 1);
  static const int maxCacheSize = 100; // MB

  // Image Settings
  static const double imageQuality = 0.8;
  static const int imageMaxWidth = 1920;
  static const int imageMaxHeight = 1080;
  static const int imageMinWidth = 100;
  static const int imageMinHeight = 100;
  static const int avatarSize = 200;
  static const int thumbnailSize = 100;

  // File Settings
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedVideoTypes = ['mp4', 'mov', 'avi', 'mkv'];
  static const List<String> allowedAudioTypes = ['mp3', 'wav', 'aac', 'ogg'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'txt'];

  // Animation Settings
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Curve animationCurve = Curves.easeInOut;

  // Chat Settings
  static const int maxMessageLength = 1000;
  static const int maxMediaPerMessage = 5;
  static const int typingTimeout = 3000; // milliseconds
  static const int messageLoadLimit = 50;

  // Call Settings
  static const int maxCallDuration = 60; // minutes
  static const int maxParticipants = 8;
  static const int iceGatheringTimeout = 5000; // milliseconds

  // Gift Settings
  static const int minGiftPrice = 1;
  static const int maxGiftPrice = 1000;
  static const int giftAnimationDuration = 800; // milliseconds

  // Game Settings
  static const int minBetAmount = 10;
  static const int maxBetAmount = 10000;
  static const int gameTimeout = 30; // seconds

  // Coin Settings
  static const int minCoinPurchase = 100;
  static const int maxCoinPurchase = 1000000;
  static const double coinExchangeRate = 1.0; // 1 coin = 1 taka
  static const int welcomeBonus = 1000;
  static const int referralBonus = 500;

  // Diamond Settings
  static const int diamondExchangeRate = 10; // 1 diamond = 10 coins
  static const int minDiamondWithdraw = 100;
  static const double withdrawFee = 0.05; // 5%

  // Seller Settings
  static const int minSellerDiscount = 5; // percent
  static const int maxSellerDiscount = 30; // percent
  static const double sellerCommission = 0.05; // 5%
  static const int minSellerCoins = 1000;

  // Clan Settings
  static const int minClanNameLength = 3;
  static const int maxClanNameLength = 20;
  static const int maxClanMembers = 50;
  static const int clanWarDuration = 24; // hours
  static const int clanTaskReset = 24; // hours

  // PK Battle Settings
  static const int pkBattleDuration = 5; // minutes
  static const int minPkBet = 100;
  static const int maxPkBet = 10000;

  // Agency Settings
  static const double agencyCommission = 0.1; // 10%
  static const int minAgencyMembers = 5;
  static const int maxAgencyMembers = 50;

  // Location Settings
  static const double defaultLatitude = 23.8103;
  static const double defaultLongitude = 90.4125;
  static const int locationUpdateInterval = 10000; // milliseconds
  static const int locationAccuracy = 100; // meters

  // Notification Settings
  static const int maxNotifications = 100;
  static const Duration notificationTimeout = Duration(seconds: 5);

  // Security Settings
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int sessionTimeout = 30; // minutes
  static const int maxLoginAttempts = 5;
  static const int lockoutDuration = 15; // minutes
  static const int otpExpiry = 5; // minutes

  // Rate Limiting
  static const int maxRequestsPerMinute = 60;
  static const int maxRequestsPerHour = 1000;

  // Feature Flags
  static const bool enableVoiceCall = true;
  static const bool enableVideoCall = true;
  static const bool enableGames = true;
  static const bool enableClans = true;
  static const bool enablePkBattle = true;
  static const bool enableAgency = true;
  static const bool enableSeller = true;

  // Debug Settings
  static const bool debugMode = true;
  static const bool logNetworkRequests = true;
  static const bool logSocketEvents = true;
  static const bool logAnalytics = false;

  // Environment
  static const Environment environment = Environment.development;

  // Theme Settings
  static const ThemeMode defaultThemeMode = ThemeMode.system;
  static const Brightness defaultBrightness = Brightness.light;
  static const Color primaryColor = Color(0xFF6C5CE7);
  static const Color accentColor = Color(0xFF00B894);
  static const Color errorColor = Color(0xFFD63031);
  static const Color successColor = Color(0xFF00B894);
  static const Color warningColor = Color(0xFFFDCB6E);
  static const Color infoColor = Color(0xFF0984E3);

  // Font Settings
  static const String defaultFontFamily = 'Poppins';
  static const double defaultFontSize = 14;
  static const double smallFontSize = 12;
  static const double largeFontSize = 16;
  static const double headerFontSize = 20;
  static const double titleFontSize = 24;

  // Spacing Settings
  static const double spacingTiny = 4;
  static const double spacingSmall = 8;
  static const double spacingMedium = 16;
  static const double spacingLarge = 24;
  static const double spacingHuge = 32;

  // Border Radius
  static const double radiusTiny = 4;
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusHuge = 24;
  static const double radiusCircular = 999;

  // Shadow Settings
  static const double shadowBlur = 10;
  static const double shadowSpread = 0;
  static const Offset shadowOffset = Offset(0, 2);

  // Icon Sizes
  static const double iconTiny = 12;
  static const double iconSmall = 16;
  static const double iconMedium = 24;
  static const double iconLarge = 32;
  static const double iconHuge = 48;

  // Bottom Sheet Settings
  static const double bottomSheetRatio = 0.9;
  static const double bottomSheetMinRatio = 0.5;
  static const double bottomSheetMaxRatio = 0.95;

  // Dialog Settings
  static const Duration dialogAnimationDuration = Duration(milliseconds: 200);

  // Toast Settings
  static const Duration toastDuration = Duration(seconds: 3);
  static const Duration toastAnimationDuration = Duration(milliseconds: 300);

  // Loading Settings
  static const Duration loadingMinimumDuration = Duration(milliseconds: 500);
  static const Duration loadingDebounceDuration = Duration(milliseconds: 300);

  // Search Settings
  static const int searchDebounceDuration = 300; // milliseconds
  static const int searchMinLength = 2;
  static const int searchMaxSuggestions = 5;

  // Form Settings
  static const int formDebounceDuration = 500; // milliseconds
  static const bool formAutoValidate = false;

  // Keyboard Settings
  static const Duration keyboardAnimationDuration = Duration(milliseconds: 300);

  // Network Settings
  static const int networkRetryCount = 3;
  static const Duration networkRetryDelay = Duration(seconds: 1);
  static const bool networkShowErrors = true;

  // Database Settings
  static const String databaseName = 'lotchat.db';
  static const int databaseVersion = 1;

  // Shared Preferences Keys
  static const String prefUserId = 'user_id';
  static const String prefUserToken = 'user_token';
  static const String prefUserData = 'user_data';
  static const String prefThemeMode = 'theme_mode';
  static const String prefLanguage = 'language';
  static const String prefNotifications = 'notifications';
  static const String prefLastLogin = 'last_login';
  static const String prefOnboarding = 'onboarding_completed';

  // Helper Methods
  static bool isDevelopment() => environment == Environment.development;
  static bool isStaging() => environment == Environment.staging;
  static bool isProduction() => environment == Environment.production;

  static String getBaseUrl() {
    switch (environment) {
      case Environment.development:
        return 'https://dev-api.lotchat.com/v1';
      case Environment.staging:
        return 'https://staging-api.lotchat.com/v1';
      case Environment.production:
        return apiBaseUrl;
    }
  }

  static String getSocketUrl() {
    switch (environment) {
      case Environment.development:
        return 'wss://dev-socket.lotchat.com';
      case Environment.staging:
        return 'wss://staging-socket.lotchat.com';
      case Environment.production:
        return socketUrl;
    }
  }

  static String getCdnUrl() {
    switch (environment) {
      case Environment.development:
        return 'https://dev-cdn.lotchat.com';
      case Environment.staging:
        return 'https://staging-cdn.lotchat.com';
      case Environment.production:
        return cdnUrl;
    }
  }

  static bool isAllowedImageType(String extension) {
    return allowedImageTypes.contains(extension.toLowerCase());
  }

  static bool isAllowedVideoType(String extension) {
    return allowedVideoTypes.contains(extension.toLowerCase());
  }

  static bool isAllowedAudioType(String extension) {
    return allowedAudioTypes.contains(extension.toLowerCase());
  }

  static bool isAllowedDocumentType(String extension) {
    return allowedDocumentTypes.contains(extension.toLowerCase());
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

enum Environment {
  development,
  staging,
  production
}