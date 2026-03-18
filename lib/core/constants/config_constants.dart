class ConfigConstants {
  // Private constructor to prevent instantiation
  ConfigConstants._();

  // Environment
  static const bool isProduction = bool.fromEnvironment('PRODUCTION');
  static const bool isDevelopment = !isProduction;

  // API Configuration
  static String get apiBaseUrl {
    if (isProduction) {
      return 'https://api.lotchat.com/v1';
    } else {
      return 'https://dev-api.lotchat.com/v1';
    }
  }

  static String get socketUrl {
    if (isProduction) {
      return 'wss://socket.lotchat.com';
    } else {
      return 'wss://dev-socket.lotchat.com';
    }
  }

  // Feature Flags (bool)
  static const bool enableGames = true;
  static const bool enablePKBattle = true;
  static const bool enableClanSystem = true;
  static const bool enableAISuggestions = true;
  static const bool enableVoiceTranslation = false;
  static const bool enableScreenRecording = true;
  static const bool enableAutoModeration = true;

  // Limits & Thresholds (int)
  static const int maxRoomViewers = 1000;
  static const int maxRoomSeats = 9;
  static const int maxGiftsPerMinute = 10;
  static const int maxMessagesPerMinute = 30;

  // Auto Ban Thresholds
  static const int maxReportsForAutoBan = 5;
  static const bool extremeSlangAutoBan = true; // 🟢 bool type
  static const int spamMessageThreshold = 10; // messages per second

  // Cache Settings
  static const int cacheMaxAge = 7; // days
  static const int imageCacheSize = 100; // MB

  // Performance
  static const bool enableLogging = isDevelopment; // 🟢 bool type
  static const bool enableAnalytics = isProduction; // 🟢 bool type
  static const bool enableCrashlytics = isProduction; // 🟢 bool type

  // Version
  static const int androidVersionCode = 1;
  static const String iosVersion = '1.0.0';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Timeouts
  static const int connectionTimeout = 30; // seconds
  static const int receiveTimeout = 30; // seconds

  // File Upload
  static const int maxFileSize = 50; // MB
  static const int maxImageSize = 10; // MB
  static const int maxVideoSize = 100; // MB

  // Rate Limiting
  static const int maxLoginAttempts = 5;
  static const int loginLockoutDuration = 15; // minutes

  // Chat Settings
  static const int maxMessageLength = 1000;
  static const int maxMediaPerMessage = 5;

  // Gift Settings
  static const int minGiftPrice = 1;
  static const int maxGiftPrice = 100000;
  static const int freeGiftDailyLimit = 5;

  // PK Battle Settings
  static const int pkBattleMinDuration = 3; // minutes
  static const int pkBattleMaxDuration = 30; // minutes
  static const int pkBattleCooldown = 5; // minutes

  // Economy Settings
  static const int coinToDiamondRate = 2; // 2 coins = 1 diamond
  static const int dailyBonus = 100; // coins
  static const int newUserBonus = 500; // coins

  // Room Settings
  static const int maxRoomTitleLength = 100;
  static const int maxRoomDescriptionLength = 500;
  static const int minRoomPasswordLength = 4;

  // Profile Settings
  static const int maxBioLength = 500;
  static const int maxUsernameLength = 30;
  static const int minUsernameLength = 3;

  // Search Settings
  static const int searchDebounceTime = 500; // milliseconds
  static const int searchMinChars = 2;

  // Animation Settings
  static const int animationDuration = 300; // milliseconds
  static const int giftAnimationDuration = 5; // seconds

  // Media Quality
  static const int videoQuality = 720; // p
  static const int audioBitrate = 128; // kbps

  // Feature Flags (more)
  static const bool enableGiftAnimations = true;
  static const bool enableSeatSounds = true;
  static const bool enableEntryEffects = true;
  static const bool enableBackgroundMusic = true;
  static const bool enableSoundEffects = true;
  static const bool enablePushNotifications = true;
  static const bool enableInAppNotifications = true;
  static const bool enableFriendSystem = true;
  static const bool enableClanWars = false;
  static const bool enableTournaments = false;

  // Maintenance
  static const bool isMaintenanceMode = false;
  static const String maintenanceMessage = 'App is under maintenance. Please try again later.';

  // Support
  static const String supportEmail = 'support@lotchat.com';
  static const String privacyPolicyUrl = 'https://lotchat.com/privacy';
  static const String termsOfServiceUrl = 'https://lotchat.com/terms';
  static const String helpCenterUrl = 'https://help.lotchat.com';

  // Social Links
  static const String facebookUrl = 'https://facebook.com/lotchat';
  static const String instagramUrl = 'https://instagram.com/lotchat';
  static const String twitterUrl = 'https://twitter.com/lotchat';
  static const String discordUrl = 'https://discord.gg/lotchat';
  static const String telegramUrl = 'https://t.me/lotchat';

  // App Store Links
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.lotchat.app';
  static const String appStoreUrl = 'https://apps.apple.com/app/lotchat/id123456789';

  // Ad Configuration
  static const bool enableAds = isDevelopment ? false : true;
  static const int adInterval = 5; // minutes between ads
  static const int rewardedVideoCoins = 50;

  // Subscription Plans
  static const double vipMonthlyPrice = 9.99;
  static const double svipMonthlyPrice = 19.99;
  static const String vipProductId = 'com.lotchat.vip.monthly';
  static const String svipProductId = 'com.lotchat.svip.monthly';
}