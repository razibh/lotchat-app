import 'package:flutter/material.dart';
import '../../core/services/connectivity_service.dart';

class AppProvider extends ChangeNotifier {

  AppProvider() {
    _initConnectivity();
  }
  bool _isLoading = false;
  String? _error;
  bool _isConnected = true;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _isConnected;

  void _initConnectivity() {
    ConnectivityService().connectionStream.listen((ConnectionStatus status) {
      _isConnected = status;
      notifyListeners();
    });
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}