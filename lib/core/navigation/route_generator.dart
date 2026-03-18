import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// ==================== CORE IMPORTS ====================
import '../../../core/constants/route_constants.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/models/room_model.dart';
import '../../../core/models/clan_model.dart';
import '../../../profile/models/profile_model.dart';
import '../../../core/models/seat_model.dart';
import '../../../core/models/user_models.dart';
import '../../../chat/models/chat_model.dart';

// ==================== AUTH FEATURE ====================
import '../../../features/auth/login_screen.dart';
import '../../../features/auth/register_screen.dart';
import '../../../features/auth/forgot_password_screen.dart' as forgot;
import '../../../features/auth/otp_verification_screen.dart';

// ==================== SPLASH & HOME ====================
import '../../../features/splash/splash_screen.dart';
import '../../../features/home/home_screen.dart';

// ==================== PROFILE FEATURE ====================
import '../../../features/profile/profile_screen.dart';
import '../../../features/profile/edit_profile_screen.dart';
import '../../../features/profile/profile_settings_screen.dart';
import '../../../features/profile/followers_screen.dart';
import '../../../features/profile/following_screen.dart';
import '../../../features/profile/badges_screen.dart';
import '../../../features/profile/frames_screen.dart';
import '../../../features/profile/achievements_screen.dart';
import '../../../features/profile/profile_stats_screen.dart';

// ==================== FRIENDS FEATURE ====================
import '../../../features/friends/friends_screen.dart';
import '../../../features/friends/blocked_users_screen.dart';
import '../../../features/friends/find_friends_screen.dart';
import '../../../features/friends/friend_requests_screen.dart';
import '../../../features/friends/friend_suggestions_screen.dart';

// ==================== ROOM FEATURE ====================
import '../../../features/room/room_screen.dart';
import '../../../features/room/create_room_screen.dart';
import '../../../features/room/room_search_screen.dart';
import '../../../features/room/room_history_screen.dart';

// ==================== CHAT FEATURE ====================
import '../../../chat/chat_detail_screen.dart';
import '../../../chat/chat_list_screen.dart';
import '../../../chat/chat_info_screen.dart';
import '../../../chat/group_chat_screen.dart';
import '../../../chat/chat_search_screen.dart';

// ==================== CALL FEATURE ====================
import '../../../features/call/call_screen.dart';
import '../../../features/call/incoming_call_screen.dart';
import '../../../features/call/call_history_screen.dart';

// ==================== GAMES FEATURE ====================
import '../../../features/games/games_home_screen.dart';
import '../../../features/games/roulette_game.dart';
import '../../../features/games/three_patti_game.dart';
import '../../../features/games/ludo_game.dart';
import '../../../features/games/carrom_game.dart';
import '../../../features/games/greedy_cat_game.dart';
import '../../../features/games/werewolf_game.dart';
import '../../../features/games/trivia_game.dart';
import '../../../features/games/pictionary_game.dart';
import '../../../features/games/chess_game.dart';
import '../../../features/games/truth_or_dare_game.dart';

// ==================== WALLET FEATURE ====================
import '../../../features/wallet/wallet_screen.dart';
import '../../../features/wallet/recharge_screen.dart';
import '../../../features/wallet/withdraw_screen.dart';
import '../../../features/wallet/transaction_history_screen.dart';

// ==================== DISCOVER FEATURE ====================
import '../../../features/discover/discover_screen.dart';
import '../../../features/discover/create_post_screen.dart';
import '../../../features/discover/post_detail_screen.dart';
import '../../../features/discover/edit_post_screen.dart';

// ==================== NOTIFICATIONS FEATURE ====================
import '../../../features/notifications/notifications_screen.dart';

// ==================== LEADERBOARD FEATURE ====================
import '../../../features/leaderboard/leaderboard_screen.dart';
import '../../../features/leaderboard/gift_leaderboard_screen.dart';
import '../../../features/leaderboard/game_leaderboard_screen.dart';
import '../../../features/clan/clan_leaderboard_screen.dart';

// ==================== SEARCH FEATURE ====================
import '../../../features/search/search_screen.dart';
import '../../../features/search/search_result_screen.dart';

// ==================== SETTINGS FEATURE ====================
import '../../../features/settings/settings_screen.dart';

// ==================== ADMIN FEATURE ====================
import '../../../features/admin/admin_panel.dart';
import '../../../features/admin/user_management.dart';
import '../../../features/admin/agency_management.dart';
import '../../../features/admin/seller_management.dart';
import '../../../features/admin/gift_management.dart';
import '../../../features/admin/report_management.dart';
import '../../../features/admin/dashboard/admin_dashboard.dart';

// ==================== AGENCY FEATURE ====================
import '../../../features/agency/agency_dashboard.dart';
import '../../../features/agency/member_management.dart';
import '../../../features/agency/earnings/agency_earnings_screen.dart';

// ==================== CLAN FEATURE ====================
import '../../../features/clan/clan_home_screen.dart';
import '../../../features/clan/create_clan_screen.dart';
import '../../../features/clan/clan_detail_screen.dart';
import '../../../features/clan/clan_members_screen.dart';
import '../../../features/clan/clan_chat_screen.dart';
import '../../../features/clan/clan_tasks_screen.dart';
import '../../../features/clan/clan_shop_screen.dart';
import '../../../features/clan/clan_wars_screen.dart';
import '../../../features/clan/clan_leaderboard_screen.dart';
import '../../../features/clan/clan_requests_screen.dart';
import '../../../features/clan/clan_settings_screen.dart';

// ==================== PK FEATURE ====================
import '../../../features/pk/pk_battle_screen.dart';
import '../../../features/pk/pk_history_screen.dart';
import '../../../features/pk/create_pk_screen.dart';

// ==================== EVENTS & REFERRAL ====================
import '../../../features/events/events_screen.dart';
import '../../../features/referral/referral_screen.dart';
import '../../../features/lucky_draw/lucky_draw_screen.dart';

// ==================== AVATAR & MOMENTS ====================
import '../../../features/avatar/avatar_builder_screen.dart';
import '../../../features/moments/moments_screen.dart';

// ==================== WEBVIEW ====================
import '../../../features/webview/webview_screen.dart';

// ==================== ERROR SCREENS ====================
import '../../../features/not_found_screen.dart';
import '../../../maintenance/maintenance_screen.dart';
import '../../../features/no_internet/no_internet_screen.dart';

// ==================== COUNTRY MANAGER SCREENS ====================
import '../../../features/country_manager/dashboard/country_manager_dashboard.dart';
import '../../features/agency/agency_list_screen.dart';
import '../../features/agency/agency_approval_screen.dart';
import '../../features/country_manager/dashboard/country_statistics_screen.dart';
import '../../../features/country_manager/recruitment/recruitment_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final dynamic args = settings.arguments;

    switch (settings.name) {
    // ==================== AUTH ROUTES ====================
      case RouteConstants.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case RouteConstants.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case RouteConstants.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case RouteConstants.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const forgot.ForgotPasswordScreen(),
        );

      case RouteConstants.otpVerification:
        if (args is Map<String, dynamic> &&
            args.containsKey('verificationId') &&
            args.containsKey('phoneNumber')) {
          return MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              verificationId: args['verificationId'] as String,
              phoneNumber: args['phoneNumber'] as String,
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
        if (args is Map<String, dynamic> && args.containsKey('query')) {
          return MaterialPageRoute(
            builder: (_) => SearchResultScreen(query: args['query'] as String),
          );
        }
        return _errorRoute();

      case RouteConstants.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

    // ==================== ROOM ROUTES ====================
      case RouteConstants.room:
        if (args is RoomModel) {
          return MaterialPageRoute(
            builder: (_) => RoomScreen(room: args),
          );
        } else if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => RoomScreen(room: RoomModel.fromJson(args)),
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
          return MaterialPageRoute(
            builder: (_) => ProfileScreen(userId: args, isOwnProfile: false),
          );
        } else if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => ProfileScreen(
              userId: args['userId'] as String? ?? '',
              isOwnProfile: args['isOwnProfile'] as bool? ?? false,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(userId: ''),
        );

      case RouteConstants.profileView:
        if (args is Map<String, dynamic> && args.containsKey('userId')) {
          return MaterialPageRoute(
            builder: (_) => ProfileScreen(
              userId: args['userId'] as String,
              isOwnProfile: args['isOwnProfile'] as bool? ?? false,
            ),
          );
        } else if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ProfileScreen(userId: args, isOwnProfile: false),
          );
        }
        return _errorRoute();

      case RouteConstants.profileEdit:
        if (args is User) {
          return MaterialPageRoute(
            builder: (_) => EditProfileScreen(user: args),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const EditProfileScreen(),
        );

      case RouteConstants.profileSettings:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ProfileSettingsScreen(userId: args),
          );
        } else if (args is Map<String, dynamic> && args.containsKey('userId')) {
          return MaterialPageRoute(
            builder: (_) => ProfileSettingsScreen(userId: args['userId'] as String),
          );
        }
        return _errorRoute();

      case RouteConstants.profileFriends:
        return MaterialPageRoute(builder: (_) => const FriendsScreen());

      case RouteConstants.profileFollowers:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => FollowersScreen(userId: args, initialTab: FollowersTab.followers),
          );
        } else if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => FollowersScreen(
              userId: args['userId'] as String?,
              initialTab: args['initialTab'] != null
                  ? _parseFollowersTab(args['initialTab'] as String)
                  : FollowersTab.followers,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const FollowersScreen(),
        );

      case RouteConstants.profileFollowing:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => FollowingScreen(userId: args, showAppBar: true),
          );
        } else if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => FollowingScreen(
              userId: args['userId'] as String?,
              showAppBar: args['showAppBar'] as bool? ?? true,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const FollowingScreen(),
        );

      case RouteConstants.profileBadges:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => BadgesScreen(userId: args),
          );
        } else if (args is Map<String, dynamic> && args.containsKey('userId')) {
          return MaterialPageRoute(
            builder: (_) => BadgesScreen(userId: args['userId'] as String),
          );
        }
        return _errorRoute();

      case RouteConstants.profileFrames:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => FramesScreen(userId: args),
          );
        } else if (args is Map<String, dynamic> && args.containsKey('userId')) {
          return MaterialPageRoute(
            builder: (_) => FramesScreen(userId: args['userId'] as String),
          );
        }
        return _errorRoute();

      case RouteConstants.profileAchievements:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => AchievementsScreen(userId: args),
          );
        } else if (args is Map<String, dynamic> && args.containsKey('userId')) {
          return MaterialPageRoute(
            builder: (_) => AchievementsScreen(userId: args['userId'] as String),
          );
        }
        return _errorRoute();

      case RouteConstants.profileStats:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ProfileStatsScreen(userId: args),
          );
        } else if (args is Map<String, dynamic> && args.containsKey('userId')) {
          return MaterialPageRoute(
            builder: (_) => ProfileStatsScreen(userId: args['userId'] as String),
          );
        }
        return _errorRoute();

      case RouteConstants.profileBlocked:
        return MaterialPageRoute(builder: (_) => const BlockedUsersScreen());

    // ==================== CHAT ROUTES ====================
      case RouteConstants.chatList:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());

      case RouteConstants.chatDetail:
        if (args is ChatModel) {
          return MaterialPageRoute(
            builder: (_) => ChatDetailScreen(chat: args),
          );
        } else if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => ChatDetailScreen(chat: ChatModel.fromJson(args)),
          );
        }
        return _errorRoute();

      case RouteConstants.chatGroup:
        return MaterialPageRoute(builder: (_) => const GroupChatScreen());

      case RouteConstants.chatInfo:
        if (args is ChatModel) {
          return MaterialPageRoute(
            builder: (_) => ChatInfoScreen(chat: args),
          );
        } else if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => ChatInfoScreen(chat: ChatModel.fromJson(args)),
          );
        }
        return _errorRoute();

      case RouteConstants.chatSearch:
        return MaterialPageRoute(builder: (_) => const ChatSearchScreen());

    // ==================== CALL ROUTES ====================
      case RouteConstants.callAudio:
        if (args is Map<String, dynamic> && args.containsKey('user')) {
          return MaterialPageRoute(
            builder: (_) => CallScreen(
              user: args['user'],
              isVideoCall: false,
            ),
          );
        }
        return _errorRoute();

      case RouteConstants.callVideo:
        if (args is Map<String, dynamic> && args.containsKey('user')) {
          return MaterialPageRoute(
            builder: (_) => CallScreen(
              user: args['user'],
              isVideoCall: true,
            ),
          );
        }
        return _errorRoute();

      case RouteConstants.callIncoming:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => IncomingCallScreen(
              callerId: args['callerId'] as String? ?? '',
              callerName: args['callerName'] as String? ?? '',
              callerAvatar: args['callerAvatar'] as String?,
              callType: args['callType'] as String? ?? 'audio',
              channelId: args['channelId'] as String? ?? '',
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
        if (args is Map<String, dynamic> && args.containsKey('betAmount')) {
          return MaterialPageRoute(
            builder: (_) => RouletteGame(betAmount: args['betAmount'] as int),
          );
        } else if (args is int) {
          return MaterialPageRoute(
            builder: (_) => RouletteGame(betAmount: args),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const RouletteGame(betAmount: 100),
        );

      case RouteConstants.gameThreePatti:
        if (args is Map<String, dynamic> && args.containsKey('gameId')) {
          return MaterialPageRoute(
            builder: (_) => ThreePattiGame(gameId: args['gameId'] as String?),
          );
        }
        return MaterialPageRoute(builder: (_) => const ThreePattiGame());

      case RouteConstants.gameLudo:
        if (args is Map<String, dynamic> && args.containsKey('gameId')) {
          return MaterialPageRoute(
            builder: (_) => LudoGame(gameId: args['gameId'] as String?),
          );
        }
        return MaterialPageRoute(builder: (_) => const LudoGame());

      case RouteConstants.gameCarrom:
        if (args is Map<String, dynamic> && args.containsKey('gameId')) {
          return MaterialPageRoute(
            builder: (_) => CarromGame(gameId: args['gameId'] as String),
          );
        }
        return MaterialPageRoute(
          builder: (_) => CarromGame(gameId: ''),
        );

      case RouteConstants.gameGreedyCat:
        if (args is Map<String, dynamic> && args.containsKey('gameId')) {
          return MaterialPageRoute(
            builder: (_) => GreedyCatGame(gameId: args['gameId'] as String?),
          );
        }
        return MaterialPageRoute(builder: (_) => const GreedyCatGame());

      case RouteConstants.gameWerewolf:
        if (args is Map<String, dynamic> && args.containsKey('gameId')) {
          return MaterialPageRoute(
            builder: (_) => WerewolfGame(gameId: args['gameId'] as String),
          );
        }
        return MaterialPageRoute(
          builder: (_) => WerewolfGame(gameId: ''),
        );

      case RouteConstants.gameTrivia:
        if (args is Map<String, dynamic> && args.containsKey('gameId')) {
          return MaterialPageRoute(
            builder: (_) => TriviaGame(gameId: args['gameId'] as String),
          );
        }
        return MaterialPageRoute(
          builder: (_) => TriviaGame(gameId: ''),
        );

      case RouteConstants.gamePictionary:
        if (args is Map<String, dynamic> && args.containsKey('gameId')) {
          return MaterialPageRoute(
            builder: (_) => PictionaryGame(gameId: args['gameId'] as String),
          );
        }
        return MaterialPageRoute(
          builder: (_) => PictionaryGame(gameId: ''),
        );

      case RouteConstants.gameChess:
        if (args is Map<String, dynamic> && args.containsKey('gameId')) {
          return MaterialPageRoute(
            builder: (_) => ChessGame(gameId: args['gameId'] as String),
          );
        }
        return MaterialPageRoute(
          builder: (_) => ChessGame(gameId: ''),
        );

      case RouteConstants.gameTruthOrDare:
        if (args is Map<String, dynamic> && args.containsKey('gameId')) {
          return MaterialPageRoute(
            builder: (_) => TruthOrDareGame(gameId: args['gameId'] as String),
          );
        }
        return MaterialPageRoute(
          builder: (_) => TruthOrDareGame(gameId: ''),
        );

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
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => PostDetailScreen(post: args),
          );
        }
        return _errorRoute();

      case RouteConstants.postEdit:
        if (args is Map<String, dynamic> && args.containsKey('postId')) {
          return MaterialPageRoute(
            builder: (_) => EditPostScreen(postId: args['postId'] as String),
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

      case RouteConstants.clanJoin:
        return MaterialPageRoute(builder: (_) => const ClanHomeScreen());

      case RouteConstants.clanDetail:
        if (args is ClanModel) {
          return MaterialPageRoute(
            builder: (_) => ClanDetailScreen(clan: args),
          );
        } else if (args is Map<String, dynamic> && args.containsKey('clanId')) {
          return MaterialPageRoute(
            builder: (_) => ClanDetailScreen(clan: ClanModel.fromJson(args)),
          );
        } else if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ClanDetailScreen(clan: ClanModel(
              id: args,
              name: '',
              leaderId: '',
              members: [],
              level: 1,
              xp: 0,
              xpToNextLevel: 1000,
              clanCoins: 0,
              memberCount: 0,
              maxMembers: 50,
              joinType: ClanJoinType.open,
              createdAt: DateTime.now(),
            )),
          );
        }
        return _errorRoute();

      case RouteConstants.clanMembers:
        if (args is ClanModel) {
          return MaterialPageRoute(
            builder: (_) => ClanMembersScreen(clan: args),
          );
        } else if (args is Map<String, dynamic> && args.containsKey('clanId')) {
          return MaterialPageRoute(
            builder: (_) => ClanMembersScreen(clan: ClanModel.fromJson(args)),
          );
        } else if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ClanMembersScreen(clan: ClanModel(
              id: args,
              name: '',
              leaderId: '',
              members: [],
              level: 1,
              xp: 0,
              xpToNextLevel: 1000,
              clanCoins: 0,
              memberCount: 0,
              maxMembers: 50,
              joinType: ClanJoinType.open,
              createdAt: DateTime.now(),
            )),
          );
        }
        return _errorRoute();

      case RouteConstants.clanChat:
        if (args is Map<String, dynamic> &&
            args.containsKey('clanId') &&
            args.containsKey('clanName')) {
          return MaterialPageRoute(
            builder: (_) => ClanChatScreen(
              clanId: args['clanId'] as String,
              clanName: args['clanName'] as String,
            ),
          );
        }
        return _errorRoute();

      case RouteConstants.clanTasks:
        if (args is Map<String, dynamic> && args.containsKey('clanId')) {
          return MaterialPageRoute(
            builder: (_) => ClanTasksScreen(clanId: args['clanId'] as String),
          );
        } else if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ClanTasksScreen(clanId: args),
          );
        }
        return _errorRoute();

      case RouteConstants.clanShop:
        if (args is Map<String, dynamic> && args.containsKey('clanId')) {
          return MaterialPageRoute(
            builder: (_) => ClanShopScreen(clanId: args['clanId'] as String),
          );
        } else if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ClanShopScreen(clanId: args),
          );
        }
        return _errorRoute();

      case RouteConstants.clanWars:
        if (args is Map<String, dynamic> && args.containsKey('clanId')) {
          return MaterialPageRoute(
            builder: (_) => ClanWarsScreen(clanId: args['clanId'] as String),
          );
        } else if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ClanWarsScreen(clanId: args),
          );
        }
        return _errorRoute();

      case RouteConstants.clanLeaderboard:
        return MaterialPageRoute(builder: (_) => const ClanLeaderboardScreen());

      case RouteConstants.clanRequests:
        if (args is Map<String, dynamic> && args.containsKey('clanId')) {
          return MaterialPageRoute(
            builder: (_) => ClanRequestsScreen(clanId: args['clanId'] as String),
          );
        } else if (args is String) {
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
        } else if (args is Map<String, dynamic> && args.containsKey('clanId')) {
          return MaterialPageRoute(
            builder: (_) => ClanSettingsScreen(clan: ClanModel.fromJson(args)),
          );
        }
        return _errorRoute();

    // ==================== PK ROUTES ====================
      case RouteConstants.pkBattle:
        if (args is Map<String, dynamic> &&
            args.containsKey('roomId') &&
            args.containsKey('opponentRoomId')) {
          return MaterialPageRoute(
            builder: (_) => PKBattleScreen(
              roomId: args['roomId'] as String,
              opponentRoomId: args['opponentRoomId'] as String,
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
        if (args is Map<String, dynamic> && args.containsKey('agencyId')) {
          return MaterialPageRoute(
            builder: (_) => MemberManagement(agencyId: args['agencyId'] as String),
          );
        } else if (args is String) {
          return MaterialPageRoute(
            builder: (_) => MemberManagement(agencyId: args),
          );
        }
        return _errorRoute();

      case RouteConstants.agencyEarnings:
        if (args is Map<String, dynamic> && args.containsKey('agencyId')) {
          return MaterialPageRoute(
            builder: (_) => AgencyEarningsScreen(agencyId: args['agencyId'] as String),
          );
        } else if (args is String) {
          return MaterialPageRoute(
            builder: (_) => AgencyEarningsScreen(agencyId: args),
          );
        }
        return _errorRoute();

    // ==================== SELLER ROUTES ====================
      case RouteConstants.seller:
        return MaterialPageRoute(builder: (_) => const SellerDashboardScreen());

      case RouteConstants.sellerDashboard:
        return MaterialPageRoute(builder: (_) => const SellerDashboardScreen());

      case RouteConstants.sellerPackages:
        if (args is Map<String, dynamic> && args.containsKey('sellerId')) {
          return MaterialPageRoute(
            builder: (_) => SellerPackagesScreen(sellerId: args['sellerId'] as String),
          );
        }
        return MaterialPageRoute(builder: (_) => const SellerPackagesScreen());

      case RouteConstants.sellerSales:
        if (args is Map<String, dynamic> && args.containsKey('sellerId')) {
          return MaterialPageRoute(
            builder: (_) => SellerSalesScreen(sellerId: args['sellerId'] as String),
          );
        }
        return MaterialPageRoute(builder: (_) => const SellerSalesScreen());

    // ==================== FEATURE ROUTES ====================
      case RouteConstants.events:
        return MaterialPageRoute(builder: (_) => const EventsScreen());

      case RouteConstants.referral:
        return MaterialPageRoute(builder: (_) => const ReferralScreen());

      case RouteConstants.luckyDraw:
        return MaterialPageRoute(builder: (_) => const LuckyDrawScreen());

      case RouteConstants.avatarBuilder:
        return MaterialPageRoute(builder: (_) => const AvatarBuilderScreen());

      case RouteConstants.moments:
        return MaterialPageRoute(builder: (_) => const MomentsScreen());

    // ==================== COUNTRY MANAGER ROUTES ====================
      case '/country-manager/dashboard':
        if (args is Map<String, dynamic> && args.containsKey('countryId')) {
          return MaterialPageRoute(
            builder: (_) => CountryManagerDashboard(
              countryId: args['countryId'] as String,
              managerId: args['managerId'] as String?,
            ),
          );
        } else if (args is String) {
          return MaterialPageRoute(
            builder: (_) => CountryManagerDashboard(countryId: args),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const CountryManagerDashboard(countryId: ''),
        );

      case '/country-manager/agencies':
        if (args is Map<String, dynamic> && args.containsKey('countryId')) {
          return MaterialPageRoute(
            builder: (_) => AgencyListScreen(
              countryId: args['countryId'] as String,
              filter: args['filter'] as String? ?? 'all',
            ),
          );
        } else if (args is String) {
          return MaterialPageRoute(
            builder: (_) => AgencyListScreen(countryId: args),
          );
        }
        return _errorRoute();

      case '/country-manager/agency-approval':
        if (args is Map<String, dynamic> && args.containsKey('agencyId')) {
          return MaterialPageRoute(
            builder: (_) => AgencyApprovalScreen(
              agencyId: args['agencyId'] as String,
              countryId: args['countryId'] as String?,
            ),
          );
        }
        return _errorRoute();

      case '/country-manager/recruitment':
        if (args is Map<String, dynamic> && args.containsKey('countryId')) {
          return MaterialPageRoute(
            builder: (_) => RecruitmentScreen(
              countryId: args['countryId'] as String,
              recruitmentType: args['recruitmentType'] as String? ?? 'agencies',
            ),
          );
        } else if (args is String) {
          return MaterialPageRoute(
            builder: (_) => RecruitmentScreen(countryId: args),
          );
        }
        return _errorRoute();

      case '/country-manager/statistics':
        if (args is Map<String, dynamic> && args.containsKey('countryId')) {
          return MaterialPageRoute(
            builder: (_) => CountryStatisticsScreen(
              countryId: args['countryId'] as String,
              period: args['period'] as String? ?? 'month',
            ),
          );
        } else if (args is String) {
          return MaterialPageRoute(
            builder: (_) => CountryStatisticsScreen(countryId: args),
          );
        }
        return _errorRoute();

    // ==================== WEBVIEW ROUTES ====================
      case RouteConstants.webView:
        if (args is Map<String, dynamic> && args.containsKey('url')) {
          return MaterialPageRoute(
            builder: (_) => WebViewScreen(
              title: args['title'] as String? ?? 'WebView',
              url: args['url'] as String,
              showAppBar: args['showAppBar'] as bool? ?? true,
            ),
          );
        }
        return _errorRoute();

      case RouteConstants.privacyPolicy:
        return MaterialPageRoute(
          builder: (_) => const WebViewScreen(
            title: 'Privacy Policy',
            url: 'https://lotchat.com/privacy',
          ),
        );

      case RouteConstants.termsOfService:
        return MaterialPageRoute(
          builder: (_) => const WebViewScreen(
            title: 'Terms of Service',
            url: 'https://lotchat.com/terms',
          ),
        );

      case RouteConstants.helpCenter:
        return MaterialPageRoute(
          builder: (_) => const WebViewScreen(
            title: 'Help Center',
            url: 'https://help.lotchat.com',
          ),
        );

    // ==================== ERROR ROUTES ====================
      case RouteConstants.notFound:
        return MaterialPageRoute(builder: (_) => const NotFoundScreen());

      case RouteConstants.maintenance:
        return MaterialPageRoute(builder: (_) => const MaintenanceScreen());

      case RouteConstants.noInternet:
        return MaterialPageRoute(builder: (_) => const NoInternetScreen());

      default:
        return _errorRoute();
    }
  }

  static FollowersTab _parseFollowersTab(String tab) {
    switch (tab.toLowerCase()) {
      case 'following':
        return FollowersTab.following;
      case 'followers':
      default:
        return FollowersTab.followers;
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => const NotFoundScreen(),
      settings: const RouteSettings(name: RouteConstants.notFound),
    );
  }

  static Route<dynamic> unknownRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(child: Text('Unknown route')),
      ),
    );
  }
}

// ==================== SEARCH RESULT SCREEN ====================
class SearchResultScreen extends StatelessWidget {
  final String query;
  const SearchResultScreen({required this.query, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search: $query')),
      body: Center(child: Text('Searching for: $query')),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('query', query));
  }
}

// ==================== OTP VERIFICATION SCREEN ====================
class OtpVerificationScreen extends StatelessWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpVerificationScreen({
    required this.verificationId,
    required this.phoneNumber,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Center(child: Text('Verifying OTP for $phoneNumber')),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('verificationId', verificationId));
    properties.add(StringProperty('phoneNumber', phoneNumber));
  }
}

// ==================== ROOM SEARCH SCREEN ====================
class RoomSearchScreen extends StatelessWidget {
  const RoomSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Room Search Screen')),
    );
  }
}

// ==================== ROOM HISTORY SCREEN ====================
class RoomHistoryScreen extends StatelessWidget {
  const RoomHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Room History Screen')),
    );
  }
}

// ==================== CALL HISTORY SCREEN ====================
class CallHistoryScreen extends StatelessWidget {
  const CallHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Call History Screen')),
    );
  }
}

// ==================== EDIT POST SCREEN ====================
class EditPostScreen extends StatelessWidget {
  final String postId;
  const EditPostScreen({required this.postId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Post')),
      body: Center(child: Text('Editing Post: $postId')),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('postId', postId));
  }
}

// ==================== FRIEND SUGGESTIONS SCREEN ====================
class FriendSuggestionsScreen extends StatelessWidget {
  const FriendSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Friend Suggestions Screen')),
    );
  }
}

// ==================== GIFT LEADERBOARD SCREEN ====================
class GiftLeaderboardScreen extends StatelessWidget {
  const GiftLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Gift Leaderboard Screen')),
    );
  }
}

// ==================== GAME LEADERBOARD SCREEN ====================
class GameLeaderboardScreen extends StatelessWidget {
  const GameLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Game Leaderboard Screen')),
    );
  }
}

// ==================== CREATE PK SCREEN ====================
class CreatePKScreen extends StatelessWidget {
  const CreatePKScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Create PK Battle Screen')),
    );
  }
}

// ==================== ADMIN DASHBOARD SCREEN ====================
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Admin Dashboard Screen')),
    );
  }
}

// ==================== REPORT MANAGEMENT SCREEN ====================
class ReportManagement extends StatelessWidget {
  const ReportManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Report Management Screen')),
    );
  }
}

// ==================== AGENCY EARNINGS SCREEN ====================
class AgencyEarningsScreen extends StatelessWidget {
  final String agencyId;
  const AgencyEarningsScreen({required this.agencyId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agency Earnings')),
      body: Center(child: Text('Agency Earnings: $agencyId')),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('agencyId', agencyId));
  }
}

// ==================== SELLER DASHBOARD SCREEN ====================
class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Seller Dashboard Screen')),
    );
  }
}

// ==================== SELLER PACKAGES SCREEN ====================
class SellerPackagesScreen extends StatelessWidget {
  final String? sellerId;
  const SellerPackagesScreen({this.sellerId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seller Packages')),
      body: Center(
        child: Text('Seller Packages${sellerId != null ? ' for $sellerId' : ''}'),
      ),
    );
  }
}

// ==================== SELLER SALES SCREEN ====================
class SellerSalesScreen extends StatelessWidget {
  final String? sellerId;
  const SellerSalesScreen({this.sellerId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seller Sales')),
      body: Center(
        child: Text('Seller Sales${sellerId != null ? ' for $sellerId' : ''}'),
      ),
    );
  }
}

// ==================== MAINTENANCE SCREEN ====================
class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
              onPressed: () => NavigationService.goBack(),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== NO INTERNET SCREEN ====================
class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
              onPressed: () => NavigationService.goBack(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}