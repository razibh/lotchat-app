import 'dart:async';
import 'dart:io'; // InternetAddress, SocketException এর জন্য
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart'; // Consumer এর জন্য

class ConnectivityStatus extends ChangeNotifier {
  // Singleton pattern
  static final ConnectivityStatus _instance = ConnectivityStatus._internal();
  factory ConnectivityStatus() => _instance;
  ConnectivityStatus._internal();

  // Connectivity instance
  final Connectivity _connectivity = Connectivity();

  // Connection status
  bool _isConnected = true;
  bool _isChecking = false;
  ConnectivityResult _connectionType = ConnectivityResult.none;

  // Stream subscriptions
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Getters
  bool get isConnected => _isConnected;
  bool get isChecking => _isChecking;
  ConnectivityResult get connectionType => _connectionType;
  bool get isWifi => _connectionType == ConnectivityResult.wifi;
  bool get isMobile => _connectionType == ConnectivityResult.mobile;
  bool get isEthernet => _connectionType == ConnectivityResult.ethernet;
  bool get isVpn => _connectionType == ConnectivityResult.vpn;
  bool get isBluetooth => _connectionType == ConnectivityResult.bluetooth;
  bool get isNone => _connectionType == ConnectivityResult.none;

  // Initialize connectivity monitoring
  Future<void> initialize() async {
    _isChecking = true;
    notifyListeners();

    try {
      // Get initial connection status
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);

      // Listen for connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectionStatus,
        onError: (error) {
          _isConnected = false;
          _connectionType = ConnectivityResult.none;
          notifyListeners();
        },
      );
    } catch (e) {
      _isConnected = false;
      _connectionType = ConnectivityResult.none;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  // Update connection status
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      _isConnected = false;
      _connectionType = ConnectivityResult.none;
    } else {
      // Take the first connectivity result (usually the most relevant)
      _connectionType = results.first;
      _isConnected = _connectionType != ConnectivityResult.none;
    }
    notifyListeners();
  }

  // Manually check connectivity
  Future<bool> checkConnectivity() async {
    _isChecking = true;
    notifyListeners();

    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
      return _isConnected;
    } catch (e) {
      _isConnected = false;
      _connectionType = ConnectivityResult.none;
      return false;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  // Check if device has internet (requires actual network request)
  Future<bool> hasInternetAccess() async {
    try {
      // Try to reach a reliable server
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  // Check both connectivity and actual internet access
  Future<bool> isOnline() async {
    if (!_isConnected) return false;
    return hasInternetAccess();
  }

  // Get connection type as string
  String get connectionTypeString {
    switch (_connectionType) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.none:
        return 'No Connection';
      default:
        return 'Unknown';
    }
  }

  // Get connection icon
  IconData get connectionIcon {
    switch (_connectionType) {
      case ConnectivityResult.wifi:
        return Icons.wifi;
      case ConnectivityResult.mobile:
        return Icons.network_cell;
      case ConnectivityResult.ethernet:
        return Icons.settings_ethernet;
      case ConnectivityResult.vpn:
        return Icons.vpn_lock;
      case ConnectivityResult.bluetooth:
        return Icons.bluetooth;
      case ConnectivityResult.none:
        return Icons.signal_wifi_off;
      default:
        return Icons.signal_cellular_alt;
    }
  }

  // Get connection color
  Color getConnectionColor() {
    if (!_isConnected) return Colors.red;

    switch (_connectionType) {
      case ConnectivityResult.wifi:
        return Colors.blue;
      case ConnectivityResult.mobile:
        return Colors.green;
      case ConnectivityResult.ethernet:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Check if connection is metered (mobile data)
  bool get isMeteredConnection => _connectionType == ConnectivityResult.mobile;

  // Dispose
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

// Connection Status Widget
class ConnectionStatusWidget extends StatelessWidget {
  final bool showDetails;
  final VoidCallback? onRetry;

  const ConnectionStatusWidget({
    super.key,
    this.showDetails = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityStatus>(
      builder: (context, connectivity, child) {
        if (connectivity.isConnected) {
          if (showDetails) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: connectivity.getConnectionColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    connectivity.connectionIcon,
                    size: 16,
                    color: connectivity.getConnectionColor(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    connectivity.connectionTypeString,
                    style: TextStyle(
                      fontSize: 12,
                      color: connectivity.getConnectionColor(),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        } else {
          return Container(
            color: Colors.red.withOpacity(0.1),
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.signal_wifi_off, size: 16, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  'No internet connection',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
                if (onRetry != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ],
            ),
          );
        }
      },
    );
  }
}

// Connection Checker Mixin
mixin ConnectivityMixin<T extends StatefulWidget> on State<T> {
  final ConnectivityStatus _connectivity = ConnectivityStatus();

  @override
  void initState() {
    super.initState();
    _connectivity.initialize();
  }

  @override
  void dispose() {
    _connectivity.dispose();
    super.dispose();
  }

  // Check if device is online (with actual internet access)
  Future<bool> isOnline() => _connectivity.isOnline();

  // Show no internet dialog
  Future<void> showNoInternetDialog() async {
    if (!mounted) return;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.signal_wifi_off, size: 48, color: Colors.red),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No Internet Connection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Please check your internet connection and try again.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (await _connectivity.checkConnectivity()) {
                // Connected, proceed
              } else {
                // Still not connected
                showNoInternetDialog();
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Check connection before performing action
  Future<bool> ensureConnection() async {
    if (await isOnline()) return true;

    if (mounted) {
      showNoInternetDialog();
    }
    return false;
  }

  // Execute action with connection check
  Future<void> withConnectionCheck(Future<void> Function() action) async {
    if (await ensureConnection()) {
      await action();
    }
  }
}

// Internet Connection Checker Helper
class InternetChecker {
  static Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> hasConnectivity() async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  static Future<bool> isFullyConnected() async {
    return await hasConnectivity() && await hasInternet();
  }
}