// lib/core/di/service_factory.dart
import 'package:get_it/get_it.dart';

typedef ServiceCreator<T extends Object> = T Function(); // 🟢 Fixed: Added extends Object

class ServiceFactory {
  final Map<Type, ServiceCreator<Object>> _factories = {}; // 🟢 Fixed: Use Object instead of dynamic
  final Map<Type, Object> _singletons = {}; // 🟢 Fixed: Use Object instead of dynamic
  final GetIt _getIt = GetIt.instance;

  // Register a factory (creates new instance each time)
  void registerFactory<T extends Object>(ServiceCreator<T> factory) { // 🟢 Fixed: Added extends Object
    _factories[T] = factory;
  }

  // Register a singleton (same instance always)
  void registerSingleton<T extends Object>(T instance) { // 🟢 Fixed: Added extends Object
    _singletons[T] = instance;
    _getIt.registerSingleton<T>(instance);
  }

  // Register lazy singleton (created when first needed)
  void registerLazySingleton<T extends Object>(ServiceCreator<T> factory) { // 🟢 Fixed: Added extends Object
    _getIt.registerLazySingleton<T>(factory);
  }

  // Get service instance
  T get<T extends Object>() { // 🟢 Fixed: Added extends Object
    // Check singleton first
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }

    // Check factory
    if (_factories.containsKey(T)) {
      return (_factories[T]!() as T);
    }

    // Check GetIt
    if (_getIt.isRegistered<T>()) {
      return _getIt<T>();
    }

    throw Exception('Service $T not registered');
  }

  // Create new instance (ignores singleton)
  T createNew<T extends Object>() { // 🟢 Fixed: Added extends Object
    if (_factories.containsKey(T)) {
      return (_factories[T]!() as T);
    }
    throw Exception('Factory for $T not found');
  }

  // Check if service exists
  bool has<T extends Object>() { // 🟢 Fixed: Added extends Object
    return _singletons.containsKey(T) ||
        _factories.containsKey(T) ||
        _getIt.isRegistered<T>();
  }

  // Remove service
  void remove<T extends Object>() { // 🟢 Fixed: Added extends Object
    _singletons.remove(T);
    _factories.remove(T);
    if (_getIt.isRegistered<T>()) {
      _getIt.unregister<T>();
    }
  }

  // Clear all
  void clear() {
    _singletons.clear();
    _factories.clear();
  }
}