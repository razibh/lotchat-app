class ApiConstants {
  static const String baseUrl = 'https://api.lotchat.com/v1';
  static const String socketUrl = 'wss://socket.lotchat.com';
  
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOTP = '/auth/verify-otp';
  
  // User
  static const String user = '/user';
  static const String userProfile = '/user/profile';
  static const String userUpdate = '/user/update';
  static const String userCoins = '/user/coins';
  static const String userDiamonds = '/user/diamonds';
  static const String userFriends = '/user/friends';
  static const String userFollowers = '/user/followers';
  static const String userFollowing = '/user/following';
  
  // Room
  static const String rooms = '/rooms';
  static const String roomCreate = '/rooms/create';
  static const String roomJoin = '/rooms/join';
  static const String roomLeave = '/rooms/leave';
  static const String roomSeats = '/rooms/seats';
  static const String roomSeatTake = '/rooms/seat/take';
  static const String roomSeatLeave = '/rooms/seat/leave';
  
  // Gifts
  static const String gifts = '/gifts';
  static const String giftSend = '/gifts/send';
  static const String giftReceive = '/gifts/receive';
  static const String giftHistory = '/gifts/history';
  static const String giftLeaderboard = '/gifts/leaderboard';
  
  // Games
  static const String games = '/games';
  static const String gamePlay = '/games/play';
  static const String gameResult = '/games/result';
  static const String gameHistory = '/games/history';
  
  // PK Battle
  static const String pkStart = '/pk/start';
  static const String pkEnd = '/pk/end';
  static const String pkScore = '/pk/score';
  static const String pkHistory = '/pk/history';
  
  // Transactions
  static const String transactions = '/transactions';
  static const String purchaseCoins = '/purchase/coins';
  static const String withdrawDiamonds = '/withdraw/diamonds';
  
  // Admin
  static const String adminUsers = '/admin/users';
  static const String adminBan = '/admin/ban';
  static const String adminUnban = '/admin/unban';
  static const String adminAddCoins = '/admin/add-coins';
  static const String adminGifts = '/admin/gifts';
  static const String adminReports = '/admin/reports';
  
  // Agency
  static const String agencies = '/agencies';
  static const String agencyAddMember = '/agency/add-member';
  static const String agencyRemoveMember = '/agency/remove-member';
  static const String agencyEarnings = '/agency/earnings';
  
  // Seller
  static const String sellers = '/sellers';
  static const String sellerAddCoins = '/seller/add-coins';
  static const String sellerPackages = '/seller/packages';
  static const String sellerSales = '/seller/sales';
  
  // Headers
  static const String headerAuthorization = 'Authorization';
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';
  static const String headerUserAgent = 'User-Agent';
  
  // Content Types
  static const String contentTypeJson = 'application/json';
  static const String contentTypeForm = 'application/x-www-form-urlencoded';
  static const String contentTypeMultipart = 'multipart/form-data';
}