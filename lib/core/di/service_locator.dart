import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
import '../../features/clan/services/clan_service.dart';
import '../services/pk_service.dart';

final GetIt getIt = GetIt.instance;

class ServiceLocator {
  // Singleton pattern
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();
  static final ServiceLocator _instance = ServiceLocator._internal();

  // Static getter for instance
  static ServiceLocator get instance => _instance;

  static const bool _isProduction = bool.fromEnvironment('PRODUCTION');

  // Initialize all services
  Future<void> init() async {
    try {
      debugPrint('🚀 Initializing ServiceLocator...');

      // Register Supabase client first
      _registerSupabase();

      // Register all services
      await _registerCoreServices();
      _registerApiServices();
      _registerBusinessServices();
      _registerUtilityServices();
      _registerFeatureServices();

      // Initialize async services
      await _initializeServices();

      debugPrint('✅ ServiceLocator initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ ServiceLocator initialization failed: $e');
      debugPrint('📚 StackTrace: $stackTrace');
    }
  }

  // Register Supabase client
  void _registerSupabase() {
    debugPrint('📝 Registering Supabase Client...');

    try {
      final supabase = Supabase.instance.client;
      getIt.registerSingleton<SupabaseClient>(supabase);
      debugPrint('   ✅ SupabaseClient registered');
    } catch (e) {
      debugPrint('❌ Error registering Supabase client: $e');
    }
  }

  // Core Services - Async registration
  Future<void> _registerCoreServices() async {
    debugPrint('📝 Registering Core Services...');

    try {
      // Storage Service
      final StorageService storageService = StorageService();
      await storageService.init();
      getIt.registerSingleton<StorageService>(storageService);
      debugPrint('   ✅ StorageService registered');

      // Logger Service
      final LoggerService loggerService = LoggerService();
      await loggerService.initialize();
      getIt.registerSingleton<LoggerService>(loggerService);
      debugPrint('   ✅ LoggerService registered');

      // Config Service
      final ConfigService configService = ConfigService();
      await configService.initialize();
      getIt.registerSingleton<ConfigService>(configService);
      debugPrint('   ✅ ConfigService registered');

      // Error Service
      getIt.registerSingleton<ErrorService>(ErrorService());
      debugPrint('   ✅ ErrorService registered');

      // Cache Service
      final CacheService cacheService = CacheService();
      await cacheService.init();
      getIt.registerSingleton<CacheService>(cacheService);
      debugPrint('   ✅ CacheService registered');

    } catch (e) {
      debugPrint('❌ Error registering core services: $e');
    }
  }

  // API Services - Synchronous registration
  void _registerApiServices() {
    debugPrint('📝 Registering API Services...');

    try {
      // API Service (Lazy) - Supabase
      getIt.registerLazySingleton<ApiService>(ApiService.new);
      debugPrint('   ✅ ApiService registered');

      // Socket Service (Async)
      getIt.registerSingletonAsync<SocketService>(() async {
        final SocketService socket = SocketService();
        await socket.initSocket();
        return socket;
      });
      debugPrint('   ✅ SocketService registered');

      // Auth Service -  Supabase
      getIt.registerSingleton<AuthService>(AuthService());
      debugPrint('   ✅ AuthService registered');

      // Database Service Supabase-
      getIt.registerSingleton<DatabaseService>(DatabaseService());
      debugPrint('   ✅ DatabaseService registered');

    } catch (e) {
      debugPrint('❌ Error registering API services: $e');
    }
  }

  // Business Services - Synchronous registration
  void _registerBusinessServices() {
    debugPrint('📝 Registering Business Services...');

    try {
      getIt.registerFactory<GameService>(GameService.new);
      getIt.registerFactory<CallService>(CallService.new);
      getIt.registerFactory<PaymentService>(PaymentService.new);
      getIt.registerFactory<ModerationService>(ModerationService.new);
      getIt.registerFactory<TranslationService>(TranslationService.new);
      getIt.registerFactory<RecommendationService>(RecommendationService.new);

      debugPrint('   ✅ Business Services registered');
    } catch (e) {
      debugPrint('❌ Error registering business services: $e');
    }
  }

  // Utility Services - Synchronous registration
  void _registerUtilityServices() {
    debugPrint('📝 Registering Utility Services...');

    try {
      getIt.registerFactory<NotificationService>(NotificationService.new);
      getIt.registerFactory<RoomService>(RoomService.new);
      getIt.registerFactory<GiftService>(GiftService.new);
      getIt.registerFactory<LeaderboardService>(LeaderboardService.new);
      getIt.registerFactory<SearchService>(SearchService.new);

      debugPrint('   ✅ Utility Services registered');
    } catch (e) {
      debugPrint('❌ Error registering utility services: $e');
    }
  }

  // Feature Services - Synchronous registration
  void _registerFeatureServices() {
    debugPrint('📝 Registering Feature Services...');

    try {
      getIt.registerFactory<AdminService>(AdminService.new);
      getIt.registerFactory<AgencyService>(AgencyService.new);
      getIt.registerFactory<SellerService>(SellerService.new);
      getIt.registerFactory<FriendService>(FriendService.new);
      getIt.registerFactory<ClanService>(ClanService.new);

      if (!getIt.isRegistered<PKService>()) {
        getIt.registerFactory<PKService>(PKService.new);
        debugPrint('   ✅ PKService registered');
      }

      debugPrint('   ✅ Feature Services registered');
    } catch (e) {
      debugPrint('❌ Error registering feature services: $e');
    }
  }

  // Initialize async services
  Future<void> _initializeServices() async {
    debugPrint('📝 Initializing async services...');

    try {
      // Wait for all async services to be ready
      await getIt.allReady();
      debugPrint('   ✅ All async services ready');

      // Initialize services that need post-setup
      if (getIt.isRegistered<ApiService>()) {
        await getIt<ApiService>().init();
        debugPrint('   ✅ ApiService initialized');
      }

      if (getIt.isRegistered<TranslationService>()) {
        await getIt<TranslationService>().initialize();
        debugPrint('   ✅ TranslationService initialized');
      }

      if (getIt.isRegistered<NotificationService>()) {
        await getIt<NotificationService>().initialize();
        debugPrint('   ✅ NotificationService initialized');
      }

      if (getIt.isRegistered<PKService>()) {
        await getIt<PKService>().initialize();
        debugPrint('   ✅ PKService initialized');
      }

      if (getIt.isRegistered<CallService>()) {
        await getIt<CallService>().initialize();
        debugPrint('   ✅ CallService initialized');
      }

      // Log success
      if (getIt.isRegistered<LoggerService>()) {
        getIt<LoggerService>().info('All services initialized successfully');
      }

      debugPrint('✅ All services initialized successfully');
    } catch (e, s) {
      debugPrint('❌ Error initializing services: $e');
      if (getIt.isRegistered<LoggerService>()) {
        getIt<LoggerService>().error('Failed to initialize services', error: e, stackTrace: s);
      }
    }
  }

  // Generic get method
  T get<T extends Object>() {
    try {
      return getIt<T>();
    } catch (e) {
      throw Exception('❌ Service $T not found: $e');
    }
  }

  // Get Supabase client (helper method)
  SupabaseClient get supabase {
    try {
      return getIt<SupabaseClient>();
    } catch (e) {
      throw Exception('❌ SupabaseClient not found: $e');
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
    debugPrint('🔄 ServiceLocator reset');
  }

  // Dispose all services
  Future<void> dispose() async {
    debugPrint('🗑️ Disposing services...');

    try {
      // Dispose in reverse order of dependency
      if (getIt.isRegistered<SocketService>()) {
        await getIt<SocketService>().disconnect();
        debugPrint('   ✅ SocketService disposed');
      }

      if (getIt.isRegistered<CallService>()) {
        await getIt<CallService>().dispose();
        debugPrint('   ✅ CallService disposed');
      }

      if (getIt.isRegistered<TranslationService>()) {
        await getIt<TranslationService>().dispose();
        debugPrint('   ✅ TranslationService disposed');
      }

      if (getIt.isRegistered<PKService>()) {
        await getIt<PKService>().dispose();
        debugPrint('   ✅ PKService disposed');
      }

      if (getIt.isRegistered<StorageService>()) {
        await getIt<StorageService>().clearAllData();
        debugPrint('   ✅ StorageService disposed');
      }

      if (getIt.isRegistered<CacheService>()) {
        await getIt<CacheService>().clearAll();
        debugPrint('   ✅ CacheService disposed');
      }

      // Note: Supabase client doesn't need explicit disposal

      debugPrint('✅ All services disposed successfully');
    } catch (e) {
      debugPrint('❌ Error disposing services: $e');
    }
  }
}

// Extension for easy access from BuildContext
extension ServiceLocatorExtension on BuildContext {
  T service<T extends Object>() {
    try {
      return ServiceLocator.instance.get<T>();
    } catch (e) {
      throw Exception('Failed to get service $T: $e');
    }
  }
}

// Global helper function
T getService<T extends Object>() {
  return ServiceLocator.instance.get<T>();
}

// Global helper for Supabase access
SupabaseClient get supabase => ServiceLocator.instance.supabase;