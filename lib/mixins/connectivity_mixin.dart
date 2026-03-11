import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

mixin ConnectivityMixin {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;

  void initConnectivity() {
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    _isConnected = result != ConnectivityResult.none;
  }

  bool get isConnected => _isConnected;

  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<ConnectivityResult> getConnectionType() async {
    return await _connectivity.checkConnectivity();
  }

  bool get isOnWifi => _isConnected; // You'll need to track actual type

  bool get isOnMobile => _isConnected; // You'll need to track actual type

  // Show no internet dialog
  Future<void> showNoInternetDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('No Internet'),
        content: const Text('Please check your internet connection.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () async {
              final connected = await checkConnection();
              if (connected) {
                Navigator.pop(context);
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}