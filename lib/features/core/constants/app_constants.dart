
class AppConstants {
  // App Info
  static const String appName = 'LotChat';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String packageName = 'com.lotchat.app';
  static const String appStoreId = '123456789';
  static const String appCenterId = 'lotchat-ios/android';

  // Deep Links
  static const String appScheme = 'lotchat';
  static const String appDomain = 'lotchat.app';
  static const String dynamicLinkPrefix = 'https://lotchat.page.link';

  // Pagination
  static const int pageSize = 20;
  static const int maxPageSize = 100;
  static const int initialPage = 0;
  static const double infiniteScrollThreshold = 0.8;

  // Limits
  static const int maxUsernameLength = 20;
  static const int minUsernameLength = 3;
  static const int maxBioLength = 150;
  static const int maxMessageLength = 1000;
  static const int maxRoomNameLength = 50;
  static const int maxRoomDescriptionLength = 200;
  static const int maxInterests = 10;
  static const int maxFriends = 5000;
  static const int maxGiftsPerMinute = 10;
  static const int maxMessagesPerMinute = 30;

  // Economy
  static const int coinPerDollar = 10000;
  static const int diamondPerCoin = 2;
  static const int giftCommissionRate = 10; // percentage
  static const int minWithdrawal = 1000;
  static const int maxWithdrawal = 100000;
  static const int welcomeBonus = 1000;

  // VIP Levels
  static const int vipLevels = 10;
  static const int svipLevels = 8;
  static const Map<int, int> vipCoinThreshold = <int, int>{
    1: 10000,
    2: 50000,
    3: 100000,
    4: 200000,
    5: 500000,
    6: 1000000,
    7: 2000000,
    8: 5000000,
    9: 10000000,
    10: 20000000,
  };

  // Games
  static const Map<String, Map<String, int>> gameLimits = <String, Map<String, int>>{
    'roulette': <String, int>{'minBet': 100, 'maxBet': 10000},
    'threePatti': <String, int>{'minBet': 500, 'maxBet': 50000},
    'ludo': <String, int>{'minBet': 200, 'maxBet': 20000},
    'carrom': <String, int>{'minBet': 200, 'maxBet': 20000},
    'greedyCat': <String, int>{'minBet': 100, 'maxBet': 5000},
  };

  // Room Limits
  static const int maxRoomViewers = 1000;
  static const int maxRoomSeats = 9;
  static const int maxModerators = 5;

  // Chat Limits
  static const int maxChatParticipants = 50;
  static const int maxMessageReactions = 20;
  static const int maxAttachmentSize = 50 * 1024 * 1024; // 50MB

  // Image Limits
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const int maxImageDimension = 1920;
  static const int imageQuality = 85;

  // Video Limits
  static const int maxVideoSize = 100 * 1024 * 1024; // 100MB
  static const int maxVideoDuration = 300; // 5 minutes
  static const int videoQuality = 720;

  // Cache Settings
  static const int cacheMaxAge = 7; // days
  static const int imageCacheSize = 100; // MB
  static const int cacheCleanupInterval = 24; // hours

  // Timeouts
  static const int connectionTimeout = 30; // seconds
  static const int receiveTimeout = 30; // seconds
  static const int socketTimeout = 60; // seconds
  static const int uploadTimeout = 120; // seconds

  // Animation Durations
  static const int splashDuration = 2000; // milliseconds
  static const int dialogAnimationDuration = 300; // milliseconds
  static const int snackbarDuration = 3000; // milliseconds
  static const int toastDuration = 2000; // milliseconds

  // Validation
  static final RegExp emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );
  static final RegExp usernameRegex = RegExp(
    r'^[a-zA-Z0-9_]{3,20}$',
  );
  static final RegExp phoneRegex = RegExp(
    r'^\+?[\d\s-]{10,}$',
  );

  // Default Values
  static const String defaultAvatar = 'assets/images/default_avatar.png';
  static const String defaultRoomCover = 'assets/images/default_room_cover.jpg';
  static const String defaultCountry = 'US';
  static const String defaultLanguage = 'en';

  // Feature Flags
  static const bool enableGames = true;
  static const bool enablePKBattle = true;
  static const bool enableClanSystem = true;
  static const bool enableAISuggestions = true;
  static const bool enableVoiceTranslation = false;
  static const bool enableScreenRecording = true;
  static const bool enableAutoModeration = true;

  // Maintenance
  static const bool isMaintenanceMode = false;
  static const String maintenanceMessage = 'App is under maintenance. Please check back later.';

  // Support
  static const String supportEmail = 'support@lotchat.com';
  static const String supportPhone = '+1-800-LOTCHAT';
  static const String privacyPolicyUrl = 'https://lotchat.com/privacy';
  static const String termsOfServiceUrl = 'https://lotchat.com/terms';
  static const String helpCenterUrl = 'https://help.lotchat.com';

  // Social Links
  static const String facebookUrl = 'https://facebook.com/lotchat';
  static const String twitterUrl = 'https://twitter.com/lotchat';
  static const String instagramUrl = 'https://instagram.com/lotchat';
  static const String discordUrl = 'https://discord.gg/lotchat';
  static const String telegramUrl = 'https://t.me/lotchat';

  // Rate Limits
  static const int maxLoginAttempts = 5;
  static const int loginLockoutDuration = 15; // minutes
  static const int maxOtpAttempts = 3;
  static const int otpExpiryDuration = 5; // minutes

  // Session
  static const int sessionTimeout = 60; // minutes
  static const bool rememberMeDefault = true;

  // Notifications
  static const int maxNotifications = 100;
  static const int notificationCleanupDays = 30;
}