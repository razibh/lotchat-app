import 'package:flutter/material.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/home/home_screen.dart';
import '../features/room/room_screen.dart';
import '../features/room/create_room_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/games/games_home_screen.dart';
import '../features/games/roulette_game.dart';
import '../features/games/three_patti_game.dart';
import '../features/games/ludo_game.dart';
import '../features/games/carrom_game.dart';
import '../features/games/greedy_cat_game.dart';
import '../features/games/werewolf_game.dart';
import '../features/games/trivia_game.dart';
import '../features/games/pictionary_game.dart';
import '../features/games/chess_game.dart';
import '../features/games/truth_or_dare_game.dart';
import '../features/call/widgets/call_screen.dart';
import '../features/call/widgets/incoming_call_screen.dart';
import '../features/chat/chat_list_screen.dart';
import '../features/chat/chat_detail_screen.dart';
import '../features/wallet/wallet_screen.dart';
import '../features/wallet/recharge_screen.dart';
import '../features/wallet/withdraw_screen.dart';
import '../features/wallet/transaction_history_screen.dart';
import '../features/discover/discover_screen.dart';
import '../features/discover/create_post_screen.dart';
import '../features/discover/post_detail_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/friends/friends_screen.dart';
import '../features/friends/friend_requests_screen.dart';
import '../features/friends/find_friends_screen.dart';
import '../features/leaderboard/leaderboard_screen.dart';
import '../features/search/search_screen.dart';
import '../features/search/search_result_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/admin/admin_panel.dart';
import '../features/admin/user_management.dart';
import '../features/admin/agency_management.dart';
import '../features/admin/seller_management.dart';
import '../features/admin/gift_management.dart';
import '../features/agency/agency_dashboard.dart';
import '../features/agency/member_management.dart';
import '../features/pk/pk_battle_screen.dart';
import '../features/pk/pk_history_screen.dart';
import '../features/clan/clan_home_screen.dart';
import '../features/clan/create_clan_screen.dart';
import '../features/clan/clan_detail_screen.dart';
import 'models/room_model.dart';
import 'models/user_model.dart';

class RouteGenerator {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String room = '/room';
  static const String createRoom = '/room/create';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
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
  static const String call = '/call';
  static const String incomingCall = '/call/incoming';
  static const String chatList = '/chat';
  static const String chatDetail = '/chat/detail';
  static const String wallet = '/wallet';
  static const String recharge = '/wallet/recharge';
  static const String withdraw = '/wallet/withdraw';
  static const String transactionHistory = '/wallet/history';
  static const String discover = '/discover';
  static const String createPost = '/discover/create';
  static const String postDetail = '/discover/post';
  static const String notifications = '/notifications';
  static const String friends = '/friends';
  static const String friendRequests = '/friends/requests';
  static const String findFriends = '/friends/find';
  static const String leaderboard = '/leaderboard';
  static const String search = '/search';
  static const String searchResult = '/search/result';
  static const String settings = '/settings';
  static const String admin = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminAgencies = '/admin/agencies';
  static const String adminSellers = '/admin/sellers';
  static const String adminGifts = '/admin/gifts';
  static const String agency = '/agency';
  static const String agencyMembers = '/agency/members';
  static const String pk = '/pk';
  static const String pkHistory = '/pk/history';
  static const String clan = '/clan';
  static const String createClan = '/clan/create';
  static const String clanDetail = '/clan/detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case room:
        if (args is RoomModel) {
          return MaterialPageRoute(builder: (_) => RoomScreen(room: args));
        }
        return _errorRoute();
      
      case createRoom:
        return MaterialPageRoute(builder: (_) => const CreateRoomScreen());
      
      case profile:
        if (args is String) {
          return MaterialPageRoute(builder: (_) => ProfileScreen(userId: args));
        }
        return MaterialPageRoute(builder: (_) => const ProfileScreen(userId: ''));
      
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      
      case games:
        return MaterialPageRoute(builder: (_) => const GamesHomeScreen());
      
      case gameRoulette:
        return MaterialPageRoute(builder: (_) => const RouletteGame());
      
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
              callType: args['callType'],
            ),
          );
        }
        return _errorRoute();
      
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
      
      case wallet:
        return MaterialPageRoute(builder: (_) => const WalletScreen());
      
      case recharge:
        return MaterialPageRoute(builder: (_) => const RechargeScreen());
      
      case withdraw:
        return MaterialPageRoute(builder: (_) => const WithdrawScreen());
      
      case transactionHistory:
        return MaterialPageRoute(builder: (_) => const TransactionHistoryScreen());
      
      case discover:
        return MaterialPageRoute(builder: (_) => const DiscoverScreen());
      
      case createPost:
        return MaterialPageRoute(builder: (_) => const CreatePostScreen());
      
      case postDetail:
        if (args is Map) {
          return MaterialPageRoute(
            builder: (_) => PostDetailScreen(post: args),
          );
        }
        return _errorRoute();
      
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      
      case friends:
        return MaterialPageRoute(builder: (_) => const FriendsScreen());
      
      case friendRequests:
        return MaterialPageRoute(builder: (_) => const FriendRequestsScreen());
      
      case findFriends:
        return MaterialPageRoute(builder: (_) => const FindFriendsScreen());
      
      case leaderboard:
        return MaterialPageRoute(builder: (_) => const LeaderboardScreen());
      
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
      
      case agency:
        return MaterialPageRoute(builder: (_) => const AgencyDashboard());
      
      case agencyMembers:
        return MaterialPageRoute(builder: (_) => const MemberManagement());
      
      case pk:
        return MaterialPageRoute(builder: (_) => const PKBattleScreen());
      
      case pkHistory:
        return MaterialPageRoute(builder: (_) => const PKHistoryScreen());
      
      case clan:
        return MaterialPageRoute(builder: (_) => const ClanHomeScreen());
      
      case createClan:
        return MaterialPageRoute(builder: (_) => const CreateClanScreen());
      
      case clanDetail:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ClanDetailScreen(clanId: args),
          );
        }
        return _errorRoute();
      
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
    });
  }
}