import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/navigation_service.dart';

class DeviceInfoProvider extends ChangeNotifier {
  final LoggerService _logger = ServiceLocator().get<LoggerService>();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Map<String, dynamic> _deviceInfoData = {};
  Map<String, dynamic> _appInfoData = {};
  bool _isLoading = true;

  Map<String, dynamic> get deviceInfo => _deviceInfoData;
  Map<String, dynamic> get appInfo => _appInfoData;
  bool get isLoading => _isLoading;

  DeviceInfoProvider() {
    _loadDeviceInfo();
    _loadAppInfo();
  }

  BuildContext? _getContext() {
    // NavigationService এর navigatorKey static
    return NavigationService.navigatorKey.currentContext;
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final context = _getContext();

      TargetPlatform? platform;
      if (context != null) {
        platform = Theme.of(context).platform;
      }

      if (platform == TargetPlatform.android) {
        final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        _deviceInfoData = {
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
          'id': androidInfo.id,
          'platform': 'android',
        };
      } else if (platform == TargetPlatform.iOS) {
        final IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        _deviceInfoData = {
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'localizedModel': iosInfo.localizedModel,
          'identifierForVendor': iosInfo.identifierForVendor,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
          'utsname': iosInfo.utsname.machine,
          'platform': 'ios',
        };
      } else {
        // Web, Windows, macOS, Linux এর জন্য platform detection
        if (context != null) {
          _deviceInfoData = {
            'platform': platform?.name ?? 'unknown',
          };
        } else {
          _deviceInfoData = {
            'platform': 'unknown',
          };
        }
      }

      _logger.info('Device info loaded successfully');
    } catch (e) {
      _logger.error('Failed to load device info', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAppInfo() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _appInfoData = {
        'appName': packageInfo.appName,
        'packageName': packageInfo.packageName,
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
        'buildSignature': packageInfo.buildSignature,
      };
      _logger.info('App info loaded successfully');
    } catch (e) {
      _logger.error('Failed to load app info', error: e);
    }
  }

  // Get device ID (for analytics)
  Future<String?> getDeviceId() async {
    try {
      final context = _getContext();
      if (context == null) return null;

      final platform = Theme.of(context).platform;

      if (platform == TargetPlatform.android) {
        final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (platform == TargetPlatform.iOS) {
        final IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor;
      }
      return null;
    } catch (e) {
      _logger.error('Failed to get device ID', error: e);
      return null;
    }
  }

  // Check if device is tablet
  bool isTablet(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double shortestSide = size.shortestSide;
    return shortestSide > 600; // 600dp is typical tablet threshold
  }

  // Get device type
  String getDeviceType(BuildContext context) {
    if (isTablet(context)) return 'tablet';
    return 'phone';
  }

  // Get screen size category
  String getScreenSizeCategory(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width < 360) return 'small';
    if (width < 600) return 'normal';
    if (width < 900) return 'large';
    return 'xlarge';
  }

  // Get platform name
  String getPlatformName(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform.name;
  }

  // Check if running on web
  bool get isWeb => _deviceInfoData['platform'] == 'web';

  // Get device name
  String getDeviceName() {
    if (_deviceInfoData.containsKey('model')) {
      return _deviceInfoData['model'] as String;
    } else if (_deviceInfoData.containsKey('name')) {
      return _deviceInfoData['name'] as String;
    }
    return 'Unknown Device';
  }

  // Get OS version
  String getOsVersion() {
    if (_deviceInfoData.containsKey('version')) {
      return _deviceInfoData['version'] as String;
    } else if (_deviceInfoData.containsKey('systemVersion')) {
      return _deviceInfoData['systemVersion'] as String;
    }
    return 'Unknown';
  }
}