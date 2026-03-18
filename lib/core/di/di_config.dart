// lib/core/di/di_config.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import your service classes (you need to import them)
// import '../services/api_service.dart';
// import '../services/auth_service.dart';
// etc.

class DIConfig {
  // Private constructor to prevent instantiation
  DIConfig._();

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
  static const Map<Type, ServiceLifetime> serviceLifetimes = {
    // Core services - Singleton
    // ApiService: ServiceLifetime.singleton,
    // AuthService: ServiceLifetime.singleton,
    // DatabaseService: ServiceLifetime.singleton,
    // SocketService: ServiceLifetime.singleton,
    // StorageService: ServiceLifetime.singleton,
    // LoggerService: ServiceLifetime.singleton,
    // ConfigService: ServiceLifetime.singleton,

    // Business services - Lazy Singleton (created when first used)
    // GameService: ServiceLifetime.lazySingleton,
    // CallService: ServiceLifetime.lazySingleton,
    // PaymentService: ServiceLifetime.lazySingleton,

    // Feature services - Factory (new instance each time)
    // RoomService: ServiceLifetime.factory,
    // GiftService: ServiceLifetime.factory,
    // SearchService: ServiceLifetime.factory,
  };

  // Service dependencies
  static const Map<Type, List<Type>> serviceDependencies = {
    // ApiService: [ConfigService, LoggerService],
    // DatabaseService: [StorageService],
    // SocketService: [AuthService, LoggerService],
    // GameService: [PaymentService, LoggerService],
    // CallService: [SocketService],
  };

  // Service initialization order
  static const List<Type> initializationOrder = [
    // StorageService,
    // LoggerService,
    // ConfigService,
    // ApiService,
    // DatabaseService,
    // AuthService,
    // SocketService,
    // ... other services
  ];

  // Mock services for testing
  static const Map<Type, Type> mockServices = {
    // ApiService: MockApiService,
    // DatabaseService: MockDatabaseService,
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
  final Type type;
  final ServiceLifetime lifetime;
  final List<Type> dependencies;
  final bool isAsync;
  final Duration timeout;

  const ServiceInfo({
    required this.type,
    required this.lifetime,
    this.dependencies = const [],
    this.isAsync = false,
    this.timeout = const Duration(seconds: 30),
  });

  // Predefined service infos
  static const Map<Type, ServiceInfo> all = {
    // ApiService: ServiceInfo(
    //   type: ApiService,
    //   lifetime: ServiceLifetime.singleton,
    //   dependencies: [ConfigService, LoggerService],
    //   isAsync: true,
    // ),
    // AuthService: ServiceInfo(
    //   type: AuthService,
    //   lifetime: ServiceLifetime.singleton,
    //   dependencies: [ApiService, DatabaseService],
    // ),
    // ... other services
  };
}

// Service registry for manual registration
class ServiceRegistry {
  static final Map<Type, dynamic> _registry = {};

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

// Mock service classes (for testing)
// class MockApiService {}
// class MockDatabaseService {}