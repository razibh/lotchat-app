class AppConstants {
  static const String appName = 'Game & Live Platform';
  static const String version = '1.0.0';
  static const String buildNumber = '1';
  
  // Shared Preferences Keys
  static const String prefUser = 'user';
  static const String prefToken = 'token';
  static const String prefRefreshToken = 'refresh_token';
  static const String prefTheme = 'theme';
  static const String prefCountry = 'selected_country';
  static const String prefLanguage = 'language';
  static const String prefNotifications = 'notifications_enabled';
  static const String prefFirstLaunch = 'first_launch';
  static const String prefLastSync = 'last_sync';
  
  // Pagination
  static const int itemsPerPage = 20;
  static const int maxRetries = 3;
  
  // Coin Settings
  static const double coinToBdtRate = 1; // 1 coin = 1 BDT
  static const double minWithdrawal = 500;
  static const double maxWithdrawal = 50000;
  static const double coinToDiamondRate = 100; // 100 coins = 1 diamond
  
  // Commission Rates
  static const double agencyBaseCommission = 10; // 10%
  static const double platformCommission = 5; // 5%
  static const double countryManagerCommission = 2; // 2%
  static const double hostCommissionRange = 20; // Max 20%
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int socketReconnectDelay = 3000; // 3 seconds
  
  // Cache
  static const int cacheMaxAge = 604800; // 7 days in seconds
  static const int cacheMaxSize = 100; // Max 100 items
  
  // File Upload
  static const int maxFileSize = 10485760; // 10 MB
  static const List<String> allowedImageTypes = <String>['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedVideoTypes = <String>['mp4', 'mov', 'avi', 'mkv'];
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  static const int maxBioLength = 150;
  
  // Room Settings
  static const int maxRoomTitleLength = 50;
  static const int maxRoomDescriptionLength = 200;
  static const int maxRoomParticipants = 1000;
  static const int maxRoomSeats = 8;
  static const int minRoomDuration = 5; // minutes
  static const int maxRoomDuration = 120; // minutes
  
  // Gift Settings
  static const int minGiftAmount = 1;
  static const int maxGiftAmount = 1000;
  static const int giftAnimationDuration = 2000; // milliseconds
  
  // Game Settings
  static const int minGameBet = 10;
  static const int maxGameBet = 10000;
  static const int gameCountdown = 10; // seconds
  
  // Streak Settings
  static const int streakRewardDays = 7;
  static const double streakRewardMultiplier = 1.5;
  
  // Ranking Thresholds
  static const int bronzeThreshold = 0;
  static const int silverThreshold = 1000;
  static const int goldThreshold = 5000;
  static const int platinumThreshold = 10000;
  static const int diamondThreshold = 50000;
  
  // Notification Channels
  static const String notificationChannelId = 'game_live_channel';
  static const String notificationChannelName = 'Game & Live Notifications';
  static const String notificationChannelDescription = 'Notifications for game and live events';
  
  // Deep Links
  static const String deepLinkHost = 'gamelive.page.link';
  static const String deepLinkPrefix = 'https://gamelive.page.link';
  
  // Social Links
  static const String facebookUrl = 'https://facebook.com/gamelive';
  static const String instagramUrl = 'https://instagram.com/gamelive';
  static const String twitterUrl = 'https://twitter.com/gamelive';
  static const String telegramUrl = 'https://t.me/gamelive';
  static const String discordUrl = 'https://discord.gg/gamelive';
  
  // Support
  static const String supportEmail = 'support@gamelive.com';
  static const String supportWebsite = 'https://gamelive.com';
  static const String privacyPolicyUrl = 'https://gamelive.com/privacy';
  static const String termsOfServiceUrl = 'https://gamelive.com/terms';
  static const String faqUrl = 'https://gamelive.com/faq';
  
  // Error Messages
  static const String errorNetwork = 'Network connection error. Please check your internet.';
  static const String errorServer = 'Server error. Please try again later.';
  static const String errorUnauthorized = 'Session expired. Please login again.';
  static const String errorForbidden = 'You do not have permission to perform this action.';
  static const String errorNotFound = 'Resource not found.';
  static const String errorValidation = 'Validation failed. Please check your input.';
  static const String errorTimeout = 'Request timeout. Please try again.';
  static const String errorUnknown = 'An unknown error occurred.';
  
  // Success Messages
  static const String successLogin = 'Login successful!';
  static const String successRegister = 'Registration successful!';
  static const String successLogout = 'Logout successful!';
  static const String successUpdate = 'Profile updated successfully!';
  static const String successSend = 'Gift sent successfully!';
  static const String successWithdraw = 'Withdrawal request submitted!';
  static const String successRecharge = 'Recharge successful!';
  
  // Date Formats
  static const String dateFormatFull = 'yyyy-MM-dd HH:mm:ss';
  static const String dateFormatDate = 'yyyy-MM-dd';
  static const String dateFormatTime = 'HH:mm:ss';
  static const String dateFormatDisplay = 'dd MMM yyyy';
  static const String dateFormatDisplayTime = 'dd MMM yyyy, HH:mm';
  
  // Animation Durations
  static const int animationFast = 200;
  static const int animationNormal = 300;
  static const int animationSlow = 500;
  
  // Layout Breakpoints
  static const double mobileBreakpoint = 480;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;
  
  // Font Sizes
  static const double fontSizeSmall = 12;
  static const double fontSizeNormal = 14;
  static const double fontSizeMedium = 16;
  static const double fontSizeLarge = 18;
  static const double fontSizeXLarge = 20;
  static const double fontSizeXXLarge = 24;
  
  // Spacing
  static const double spacingXSmall = 4;
  static const double spacingSmall = 8;
  static const double spacingNormal = 12;
  static const double spacingMedium = 16;
  static const double spacingLarge = 20;
  static const double spacingXLarge = 24;
  static const double spacingXXLarge = 32;
  
  // Border Radius
  static const double radiusSmall = 4;
  static const double radiusNormal = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXLarge = 20;
  static const double radiusCircle = 999;
  
  // Icon Sizes
  static const double iconSmall = 16;
  static const double iconNormal = 20;
  static const double iconMedium = 24;
  static const double iconLarge = 32;
  static const double iconXLarge = 48;
  
  // Button Sizes
  static const double buttonHeightSmall = 32;
  static const double buttonHeightNormal = 40;
  static const double buttonHeightLarge = 48;
  static const double buttonHeightXLarge = 56;
  
  // Image Sizes
  static const double avatarSmall = 32;
  static const double avatarNormal = 40;
  static const double avatarMedium = 48;
  static const double avatarLarge = 56;
  static const double avatarXLarge = 80;
}

class ApiConstants {
  static const String baseUrl = 'https://api.lotchat.com/v1';
  static const String socketUrl = 'wss://socket.lotchat.com';
  
  // API Version
  static const String apiVersion = 'v1';
  static const String apiPrefix = '/api';
  
  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String verifyOTP = '/auth/verify-otp';
  static const String changePassword = '/auth/change-password';
  
  // User Endpoints
  static const String user = '/user';
  static const String userProfile = '/user/profile';
  static const String userUpdate = '/user/update';
  static const String userCoins = '/user/coins';
  static const String userDiamonds = '/user/diamonds';
  static const String userFriends = '/user/friends';
  static const String userFollowers = '/user/followers';
  static const String userFollowing = '/user/following';
  static const String userBlocked = '/user/blocked';
  static const String userReports = '/user/reports';
  static const String userSettings = '/user/settings';
  static const String userStats = '/user/stats';
  static const String userAchievements = '/user/achievements';
  
  // Room Endpoints
  static const String rooms = '/rooms';
  static const String roomCreate = '/rooms/create';
  static const String roomJoin = '/rooms/join';
  static const String roomLeave = '/rooms/leave';
  static const String roomSeats = '/rooms/seats';
  static const String roomSeatTake = '/rooms/seat/take';
  static const String roomSeatLeave = '/rooms/seat/leave';
  static const String roomMessages = '/rooms/messages';
  static const String roomSendMessage = '/rooms/send-message';
  static const String roomDeleteMessage = '/rooms/delete-message';
  static const String roomMute = '/rooms/mute';
  static const String roomUnmute = '/rooms/unmute';
  static const String roomKick = '/rooms/kick';
  static const String roomBan = '/rooms/ban';
  static const String roomUnban = '/rooms/unban';
  static const String roomMakeAdmin = '/rooms/make-admin';
  static const String roomRemoveAdmin = '/rooms/remove-admin';
  static const String roomSettings = '/rooms/settings';
  static const String roomHistory = '/rooms/history';
  static const String roomInvite = '/rooms/invite';
  static const String roomReport = '/rooms/report';
  
  // Gifts Endpoints
  static const String gifts = '/gifts';
  static const String giftSend = '/gifts/send';
  static const String giftReceive = '/gifts/receive';
  static const String giftHistory = '/gifts/history';
  static const String giftLeaderboard = '/gifts/leaderboard';
  static const String giftTemplates = '/gifts/templates';
  static const String giftStats = '/gifts/stats';
  static const String giftRankings = '/gifts/rankings';
  
  // Games Endpoints
  static const String games = '/games';
  static const String gameList = '/games/list';
  static const String gamePlay = '/games/play';
  static const String gameResult = '/games/result';
  static const String gameHistory = '/games/history';
  static const String gameLeaderboard = '/games/leaderboard';
  static const String gameStats = '/games/stats';
  static const String gameTournaments = '/games/tournaments';
  static const String gameJoinTournament = '/games/tournaments/join';
  static const String gameTournamentResults = '/games/tournaments/results';
  
  // PK Battle Endpoints
  static const String pkStart = '/pk/start';
  static const String pkEnd = '/pk/end';
  static const String pkScore = '/pk/score';
  static const String pkHistory = '/pk/history';
  static const String pkRankings = '/pk/rankings';
  static const String pkChallenge = '/pk/challenge';
  static const String pkAccept = '/pk/accept';
  static const String pkDecline = '/pk/decline';
  
  // Transactions Endpoints
  static const String transactions = '/transactions';
  static const String transactionDetails = '/transactions/details';
  static const String purchaseCoins = '/purchase/coins';
  static const String purchasePackages = '/purchase/packages';
  static const String withdrawDiamonds = '/withdraw/diamonds';
  static const String withdrawHistory = '/withdraw/history';
  static const String withdrawStatus = '/withdraw/status';
  static const String paymentMethods = '/payment/methods';
  static const String paymentVerify = '/payment/verify';
  
  // Admin Endpoints
  static const String adminUsers = '/admin/users';
  static const String adminUserDetails = '/admin/users/details';
  static const String adminBan = '/admin/ban';
  static const String adminUnban = '/admin/unban';
  static const String adminMute = '/admin/mute';
  static const String adminUnmute = '/admin/unmute';
  static const String adminAddCoins = '/admin/add-coins';
  static const String adminRemoveCoins = '/admin/remove-coins';
  static const String adminGifts = '/admin/gifts';
  static const String adminReports = '/admin/reports';
  static const String adminReportDetails = '/admin/reports/details';
  static const String adminResolveReport = '/admin/reports/resolve';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminStats = '/admin/stats';
  static const String adminSettings = '/admin/settings';
  static const String adminLogs = '/admin/logs';
  
  // Agency Endpoints
  static const String agencies = '/agencies';
  static const String agencyDetails = '/agencies/details';
  static const String agencyAddMember = '/agency/add-member';
  static const String agencyRemoveMember = '/agency/remove-member';
  static const String agencyUpdateMember = '/agency/update-member';
  static const String agencyEarnings = '/agency/earnings';
  static const String agencyCommission = '/agency/commission';
  static const String agencyUpdateCommission = '/agency/update-commission';
  static const String agencyHosts = '/agency/hosts';
  static const String agencyHostDetails = '/agency/hosts/details';
  static const String agencyStats = '/agency/stats';
  static const String agencyReports = '/agency/reports';
  static const String agencySettings = '/agency/settings';
  static const String agencyRegister = '/agency/register';
  static const String agencyVerify = '/agency/verify';
  
  // Seller Endpoints
  static const String sellers = '/sellers';
  static const String sellerDetails = '/sellers/details';
  static const String sellerAddCoins = '/seller/add-coins';
  static const String sellerPackages = '/seller/packages';
  static const String sellerAddPackage = '/seller/packages/add';
  static const String sellerUpdatePackage = '/seller/packages/update';
  static const String sellerDeletePackage = '/seller/packages/delete';
  static const String sellerSales = '/seller/sales';
  static const String sellerSalesHistory = '/seller/sales/history';
  static const String sellerStats = '/seller/stats';
  static const String sellerEarnings = '/seller/earnings';
  static const String sellerWithdraw = '/seller/withdraw';
  static const String sellerInventory = '/seller/inventory';
  static const String sellerRegister = '/seller/register';
  static const String sellerVerify = '/seller/verify';
  
  // Country Manager Endpoints
  static const String countryManager = '/country-manager';
  static const String managerAgencies = '/manager/agencies';
  static const String managerAgencyDetails = '/manager/agencies/details';
  static const String managerApproveAgency = '/manager/agencies/approve';
  static const String managerRejectAgency = '/manager/agencies/reject';
  static const String managerSuspendAgency = '/manager/agencies/suspend';
  static const String managerHosts = '/manager/hosts';
  static const String managerHostDetails = '/manager/hosts/details';
  static const String managerIssues = '/manager/issues';
  static const String managerIssueDetails = '/manager/issues/details';
  static const String managerResolveIssue = '/manager/issues/resolve';
  static const String managerStats = '/manager/stats';
  static const String managerReports = '/manager/reports';
  static const String managerRecruit = '/manager/recruit';
  static const String managerCommission = '/manager/commission';
  
  // Host Endpoints
  static const String host = '/host';
  static const String hostProfile = '/host/profile';
  static const String hostUpdate = '/host/update';
  static const String hostEarnings = '/host/earnings';
  static const String hostStats = '/host/stats';
  static const String hostAnalytics = '/host/analytics';
  static const String hostSchedule = '/host/schedule';
  static const String hostAddSchedule = '/host/schedule/add';
  static const String hostRemoveSchedule = '/host/schedule/remove';
  static const String hostRooms = '/host/rooms';
  static const String hostRoomHistory = '/host/rooms/history';
  static const String hostFollowers = '/host/followers';
  static const String hostGifts = '/host/gifts';
  static const String hostRankings = '/host/rankings';
  
  // Wallet Endpoints
  static const String wallet = '/wallet';
  static const String walletBalance = '/wallet/balance';
  static const String walletHistory = '/wallet/history';
  static const String walletRecharge = '/wallet/recharge';
  static const String walletWithdraw = '/wallet/withdraw';
  static const String walletTransfer = '/wallet/transfer';
  static const String walletAddCard = '/wallet/cards/add';
  static const String walletRemoveCard = '/wallet/cards/remove';
  static const String walletCards = '/wallet/cards';
  static const String walletDefaultCard = '/wallet/cards/default';
  
  // Search Endpoints
  static const String search = '/search';
  static const String searchUsers = '/search/users';
  static const String searchRooms = '/search/rooms';
  static const String searchGames = '/search/games';
  static const String searchGifts = '/search/gifts';
  static const String searchHistory = '/search/history';
  static const String searchTrending = '/search/trending';
  
  // Notification Endpoints
  static const String notifications = '/notifications';
  static const String notificationMarkRead = '/notifications/mark-read';
  static const String notificationMarkAllRead = '/notifications/mark-all-read';
  static const String notificationDelete = '/notifications/delete';
  static const String notificationSettings = '/notifications/settings';
  static const String notificationUpdateSettings = '/notifications/settings/update';
  
  // Upload Endpoints
  static const String uploadImage = '/upload/image';
  static const String uploadVideo = '/upload/video';
  static const String uploadAudio = '/upload/audio';
  static const String uploadFile = '/upload/file';
  static const String uploadAvatar = '/upload/avatar';
  static const String uploadCover = '/upload/cover';
  
  // Headers
  static const String headerAuthorization = 'Authorization';
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';
  static const String headerUserAgent = 'User-Agent';
  static const String headerAuthorizationBearer = 'Bearer ';
  static const String headerApiKey = 'X-API-Key';
  static const String headerDeviceId = 'X-Device-ID';
  static const String headerDeviceType = 'X-Device-Type';
  static const String headerAppVersion = 'X-App-Version';
  static const String headerPlatform = 'X-Platform';
  static const String headerLanguage = 'X-Language';
  static const String headerCountry = 'X-Country';
  
  // Content Types
  static const String contentTypeJson = 'application/json';
  static const String contentTypeForm = 'application/x-www-form-urlencoded';
  static const String contentTypeMultipart = 'multipart/form-data';
  static const String contentTypePlain = 'text/plain';
  static const String contentTypeHtml = 'text/html';
  static const String contentTypeXml = 'application/xml';
  
  // HTTP Methods
  static const String methodGet = 'GET';
  static const String methodPost = 'POST';
  static const String methodPut = 'PUT';
  static const String methodDelete = 'DELETE';
  static const String methodPatch = 'PATCH';
  
  // Response Codes
  static const int codeSuccess = 200;
  static const int codeCreated = 201;
  static const int codeAccepted = 202;
  static const int codeNoContent = 204;
  static const int codeBadRequest = 400;
  static const int codeUnauthorized = 401;
  static const int codeForbidden = 403;
  static const int codeNotFound = 404;
  static const int codeMethodNotAllowed = 405;
  static const int codeConflict = 409;
  static const int codeUnprocessable = 422;
  static const int codeTooManyRequests = 429;
  static const int codeServerError = 500;
  static const int codeBadGateway = 502;
  static const int codeServiceUnavailable = 503;
  static const int codeGatewayTimeout = 504;
}

class SharedPrefKeys {
  static const String user = 'user';
  static const String token = 'token';
  static const String refreshToken = 'refresh_token';
  static const String theme = 'theme';
  static const String language = 'language';
  static const String country = 'country';
  static const String notifications = 'notifications';
  static const String firstLaunch = 'first_launch';
  static const String lastSync = 'last_sync';
  static const String deviceId = 'device_id';
  static const String fcmToken = 'fcm_token';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String appVersion = 'app_version';
  static const String lastNotificationCheck = 'last_notification_check';
}

class CacheKeys {
  static const String userProfile = 'user_profile';
  static const String userSettings = 'user_settings';
  static const String userStats = 'user_stats';
  static const String userFriends = 'user_friends';
  static const String userFollowers = 'user_followers';
  static const String rooms = 'rooms';
  static const String games = 'games';
  static const String gifts = 'gifts';
  static const String giftTemplates = 'gift_templates';
  static const String leaderboard = 'leaderboard';
  static const String countries = 'countries';
  static const String translations = 'translations';
  static const String notifications = 'notifications';
  static const String searchHistory = 'search_history';
}

class DatabaseTables {
  static const String users = 'users';
  static const String rooms = 'rooms';
  static const String messages = 'messages';
  static const String gifts = 'gifts';
  static const String transactions = 'transactions';
  static const String notifications = 'notifications';
  static const String friends = 'friends';
  static const String followers = 'followers';
  static const String games = 'games';
  static const String gameHistory = 'game_history';
  static const String settings = 'settings';
  static const String cache = 'cache';
}

class NotificationTypes {
  static const String gift = 'gift';
  static const String follow = 'follow';
  static const String friendRequest = 'friend_request';
  static const String friendAccept = 'friend_accept';
  static const String roomInvite = 'room_invite';
  static const String roomJoin = 'room_join';
  static const String roomLeave = 'room_leave';
  static const String gameInvite = 'game_invite';
  static const String gameResult = 'game_result';
  static const String tournamentStart = 'tournament_start';
  static const String tournamentEnd = 'tournament_end';
  static const String tournamentResult = 'tournament_result';
  static const String pkChallenge = 'pk_challenge';
  static const String pkResult = 'pk_result';
  static const String withdrawComplete = 'withdraw_complete';
  static const String withdrawFailed = 'withdraw_failed';
  static const String rechargeSuccess = 'recharge_success';
  static const String rechargeFailed = 'recharge_failed';
  static const String system = 'system';
  static const String admin = 'admin';
  static const String warning = 'warning';
  static const String ban = 'ban';
  static const String mute = 'mute';
  static const String report = 'report';
}

class SocketEvents {
  static const String connect = 'connect';
  static const String disconnect = 'disconnect';
  static const String error = 'error';
  static const String reconnect = 'reconnect';
  
  // Room Events
  static const String roomJoin = 'room:join';
  static const String roomLeave = 'room:leave';
  static const String roomMessage = 'room:message';
  static const String roomTyping = 'room:typing';
  static const String roomUserJoin = 'room:user:join';
  static const String roomUserLeave = 'room:user:leave';
  static const String roomSeatTake = 'room:seat:take';
  static const String roomSeatLeave = 'room:seat:leave';
  static const String roomGift = 'room:gift';
  static const String roomGameStart = 'room:game:start';
  static const String roomGameEnd = 'room:game:end';
  static const String roomMute = 'room:mute';
  static const String roomUnmute = 'room:unmute';
  static const String roomKick = 'room:kick';
  static const String roomBan = 'room:ban';
  
  // User Events
  static const String userOnline = 'user:online';
  static const String userOffline = 'user:offline';
  static const String userUpdate = 'user:update';
  static const String userFollow = 'user:follow';
  static const String userUnfollow = 'user:unfollow';
  
  // Gift Events
  static const String giftSend = 'gift:send';
  static const String giftReceive = 'gift:receive';
  static const String giftBroadcast = 'gift:broadcast';
  
  // Game Events
  static const String gameStart = 'game:start';
  static const String gameMove = 'game:move';
  static const String gameEnd = 'game:end';
  static const String gameResult = 'game:result';
  
  // PK Events
  static const String pkStart = 'pk:start';
  static const String pkScore = 'pk:score';
  static const String pkEnd = 'pk:end';
  static const String pkResult = 'pk:result';
  
  // Notification Events
  static const String notification = 'notification';
  static const String notificationRead = 'notification:read';
}

class AnalyticsEvents {
  static const String appOpen = 'app_open';
  static const String appClose = 'app_close';
  static const String screenView = 'screen_view';
  static const String buttonClick = 'button_click';
  static const String login = 'login';
  static const String register = 'register';
  static const String logout = 'logout';
  static const String roomCreate = 'room_create';
  static const String roomJoin = 'room_join';
  static const String roomLeave = 'room_leave';
  static const String giftSend = 'gift_send';
  static const String gamePlay = 'game_play';
  static const String gameWin = 'game_win';
  static const String gameLose = 'game_lose';
  static const String recharge = 'recharge';
  static const String withdraw = 'withdraw';
  static const String follow = 'follow';
  static const String unfollow = 'unfollow';
  static const String share = 'share';
  static const String report = 'report';
  static const String search = 'search';
}