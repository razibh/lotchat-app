import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/services/logger_service.dart';

enum AppLifecycleStateEx {
  resumed,
  paused,
  inactive,
  detached,
  background
}

class AppLifecycleProvider extends ChangeNotifier {
  final LoggerService _logger = ServiceLocator().get<LoggerService>();
  
  AppLifecycleStateEx _currentState = AppLifecycleStateEx.resumed;
  DateTime _lastBackgroundTime = DateTime.now();
  int _backgroundDuration = 0;
  bool _isInBackground = false;
  StreamSubscription? _lifecycleSubscription;

  AppLifecycleStateEx get currentState => _currentState;
  bool get isInBackground => _isInBackground;
  int get backgroundDuration => _backgroundDuration;

  void initialize() {
    _lifecycleSubscription = WidgetsBinding.instance.lifecycleStateChanges.listen(
      _handleLifecycleChange,
    );
  }

  void _handleLifecycleChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _currentState = AppLifecycleStateEx.resumed;
        if (_isInBackground) {
          _backgroundDuration = DateTime.now().difference(_lastBackgroundTime).inSeconds;
          _logger.info('App resumed after $_backgroundDuration seconds in background');
        }
        _isInBackground = false;

      case AppLifecycleState.inactive:
        _currentState = AppLifecycleStateEx.inactive;

      case AppLifecycleState.paused:
        _currentState = AppLifecycleStateEx.paused;
        _lastBackgroundTime = DateTime.now();
        _isInBackground = true;

      case AppLifecycleState.detached:
        _currentState = AppLifecycleStateEx.detached;

      default:
        _currentState = AppLifecycleStateEx.background;
    }

    _logger.debug('App lifecycle state changed: $_currentState');
    notifyListeners();
  }

  // Check if app was in background for more than X seconds
  bool wasInBackgroundForMoreThan(int seconds) {
    return _backgroundDuration > seconds;
  }

  // Reset background duration
  void resetBackgroundDuration() {
    _backgroundDuration = 0;
  }

  @override
  void dispose() {
    _lifecycleSubscription?.cancel();
    super.dispose();
  }
}