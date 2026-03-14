// lib/core/di/di_config.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DIConfig {
  // Environment types
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';
  static bool get isTesting => environment == 'test';

  // Service lifetimes
  static const Map<Type, ServiceLifetime> serviceLifetimes = <Type, ServiceLifetime>{
    // Core services - Singleton
    ApiService: ServiceLifetime.singleton,
    AuthService: ServiceLifetime.singleton,
    DatabaseService: ServiceLifetime.singleton,
    SocketService: ServiceLifetime.singleton,
    StorageService: ServiceLifetime.singleton,
    LoggerService: ServiceLifetime.singleton,
    ConfigService: ServiceLifetime.singleton,
    
    // Business services - Lazy Singleton (created when first used)
    GameService: ServiceLifetime.lazySingleton,
    CallService: ServiceLifetime.lazySingleton,
    PaymentService: ServiceLifetime.lazySingleton,
    
    // Feature services - Factory (new instance each time)
    RoomService: ServiceLifetime.factory,
    GiftService: ServiceLifetime.factory,
    SearchService: ServiceLifetime.factory,
  };

  // Service dependencies
  static const Map<Type, List<Type>> serviceDependencies = <Type, List<Type>>{
    ApiService: <Type>[ConfigService, LoggerService],
    DatabaseService: <Type>[StorageService],
    SocketService: <Type>[AuthService, LoggerService],
    GameService: <Type>[PaymentService, LoggerService],
    CallService: <Type>[SocketService],
  };

  // Service initialization order
  static const List<Type> initializationOrder = <Type>[
    StorageService,
    LoggerService,
    ConfigService,
    ApiService,
    DatabaseService,
    AuthService,
    SocketService,
    // ... other services
  ];

  // Mock services for testing
  static const Map<Type, Type> mockServices = <Type, Type>{
    ApiService: MockApiService,
    DatabaseService: MockDatabaseService,
    // ... other mocks
  };
}

enum ServiceLifetime {
  singleton,      // One instance for entire app lifetime
  lazySingleton,  // Created when first used, then reused
  factory,        // New instance each time requested
  scoped,         // New instance per scope (e.g., per screen)
}

// Service initialization info
class ServiceInfo {

  const ServiceInfo({
    required this.type,
    required this.lifetime,
    this.dependencies = const <Type>[],
    this.isAsync = false,
    this.timeout = const Duration(seconds: 30),
  });
  final Type type;
  final ServiceLifetime lifetime;
  final List<Type> dependencies;
  final bool isAsync;
  final Duration timeout;

  // Predefined service infos
  static const Map<Type, ServiceInfo> all = <Type, ServiceInfo>{
    ApiService: ServiceInfo(
      type: ApiService,
      lifetime: ServiceLifetime.singleton,
      dependencies: <Type>[ConfigService, LoggerService],
      isAsync: true,
    ),
    AuthService: ServiceInfo(
      type: AuthService,
      lifetime: ServiceLifetime.singleton,
      dependencies: <Type>[ApiService, DatabaseService],
    ),
    // ... other services
  };
}

// Service registry for manual registration
class ServiceRegistry {
  static final Map<Type, dynamic> _registry = <Type, dynamic>{};

  static void register<T>(T instance) {
    _registry[T] = instance;
  }

  static T? get<T>() {
    return _registry[T] as T?;
  }

  static bool isRegistered<T>() {
    return _registry.containsKey(T);
  }

  static void unregister<T>() {
    _registry.remove(T);
  }

  static void clear() {
    _registry.clear();
  }
}