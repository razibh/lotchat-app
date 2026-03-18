// lib/core/di/injection_modules.dart
import 'package:get_it/get_it.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/socket_service.dart'; // 🟢 SocketService import
// import '../repositories/auth_repository.dart'; // 🟢 AuthRepository import (if exists)

abstract class InjectionModule {
  Future<void> register(GetIt getIt);
}

class ApiModule implements InjectionModule {
  @override
  Future<void> register(GetIt getIt) async {
    getIt.registerSingletonAsync<ApiService>(() async {
      final ApiService api = ApiService();
      await api.init();
      return api;
    });
  }
}

class AuthModule implements InjectionModule {
  @override
  Future<void> register(GetIt getIt) async {
    getIt.registerSingleton<AuthService>(AuthService());

    // Register repositories if needed
    // 🟢 Comment out if AuthRepository doesn't exist
    // getIt.registerFactory(() => AuthRepository(getIt<AuthService>()));
  }
}

class DatabaseModule implements InjectionModule {
  @override
  Future<void> register(GetIt getIt) async {
    getIt.registerSingleton<DatabaseService>(DatabaseService());
  }
}

class SocketModule implements InjectionModule {
  @override
  Future<void> register(GetIt getIt) async {
    getIt.registerSingletonAsync<SocketService>(() async {
      final socket = SocketService();
      await socket.initSocket();
      return socket;
    });
  }
}

// Module loader
class ModuleLoader {
  static final List<InjectionModule> modules = [
    ApiModule(),
    AuthModule(),
    DatabaseModule(),
    SocketModule(),
  ];

  static Future<void> loadAll(GetIt getIt) async {
    for (InjectionModule module in modules) {
      await module.register(getIt);
    }
  }
}