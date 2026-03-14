class ConfigConstants {
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
  
  // Feature Flags
  static const bool enableGames = true;
  static const bool enablePKBattle = true;
  static const bool enableClanSystem = true;
  static const bool enableAISuggestions = true;
  static const bool enableVoiceTranslation = false;
  static const bool enableScreenRecording = true;
  static const bool enableAutoModeration = true;
  
  // Limits & Thresholds
  static const int maxRoomViewers = 1000;
  static const int maxRoomSeats = 9;
  static const int maxGiftsPerMinute = 10;
  static const int maxMessagesPerMinute = 30;
  
  // Auto Ban Thresholds
  static const int maxReportsForAutoBan = 5;
  static const int extremeSlangAutoBan = true;
  static const int spamMessageThreshold = 10; // messages per second
  
  // Cache Settings
  static const int cacheMaxAge = 7; // days
  static const int imageCacheSize = 100; // MB
  
  // Performance
  static const bool enableLogging = isDevelopment;
  static const bool enableAnalytics = isProduction;
  static const bool enableCrashlytics = isProduction;
  
  // Version
  static const int androidVersionCode = 1;
  static const String iosVersion = '1.0.0';
}