import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/services/logger_service.dart';

enum ConnectionStatus { wifi, mobile, none }

class ConnectivityProvider extends ChangeNotifier {

  ConnectivityProvider() {
    _initConnectivity();
    _subscribeToChanges();
  }
  final LoggerService _logger = ServiceLocator().get<LoggerService>();
  final Connectivity _connectivity = Connectivity();
  
  ConnectionStatus _connectionStatus = ConnectionStatus.none;
  bool _isConnected = false;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectionStatus get connectionStatus => _connectionStatus;
  bool get isConnected => _isConnected;
  bool get isOnWifi => _connectionStatus == ConnectionStatus.wifi;
  bool get isOnMobile => _connectionStatus == ConnectionStatus.mobile;

  Future<void> _initConnectivity() async {
    try {
      final List<ConnectivityResult> result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      _logger.error('Failed to check connectivity', error: e);
    }
  }

  void _subscribeToChanges() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
      onError: (e) {
        _logger.error('Connectivity stream error', error: e);
      },
    );
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final ConnectivityResult result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    
    ConnectionStatus newStatus;
    switch (result) {
      case ConnectivityResult.wifi:
        newStatus = ConnectionStatus.wifi;
        _isConnected = true;
      case ConnectivityResult.mobile:
        newStatus = ConnectionStatus.mobile;
        _isConnected = true;
      default:
        newStatus = ConnectionStatus.none;
        _isConnected = false;
    }

    if (_connectionStatus != newStatus) {
      _connectionStatus = newStatus;
      _logger.info('Connection status changed: $_connectionStatus');
      notifyListeners();
    }
  }

  // Check connection manually
  Future<bool> checkConnection() async {
    await _initConnectivity();
    return _isConnected;
  }

  // Show no connection dialog
  Future<void> showNoConnectionDialog(BuildContext context) async {
    if (!_isConnected) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text('Please check your internet connection and try again.'),
          actions: <>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await checkConnection();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}