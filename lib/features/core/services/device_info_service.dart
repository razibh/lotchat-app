import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/logger_service.dart';

class DeviceInfoService {
  factory DeviceInfoService() => _instance;
  DeviceInfoService._internal();
  static final DeviceInfoService _instance = DeviceInfoService._internal();

  final LoggerService _logger = ServiceLocator().get<LoggerService>();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  
  Map<String, dynamic> _deviceInfoData = <String, dynamic>{};
  String? _deviceId;
  bool _isInitialized = false;

  // Device info
  Map<String, dynamic> get deviceInfo => _deviceInfoData;
  String? get deviceId => _deviceId;
  bool get isInitialized => _isInitialized;

  // Initialize
  Future<void> initialize() async {
    try {
      if (Theme.of(_getContext()).platform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        _deviceInfoData = <String, dynamic>{
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'manufacturer': androidInfo.manufacturer,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'device': androidInfo.device,
          'display': androidInfo.display,
          'hardware': androidInfo.hardware,
          'product': androidInfo.product,
          'tags': androidInfo.tags,
          'type': androidInfo.type,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
        };
        _deviceId = androidInfo.id;
      } else if (Theme.of(_getContext()).platform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _deviceInfoData = <String, dynamic>{
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'localizedModel': iosInfo.localizedModel,
          'identifierForVendor': iosInfo.identifierForVendor,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
          'utsname': iosInfo.utsname,
        };
        _deviceId = iosInfo.identifierForVendor;
      }
      
      _isInitialized = true;
      _logger.info('Device info loaded successfully');
    } catch (e) {
      _logger.error('Failed to load device info', error: e);
    }
  }

  // Get platform
  String getPlatform() {
    if (Theme.of(_getContext()).platform == TargetPlatform.android) {
      return 'android';
    } else if (Theme.of(_getContext()).platform == TargetPlatform.iOS) {
      return 'ios';
    } else {
      return 'unknown';
    }
  }

  // Check if device is tablet
  bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal = (size.width * size.width + size.height * size.height).sqrt();
    return diagonal > 1100; // Approx 7 inches
  }

  // Get device type
  String getDeviceType(BuildContext context) {
    if (isTablet(context)) return 'tablet';
    return 'phone';
  }

  // Get screen size category
  String getScreenSizeCategory(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 'small';
    if (width < 600) return 'normal';
    if (width < 900) return 'large';
    return 'xlarge';
  }

  // Get device info map for API
  Map<String, dynamic> getDeviceInfoForApi() {
    return <String, dynamic>{
      'platform': getPlatform(),
      'deviceId': _deviceId,
      'deviceModel': _deviceInfoData['model'],
      'osVersion': _deviceInfoData['version'] ?? _deviceInfoData['systemVersion'],
      'appVersion': ServiceLocator().get<AppInfoService>().version,
    };
  }

  BuildContext? _getContext() {
    // This would need navigation service
    return null;
  }
}