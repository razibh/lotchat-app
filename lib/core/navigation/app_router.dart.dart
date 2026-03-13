import 'package:flutter/material.dart';
import 'route_constants.dart';
import 'navigation_service.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/room/room_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/not_found_screen.dart';

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
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      
      // Main Routes
      case RouteConstants.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      // Room Routes
      case RouteConstants.room:
        final Map<String, dynamic>? args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args.containsKey('roomId')) {
          return MaterialPageRoute(
            builder: (_) => RoomScreen(roomId: args['roomId']),
          );
        }
        return _errorRoute();
      
      // Profile Routes
      case RouteConstants.profile:
        final Map<String, dynamic>? args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args.containsKey('userId')) {
          return MaterialPageRoute(
            builder: (_) => ProfileScreen(userId: args['userId']),
          );
        }
        return MaterialPageRoute(builder: (_) => const ProfileScreen(userId: null));
      
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