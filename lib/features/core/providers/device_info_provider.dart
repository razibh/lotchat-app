import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/di/service_locator.dart';

class DeviceInfoProvider extends ChangeNotifier {

  DeviceInfoProvider() {
    _loadDeviceInfo();
    _loadAppInfo();
  }
  final LoggerService _logger = ServiceLocator().get<LoggerService>();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  
  Map<String, dynamic> _deviceInfoData = <String, dynamic>{};
  Map<String, dynamic> _appInfoData = <String, dynamic>{};
  bool _isLoading = true;

  Map<String, dynamic> get deviceInfo => _deviceInfoData;
  Map<String, dynamic> get appInfo => _appInfoData;
  bool get isLoading => _isLoading;

  Future<void> _loadDeviceInfo() async {
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
      final packageInfo = await PackageInfo.fromPlatform();
      _appInfoData = <String, dynamic>{
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
      if (Theme.of(_getContext()).platform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Theme.of(_getContext()).platform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
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

  BuildContext? _getContext() {
    // This would need navigation service
    return null;
  }
}