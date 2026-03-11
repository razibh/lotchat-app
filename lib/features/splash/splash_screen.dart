import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/config_service.dart';
import '../../core/constants/asset_constants.dart';
import '../../mixins/loading_mixin.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with LoadingMixin {
  final _authService = ServiceLocator().get<AuthService>();
  final _configService = ServiceLocator().get<ConfigService>();

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
    
    // Check if user is logged in
    final isLoggedIn = _authService.isLoggedIn();
    
    if (isLoggedIn) {
      // Auto login
      final user = await _authService.getCurrentUser();
      if (user != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void _showMaintenanceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Under Maintenance'),
        content: Text(_configService.maintenanceMessage),
        actions: [
          TextButton(
            onPressed: () => exit(0),
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