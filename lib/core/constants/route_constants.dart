class RouteConstants {
  // Private constructor to prevent instantiation
  RouteConstants._();

  // ==================== AUTH ROUTES ====================
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';

  // ==================== MAIN ROUTES ====================
  static const String home = '/home';
  static const String discover = '/discover';
  static const String messages = '/messages';
  static const String notifications = '/notifications';
  static const String search = '/search';
  static const String searchResult = '/search/result';
  static const String settings = '/settings';
  static const String profile = '/profile';

  // ==================== ROOM ROUTES ====================
  static const String room = '/room';
  static const String roomCreate = '/room/create';
  static const String roomSearch = '/room/search';
  static const String roomHistory = '/room/history';

  // ==================== PROFILE ROUTES ====================
  static const String profileView = '/profile/view';
  static const String profileEdit = '/profile/edit';
  static const String profileSettings = '/profile/settings';
  static const String profileFriends = '/profile/friends';
  static const String profileFollowers = '/profile/followers';
  static const String profileFollowing = '/profile/following';
  static const String profileBadges = '/profile/badges';
  static const String profileFrames = '/profile/frames';
  static const String profileAchievements = '/profile/achievements';
  static const String profileStats = '/profile/stats';
  static const String profileBlocked = '/profile/blocked';

  // ==================== CHAT ROUTES ====================
  static const String chatList = '/chat/list';
  static const String chatDetail = '/chat/detail';
  static const String chatGroup = '/chat/group';
  static const String chatInfo = '/chat/info';
  static const String chatSearch = '/chat/search';

  // ==================== CALL ROUTES ====================
  static const String callAudio = '/call/audio';
  static const String callVideo = '/call/video';
  static const String callIncoming = '/call/incoming';
  static const String callHistory = '/call/history';

  // ==================== GAME ROUTES ====================
  static const String games = '/games';
  static const String gameRoulette = '/game/roulette';
  static const String gameThreePatti = '/game/three-patti';
  static const String gameLudo = '/game/ludo';
  static const String gameCarrom = '/game/carrom';
  static const String gameGreedyCat = '/game/greedy-cat';
  static const String gameWerewolf = '/game/werewolf';
  static const String gameTrivia = '/game/trivia';
  static const String gamePictionary = '/game/pictionary';
  static const String gameChess = '/game/chess';
  static const String gameTruthOrDare = '/game/truth-or-dare';

  // ==================== POST ROUTES ====================
  static const String postCreate = '/post/create';
  static const String postDetail = '/post/detail';
  static const String postEdit = '/post/edit';

  // ==================== FRIEND ROUTES ====================
  static const String findFriends = '/friends/find';
  static const String friendRequests = '/friends/requests';
  static const String friendSuggestions = '/friends/suggestions';

  // ==================== LEADERBOARD ROUTES ====================
  static const String leaderboard = '/leaderboard';
  static const String leaderboardGifts = '/leaderboard/gifts';
  static const String leaderboardGames = '/leaderboard/games';
  static const String leaderboardClans = '/leaderboard/clans';

  // ==================== CLAN ROUTES ====================
  static const String clan = '/clan';
  static const String clanCreate = '/clan/create';
  static const String clanJoin = '/clan/join';
  static const String clanDetail = '/clan/detail';
  static const String clanMembers = '/clan/members';
  static const String clanChat = '/clan/chat';
  static const String clanTasks = '/clan/tasks';
  static const String clanShop = '/clan/shop';
  static const String clanWars = '/clan/wars';
  static const String clanLeaderboard = '/clan/leaderboard';
  static const String clanRequests = '/clan/requests';
  static const String clanSettings = '/clan/settings';

  // ==================== PK ROUTES ====================
  static const String pkBattle = '/pk/battle';
  static const String pkHistory = '/pk/history';
  static const String pkCreate = '/pk/create';

  // ==================== WALLET ROUTES ====================
  static const String wallet = '/wallet';
  static const String walletRecharge = '/wallet/recharge';
  static const String walletWithdraw = '/wallet/withdraw';
  static const String walletHistory = '/wallet/history';

  // ==================== GIFT ROUTES ====================
  static const String giftShop = '/gift/shop';
  static const String giftHistory = '/gift/history';
  static const String giftLeaderboard = '/gift/leaderboard';

  // ==================== ADMIN ROUTES ====================
  static const String admin = '/admin';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminGifts = '/admin/gifts';
  static const String adminReports = '/admin/reports';
  static const String adminAgencies = '/admin/agencies';
  static const String adminSellers = '/admin/sellers';

  // ==================== AGENCY ROUTES ====================
  static const String agency = '/agency';
  static const String agencyDashboard = '/agency/dashboard';
  static const String agencyMembers = '/agency/members';
  static const String agencyEarnings = '/agency/earnings';

  // ==================== SELLER ROUTES ====================
  static const String seller = '/seller';
  static const String sellerDashboard = '/seller/dashboard';
  static const String sellerPackages = '/seller/packages';
  static const String sellerSales = '/seller/sales';

  // ==================== FEATURE ROUTES ====================
  static const String events = '/events';
  static const String referral = '/referral';
  static const String luckyDraw = '/lucky-draw';
  static const String avatarBuilder = '/avatar/builder';
  static const String moments = '/moments';
  static const String webView = '/webview';

  // ==================== WEBVIEW SPECIFIC ROUTES ====================
  static const String privacyPolicy = '/privacy-policy';
  static const String termsOfService = '/terms-of-service';
  static const String helpCenter = '/help-center';

  // ==================== ERROR ROUTES ====================
  static const String notFound = '/404';
  static const String maintenance = '/maintenance';
  static const String noInternet = '/no-internet';

  // ==================== NAVIGATION HELPERS ====================
  static Map<String, String> get allRoutes => {
    splash: splash,
    login: login,
    register: register,
    forgotPassword: forgotPassword,
    otpVerification: otpVerification,
    home: home,
    discover: discover,
    messages: messages,
    notifications: notifications,
    search: search,
    searchResult: searchResult,
    settings: settings,
    profile: profile,
    room: room,
    roomCreate: roomCreate,
    roomSearch: roomSearch,
    roomHistory: roomHistory,
    games: games,
    wallet: wallet,
    admin: admin,
    agency: agency,
    seller: seller,
    clan: clan,
    notFound: notFound,
    maintenance: maintenance,
    noInternet: noInternet,
  };

  static bool isAuthRoute(String route) {
    return route == login ||
        route == register ||
        route == forgotPassword ||
        route == otpVerification;
  }

  static bool isProtectedRoute(String route) {
    return !isAuthRoute(route) && route != splash;
  }
}