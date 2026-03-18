import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

mixin ConnectivityMixin {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  ConnectivityResult? _connectionType;

  void initConnectivity() {
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    final List<ConnectivityResult> result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  // 🟢 Updated to accept List<ConnectivityResult>
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    _isConnected = !results.contains(ConnectivityResult.none);
    if (results.isNotEmpty) {
      _connectionType = results.first;
    } else {
      _connectionType = ConnectivityResult.none;
    }
    if (kDebugMode) {
      print('Connection status: $_isConnected, Type: $_connectionType');
    }
  }

  bool get isConnected => _isConnected;

  Future<bool> checkConnection() async {
    final List<ConnectivityResult> result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  // 🟢 Updated return type to List<ConnectivityResult>
  Future<List<ConnectivityResult>> getConnectionType() async {
    return await _connectivity.checkConnectivity();
  }

  // 🟢 Check if on wifi
  bool get isOnWifi => _connectionType == ConnectivityResult.wifi;

  // 🟢 Check if on mobile data
  bool get isOnMobile => _connectionType == ConnectivityResult.mobile;

  // 🟢 Check if on ethernet
  bool get isOnEthernet => _connectionType == ConnectivityResult.ethernet;

  // 🟢 Check if on vpn
  bool get isOnVpn => _connectionType == ConnectivityResult.vpn;

  // Show no internet dialog
  Future<void> showNoInternetDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('No Internet'),
        content: const Text('Please check your internet connection.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () async {
              final bool connected = await checkConnection();
              if (connected && context.mounted) {
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