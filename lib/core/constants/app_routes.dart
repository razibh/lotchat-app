import 'package:flutter/material.dart';
class AppRoutes {
  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';

  // Main Routes
  static const String home = '/home';
  static const String dashboard = '/dashboard';

  // Profile Routes
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String profileSettings = '/profile/settings';
  static const String profileStats = '/profile/stats';

  // Social Routes
  static const String friends = '/friends';
  static const String followers = '/followers';
  static const String following = '/following';
  static const String chat = '/chat';
  static const String chatDetail = '/chat/detail';

  // Room Routes
  static const String rooms = '/rooms';
  static const String createRoom = '/room/create';
  static const String room = '/room';
  static const String roomDetail = '/room/detail';

  // Game Routes
  static const String games = '/games';
  static const String game = '/game';
  static const String gameDetail = '/game/detail';

  // Wallet Routes
  static const String wallet = '/wallet';
  static const String recharge = '/recharge';
  static const String withdraw = '/withdraw';
  static const String transactions = '/transactions';

  // Search Routes
  static const String search = '/search';
  static const String searchResult = '/search/result';

  // Notification Routes
  static const String notifications = '/notifications';

  // Settings Routes
  static const String settings = '/settings';
  static const String privacy = '/settings/privacy';
  static const String security = '/settings/security';
  static const String language = '/settings/language';
  static const String theme = '/settings/theme';

  // Support Routes
  static const String help = '/help';
  static const String faq = '/faq';
  static const String contact = '/contact';
  static const String feedback = '/feedback';

  // Admin Routes
  static const String admin = '/admin';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminRooms = '/admin/rooms';
  static const String adminReports = '/admin/reports';

  // WebView Routes
  static const String webView = '/webview';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsOfService = '/terms-of-service';

  // Error Routes
  static const String notFound = '/404';
  static const String maintenance = '/maintenance';

  // Get route name
  static String getRouteName(String route) {
    switch (route) {
      case splash:
        return 'Splash';
      case login:
        return 'Login';
      case register:
        return 'Register';
      case home:
        return 'Home';
      case profile:
        return 'Profile';
      case settings:
        return 'Settings';
      case friends:
        return 'Friends';
      case chat:
        return 'Chat';
      case rooms:
        return 'Rooms';
      case games:
        return 'Games';
      case wallet:
        return 'Wallet';
      case notifications:
        return 'Notifications';
      case search:
        return 'Search';
      default:
        return 'Unknown';
    }
  }

  // Check if route requires authentication
  static bool requiresAuth(String route) {
    final publicRoutes = [
      splash,
      login,
      register,
      forgotPassword,
      otpVerification,
      privacyPolicy,
      termsOfService,
      maintenance,
    ];
    return !publicRoutes.contains(route);
  }

  // Get routes for navigation drawer
  static List<NavigationItem> get drawerRoutes => [
    NavigationItem(icon: Icons.home, label: 'Home', route: home),
    NavigationItem(icon: Icons.person, label: 'Profile', route: profile),
    NavigationItem(icon: Icons.people, label: 'Friends', route: friends),
    NavigationItem(icon: Icons.chat, label: 'Chat', route: chat),
    NavigationItem(icon: Icons.meeting_room, label: 'Rooms', route: rooms),
    NavigationItem(icon: Icons.sports_esports, label: 'Games', route: games),
    NavigationItem(icon: Icons.wallet, label: 'Wallet', route: wallet),
    NavigationItem(icon: Icons.settings, label: 'Settings', route: settings),
    NavigationItem(icon: Icons.help, label: 'Help', route: help),
  ];
}

class NavigationItem {
  final IconData icon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}