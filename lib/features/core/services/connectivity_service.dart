import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/logger_service.dart';

enum ConnectionStatus { wifi, mobile, none }

class ConnectivityService {
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();
  static final ConnectivityService _instance = ConnectivityService._internal();

  final LoggerService _logger = ServiceLocator().get<LoggerService>();
  final Connectivity _connectivity = Connectivity();
  
  final StreamController<ConnectionStatus> _connectionController = 
      StreamController<ConnectionStatus>.broadcast();
  
  ConnectionStatus _lastStatus = ConnectionStatus.none;
  StreamSubscription? _subscription;

  // Stream for connection changes
  Stream<ConnectionStatus> get connectionStream => _connectionController.stream;
  
  // Last known status
  ConnectionStatus get lastStatus => _lastStatus;
  
  // Is connected
  bool get isConnected => _lastStatus != ConnectionStatus.none;

  // Initialize
  Future<void> initialize() async {
    try {
      // Get initial status
      final result = await _connectivity.checkConnectivity();
      _updateStatus(result);
      
      // Listen for changes
      _subscription = _connectivity.onConnectivityChanged.listen(
        _updateStatus,
        onError: (e) {
          _logger.error('Connectivity stream error', error: e);
        },
      );
      
      _logger.info('Connectivity service initialized');
    } catch (e) {
      _logger.error('Failed to initialize connectivity service', error: e);
    }
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    
    ConnectionStatus newStatus;
    switch (result) {
      case ConnectivityResult.wifi:
        newStatus = ConnectionStatus.wifi;
      case ConnectivityResult.mobile:
        newStatus = ConnectionStatus.mobile;
      default:
        newStatus = ConnectionStatus.none;
    }

    if (_lastStatus != newStatus) {
      _lastStatus = newStatus;
      _connectionController.add(newStatus);
      _logger.debug('Connection status changed: $newStatus');
    }
  }

  // Check current connection
  Future<ConnectionStatus> checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final results = result is List<ConnectivityResult> ? result : <>[result];
      _updateStatus(results);
      return _lastStatus;
    } catch (e) {
      _logger.error('Failed to check connection', error: e);
      return ConnectionStatus.none;
    }
  }

  // Check if connected
  Future<bool> hasConnection() async {
    await checkConnection();
    return isConnected;
  }

  // Check if on WiFi
  Future<bool> isOnWifi() async {
    await checkConnection();
    return _lastStatus == ConnectionStatus.wifi;
  }

  // Check if on Mobile
  Future<bool> isOnMobile() async {
    await checkConnection();
    return _lastStatus == ConnectionStatus.mobile;
  }

  // Dispose
  void dispose() {
    _subscription?.cancel();
    _connectionController.close();
  }
}