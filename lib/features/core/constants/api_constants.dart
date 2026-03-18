class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://api.lotchat.com/v1';
  static const String socketUrl = 'wss://socket.lotchat.com';
  static const String cdnUrl = 'https://cdn.lotchat.com';

  // Development URLs
  static const String devBaseUrl = 'https://dev-api.lotchat.com/v1';
  static const String devSocketUrl = 'wss://dev-socket.lotchat.com';
  static const String devCdnUrl = 'https://dev-cdn.lotchat.com';

  // Staging URLs
  static const String stagingBaseUrl = 'https://staging-api.lotchat.com/v1';
  static const String stagingSocketUrl = 'wss://staging-socket.lotchat.com';
  static const String stagingCdnUrl = 'https://staging-cdn.lotchat.com';

  // API Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String verifyPhone = '/auth/verify-phone';
  static const String verifyOtp = '/auth/verify-otp';

  // User Endpoints
  static const String user = '/user';
  static const String userProfile = '/user/profile';
  static const String userUpdate = '/user/update';
  static const String userCoins = '/user/coins';
  static const String userDiamonds = '/user/diamonds';
  static const String userFriends = '/user/friends';
  static const String userFollowers = '/user/followers';
  static const String userFollowing = '/user/following';
  static const String userSettings = '/user/settings';
  static const String userBlocked = '/user/blocked';

  // Room Endpoints
  static const String rooms = '/rooms';
  static const String roomCreate = '/rooms/create';
  static const String roomJoin = '/rooms/join';
  static const String roomLeave = '/rooms/leave';
  static const String roomSeats = '/rooms/seats';
  static const String roomSeatTake = '/rooms/seat/take';
  static const String roomSeatLeave = '/rooms/seat/leave';
  static const String roomMute = '/rooms/mute';
  static const String roomUnmute = '/rooms/unmute';
  static const String roomRaiseHand = '/rooms/raise-hand';
  static const String roomLowerHand = '/rooms/lower-hand';

  // Gift Endpoints
  static const String gifts = '/gifts';
  static const String giftSend = '/gifts/send';
  static const String giftReceive = '/gifts/receive';
  static const String giftHistory = '/gifts/history';
  static const String giftLeaderboard = '/gifts/leaderboard';
  static const String giftShop = '/gifts/shop';
  static const String giftPurchase = '/gifts/purchase';

  // Game Endpoints
  static const String games = '/games';
  static const String gamePlay = '/games/play';
  static const String gameResult = '/games/result';
  static const String gameHistory = '/games/history';
  static const String gameLeaderboard = '/games/leaderboard';
  static const String gameSpin = '/games/spin';
  static const String gameBet = '/games/bet';

  // Chat Endpoints
  static const String chats = '/chats';
  static const String chatCreate = '/chats/create';
  static const String chatDelete = '/chats/delete';
  static const String messages = '/messages';
  static const String messageSend = '/messages/send';
  static const String messageDelete = '/messages/delete';
  static const String messageEdit = '/messages/edit';
  static const String messageReact = '/messages/react';

  // Call Endpoints
  static const String calls = '/calls';
  static const String callStart = '/calls/start';
  static const String callEnd = '/calls/end';
  static const String callJoin = '/calls/join';
  static const String callLeave = '/calls/leave';
  static const String callMute = '/calls/mute';
  static const String callUnmute = '/calls/unmute';

  // Payment Endpoints
  static const String payments = '/payments';
  static const String paymentCreate = '/payments/create';
  static const String paymentVerify = '/payments/verify';
  static const String paymentHistory = '/payments/history';
  static const String purchaseCoins = '/purchase/coins';
  static const String withdrawDiamonds = '/withdraw/diamonds';

  // Clan Endpoints
  static const String clans = '/clans';
  static const String clanCreate = '/clans/create';
  static const String clanJoin = '/clans/join';
  static const String clanLeave = '/clans/leave';
  static const String clanMembers = '/clans/members';
  static const String clanTasks = '/clans/tasks';
  static const String clanShop = '/clans/shop';
  static const String clanWars = '/clans/wars';

  // PK Battle Endpoints
  static const String pkBattles = '/pk-battles';
  static const String pkStart = '/pk-battles/start';
  static const String pkEnd = '/pk-battles/end';
  static const String pkScore = '/pk-battles/score';
  static const String pkHistory = '/pk-battles/history';

  // Leaderboard Endpoints
  static const String leaderboard = '/leaderboard';
  static const String leaderboardGifts = '/leaderboard/gifts';
  static const String leaderboardGames = '/leaderboard/games';
  static const String leaderboardClans = '/leaderboard/clans';

  // Search Endpoints
  static const String search = '/search';
  static const String searchUsers = '/search/users';
  static const String searchRooms = '/search/rooms';
  static const String searchGifts = '/search/gifts';
  static const String searchPosts = '/search/posts';

  // Admin Endpoints
  static const String admin = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminBan = '/admin/ban';
  static const String adminUnban = '/admin/unban';
  static const String adminAddCoins = '/admin/add-coins';
  static const String adminRemoveCoins = '/admin/remove-coins';
  static const String adminGifts = '/admin/gifts';
  static const String adminReports = '/admin/reports';

  // Agency Endpoints
  static const String agencies = '/agencies';
  static const String agencyMembers = '/agencies/members';
  static const String agencyEarnings = '/agencies/earnings';
  static const String agencyAddMember = '/agencies/add-member';
  static const String agencyRemoveMember = '/agencies/remove-member';

  // Seller Endpoints
  static const String sellers = '/sellers';
  static const String sellerCoins = '/sellers/coins';
  static const String sellerAddCoins = '/sellers/add-coins'; // ✅ 'string' → 'String'
  static const String sellerSales = '/sellers/sales';

  // Upload Endpoints
  static const String upload = '/upload';
  static const String uploadImage = '/upload/image';
  static const String uploadVideo = '/upload/video';
  static const String uploadAudio = '/upload/audio';
  static const String uploadFile = '/upload/file';

  // Report Endpoints
  static const String reports = '/reports';
  static const String reportCreate = '/reports/create';
  static const String reportUser = '/reports/user';
  static const String reportMessage = '/reports/message';
  static const String reportRoom = '/reports/room';

  // Notification Endpoints
  static const String notifications = '/notifications';
  static const String notificationRead = '/notifications/read';
  static const String notificationDelete = '/notifications/delete';
  static const String notificationSettings = '/notifications/settings';

  // WebSocket Events
  static const String wsConnect = 'connect';
  static const String wsDisconnect = 'disconnect';
  static const String wsJoinRoom = 'join-room';
  static const String wsLeaveRoom = 'leave-room';
  static const String wsSendMessage = 'send-message';
  static const String wsReceiveMessage = 'receive-message';
  static const String wsTyping = 'typing';
  static const String wsStopTyping = 'stop-typing';
  static const String wsUserJoined = 'user-joined';
  static const String wsUserLeft = 'user-left';
  static const String wsSeatTaken = 'seat-taken';
  static const String wsSeatLeft = 'seat-left';
  static const String wsMicToggled = 'mic-toggled';
  static const String wsGiftSent = 'gift-sent';
  static const String wsPkUpdate = 'pk-update';
  static const String wsPkEnd = 'pk-end';

  // Headers
  static const String headerAuthorization = 'Authorization';
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';
  static const String headerUserAgent = 'User-Agent';
  static const String headerApiKey = 'X-API-Key';
  static const String headerDeviceId = 'X-Device-ID';
  static const String headerPlatform = 'X-Platform';
  static const String headerVersion = 'X-App-Version';

  // Content Types
  static const String contentTypeJson = 'application/json';
  static const String contentTypeForm = 'application/x-www-form-urlencoded';
  static const String contentTypeMultipart = 'multipart/form-data';
  static const String contentTypeImage = 'image/jpeg';
  static const String contentTypeVideo = 'video/mp4';
  static const String contentTypeAudio = 'audio/mpeg';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  static const Duration socketTimeout = Duration(minutes: 1);

  // Retry Config
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
}