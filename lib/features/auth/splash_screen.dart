import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/country_provider.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/services/navigation_service.dart';
import '../../core/services/socket_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize all providers
      await Future.wait(<Future<void>>[
        _initializeAuth(),
        _initializeCountry(),
        _initializeNotifications(),
        _initializeTheme(),
        _initializeLocale(),
        _initializeSocket(),
      ]);

      // Small delay for smooth animation
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        _navigateToNext();
      }
    } catch (e) {
      debugPrint('Error initializing app: $e');
      if (mounted) {
        _showErrorDialog();
      }
    }
  }

  Future<void> _initializeAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();
  }

  Future<void> _initializeCountry() async {
    final countryProvider = Provider.of<CountryProvider>(context, listen: false);
    await countryProvider.loadSupportedCountries();
    await countryProvider.loadSavedCountry();
  }

  Future<void> _initializeNotifications() async {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    await notificationProvider.initialize();
  }

  Future<void> _initializeTheme() async {
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    await themeProvider.loadTheme();
  }

  Future<void> _initializeLocale() async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    await localeProvider.loadLocale();
  }

  Future<void> _initializeSocket() async {
    try {
      await SocketService().initSocket();
    } catch (e) {
      debugPrint('Socket initialization failed: $e');
      // Don't crash the app if socket fails
    }
  }

  void _navigateToNext() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final countryProvider = Provider.of<CountryProvider>(context, listen: false);

    if (authProvider.isLoggedIn) {
      if (countryProvider.selectedCountry == null) {
        NavigationService.navigateToReplacement('/country-select');
      } else {
        NavigationService.navigateToReplacement(authProvider.getHomeRoute());
      }
    } else {
      NavigationService.navigateToReplacement('/login');
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text(
          'Initialization Error',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Failed to initialize the app. Please check your internet connection and try again.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: <>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeApp(); // Retry initialization
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <>[
              AppColors.accentPurple,
              AppColors.accentBlue,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: <>[
              // Animated Background Elements
              _buildAnimatedBackground(),
              
              // Main Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <>[
                    // Logo with Animation
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildLogo(),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // App Name with Animation
                    SlideTransition(
                      position: _slideAnimation,
                      child: _buildAppName(),
                    ),
                    
                    const SizedBox(height: 50),
                    
                    // Loading Indicator
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildLoadingIndicator(),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Version Info
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildVersionInfo(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: <>[
        // Animated circles
        ...List.generate(5, (int index) {
          return Positioned(
            top: (index * 100.0) % MediaQuery.of(context).size.height,
            left: (index * 80.0) % MediaQuery.of(context).size.width,
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(seconds: 3 + index),
              curve: Curves.easeInOut,
              builder: (BuildContext context, value, Widget? child) {
                return Opacity(
                  opacity: 0.1 + (value * 0.1),
                  child: Transform.translate(
                    offset: Offset(
                      value * 20,
                      value * 20,
                    ),
                    child: Container(
                      width: 100 + (index * 50),
                      height: 100 + (index * 50),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <>[
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: <>[
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(
        Icons.sports_esports,
        size: 70,
        color: Colors.white,
      ),
    );
  }

  Widget _buildAppName() {
    return Column(
      children: <>[
        const Text(
          AppConstants.appName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            shadows: <>[
              Shadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Play Games • Live Stream • Earn Coins',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: <>[
        const SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 16),
        TweenAnimationBuilder(
          tween: IntTween(begin: 0, end: 100),
          duration: const Duration(milliseconds: 1500),
          builder: (BuildContext context, value, Widget? child) {
            return Text(
              '$value%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVersionInfo() {
    return Column(
      children: <>[
        Text(
          'Version ${AppConstants.version}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '© 2024 ${AppConstants.appName}. All rights reserved.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// Additional helper widget for loading states
class AnimatedSplashLogo extends StatefulWidget {

  const AnimatedSplashLogo({
    super.key,
    this.duration = const Duration(seconds: 2),
    this.onComplete,
  });
  final Duration duration;
  final VoidCallback? onComplete;

  @override
  State<AnimatedSplashLogo> createState() => _AnimatedSplashLogoState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Duration>('duration', duration));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onComplete', onComplete));
  }
}

class _AnimatedSplashLogoState extends State<AnimatedSplashLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed && widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scale: _animation.value,
          child: Opacity(
            opacity: _animation.value,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <>[
                    AppColors.accentPurple,
                    AppColors.accentBlue,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: <>[
                  BoxShadow(
                    color: AppColors.accentPurple.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.sports_esports,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Splash screen with branded background image
class BrandedSplashScreen extends StatelessWidget {

  const BrandedSplashScreen({
    required this.backgroundImage, super.key,
    this.logo,
    this.title,
    this.onLoadComplete,
  });
  final String backgroundImage;
  final Widget? logo;
  final String? title;
  final VoidCallback? onLoadComplete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <>[
          // Background Image
          Image.asset(
            backgroundImage,
            fit: BoxFit.cover,
          ),
          
          // Overlay
          Container(
            color: Colors.black.withValues(alpha: 0.5),
          ),
          
          // Content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <>[
                  if (logo != null) logo!,
                  if (title != null) ...<>[
                    const SizedBox(height: 20),
                    Text(
                      title!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 50),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('backgroundImage', backgroundImage));
    properties.add(StringProperty('title', title));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onLoadComplete', onLoadComplete));
  }
}

// Preloader widget for showing progress
class SplashPreloader extends StatelessWidget {

  const SplashPreloader({
    required this.progress, super.key,
    this.message,
  });
  final double progress;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <>[
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 12),
        if (message != null)
          Text(
            message!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toInt()}%',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('progress', progress));
    properties.add(StringProperty('message', message));
  }
}