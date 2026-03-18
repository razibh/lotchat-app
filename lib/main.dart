import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


// ==================== CORE ====================
import 'core/constants/route_constants.dart';
import 'core/navigation/route_generator.dart';
import 'core/di/service_locator.dart';
import 'core/services/notification_service.dart';
import 'core/constants/app_theme.dart';
import 'core/services/logger_service.dart';
import 'core/services/config_service.dart';
import 'core/services/analytics_service.dart'; // Analytics Service

// ==================== PROVIDERS ====================
import 'features/auth/providers/auth_provider.dart';
import 'profile/providers/profile_provider.dart';
import 'chat/providers/chat_provider.dart';
import 'core/providers/room_provider.dart';
import 'core/providers/game_provider.dart';
import 'core/providers/theme_provider.dart';
import 'features/clan/clan_provider.dart';
import 'core/providers/language_provider.dart';
import 'core/navigation/navigation_service.dart';

enum Flavor { dev, prod }

class AppConfig {
  static late Flavor flavor;
  static late String appName;
  static late String apiBaseUrl;
  static late bool isProduction;

  static void initialize(Flavor f) {
    flavor = f;
    isProduction = f == Flavor.prod;

    switch (f) {
      case Flavor.dev:
        appName = 'LotChat (Dev)';
        apiBaseUrl = 'https://dev-api.lotchat.com';
        break;
      case Flavor.prod:
        appName = 'LotChat';
        apiBaseUrl = 'https://api.lotchat.com';
        break;
    }
  }

  static String get baseUrl => apiBaseUrl;
}

// ==================== PUSH NOTIFICATION HANDLER ====================
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Flavor/Environment setup (default: dev)
    const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    AppConfig.initialize(flavor == 'prod' ? Flavor.prod : Flavor.dev);

    debugPrint('🚀 Starting ${AppConfig.appName}');
    debugPrint('🌐 API Base URL: ${AppConfig.baseUrl}');

    // Initialize Firebase
    await Firebase.initializeApp(
      options: AppConfig.isProduction
          ? const FirebaseOptions(
        apiKey: 'YOUR_PROD_API_KEY',
        appId: 'YOUR_PROD_APP_ID',
        messagingSenderId: 'YOUR_PROD_SENDER_ID',
        projectId: 'YOUR_PROD_PROJECT_ID',
      )
          : const FirebaseOptions(
        apiKey: 'YOUR_DEV_API_KEY',
        appId: 'YOUR_DEV_APP_ID',
        messagingSenderId: 'YOUR_DEV_SENDER_ID',
        projectId: 'YOUR_DEV_PROJECT_ID',
      ),
    );

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize Service Locator
    await ServiceLocator.instance.init();

    // Initialize Notification Service
    final notificationService = NotificationService();
    await notificationService.initialize();

    // Initialize Analytics Service
    final analyticsService = AnalyticsService();
    await analyticsService.initialize();

    // Lock orientation to portrait
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    runApp(const MyApp());
  } catch (e, stackTrace) {
    debugPrint('❌ Failed to initialize app: $e');
    debugPrint('📚 Stack trace: $stackTrace');
    runApp(const ErrorApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final LoggerService _logger;
  late final ConfigService _configService;
  late final NotificationService _notificationService;
  late final AnalyticsService _analyticsService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      _logger = ServiceLocator.instance.get<LoggerService>();
      _configService = ServiceLocator.instance.get<ConfigService>();
      _notificationService = NotificationService();
      _analyticsService = AnalyticsService();

      // Track app open
      _analyticsService.trackScreen(
        'App',
        screenClass: 'MyApp',
        parameters: {
          'flavor': AppConfig.flavor.toString(),
          'is_production': AppConfig.isProduction.toString(),
        },
      );

      _logger.info('✅ App initialized successfully with flavor: ${AppConfig.flavor}');
    } catch (e) {
      debugPrint('❌ Error initializing services in MyApp: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => RoomProvider()),
        ChangeNotifierProvider(create: (_) => ClanProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: AppConfig.isProduction ? false : true,

            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            locale: languageProvider.locale,
            supportedLocales: const [
              Locale('en', ''),
              Locale('bn', ''),
            ],

            initialRoute: RouteConstants.splash,
            onGenerateRoute: (settings) => RouteGenerator.generateRoute(settings),
            onUnknownRoute: (settings) => RouteGenerator.unknownRoute(),

            navigatorKey: NavigationService.navigatorKey,

            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Error App Widget
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LotChat - Error',
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to Initialize App',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please check your internet connection and restart the app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Exit App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}