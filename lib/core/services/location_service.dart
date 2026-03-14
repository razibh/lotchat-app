import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/country_model.dart';
import '../di/service_locator.dart';
import 'logger_service.dart';

class LocationService {
  factory LocationService() => _instance;
  LocationService._internal();
  static final LocationService _instance = LocationService._internal();

  final LoggerService _logger = ServiceLocator().get<LoggerService>();
  
  Position? _currentPosition;
  String? _currentCountry;
  String? _currentCity;
  bool _isServiceEnabled = false;
  LocationPermission? _permission;

  // Initialize
  Future<bool> initialize() async {
    try {
      _isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      _permission = await Geolocator.checkPermission();
      
      _logger.info('Location service initialized');
      return true;
    } catch (e) {
      _logger.error('Failed to initialize location service', error: e);
      return false;
    }
  }

  // Request permissions
  Future<bool> requestPermission() async {
    try {
      _permission = await Geolocator.requestPermission();
      
      if (_permission == LocationPermission.whileInUse ||
          _permission == LocationPermission.always) {
        _logger.info('Location permission granted');
        return true;
      }
      
      _logger.warning('Location permission denied');
      return false;
    } catch (e) {
      _logger.error('Failed to request location permission', error: e);
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
        _logger.warning('Location services are disabled');
        return null;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _logger.info('Current location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
      
      // Get address from coordinates
      await _getAddressFromCoordinates();
      
      return _currentPosition;
    } catch (e) {
      _logger.error('Failed to get current location', error: e);
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

  // Get address from coordinates
  Future<void> _getAddressFromCoordinates() async {
    if (_currentPosition == null) return;

    try {
      final placemarks = await Geolocator.placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        _currentCountry = placemark.country;
        _currentCity = placemark.locality;
        
        _logger.info('Current country: $_currentCountry, city: $_currentCity');
        
        // Save to preferences
        await _saveLocation();
      }
    } catch (e) {
      _logger.error('Failed to get address from coordinates', error: e);
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
      _logger.error('Failed to save location', error: e);
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
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
    } catch (e) {
      _logger.error('Failed to load last location', error: e);
    }
  }

  // Get country code from location
  Future<String?> getCountryCode() async {
    if (_currentCountry == null) {
      await getCurrentLocation();
    }

    if (_currentCountry != null) {
      // Match country name to country code
      final List<CountryModel> countries = CountryModel.getCountries();
      final CountryModel country = countries.firstWhere(
        (CountryModel c) => c.name == _currentCountry,
        orElse: () => countries.first,
      );
      return country.code;
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
    double radiusInMeters,
    {int limit = 50,}
  ) async {
    if (_currentPosition == null) return <Map<String, dynamic>>[];

    // This would query Firestore with geohash
    // Implementation depends on how you store locations
    return <Map<String, dynamic>>[];
  }

  // Stream location updates
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).map((position) {
      _currentPosition = position;
      _getAddressFromCoordinates();
      return position;
    });
  }

  // Stop location updates
  void stopLocationUpdates() {
    // Stream will be closed when subscription is cancelled
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  // Get current position
  Position? get currentPosition => _currentPosition;
  
  // Get current country
  String? get currentCountry => _currentCountry;
  
  // Get current city
  String? get currentCity => _currentCity;
  
  // Check if location services are enabled
  bool get isLocationEnabled => _isServiceEnabled;
  
  // Check permission status
  LocationPermission? get permissionStatus => _permission;
}