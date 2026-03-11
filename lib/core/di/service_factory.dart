// lib/core/di/service_factory.dart
import 'package:get_it/get_it.dart';

typedef ServiceCreator<T> = T Function();

class ServiceFactory {
  final Map<Type, ServiceCreator> _factories = {};
  final Map<Type, dynamic> _singletons = {};
  final GetIt _getIt = GetIt.instance;

  // Register a factory (creates new instance each time)
  void registerFactory<T>(ServiceCreator<T> factory) {
    _factories[T] = factory;
  }

  // Register a singleton (same instance always)
  void registerSingleton<T>(T instance) {
    _singletons[T] = instance;
    _getIt.registerSingleton<T>(instance);
  }

  // Register lazy singleton (created when first needed)
  void registerLazySingleton<T>(ServiceCreator<T> factory) {
    _getIt.registerLazySingleton<T>(factory);
  }

  // Get service instance
  T get<T>() {
    // Check singleton first
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }

    // Check factory
    if (_factories.containsKey(T)) {
      return _factories[T]!() as T;
    }

    // Check GetIt
    if (_getIt.isRegistered<T>()) {
      return _getIt<T>();
    }

    throw Exception('Service ${T.toString()} not registered');
  }

  // Create new instance (ignores singleton)
  T createNew<T>() {
    if (_factories.containsKey(T)) {
      return _factories[T]!() as T;
    }
    throw Exception('Factory for ${T.toString()} not found');
  }

  // Check if service exists
  bool has<T>() {
    return _singletons.containsKey(T) || 
           _factories.containsKey(T) || 
           _getIt.isRegistered<T>();
  }

  // Remove service
  void remove<T>() {
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