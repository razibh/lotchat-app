import 'package:flutter/material.dart';
import 'route_constants.dart';
import 'navigation_service.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/room/room_screen.dart';
import '../../features/room/create_room_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/profile/profile_settings_screen.dart';
import '../../features/profile/friends_screen.dart';
import '../../features/profile/followers_screen.dart';
import '../../features/profile/following_screen.dart';
import '../../features/profile/blocked_users_screen.dart';
import '../../features/profile/badges_screen.dart';
import '../../features/profile/frames_screen.dart';
import '../../features/profile/achievements_screen.dart';
import '../../features/profile/profile_stats_screen.dart';
import '../../features/games/games_home_screen.dart';
import '../../features/games/roulette_game.dart';
import '../../features/games/three_patti_game.dart';
import '../../features/games/ludo_game.dart';
import '../../features/games/carrom_game.dart';
import '../../features/games/greedy_cat_game.dart';
import '../../features/games/werewolf_game.dart';
import '../../features/games/trivia_game.dart';
import '../../features/games/pictionary_game.dart';
import '../../features/games/chess_game.dart';
import '../../features/games/truth_or_dare_game.dart';
import '../../features/call/call_screen.dart';
import '../../features/call/incoming_call_screen.dart';
import '../../features/chat/chat_list_screen.dart';
import '../../features/chat/chat_detail_screen.dart';
import '../../features/wallet/wallet_screen.dart';
import '../../features/wallet/recharge_screen.dart';
import '../../features/wallet/withdraw_screen.dart';
import '../../features/wallet/transaction_history_screen.dart';
import '../../features/discover/discover_screen.dart';
import '../../features/discover/create_post_screen.dart';
import '../../features/discover/post_detail_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/friends/find_friends_screen.dart';
import '../../features/friends/friend_requests_screen.dart';
import '../../features/leaderboard/leaderboard_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/search/search_result_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/admin/admin_panel.dart';
import '../../features/admin/user_management.dart';
import '../../features/admin/agency_management.dart';
import '../../features/admin/seller_management.dart';
import '../../features/admin/gift_management.dart';
import '../../features/agency/agency_dashboard.dart';
import '../../features/agency/member_management.dart';
import '../../features/clan/clan_home_screen.dart';
import '../../features/clan/create_clan_screen.dart';
import '../../features/clan/clan_detail_screen.dart';
import '../../features/clan/clan_members_screen.dart';
import '../../features/clan/clan_chat_screen.dart';
import '../../features/clan/clan_tasks_screen.dart';
import '../../features/clan/clan_shop_screen.dart';
import '../../features/clan/clan_wars_screen.dart';
import '../../features/clan/clan_leaderboard_screen.dart';
import '../../features/clan/clan_requests_screen.dart';
import '../../features/clan/clan_settings_screen.dart';
import '../../features/pk/pk_battle_screen.dart';
import '../../features/pk/pk_history_screen.dart';
import '../../features/events/events_screen.dart';
import '../../features/referral/referral_screen.dart';
import '../../features/lucky_draw/lucky_draw_screen.dart';
import '../../features/translation/voice_translation_screen.dart';
import '../../features/avatar/avatar_builder_screen.dart';
import '../../features/moments/moments_screen.dart';
import '../../features/webview/webview_screen.dart';
import '../../features/not_found_screen.dart';
import '../models/room_model.dart';
import '../models/user_model.dart';
import '../models/clan_model.dart';

class RouteGenerator {
  // Generate route based on settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      // ==================== AUTH ROUTES ====================
      case RouteConstants.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case RouteConstants.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case RouteConstants.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case RouteConstants.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      
      case RouteConstants.otpVerification:
        if (args is Map && args.containsKey('verificationId')) {
          return MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              verificationId: args['verificationId'],
              phoneNumber: args['phoneNumber'],
            ),
          );
        }
        return _errorRoute();

      // ==================== MAIN ROUTES ====================
      case RouteConstants.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case RouteConstants.discover:
        return MaterialPageRoute(builder: (_) => const DiscoverScreen());
      
      case RouteConstants.messages:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());
      
      case RouteConstants.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      
      case RouteConstants.search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      
      case RouteConstants.searchResult:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => SearchResultScreen(query: args),
          );
        }
        return _errorRoute();
      
      case RouteConstants.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      // ==================== ROOM ROUTES ====================
      case RouteConstants.room:
        if (args is RoomModel) {
          return MaterialPageRoute(builder: (_) => RoomScreen(room: args));
        } else if (args is Map && args.containsKey('roomId')) {
          return MaterialPageRoute(
            builder: (_) => RoomScreen(roomId: args['roomId']),
          );
        }
        return _errorRoute();
      
      case RouteConstants.roomCreate:
        return MaterialPageRoute(builder: (_) => const CreateRoomScreen());
      
      case RouteConstants.roomSearch:
        return MaterialPageRoute(builder: (_) => const RoomSearchScreen());
      
      case RouteConstants.roomHistory:
        return MaterialPageRoute(builder: (_) => const RoomHistoryScreen());

      // ==================== PROFILE ROUTES ====================
      case RouteConstants.profile:
        if (args is String) {
          return MaterialPageRoute(builder: (_) => ProfileScreen(userId: args));
        }
        return MaterialPageRoute(builder: (_) => const ProfileScreen(userId: null));
      
      case RouteConstants.profileView:
        if (args is Map && args.containsKey('userId')) {
          return MaterialPageRoute(
            builder: (_) => ProfileScreen(userId: args['userId']),
          );
        }
        return _errorRoute();
      
      case RouteConstants.profileEdit:
        if (args is ProfileModel) {
          return MaterialPageRoute(
            builder: (_) => EditProfileScreen(profile: args),
          );
        }
        return _errorRoute();
      
      case RouteConstants.profileSettings:
        return MaterialPageRoute(builder: (_) => const ProfileSettingsScreen());
      
      case RouteConstants.profileFriends:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => FriendsScreen(userId: args),
          );
        }
        return _errorRoute();
      
      case RouteConstants.profileFollowers:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => FollowersScreen(userId: args),
          );
        }
        return _errorRoute();
      
      case RouteConstants.profileFollowing:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => FollowingScreen(userId: args),
          );
        }
        return _errorRoute();
      
      case RouteConstants.profileBadges:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => BadgesScreen(userId: args),
          );
        }
        return _errorRoute();
      
      case RouteConstants.profileFrames:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => FramesScreen(userId: args),
          );
        }
        return _errorRoute();
      
      case RouteConstants.profileAchievements:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => AchievementsScreen(userId: args),
          );
        }
        return _errorRoute();
      
      case RouteConstants.profileStats:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ProfileStatsScreen(userId: args),
          );
        }
        return _errorRoute();
      
      case RouteConstants.profileBlocked:
        return MaterialPageRoute(builder: (_) => const BlockedUsersScreen());

      // ==================== CHAT ROUTES ====================
      case RouteConstants.chatList:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());
      
      case RouteConstants.chatDetail:
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
      
      case RouteConstants.chatGroup:
        if (args is Map && args.containsKey('groupId')) {
          return MaterialPageRoute(
            builder: (_) => GroupChatScreen(
              groupId: args['groupId'],
              groupName: args['groupName'],
            ),
          );
        }
        return _errorRoute();
      
      case RouteConstants.chatInfo:
        if (args is Map && args.containsKey('chatId')) {
          return MaterialPageRoute(
            builder: (_) => ChatInfoScreen(
              chatId: args['chatId'],
              chatType: args['chatType'],
            ),
          );
        }
        return _errorRoute();
      
      case RouteConstants.chatSearch:
        return MaterialPageRoute(builder: (_) => const ChatSearchScreen());

      // ==================== CALL ROUTES ====================
      case RouteConstants.callAudio:
        if (args is Map && args.containsKey('user')) {
          return MaterialPageRoute(
            builder: (_) => CallScreen(
              user: args['user'],
              isVideoCall: false,
            ),
          );
        }
        return _errorRoute();
      
      case RouteConstants.callVideo:
        if (args is Map && args.containsKey('user')) {
          return MaterialPageRoute(
            builder: (_) => CallScreen(
              user: args['user'],
              isVideoCall: true,
            ),
          );
        }
        return _errorRoute();
      
      case RouteConstants.callIncoming:
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
      
      case RouteConstants.callHistory:
        return MaterialPageRoute(builder: (_) => const CallHistoryScreen());

      // ==================== GAME ROUTES ====================
      case RouteConstants.games:
        return MaterialPageRoute(builder: (_) => const GamesHomeScreen());
      
      case RouteConstants.gameRoulette:
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => RouletteGame(betAmount: args),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const RouletteGame(betAmount: 100),
        );
      
      case RouteConstants.gameThreePatti:
        return MaterialPageRoute(builder: (_) => const ThreePattiGame());
      
      case RouteConstants.gameLudo:
        return MaterialPageRoute(builder: (_) => const LudoGame());
      
      case RouteConstants.gameCarrom:
        return MaterialPageRoute(builder: (_) => const CarromGame());
      
      case RouteConstants.gameGreedyCat:
        return MaterialPageRoute(builder: (_) => const GreedyCatGame());
      
      case RouteConstants.gameWerewolf:
        return MaterialPageRoute(builder: (_) => const WerewolfGame());
      
      case RouteConstants.gameTrivia:
        return MaterialPageRoute(builder: (_) => const TriviaGame());
      
      case RouteConstants.gamePictionary:
        return MaterialPageRoute(builder: (_) => const PictionaryGame());
      
      case RouteConstants.gameChess:
        return MaterialPageRoute(builder: (_) => const ChessGame());
      
      case RouteConstants.gameTruthOrDare:
        return MaterialPageRoute(builder: (_) => const TruthOrDareGame());

      // ==================== WALLET ROUTES ====================
      case RouteConstants.wallet:
        return MaterialPageRoute(builder: (_) => const WalletScreen());
      
      case RouteConstants.walletRecharge:
        return MaterialPageRoute(builder: (_) => const RechargeScreen());
      
      case RouteConstants.walletWithdraw:
        return MaterialPageRoute(builder: (_) => const WithdrawScreen());
      
      case RouteConstants.walletHistory:
        return MaterialPageRoute(builder: (_) => const TransactionHistoryScreen());

      // ==================== POST ROUTES ====================
      case RouteConstants.postCreate:
        return MaterialPageRoute(builder: (_) => const CreatePostScreen());
      
      case RouteConstants.postDetail:
        if (args is Map) {
          return MaterialPageRoute(
            builder: (_) => PostDetailScreen(post: args),
          );
        }
        return _errorRoute();
      
      case RouteConstants.postEdit:
        if (args is Map && args.containsKey('postId')) {
          return MaterialPageRoute(
            builder: (_) => EditPostScreen(postId: args['postId']),
          );
        }
        return _errorRoute();

      // ==================== FRIEND ROUTES ====================
      case RouteConstants.findFriends:
        return MaterialPageRoute(builder: (_) => const FindFriendsScreen());
      
      case RouteConstants.friendRequests:
        return MaterialPageRoute(builder: (_) => const FriendRequestsScreen());
      
      case RouteConstants.friendSuggestions:
        return MaterialPageRoute(builder: (_) => const FriendSuggestionsScreen());

      // ==================== LEADERBOARD ROUTES ====================
      case RouteConstants.leaderboard:
        return MaterialPageRoute(builder: (_) => const LeaderboardScreen());
      
      case RouteConstants.leaderboardGifts:
        return MaterialPageRoute(builder: (_) => const GiftLeaderboardScreen());
      
      case RouteConstants.leaderboardGames:
        return MaterialPageRoute(builder: (_) => const GameLeaderboardScreen());
      
      case RouteConstants.leaderboardClans:
        return MaterialPageRoute(builder: (_) => const ClanLeaderboardScreen());

      // ==================== CLAN ROUTES ====================
      case RouteConstants.clan:
        return MaterialPageRoute(builder: (_) => const ClanHomeScreen());
      
      case RouteConstants.clanCreate:
        return MaterialPageRoute(builder: (_) => const CreateClanScreen());
      
      case RouteConstants.clanDetail:
        if (args is ClanModel) {
          return MaterialPageRoute(
            builder: (_) => ClanDetailScreen(clan: args),
          );
        } else if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ClanDetailScreen(clanId: args),
          );
        }
        return _errorRoute();
      
      case RouteConstants.clanMembers:
        if (args is ClanModel) {
          return MaterialPageRoute(
            builder: (_) => ClanMembersScreen(clan: args),
          );
        }
        return _errorRoute();
      
      case RouteConstants.clanChat:
        if (args is Map && args.containsKey('clanId') && args.containsKey('clanName')) {
          return MaterialPageRoute(
            builder: (_) => ClanChatScreen(
              clanId: args['clanId'],
              clanName: args['clanName'],
            ),
          );
        }
        return _errorRoute();
      
      case RouteConstants.clanTasks:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ClanTasksScreen(clanId: args),
          );
        }
        return _errorRoute();
      
      case RouteConstants.clanShop:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ClanShopScreen(clanId: args),
          );
        }
        return _errorRoute();
      
      case RouteConstants.clanWars:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ClanWarsScreen(clanId: args),
          );
        }
        return _errorRoute();
      
      case RouteConstants.clanLeaderboard:
        return MaterialPageRoute(builder: (_) => const ClanLeaderboardScreen());
      
      case RouteConstants.clanRequests:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ClanRequestsScreen(clanId: args),
          );
        }
        return _errorRoute();
      
      case RouteConstants.clanSettings:
        if (args is ClanModel) {
          return MaterialPageRoute(
            builder: (_) => ClanSettingsScreen(clan: args),
          );
        }
        return _errorRoute();

      // ==================== PK ROUTES ====================
      case RouteConstants.pkBattle:
        if (args is Map && args.containsKey('roomId') && args.containsKey('opponentRoomId')) {
          return MaterialPageRoute(
            builder: (_) => PKBattleScreen(
              roomId: args['roomId'],
              opponentRoomId: args['opponentRoomId'],
            ),
          );
        }
        return _errorRoute();
      
      case RouteConstants.pkHistory:
        return MaterialPageRoute(builder: (_) => const PKHistoryScreen());
      
      case RouteConstants.pkCreate:
        return MaterialPageRoute(builder: (_) => const CreatePKScreen());

      // ==================== ADMIN ROUTES ====================
      case RouteConstants.admin:
        return MaterialPageRoute(builder: (_) => const AdminPanel());
      
      case RouteConstants.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      
      case RouteConstants.adminUsers:
        return MaterialPageRoute(builder: (_) => const UserManagement());
      
      case RouteConstants.adminGifts:
        return MaterialPageRoute(builder: (_) => const GiftManagement());
      
      case RouteConstants.adminReports:
        return MaterialPageRoute(builder: (_) => const ReportManagement());
      
      case RouteConstants.adminAgencies:
        return MaterialPageRoute(builder: (_) => const AgencyManagement());
      
      case RouteConstants.adminSellers:
        return MaterialPageRoute(builder: (_) => const SellerManagement());

      // ==================== AGENCY ROUTES ====================
      case RouteConstants.agency:
        return MaterialPageRoute(builder: (_) => const AgencyDashboard());
      
      case RouteConstants.agencyDashboard:
        return MaterialPageRoute(builder: (_) => const AgencyDashboard());
      
      case RouteConstants.agencyMembers:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => MemberManagement(agencyId: args),
          );
        }
        return _errorRoute();
      
      case RouteConstants.agencyEarnings:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => AgencyEarningsScreen(agencyId: args),
          );
        }
        return _errorRoute();

      // ==================== SELLER ROUTES ====================
      case RouteConstants.seller:
        return MaterialPageRoute(builder: (_) => const SellerDashboard());
      
      case RouteConstants.sellerDashboard:
        return MaterialPageRoute(builder: (_) => const SellerDashboard());
      
      case RouteConstants.sellerPackages:
        return MaterialPageRoute(builder: (_) => const SellerPackagesScreen());
      
      case RouteConstants.sellerSales:
        return MaterialPageRoute(builder: (_) => const SellerSalesScreen());

      // ==================== FEATURE ROUTES ====================
      case RouteConstants.events:
        return MaterialPageRoute(builder: (_) => const EventsScreen());
      
      case RouteConstants.referral:
        return MaterialPageRoute(builder: (_) => const ReferralScreen());
      
      case RouteConstants.luckyDraw:
        return MaterialPageRoute(builder: (_) => const LuckyDrawScreen());
      
      case RouteConstants.voiceTranslation:
        return MaterialPageRoute(builder: (_) => const VoiceTranslationScreen());
      
      case RouteConstants.avatarBuilder:
        return MaterialPageRoute(builder: (_) => const AvatarBuilderScreen());
      
      case RouteConstants.moments:
        return MaterialPageRoute(builder: (_) => const MomentsScreen());

      // ==================== WEBVIEW ROUTES ====================
      case RouteConstants.webView:
        if (args is Map && args.containsKey('url')) {
          return MaterialPageRoute(
            builder: (_) => WebViewScreen(
              url: args['url'],
              title: args['title'],
            ),
          );
        }
        return _errorRoute();
      
      case RouteConstants.privacyPolicy:
        return MaterialPageRoute(
          builder: (_) => const WebViewScreen(
            url: 'https://lotchat.com/privacy',
            title: 'Privacy Policy',
          ),
        );
      
      case RouteConstants.termsOfService:
        return MaterialPageRoute(
          builder: (_) => const WebViewScreen(
            url: 'https://lotchat.com/terms',
            title: 'Terms of Service',
          ),
        );
      
      case RouteConstants.helpCenter:
        return MaterialPageRoute(
          builder: (_) => const WebViewScreen(
            url: 'https://help.lotchat.com',
            title: 'Help Center',
          ),
        );

      // ==================== ERROR ROUTES ====================
      case RouteConstants.notFound:
        return MaterialPageRoute(builder: (_) => const NotFoundScreen());
      
      case RouteConstants.maintenance:
        return MaterialPageRoute(builder: (_) => const MaintenanceScreen());
      
      case RouteConstants.noInternet:
        return MaterialPageRoute(builder: (_) => const NoInternetScreen());

      // ==================== DEFAULT ====================
      default:
        return _errorRoute();
    }
  }

  // Error route for invalid routes
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => const NotFoundScreen(),
      settings: const RouteSettings(name: RouteConstants.notFound),
    );
  }

  // Unknown route
  static Route<dynamic> unknownRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text('Unknown route'),
        ),
      ),
    );
  }
}

// ==================== ADDITIONAL SCREENS ====================

// OTP Verification Screen
class OtpVerificationScreen extends StatelessWidget {

  const OtpVerificationScreen({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
  }) : super(key: key);
  final String verificationId;
  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Center(
        child: Text('Verifying OTP for $phoneNumber'),
      ),
    );
  }
}

// Room Search Screen
class RoomSearchScreen extends StatelessWidget {
  const RoomSearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Room Search Screen')),
    );
  }
}

// Room History Screen
class RoomHistoryScreen extends StatelessWidget {
  const RoomHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Room History Screen')),
    );
  }
}

// Group Chat Screen
class GroupChatScreen extends StatelessWidget {

  const GroupChatScreen({
    Key? key,
    required this.groupId,
    required this.groupName,
  }) : super(key: key);
  final String groupId;
  final String groupName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(groupName)),
      body: Center(child: Text('Group Chat: $groupId')),
    );
  }
}

// Chat Info Screen
class ChatInfoScreen extends StatelessWidget {

  const ChatInfoScreen({
    Key? key,
    required this.chatId,
    required this.chatType,
  }) : super(key: key);
  final String chatId;
  final String chatType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Info')),
      body: Center(child: Text('Chat Info: $chatId, Type: $chatType')),
    );
  }
}

// Call History Screen
class CallHistoryScreen extends StatelessWidget {
  const CallHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Call History Screen')),
    );
  }
}

// Edit Post Screen
class EditPostScreen extends StatelessWidget {

  const EditPostScreen({Key? key, required this.postId}) : super(key: key);
  final String postId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Post')),
      body: Center(child: Text('Editing Post: $postId')),
    );
  }
}

// Friend Suggestions Screen
class FriendSuggestionsScreen extends StatelessWidget {
  const FriendSuggestionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Friend Suggestions Screen')),
    );
  }
}

// Gift Leaderboard Screen
class GiftLeaderboardScreen extends StatelessWidget {
  const GiftLeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Gift Leaderboard Screen')),
    );
  }
}

// Game Leaderboard Screen
class GameLeaderboardScreen extends StatelessWidget {
  const GameLeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Game Leaderboard Screen')),
    );
  }
}

// Create PK Screen
class CreatePKScreen extends StatelessWidget {
  const CreatePKScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Create PK Battle Screen')),
    );
  }
}

// Admin Dashboard Screen
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Admin Dashboard Screen')),
    );
  }
}

// Report Management Screen
class ReportManagement extends StatelessWidget {
  const ReportManagement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Report Management Screen')),
    );
  }
}

// Agency Earnings Screen
class AgencyEarningsScreen extends StatelessWidget {

  const AgencyEarningsScreen({Key? key, required this.agencyId}) : super(key: key);
  final String agencyId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agency Earnings')),
      body: Center(child: Text('Agency Earnings: $agencyId')),
    );
  }
}

// Seller Dashboard
class SellerDashboard extends StatelessWidget {
  const SellerDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Seller Dashboard Screen')),
    );
  }
}

// Seller Packages Screen
class SellerPackagesScreen extends StatelessWidget {
  const SellerPackagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Seller Packages Screen')),
    );
  }
}

// Seller Sales Screen
class SellerSalesScreen extends StatelessWidget {
  const SellerSalesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Seller Sales Screen')),
    );
  }
}

// Maintenance Screen
class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <>[
            const Icon(Icons.build, size: 80, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Under Maintenance',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "We'll be back soon",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: NavigationService.goBack,
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}

// No Internet Screen
class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <>[
            const Icon(Icons.wifi_off, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'No Internet Connection',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your connection and try again',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: NavigationService.goBack,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}