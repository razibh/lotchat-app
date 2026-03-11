import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionHelper {
  static final Connectivity _connectivity = Connectivity();

  // Check internet connection
  static Future<bool> hasInternet() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Get connection type
  static Future<ConnectivityResult> getConnectionType() async {
    return await _connectivity.checkConnectivity();
  }

  // Stream connection changes
  static Stream<ConnectivityResult> onConnectionChange() {
    return _connectivity.onConnectivityChanged;
  }

  // Check if on WiFi
  static Future<bool> isOnWifi() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.wifi;
  }

  // Check if on mobile data
  static Future<bool> isOnMobile() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.mobile;
  }

  // Show no internet dialog
  static Future<void> showNoInternetDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('No Internet'),
        content: const Text('Please check your internet connection and try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () async {
              final hasInternet = await ConnectionHelper.hasInternet();
              if (hasInternet) {
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