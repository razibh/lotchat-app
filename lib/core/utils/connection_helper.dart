import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 🟢 debugPrint এর জন্য

class ConnectionHelper {
  static final Connectivity _connectivity = Connectivity();

  // Check internet connection
  static Future<bool> hasInternet() async {
    try {
      final List<ConnectivityResult> connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult.isNotEmpty &&
          !connectivityResult.contains(ConnectivityResult.none);
    } catch (e) {
      debugPrint('Error checking internet: $e');
      return false;
    }
  }

  // Get connection type
  static Future<List<ConnectivityResult>> getConnectionType() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      debugPrint('Error getting connection type: $e');
      return [ConnectivityResult.none];
    }
  }

  // Stream connection changes
  static Stream<List<ConnectivityResult>> onConnectionChange() {
    return _connectivity.onConnectivityChanged;
  }

  // Check if on WiFi
  static Future<bool> isOnWifi() async {
    try {
      final List<ConnectivityResult> result = await _connectivity.checkConnectivity();
      return result.contains(ConnectivityResult.wifi);
    } catch (e) {
      debugPrint('Error checking WiFi: $e');
      return false;
    }
  }

  // Check if on mobile data
  static Future<bool> isOnMobile() async {
    try {
      final List<ConnectivityResult> result = await _connectivity.checkConnectivity();
      return result.contains(ConnectivityResult.mobile);
    } catch (e) {
      debugPrint('Error checking mobile data: $e');
      return false;
    }
  }

  // Check if on Ethernet
  static Future<bool> isOnEthernet() async {
    try {
      final List<ConnectivityResult> result = await _connectivity.checkConnectivity();
      return result.contains(ConnectivityResult.ethernet);
    } catch (e) {
      debugPrint('Error checking Ethernet: $e');
      return false;
    }
  }

  // Check if on VPN
  static Future<bool> isOnVpn() async {
    try {
      final List<ConnectivityResult> result = await _connectivity.checkConnectivity();
      return result.contains(ConnectivityResult.vpn);
    } catch (e) {
      debugPrint('Error checking VPN: $e');
      return false;
    }
  }

  // Get connection status text
  static Future<String> getConnectionStatusText() async {
    try {
      final List<ConnectivityResult> result = await _connectivity.checkConnectivity();

      if (result.contains(ConnectivityResult.wifi)) {
        return 'Connected to WiFi';
      } else if (result.contains(ConnectivityResult.mobile)) {
        return 'Connected to Mobile Data';
      } else if (result.contains(ConnectivityResult.ethernet)) {
        return 'Connected to Ethernet';
      } else if (result.contains(ConnectivityResult.vpn)) {
        return 'Connected via VPN';
      } else if (result.contains(ConnectivityResult.none)) {
        return 'No Internet Connection';
      } else {
        return 'Unknown Connection';
      }
    } catch (e) {
      return 'Error checking connection';
    }
  }

  // Show no internet dialog
  static Future<void> showNoInternetDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('No Internet'),
        content: const Text('Please check your internet connection and try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () async {
              final bool hasInternet = await ConnectionHelper.hasInternet();
              if (hasInternet && context.mounted) {
                Navigator.pop(context);
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Still no internet connection'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Show internet status snackbar
  static void showConnectionStatus(BuildContext context, List<ConnectivityResult> result) {
    String message;
    Color color;

    if (result.contains(ConnectivityResult.wifi)) {
      message = 'Connected to WiFi';
      color = Colors.green;
    } else if (result.contains(ConnectivityResult.mobile)) {
      message = 'Connected to Mobile Data';
      color = Colors.green;
    } else if (result.contains(ConnectivityResult.ethernet)) {
      message = 'Connected to Ethernet';
      color = Colors.green;
    } else if (result.contains(ConnectivityResult.vpn)) {
      message = 'Connected via VPN';
      color = Colors.green;
    } else if (result.contains(ConnectivityResult.none)) {
      message = 'No Internet Connection';
      color = Colors.red;
    } else {
      message = 'Connection Lost';
      color = Colors.orange;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}