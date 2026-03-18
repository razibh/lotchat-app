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
  final List<AppLifecycleListener> _listeners = [];

  AppLifecycleStateEx get currentState => _currentState;
  bool get isInBackground => _isInBackground;
  int get backgroundDuration => _backgroundDuration;

  void initialize() {
    // Add lifecycle listener
    final listener = AppLifecycleListener(
      onResume: _onResume,
      onPause: _onPause,
      onInactive: _onInactive,
      onDetach: _onDetach,
      onHide: _onHide,
      onShow: _onShow,
    );

    _listeners.add(listener);

    _logger.debug('App lifecycle provider initialized');
  }

  void _onResume() {
    _currentState = AppLifecycleStateEx.resumed;
    if (_isInBackground) {
      _backgroundDuration = DateTime.now().difference(_lastBackgroundTime).inSeconds;
      _logger.info('App resumed after $_backgroundDuration seconds in background');
    }
    _isInBackground = false;
    _logger.debug('App lifecycle state changed: ${_currentState.name}');
    notifyListeners();
  }

  void _onPause() {
    _currentState = AppLifecycleStateEx.paused;
    _lastBackgroundTime = DateTime.now();
    _isInBackground = true;
    _logger.debug('App lifecycle state changed: ${_currentState.name}');
    notifyListeners();
  }

  void _onInactive() {
    _currentState = AppLifecycleStateEx.inactive;
    _logger.debug('App lifecycle state changed: ${_currentState.name}');
    notifyListeners();
  }

  void _onDetach() {
    _currentState = AppLifecycleStateEx.detached;
    _logger.debug('App lifecycle state changed: ${_currentState.name}');
    notifyListeners();
  }

  void _onHide() {
    _currentState = AppLifecycleStateEx.background;
    _logger.debug('App lifecycle state changed: ${_currentState.name}');
    notifyListeners();
  }

  void _onShow() {
    _currentState = AppLifecycleStateEx.resumed;
    _logger.debug('App lifecycle state changed: ${_currentState.name}');
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
    // Dispose all listeners
    for (final listener in _listeners) {
      listener.dispose();
    }
    _listeners.clear();
    super.dispose();
  }
}