import 'package:flutter/material.dart';
import 'route_constants.dart';
import 'navigation_service.dart';

// Screen Imports
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/forgot_password_screen.dart' as forgot;
import '../../features/home/home_screen.dart';
import '../../features/room/room_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/not_found_screen.dart';

// Model Imports
import '../../core/models/room_model.dart'; // 🟢 RoomModel import

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
    // Auth Routes
      case RouteConstants.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case RouteConstants.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case RouteConstants.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case RouteConstants.forgotPassword:
        return MaterialPageRoute(builder: (_) => const forgot.ForgotPasswordScreen());

    // Main Routes
      case RouteConstants.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

    // Room Routes
      case RouteConstants.room:
        final args = settings.arguments;

        // Check if args is RoomModel
        if (args is RoomModel) {
          return MaterialPageRoute(
            builder: (_) => RoomScreen(room: args),
          );
        }

        // Check if args is Map with roomId
        if (args is Map<String, dynamic> && args.containsKey('roomId')) {
          // Create a basic RoomModel
          final room = RoomModel(
            id: args['roomId'] as String,
            name: 'Room ${args['roomId']}',
            hostId: 'host_id',
            hostName: 'Host',
            category: 'chat',
            createdAt: DateTime.now(),
            seats: [],
          );
          return MaterialPageRoute(
            builder: (_) => RoomScreen(room: room),
          );
        }

        // Default empty room
        return MaterialPageRoute(
          builder: (_) => RoomScreen(
            room: RoomModel(
              id: '',
              name: 'Unknown Room',
              hostId: '',
              hostName: '',
              category: 'chat',
              createdAt: DateTime.now(),
              seats: [],
            ),
          ),
        );

    // Profile Routes
      case RouteConstants.profile:
        final args = settings.arguments;
        if (args is Map<String, dynamic> && args.containsKey('userId')) {
          return MaterialPageRoute(
            builder: (_) => ProfileScreen(userId: args['userId'] as String),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(userId: ''),
        );

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => const NotFoundScreen(),
    );
  }
}