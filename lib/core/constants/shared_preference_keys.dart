class PrefKeys {
  // Auth
  static const String token = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String isLoggedIn = 'is_logged_in';
  
  // User
  static const String userName = 'user_name';
  static const String userEmail = 'user_email';
  static const String userPhone = 'user_phone';
  static const String userAvatar = 'user_avatar';
  static const String userTier = 'user_tier';
  static const String userCoins = 'user_coins';
  static const String userDiamonds = 'user_diamonds';
  
  // Settings
  static const String theme = 'theme_mode';
  static const String language = 'language';
  static const String notifications = 'notifications_enabled';
  static const String soundEnabled = 'sound_enabled';
  static const String vibrationEnabled = 'vibration_enabled';
  
  // Onboarding
  static const String hasSeenOnboarding = 'has_seen_onboarding';
  static const String hasCompletedProfile = 'has_completed_profile';
  
  // Location
  static const String country = 'selected_country';
  static const String region = 'selected_region';
  static const String lastLocation = 'last_location';
  
  // Cache
  static const String lastSync = 'last_sync_time';
  static const String cachedRooms = 'cached_rooms';
  static const String cachedGifts = 'cached_gifts';
  
  // Games
  static const String lastGamePlayed = 'last_game_played';
  static const String gameStats = 'game_stats';
  
  // Security
  static const String biometricEnabled = 'biometric_enabled';
  static const String pinCode = 'pin_code';
}