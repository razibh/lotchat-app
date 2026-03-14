import 'package:flutter/material.dart';

import 'core/models/room_model.dart';
import 'core/models/user_model.dart';
import 'core/navigation/navigation_service.dart';
import 'features/admin/admin_panel.dart';
import 'features/admin/agency_management.dart';
import 'features/admin/gift_management.dart';
import 'features/admin/seller_management.dart';
import 'features/admin/user_management.dart';
import 'features/agency/agency_dashboard.dart';
import 'features/agency/member_management.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/avatar/avatar_builder_screen.dart';
import 'features/call/call_screen.dart';
import 'features/call/incoming_call_screen.dart';
import 'features/chat/chat_detail_screen.dart';
import 'features/chat/chat_list_screen.dart';
import 'features/clan/clan_chat_screen.dart';
import 'features/clan/clan_detail_screen.dart';
import 'features/clan/clan_home_screen.dart';
import 'features/clan/clan_leaderboard_screen.dart';
import 'features/clan/clan_members_screen.dart';
import 'features/clan/clan_requests_screen.dart';
import 'features/clan/clan_settings_screen.dart';
import 'features/clan/clan_shop_screen.dart';
import 'features/clan/clan_tasks_screen.dart';
import 'features/clan/clan_wars_screen.dart';
import 'features/clan/create_clan_screen.dart';
import 'features/discover/create_post_screen.dart';
import 'features/discover/discover_screen.dart';
import 'features/discover/post_detail_screen.dart';
import 'features/events/events_screen.dart';
import 'features/friends/find_friends_screen.dart';
import 'features/friends/friend_requests_screen.dart';
import 'features/games/carrom_game.dart';
import 'features/games/chess_game.dart';
import 'features/games/games_home_screen.dart';
import 'features/games/greedy_cat_game.dart';
import 'features/games/ludo_game.dart';
import 'features/games/pictionary_game.dart';
import 'features/games/roulette_game.dart';
import 'features/games/three_patti_game.dart';
import 'features/games/trivia_game.dart';
import 'features/games/truth_or_dare_game.dart';
import 'features/games/werewolf_game.dart';
import 'features/home/home_screen.dart';
import 'features/leaderboard/leaderboard_screen.dart';
import 'features/lucky_draw/lucky_draw_screen.dart';
import 'features/moments/moments_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/pk/pk_battle_screen.dart';
import 'features/pk/pk_history_screen.dart';
import 'features/profile/achievements_screen.dart';
import 'features/profile/badges_screen.dart';
import 'features/profile/blocked_users_screen.dart';
import 'features/profile/edit_profile_screen.dart';
import 'features/profile/followers_screen.dart';
import 'features/profile/following_screen.dart';
import 'features/profile/frames_screen.dart';
import 'features/profile/friends_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/profile/profile_settings_screen.dart';
import 'features/profile/profile_stats_screen.dart';
import 'features/referral/referral_screen.dart';
import 'features/room/create_room_screen.dart';
import 'features/room/room_screen.dart';
import 'features/search/search_result_screen.dart';
import 'features/search/search_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/translation/voice_translation_screen.dart';
import 'features/wallet/recharge_screen.dart';
import 'features/wallet/transaction_history_screen.dart';
import 'features/wallet/wallet_screen.dart';
import 'features/wallet/withdraw_screen.dart';

class RouteGenerator {
  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  
  // Main Routes
  static const String home = '/home';
  static const String discover = '/discover';
  static const String notifications = '/notifications';
  static const String search = '/search';
  static const String searchResult = '/search/result';
  static const String settings = '/settings';
  
  // Room Routes
  static const String room = '/room';
  static const String createRoom = '/room/create';
  
  // Profile Routes
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String profileSettings = '/profile/settings';
  static const String friends = '/profile/friends';
  static const String followers = '/profile/followers';
  static const String following = '/profile/following';
  static const String blocked = '/profile/blocked';
  static const String badges = '/profile/badges';
  static const String frames = '/profile/frames';
  static const String achievements = '/profile/achievements';
  static const String profileStats = '/profile/stats';
  
  // Chat Routes
  static const String chatList = '/chat';
  static const String chatDetail = '/chat/detail';
  
  // Game Routes
  static const String games = '/games';
  static const String gameRoulette = '/games/roulette';
  static const String gameThreePatti = '/games/three-patti';
  static const String gameLudo = '/games/ludo';
  static const String gameCarrom = '/games/carrom';
  static const String gameGreedyCat = '/games/greedy-cat';
  static const String gameWerewolf = '/games/werewolf';
  static const String gameTrivia = '/games/trivia';
  static const String gamePictionary = '/games/pictionary';
  static const String gameChess = '/games/chess';
  static const String gameTruthOrDare = '/games/truth-or-dare';
  
  // Call Routes
  static const String call = '/call';
  static const String incomingCall = '/call/incoming';
  
  // Wallet Routes
  static const String wallet = '/wallet';
  static const String recharge = '/wallet/recharge';
  static const String withdraw = '/wallet/withdraw';
  static const String transactionHistory = '/wallet/history';
  
  // Post Routes
  static const String createPost = '/post/create';
  static const String postDetail = '/post/detail';
  
  // Friend Routes
  static const String findFriends = '/friends/find';
  static const String friendRequests = '/friends/requests';
  
  // Leaderboard Routes
  static const String leaderboard = '/leaderboard';
  
  // Admin Routes
  static const String admin = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminAgencies = '/admin/agencies';
  static const String adminSellers = '/admin/sellers';
  static const String adminGifts = '/admin/gifts';
  
  // Agency Routes
  static const String agency = '/agency';
  static const String agencyMembers = '/agency/members';
  
  // Clan Routes
  static const String clan = '/clan';
  static const String createClan = '/clan/create';
  static const String clanDetail = '/clan/detail';
  static const String clanMembers = '/clan/members';
  static const String clanChat = '/clan/chat';
  static const String clanTasks = '/clan/tasks';
  static const String clanShop = '/clan/shop';
  static const String clanWars = '/clan/wars';
  static const String clanLeaderboard = '/clan/leaderboard';
  static const String clanRequests = '/clan/requests';
  static const String clanSettings = '/clan/settings';
  
  // PK Routes
  static const String pkBattle = '/pk/battle';
  static const String pkHistory = '/pk/history';
  
  // Feature Routes
  static const String events = '/events';
  static const String referral = '/referral';
  static const String luckyDraw = '/lucky-draw';
  static const String voiceTranslation = '/voice-translation';
  static const String avatarBuilder = '/avatar-builder';
  static const String moments = '/moments';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final Object? args = settings.arguments;

    switch (settings.name) {
      // Auth Routes
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      
      // Main Routes
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case discover:
        return MaterialPageRoute(builder: (_) => const DiscoverScreen());
      
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      
      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      
      case searchResult:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => SearchResultScreen(query: args),
          );
        }
        return _errorRoute();
      
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      
      // Room Routes
      case room:
        if (args is RoomModel) {
          return MaterialPageRoute(builder: (_) => RoomScreen(room: args));
        }
        return _errorRoute();
      
      case createRoom:
        return MaterialPageRoute(builder: (_) => const CreateRoomScreen());
      
      // Profile Routes
      case profile:
        if (args is String) {
          return MaterialPageRoute(builder: (_) => ProfileScreen(userId: args));
        }
        return MaterialPageRoute(builder: (_) => const ProfileScreen(userId: null));
      
      case editProfile:
        if (args is ProfileModel) {
          return MaterialPageRoute(builder: (_) => EditProfileScreen(profile: args));
        }
        return _errorRoute();
      
      case profileSettings:
        return MaterialPageRoute(builder: (_) => const ProfileSettingsScreen());
      
      case friends:
        if (args is String) {
          return MaterialPageRoute(builder: (_) => FriendsScreen(userId: args));
        }
        return _errorRoute();
      
      case followers:
        if (args is String) {
          return MaterialPageRoute(builder: (_) => FollowersScreen(userId: args));
        }
        return _errorRoute();
      
      case following:
        if (args is String) {
          return MaterialPageRoute(builder: (_) => FollowingScreen(userId: args));
        }
        return _errorRoute();
      
      case blocked:
        return MaterialPageRoute(builder: (_) => const BlockedUsersScreen());
      
      case badges:
        if (args is String) {
          return MaterialPageRoute(builder: (_) => BadgesScreen(userId: args));
        }
        return _errorRoute();
      
      case frames:
        if (args is String) {
          return MaterialPageRoute(builder: (_) => FramesScreen(userId: args));
        }
        return _errorRoute();
      
      case achievements:
        if (args is String) {
          return MaterialPageRoute(builder: (_) => AchievementsScreen(userId: args));
        }
        return _errorRoute();
      
      case profileStats:
        if (args is String) {
          return MaterialPageRoute(builder: (_) => ProfileStatsScreen(userId: args));
        }
        return _errorRoute();
      
      // Chat Routes
      case chatList:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());
      
      case chatDetail:
        if (args is Map) {
          return MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              userId: args['userId'],
              userName: args['userName'],
              userAvatar: args['userAvatar'],
            ),
          );
        }
        return _errorRoute();
      
      // Game Routes
      case games:
        return MaterialPageRoute(builder: (_) => const GamesHomeScreen());
      
      case gameRoulette:
        if (args is int) {
          return MaterialPageRoute(builder: (_) => RouletteGame(betAmount: args));
        }
        return MaterialPageRoute(builder: (_) => const RouletteGame(betAmount: 100));
      
      case gameThreePatti:
        return MaterialPageRoute(builder: (_) => const ThreePattiGame());
      
      case gameLudo:
        return MaterialPageRoute(builder: (_) => const LudoGame());
      
      case gameCarrom:
        return MaterialPageRoute(builder: (_) => const CarromGame());
      
      case gameGreedyCat:
        return MaterialPageRoute(builder: (_) => const GreedyCatGame());
      
      case gameWerewolf:
        return MaterialPageRoute(builder: (_) => const WerewolfGame());
      
      case gameTrivia:
        return MaterialPageRoute(builder: (_) => const TriviaGame());
      
      case gamePictionary:
        return MaterialPageRoute(builder: (_) => const PictionaryGame());
      
      case gameChess:
        return MaterialPageRoute(builder: (_) => const ChessGame());
      
      case gameTruthOrDare:
        return MaterialPageRoute(builder: (_) => const TruthOrDareGame());
      
      // Call Routes
      case call:
        if (args is Map && args.containsKey('user') && args.containsKey('isVideo')) {
          return MaterialPageRoute(
            builder: (_) => CallScreen(
              user: args['user'],
              isVideoCall: args['isVideo'],
            ),
          );
        }
        return _errorRoute();
      
      case incomingCall:
        if (args is Map) {
          return MaterialPageRoute(
            builder: (_) => IncomingCallScreen(
              callerId: args['callerId'],
              callerName: args['callerName'],
              callerAvatar: args['callerAvatar'],
              callType: args['callType'],
              channelId: args['channelId'],
            ),
          );
        }
        return _errorRoute();
      
      // Wallet Routes
      case wallet:
        return MaterialPageRoute(builder: (_) => const WalletScreen());
      
      case recharge:
        return MaterialPageRoute(builder: (_) => const RechargeScreen());
      
      case withdraw:
        return MaterialPageRoute(builder: (_) => const WithdrawScreen());
      
      case transactionHistory:
        return MaterialPageRoute(builder: (_) => const TransactionHistoryScreen());
      
      // Post Routes
      case createPost:
        return MaterialPageRoute(builder: (_) => const CreatePostScreen());
      
      case postDetail:
        if (args is Map) {
          return MaterialPageRoute(
            builder: (_) => PostDetailScreen(post: args),
          );
        }
        return _errorRoute();
      
      // Friend Routes
      case findFriends:
        return MaterialPageRoute(builder: (_) => const FindFriendsScreen());
      
      case friendRequests:
        return MaterialPageRoute(builder: (_) => const FriendRequestsScreen());
      
      // Leaderboard Routes
      case leaderboard:
        return MaterialPageRoute(builder: (_) => const LeaderboardScreen());
      
      // Admin Routes
      case admin:
        return MaterialPageRoute(builder: (_) => const AdminPanel());
      
      case adminUsers:
        return MaterialPageRoute(builder: (_) => const UserManagement());
      
      case adminAgencies:
        return MaterialPageRoute(builder: (_) => const AgencyManagement());
      
      case adminSellers:
        return MaterialPageRoute(builder: (_) => const SellerManagement());
      
      case adminGifts:
        return MaterialPageRoute(builder: (_) => const GiftManagement());
      
      // Agency Routes
      case agency:
        return MaterialPageRoute(builder: (_) => const AgencyDashboard());
      
      case agencyMembers:
        if (args is String) {
          return MaterialPageRoute(builder: (_) => MemberManagement(agencyId: args));
        }
        return _errorRoute();
      
      // Clan Routes
      case clan:
        return MaterialPageRoute(builder: (_) => const ClanHomeScreen());
      
      case createClan:
        return MaterialPageRoute(builder: (_) => const CreateClanScreen());
      
      case clanDetail:
        if (args is ClanModel) {
          return MaterialPageRoute(builder: (_) => ClanDetailScreen(clan: args));
        }
        return _errorRoute();
      
      case clanMembers:
        if (args is ClanModel) {
          return MaterialPageRoute(builder: (_) => ClanMembersScreen(clan: args));
        }
        return _errorRoute();
      
      case clanChat:
        if (args is Map && args.containsKey('clanId') && args.containsKey('clanName')) {
          return MaterialPageRoute(
            builder: (_) => ClanChatScreen(
              clanId: args['clanId'],
              clanName: args['clanName'],
            ),
          );
        }
        return _errorRoute();
      
      case clanTasks:
        if (args is String) {
          return MaterialPageRoute(builder: (_) => ClanTasksScreen(clanId: args));
        }
        return _errorRoute();
      
      case clanShop:
        if (args is String) {
          return MaterialPageRoute(builder: (_) => ClanShopScreen(clanId: args));
        }
        return _errorRoute();
      
      case clanWars:
        if (args is String) {
          return MaterialPageRoute(builder: (_) => ClanWarsScreen(clanId: args));
        }
        return _errorRoute();
      
      case clanLeaderboard:
        return MaterialPageRoute(builder: (_) => const ClanLeaderboardScreen());
      
      case clanRequests:
        if (args is String) {
          return MaterialPageRoute(builder: (_) => ClanRequestsScreen(clanId: args));
        }
        return _errorRoute();
      
      case clanSettings:
        if (args is ClanModel) {
          return MaterialPageRoute(builder: (_) => ClanSettingsScreen(clan: args));
        }
        return _errorRoute();
      
      // PK Routes
      case pkBattle:
        if (args is Map && args.containsKey('roomId') && args.containsKey('opponentRoomId')) {
          return MaterialPageRoute(
            builder: (_) => PKBattleScreen(
              roomId: args['roomId'],
              opponentRoomId: args['opponentRoomId'],
            ),
          );
        }
        return _errorRoute();
      
      case pkHistory:
        return MaterialPageRoute(builder: (_) => const PKHistoryScreen());
      
      // Feature Routes
      case events:
        return MaterialPageRoute(builder: (_) => const EventsScreen());
      
      case referral:
        return MaterialPageRoute(builder: (_) => const ReferralScreen());
      
      case luckyDraw:
        return MaterialPageRoute(builder: (_) => const LuckyDrawScreen());
      
      case voiceTranslation:
        return MaterialPageRoute(builder: (_) => const VoiceTranslationScreen());
      
      case avatarBuilder:
        return MaterialPageRoute(builder: (_) => const AvatarBuilderScreen());
      
      case moments:
        return MaterialPageRoute(builder: (_) => const MomentsScreen());
      
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Page not found!'),
        ),
      );
    },);
  }
}