import 'package:flutter/material.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;  // ✅ Supabase User hide
import '../../core/constants/asset_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/config_service.dart';
import '../../mixins/loading_mixin.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../../core/models/user_models.dart' as app;  // ✅ আপনার নিজের User model

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with LoadingMixin {
  final AuthService _authService = ServiceLocator.instance.get<AuthService>();
  final ConfigService _configService = ServiceLocator.instance.get<ConfigService>();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2)); // Show splash for 2 seconds

    // Check if app is in maintenance mode
    if (_configService.isInMaintenanceMode) {
      _showMaintenanceDialog();
      return;
    }

    // ✅ Check if user is logged in using Supabase session
    final session = Supabase.instance.client.auth.currentSession;
    final bool isLoggedIn = session != null;

    if (isLoggedIn) {
      // User is logged in, go to home
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      // User is not logged in, go to login
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void _showMaintenanceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Under Maintenance'),
        content: Text(_configService.maintenanceMessage),
        actions: [
          TextButton(
            onPressed: () {
              if (Platform.isAndroid || Platform.isIOS) {
                // For mobile, just close the app
                exit(0);
              } else {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple, Colors.pink],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                AssetConstants.logo,
                width: 150,
                height: 150,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chat,
                      size: 80,
                      color: Colors.purple,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // App Name
              const Text(
                'LotChat',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              // Loading Indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}