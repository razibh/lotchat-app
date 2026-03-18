import 'package:flutter/material.dart';
import '../../core/services/connectivity_service.dart';

class AppProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  bool _isConnected = true;

  AppProvider() {
    _initConnectivity();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _isConnected;

  void _initConnectivity() {
    ConnectivityService().connectionStream.listen((isConnected) {
      _isConnected = isConnected as bool; // type cast
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