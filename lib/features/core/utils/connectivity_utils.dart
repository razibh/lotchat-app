import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../services/connectivity_service.dart';

class ConnectivityUtils {
  static final ConnectivityService _connectivityService = 
      ServiceLocator().get<ConnectivityService>();

  // Check if connected
  static Future<bool> isConnected() async {
    return _connectivityService.hasConnection();
  }

  // Check if on WiFi
  static Future<bool> isOnWifi() async {
    return _connectivityService.isOnWifi();
  }

  // Check if on Mobile
  static Future<bool> isOnMobile() async {
    return _connectivityService.isOnMobile();
  }

  // Get connection status
  static Future<ConnectionStatus> getConnectionStatus() async {
    return _connectivityService.checkConnection();
  }

  // Show no internet dialog
  static Future<void> showNoInternetDialog(BuildContext context) async {
    if (!await isConnected()) {
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
                if (await isConnected()) {
                  // Retry action
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
  }

  // Execute with connection check
  static Future<T?> withConnectionCheck<T>(
    BuildContext context,
    Future<T> Function() action,
  ) async {
    if (await isConnected()) {
      return action();
    } else {
      await showNoInternetDialog(context);
      return null;
    }
  }

  // Get connection type name
  static String getConnectionTypeName(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.wifi:
        return 'WiFi';
      case ConnectionStatus.mobile:
        return 'Mobile Data';
      case ConnectionStatus.none:
        return 'No Connection';
    }
  }

  // Get connection icon
  static IconData getConnectionIcon(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.wifi:
        return Icons.wifi;
      case ConnectionStatus.mobile:
        return Icons.network_cell;
      case ConnectionStatus.none:
        return Icons.wifi_off;
    }
  }

  // Get connection color
  static Color getConnectionColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.wifi:
        return Colors.green;
      case ConnectionStatus.mobile:
        return Colors.orange;
      case ConnectionStatus.none:
        return Colors.red;
    }
  }
}