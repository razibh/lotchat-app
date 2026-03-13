class SharedPrefKeys {
  // Auth Keys
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String isLoggedIn = 'is_logged_in';
  static const String userEmail = 'user_email';
  static const String userPassword = 'user_password';
  static const String rememberMe = 'remember_me';

  // User Keys
  static const String userName = 'user_name';
  static const String userDisplayName = 'user_display_name';
  static const String userAvatar = 'user_avatar';
  static const String userCover = 'user_cover';
  static const String userBio = 'user_bio';
  static const String userPhone = 'user_phone';
  static const String userCountry = 'user_country';
  static const String userRegion = 'user_region';
  static const String userCoins = 'user_coins';
  static const String userDiamonds = 'user_diamonds';
  static const String userTier = 'user_tier';
  static const String userRole = 'user_role';
  static const String userInterests = 'user_interests';
  static const String userBadges = 'user_badges';

  // Settings Keys
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String soundEnabled = 'sound_enabled';
  static const String vibrationEnabled = 'vibration_enabled';
  static const String hapticEnabled = 'haptic_enabled';
  static const String autoPlayVideos = 'auto_play_videos';
  static const String downloadOverWifi = 'download_over_wifi';
  static const String imageQuality = 'image_quality';
  static const String privacyMode = 'privacy_mode';
  static const String showOnlineStatus = 'show_online_status';
  static const String allowFriendRequests = 'allow_friend_requests';
  static const String allowMessagesFrom = 'allow_messages_from';
  static const String blockedUsers = 'blocked_users';

  // Onboarding Keys
  static const String hasSeenOnboarding = 'has_seen_onboarding';
  static const String hasCompletedProfile = 'has_completed_profile';
  static const String hasMadeFirstPost = 'has_made_first_post';
  static const String hasSentFirstGift = 'has_sent_first_gift';
  static const String hasJoinedFirstRoom = 'has_joined_first_room';
  static const String hasPlayedFirstGame = 'has_played_first_game';

  // Location Keys
  static const String lastCountry = 'last_country';
  static const String lastRegion = 'last_region';
  static const String lastCity = 'last_city';
  static const String lastLatitude = 'last_latitude';
  static const String lastLongitude = 'last_longitude';

  // Cache Keys
  static const String cachedRooms = 'cached_rooms';
  static const String cachedGifts = 'cached_gifts';
  static const String cachedUsers = 'cached_users';
  static const String cachedPosts = 'cached_posts';
  static const String lastSync = 'last_sync_time';
  static const String cacheVersion = 'cache_version';

  // Game Keys
  static const String lastGamePlayed = 'last_game_played';
  static const String gameStats = 'game_stats';
  static const String gameHighScore = 'game_high_score';
  static const String gameUnlocked = 'game_unlocked';

  // Chat Keys
  static const String lastChatId = 'last_chat_id';
  static const String mutedChats = 'muted_chats';
  static const String pinnedChats = 'pinned_chats';
  static const String archivedChats = 'archived_chats';
  static const String chatWallpaper = 'chat_wallpaper';

  // Security Keys
  static const String biometricEnabled = 'biometric_enabled';
  static const String pinCode = 'pin_code';
  static const String appLockEnabled = 'app_lock_enabled';
  static const String appLockTimeout = 'app_lock_timeout';
  static const String twoFactorEnabled = 'two_factor_enabled';
  static const String trustedDevices = 'trusted_devices';

  // Analytics Keys
  static const String deviceId = 'device_id';
  static const String appOpenedCount = 'app_opened_count';
  static const String lastOpenedVersion = 'last_opened_version';
  static const String lastReviewedVersion = 'last_reviewed_version';
  static const String ratingPromptShown = 'rating_prompt_shown';

  // Notification Keys
  static const String fcmToken = 'fcm_token';
  static const String lastNotificationId = 'last_notification_id';
  static const String notificationSettings = 'notification_settings';
  static const String quietHoursEnabled = 'quiet_hours_enabled';
  static const String quietHoursStart = 'quiet_hours_start';
  static const String quietHoursEnd = 'quiet_hours_end';

  // Payment Keys
  static const String lastPurchaseId = 'last_purchase_id';
  static const String purchasedPackages = 'purchased_packages';
  static const String subscriptionStatus = 'subscription_status';
  static const String subscriptionExpiry = 'subscription_expiry';

  // Debug Keys
  static const String debugMode = 'debug_mode';
  static const String logLevel = 'log_level';
  static const String lastError = 'last_error';
  static const String crashReports = 'crash_reports';

  // Feature Flags
  static const String featureFlags = 'feature_flags';
  static const String abTestingGroup = 'ab_testing_group';

  // Misc Keys
  static const String appVersion = 'app_version';
  static const String buildNumber = 'build_number';
  static const String installationId = 'installation_id';
  static const String lastUpdateCheck = 'last_update_check';
  static const String updateAvailable = 'update_available';
  static const String updateUrl = 'update_url';
}