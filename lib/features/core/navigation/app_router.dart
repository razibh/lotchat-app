import 'package:flutter/material.dart';
import 'route_constants.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/room/room_screen.dart';
import '../../features/profile/profile_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case RouteConstants.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case RouteConstants.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case RouteConstants.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case RouteConstants.room:
        final Map<String, dynamic> args = settings.arguments! as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => RoomScreen(roomId: args['roomId']),
        );
      
      case RouteConstants.profile:
        final Map<String, dynamic> args = settings.arguments! as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(userId: args['userId']),
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}