class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://api.lotchat.com/v1';
  static const String socketUrl = 'wss://socket.lotchat.com';
  static const String cdnUrl = 'https://cdn.lotchat.com';

  // API Version
  static const String apiVersion = 'v1';
  static const String apiPrefix = '/api';

  // ==================== AUTH ENDPOINTS ====================
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String verifyOTP = '/auth/verify-otp';
  static const String changePassword = '/auth/change-password';
  static const String socialLogin = '/auth/social-login';

  // ==================== USER ENDPOINTS ====================
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
  static const String userLevel = '/user/level';
  static const String userBadges = '/user/badges';

  // ==================== ROOM ENDPOINTS ====================
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
  static const String roomSearch = '/rooms/search';
  static const String roomTrending = '/rooms/trending';
  static const String roomNearby = '/rooms/nearby';

  // ==================== GIFT ENDPOINTS ====================
  static const String gifts = '/gifts';
  static const String giftSend = '/gifts/send';
  static const String giftReceive = '/gifts/receive';
  static const String giftHistory = '/gifts/history';
  static const String giftLeaderboard = '/gifts/leaderboard';
  static const String giftTemplates = '/gifts/templates';
  static const String giftStats = '/gifts/stats';
  static const String giftRankings = '/gifts/rankings';
  static const String giftCategories = '/gifts/categories';

  // ==================== GAME ENDPOINTS ====================
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
  static const String gameCategories = '/games/categories';

  // ==================== PK BATTLE ENDPOINTS ====================
  static const String pkStart = '/pk/start';
  static const String pkEnd = '/pk/end';
  static const String pkScore = '/pk/score';
  static const String pkHistory = '/pk/history';
  static const String pkRankings = '/pk/rankings';
  static const String pkChallenge = '/pk/challenge';
  static const String pkAccept = '/pk/accept';
  static const String pkDecline = '/pk/decline';
  static const String pkLeaderboard = '/pk/leaderboard';

  // ==================== TRANSACTION ENDPOINTS ====================
  static const String transactions = '/transactions';
  static const String transactionDetails = '/transactions/details';
  static const String purchaseCoins = '/purchase/coins';
  static const String purchasePackages = '/purchase/packages';
  static const String withdrawDiamonds = '/withdraw/diamonds';
  static const String withdrawHistory = '/withdraw/history';
  static const String withdrawStatus = '/withdraw/status';
  static const String paymentMethods = '/payment/methods';
  static const String paymentVerify = '/payment/verify';
  static const String paymentWebhook = '/payment/webhook';

  // ==================== ADMIN ENDPOINTS ====================
  static const String admin = '/admin';
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
  static const String adminBackup = '/admin/backup';

  // ==================== AGENCY ENDPOINTS ====================
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
  static const String agencyApprove = '/agency/approve';
  static const String agencyReject = '/agency/reject';

  // ==================== SELLER ENDPOINTS ====================
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
  static const String sellerCustomers = '/seller/customers';

  // ==================== CHAT ENDPOINTS ====================
  static const String chats = '/chats';
  static const String chatCreate = '/chats/create';
  static const String chatDetails = '/chats/details';
  static const String chatDelete = '/chats/delete';
  static const String chatMessages = '/chats/messages';
  static const String chatSendMessage = '/chats/send-message';
  static const String chatDeleteMessage = '/chats/delete-message';
  static const String chatTyping = '/chats/typing';
  static const String chatRead = '/chats/read';

  // ==================== SEARCH ENDPOINTS ====================
  static const String search = '/search';
  static const String searchUsers = '/search/users';
  static const String searchRooms = '/search/rooms';
  static const String searchGames = '/search/games';
  static const String searchGifts = '/search/gifts';
  static const String searchMessages = '/search/messages';
  static const String searchHistory = '/search/history';
  static const String searchTrending = '/search/trending';

  // ==================== NOTIFICATION ENDPOINTS ====================
  static const String notifications = '/notifications';
  static const String notificationMarkRead = '/notifications/mark-read';
  static const String notificationMarkAllRead = '/notifications/mark-all-read';
  static const String notificationDelete = '/notifications/delete';
  static const String notificationSettings = '/notifications/settings';
  static const String notificationUpdateSettings = '/notifications/settings/update';

  // ==================== UPLOAD ENDPOINTS ====================
  static const String upload = '/upload';
  static const String uploadImage = '/upload/image';
  static const String uploadVideo = '/upload/video';
  static const String uploadAudio = '/upload/audio';
  static const String uploadFile = '/upload/file';
  static const String uploadAvatar = '/upload/avatar';
  static const String uploadCover = '/upload/cover';
  static const String uploadMultiple = '/upload/multiple';

  // ==================== HEADERS ====================
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
  static const String headerTimezone = 'X-Timezone';

  // ==================== CONTENT TYPES ====================
  static const String contentTypeJson = 'application/json';
  static const String contentTypeForm = 'application/x-www-form-urlencoded';
  static const String contentTypeMultipart = 'multipart/form-data';
  static const String contentTypePlain = 'text/plain';
  static const String contentTypeHtml = 'text/html';
  static const String contentTypeXml = 'application/xml';
  static const String contentTypeOctetStream = 'application/octet-stream';

  // ==================== HTTP METHODS ====================
  static const String methodGet = 'GET';
  static const String methodPost = 'POST';
  static const String methodPut = 'PUT';
  static const String methodDelete = 'DELETE';
  static const String methodPatch = 'PATCH';
  static const String methodHead = 'HEAD';
  static const String methodOptions = 'OPTIONS';

  // ==================== RESPONSE CODES ====================
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

  // ==================== QUERY PARAMETERS ====================
  static const String paramPage = 'page';
  static const String paramLimit = 'limit';
  static const String paramSort = 'sort';
  static const String paramOrder = 'order';
  static const String paramSearch = 'search';
  static const String paramFilter = 'filter';
  static const String paramInclude = 'include';

  // ==================== ERROR MESSAGES ====================
  static const String errorNetwork = 'Network error';
  static const String errorServer = 'Server error';
  static const String errorUnauthorized = 'Unauthorized';
  static const String errorForbidden = 'Forbidden';
  static const String errorNotFound = 'Not found';
  static const String errorValidation = 'Validation error';
  static const String errorTimeout = 'Request timeout';
}