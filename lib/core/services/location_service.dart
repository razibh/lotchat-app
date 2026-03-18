import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // 🟢 geocoding import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/country_model.dart' as app;
import '../di/service_locator.dart';
import 'logger_service.dart';

class LocationService {
  // Singleton pattern
  factory LocationService() => _instance;

  // Private constructor
  LocationService._internal() {
    _initializeServices();
  }

  static final LocationService _instance = LocationService._internal();

  late final LoggerService _logger;

  Position? _currentPosition;
  String? _currentCountry;
  String? _currentCity;
  bool _isServiceEnabled = false;
  LocationPermission? _permission;

  void _initializeServices() {
    try {
      _logger = ServiceLocator.instance.get<LoggerService>();
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  // Initialize
  Future<bool> initialize() async {
    try {
      _isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      _permission = await Geolocator.checkPermission();

      _logger?.info('Location service initialized');
      return true;
    } catch (e) {
      _logger?.error('Failed to initialize location service', error: e);
      return false;
    }
  }

  // Request permissions
  Future<bool> requestPermission() async {
    try {
      _permission = await Geolocator.requestPermission();

      if (_permission == LocationPermission.whileInUse ||
          _permission == LocationPermission.always) {
        _logger?.info('Location permission granted');
        return true;
      }

      _logger?.warning('Location permission denied');
      return false;
    } catch (e) {
      _logger?.error('Failed to request location permission', error: e);
      return false;
    }
  }

  // Get current location
  Future<Position?> getCurrentLocation({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && _currentPosition != null) {
        return _currentPosition;
      }

      final bool permission = await _checkPermission();
      if (!permission) return null;

      if (!_isServiceEnabled) {
        _logger?.warning('Location services are disabled');
        return null;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _logger?.info('Current location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');

      // Get address from coordinates using geocoding package
      await _getAddressFromCoordinates();

      return _currentPosition;
    } catch (e) {
      _logger?.error('Failed to get current location', error: e);
      return null;
    }
  }

  // Check permission
  Future<bool> _checkPermission() async {
    _permission ??= await Geolocator.checkPermission();

    if (_permission == LocationPermission.denied) {
      _permission = await Geolocator.requestPermission();
    }

    return _permission == LocationPermission.whileInUse ||
        _permission == LocationPermission.always;
  }

  // 🟢 Get address from coordinates using geocoding
  Future<void> _getAddressFromCoordinates() async {
    if (_currentPosition == null) return;

    try {
      // placemarkFromCoordinates এখন geocoding package থেকে আসে [citation:2][citation:8]
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark placemark = placemarks.first;
        _currentCountry = placemark.country;
        _currentCity = placemark.locality;

        _logger?.info('Current country: $_currentCountry, city: $_currentCity');

        // Save to preferences
        await _saveLocation();
      }
    } catch (e) {
      _logger?.error('Failed to get address from coordinates', error: e);
    }
  }

  // Save location to preferences
  Future<void> _saveLocation() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_country', _currentCountry ?? '');
      await prefs.setString('last_city', _currentCity ?? '');
      await prefs.setDouble('last_lat', _currentPosition?.latitude ?? 0);
      await prefs.setDouble('last_lng', _currentPosition?.longitude ?? 0);
    } catch (e) {
      _logger?.error('Failed to save location', error: e);
    }
  }

  // Load last location
  Future<void> loadLastLocation() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _currentCountry = prefs.getString('last_country');
      _currentCity = prefs.getString('last_city');

      final double? lat = prefs.getDouble('last_lat');
      final double? lng = prefs.getDouble('last_lng');

      if (lat != null && lng != null) {
        _currentPosition = Position(
          latitude: lat,
          longitude: lng,
          timestamp: DateTime.now(),
          altitude: 0,
          accuracy: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
    } catch (e) {
      _logger?.error('Failed to load last location', error: e);
    }
  }

  // Get country code from location
  Future<String?> getCountryCode() async {
    if (_currentCountry == null) {
      await getCurrentLocation();
    }

    if (_currentCountry != null) {
      // Match country name to country code
      final List<app.CountryModel> countries = app.CountryModel.getCountries();
      try {
        final app.CountryModel country = countries.firstWhere(
              (app.CountryModel c) => c.name == _currentCountry,
        );
        return country.code;
      } catch (e) {
        // If country not found, return default
        return 'BD';
      }
    }

    return null;
  }

  // Get region from location
  Future<String?> getRegion() async {
    return _currentCity;
  }

  // Calculate distance between two points
  double calculateDistance(
      double lat1, double lon1,
      double lat2, double lon2,
      ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Check if user is in a specific country
  Future<bool> isInCountry(String countryCode) async {
    final String? currentCode = await getCountryCode();
    return currentCode == countryCode;
  }

  // Get nearby users (would need Firestore integration)
  Future<List<Map<String, dynamic>>> getNearbyUsers(
      double radiusInMeters, {
        int limit = 50,
      }) async {
    if (_currentPosition == null) return [];
    return [];
  }

  // Stream location updates
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).map((position) {
      _currentPosition = position;
      _getAddressFromCoordinates();
      return position;
    });
  }

  // Stop location updates
  void stopLocationUpdates() {}

  // Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  // Getters
  Position? get currentPosition => _currentPosition;
  String? get currentCountry => _currentCountry;
  String? get currentCity => _currentCity;
  bool get isLocationEnabled => _isServiceEnabled;
  LocationPermission? get permissionStatus => _permission;
}