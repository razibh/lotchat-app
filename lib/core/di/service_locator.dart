// lib/core/di/service_locator.dart
import 'package:get_it/get_it.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/socket_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../services/game_service.dart';
import '../services/call_service.dart';
import '../services/payment_service.dart';
import '../services/moderation_service.dart';
import '../services/admin_service.dart';
import '../services/agency_service.dart';
import '../services/seller_service.dart';
import '../services/translation_service.dart';
import '../services/recommendation_service.dart';
import '../services/cache_service.dart';
import '../services/logger_service.dart';
import '../services/error_service.dart';
import '../services/config_service.dart';
import '../services/room_service.dart';
import '../services/gift_service.dart';
import '../services/leaderboard_service.dart';
import '../services/search_service.dart';
import '../services/friend_service.dart';
import '../services/clan_service.dart';
import '../services/pk_service.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  static const bool _isProduction = bool.fromEnvironment('PRODUCTION', defaultValue: false);

  Future<void> init() async {
    // Register all services
    await _registerCoreServices();
    _registerApiServices();
    _registerBusinessServices();
    _registerUtilityServices();
    _registerFeatureServices();
    
    // Initialize async services
    await _initializeServices();
  }

  // Core Services (Singleton)
  Future<void> _registerCoreServices() async {
    // Storage first because others depend on it
    final storageService = await StorageService().init();
    getIt.registerSingleton<StorageService>(storageService);
    
    // Logger
    final loggerService = LoggerService();
    await loggerService.initialize();
    getIt.registerSingleton<LoggerService>(loggerService);
    
    // Config
    final configService = ConfigService();
    await configService.initialize();
    getIt.registerSingleton<ConfigService>(configService);
    
    // Error
    getIt.registerSingleton<ErrorService>(ErrorService());
    
    // Cache
    final cacheService = CacheService();
    await cacheService.init();
    getIt.registerSingleton<CacheService>(cacheService);
  }

  // API Services
  void _registerApiServices() {
    // API Service (Lazy)
    getIt.registerLazySingleton<ApiService>(() => ApiService());
    
    // Socket Service
    getIt.registerSingletonAsync<SocketService>(() async {
      final socket = SocketService();
      await socket.initSocket();
      return socket;
    });
    
    // Auth Service
    getIt.registerSingleton<AuthService>(AuthService());
    
    // Database Service
    getIt.registerSingleton<DatabaseService>(DatabaseService());
  }

  // Business Services
  void _registerBusinessServices() {
    getIt.registerFactory<GameService>(() => GameService());
    getIt.registerFactory<CallService>(() => CallService());
    getIt.registerFactory<PaymentService>(() => PaymentService());
    getIt.registerFactory<ModerationService>(() => ModerationService());
    getIt.registerFactory<TranslationService>(() => TranslationService());
    getIt.registerFactory<RecommendationService>(() => RecommendationService());
  }

  // Utility Services
  void _registerUtilityServices() {
    getIt.registerFactory<NotificationService>(() => NotificationService());
    getIt.registerFactory<RoomService>(() => RoomService());
    getIt.registerFactory<GiftService>(() => GiftService());
    getIt.registerFactory<LeaderboardService>(() => LeaderboardService());
    getIt.registerFactory<SearchService>(() => SearchService());
  }

  // Feature Services
  void _registerFeatureServices() {
    getIt.registerFactory<AdminService>(() => AdminService());
    getIt.registerFactory<AgencyService>(() => AgencyService());
    getIt.registerFactory<SellerService>(() => SellerService());
    getIt.registerFactory<FriendService>(() => FriendService());
    getIt.registerFactory<ClanService>(() => ClanService());
    getIt.registerFactory<PkService>(() => PkService());
  }

  // Initialize async services
  Future<void> _initializeServices() async {
    try {
      // Initialize GetIt async services
      await getIt.allReady();
      
      // Initialize services that need post-setup
      await getIt<ApiService>().init();
      await getIt<TranslationService>().initialize();
      await getIt<NotificationService>().initialize();
      
      // Log success
      getIt<LoggerService>().info('All services initialized successfully');
    } catch (e, s) {
      getIt<LoggerService>().error('Failed to initialize services', error: e, stackTrace: s);
      rethrow;
    }
  }

  // Generic get method
  T get<T extends Object>() {
    try {
      return getIt<T>();
    } catch (e) {
      throw Exception('Service ${T.toString()} not found: $e');
    }
  }

  // Check if service exists
  bool isRegistered<T extends Object>() {
    return getIt.isRegistered<T>();
  }

  // Reset all services (for testing)
  @visibleForTesting
  void reset() {
    getIt.reset();
  }

  // Dispose services
  Future<void> dispose() async {
    await getIt<SocketService>().disconnect();
    await getIt<CallService>().dispose();
    await getIt<TranslationService>().dispose();
    await getIt<StorageService>().clearAllData();
    await getIt<CacheService>().clearAll();
  }
}

// Extension for easy access
extension ServiceLocatorExtension on BuildContext {
  T getService<T>() => ServiceLocator().get<T>();
}