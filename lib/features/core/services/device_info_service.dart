import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/navigation_service.dart';

class DeviceInfoService {
  factory DeviceInfoService() => _instance;
  DeviceInfoService._internal();
  static final DeviceInfoService _instance = DeviceInfoService._internal();

  final LoggerService _logger = ServiceLocator().get<LoggerService>();

  // Static access for NavigationService
  BuildContext? get _context => NavigationService.navigatorKey.currentContext;

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Device info cache
  Map<String, dynamic> _deviceInfoData = {};
  bool _isInitialized = false;

  // Platform detection
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isMacOS => !kIsWeb && Platform.isMacOS;
  bool get isLinux => !kIsWeb && Platform.isLinux;
  bool get isWeb => kIsWeb;

  // Initialize device info
  Future<void> initialize() async {
    try {
      await _loadDeviceInfo();
      _isInitialized = true;
      _logger.info('Device info service initialized');
    } catch (e) {
      _logger.error('Failed to initialize device info service', error: e);
    }
  }

  Future<void> _loadDeviceInfo() async {
    try {
      if (isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        _deviceInfoData = {
          'platform': 'android',
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'manufacturer': androidInfo.manufacturer,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'device': androidInfo.device,
          'display': androidInfo.display,
          'hardware': androidInfo.hardware,
          'product': androidInfo.product,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
          'id': androidInfo.id,
          'supportedAbis': androidInfo.supportedAbis,
        };
      } else if (isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _deviceInfoData = {
          'platform': 'ios',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'localizedModel': iosInfo.localizedModel,
          'identifierForVendor': iosInfo.identifierForVendor,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
        };
      } else if (isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        _deviceInfoData = {
          'platform': 'windows',
          'computerName': windowsInfo.computerName,
          'numberOfCores': windowsInfo.numberOfCores,
          'buildNumber': windowsInfo.buildNumber,
          'majorVersion': windowsInfo.majorVersion,
          'minorVersion': windowsInfo.minorVersion,
          'productId': windowsInfo.productId,
          'servicePackMajor': windowsInfo.servicePackMajor,
          'servicePackMinor': windowsInfo.servicePackMinor,
          'productType': windowsInfo.productType,
          'registeredOwner': windowsInfo.registeredOwner,
        };
      } else if (isMacOS) {
        final macosInfo = await _deviceInfo.macOsInfo;
        _deviceInfoData = {
          'platform': 'macos',
          'arch': macosInfo.arch,
          'model': macosInfo.model,
          'osRelease': macosInfo.osRelease,
          'activeCPUs': macosInfo.activeCPUs,
          'hostName': macosInfo.hostName,
          'kernelVersion': macosInfo.kernelVersion,
          'majorVersion': macosInfo.majorVersion,
          'minorVersion': macosInfo.minorVersion,
          'patchVersion': macosInfo.patchVersion,
          'systemGUID': macosInfo.systemGUID,
        };
      } else if (isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        _deviceInfoData = {
          'platform': 'linux',
          'name': linuxInfo.name,
          'version': linuxInfo.version,
          'id': linuxInfo.id,
          'prettyName': linuxInfo.prettyName,
          'versionId': linuxInfo.versionId,
        };
      } else if (isWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        _deviceInfoData = {
          'platform': 'web',
          'browserName': webInfo.browserName.name,
          'appName': webInfo.appName,
          'appVersion': webInfo.appVersion,
          'platform': webInfo.platform,
          'userAgent': webInfo.userAgent,
          'hardwareConcurrency': webInfo.hardwareConcurrency,
          'language': webInfo.language,
        };
      }

      _logger.debug('Device info loaded for platform: ${_deviceInfoData['platform']}');
    } catch (e) {
      _logger.error('Failed to load device info', error: e);
      rethrow;
    }
  }

  // Get all device info
  Map<String, dynamic> getDeviceInfo() {
    return _deviceInfoData;
  }

  // Get specific device info field
  dynamic getDeviceInfoField(String key) {
    return _deviceInfoData[key];
  }

  // Get device ID (for analytics)
  String? getDeviceId() {
    if (isAndroid) {
      return _deviceInfoData['id'] as String?;
    } else if (isIOS) {
      return _deviceInfoData['identifierForVendor'] as String?;
    } else if (isWindows) {
      return _deviceInfoData['computerName'] as String?;
    } else if (isMacOS) {
      return _deviceInfoData['systemGUID'] as String?;
    } else if (isWeb) {
      return _deviceInfoData['userAgent'] as String?;
    }
    return null;
  }

  // Get device model
  String getDeviceModel() {
    if (isAndroid || isIOS) {
      return _deviceInfoData['model'] as String? ?? 'Unknown';
    } else if (isWindows) {
      return _deviceInfoData['computerName'] as String? ?? 'Windows PC';
    } else if (isMacOS) {
      return _deviceInfoData['model'] as String? ?? 'Mac';
    } else if (isLinux) {
      return _deviceInfoData['prettyName'] as String? ?? 'Linux';
    } else if (isWeb) {
      return 'Web Browser';
    }
    return 'Unknown';
  }

  // Get OS version
  String getOsVersion() {
    if (isAndroid) {
      return 'Android ${_deviceInfoData['version']} (API ${_deviceInfoData['sdkInt']})';
    } else if (isIOS) {
      return 'iOS ${_deviceInfoData['systemVersion']}';
    } else if (isWindows) {
      return 'Windows ${_deviceInfoData['majorVersion']}.${_deviceInfoData['minorVersion']} (Build ${_deviceInfoData['buildNumber']})';
    } else if (isMacOS) {
      return 'macOS ${_deviceInfoData['osRelease']}';
    } else if (isLinux) {
      return 'Linux ${_deviceInfoData['prettyName']}';
    } else if (isWeb) {
      return 'Web';
    }
    return 'Unknown';
  }

  // Get platform name
  String getPlatformName() {
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isWindows) return 'Windows';
    if (isMacOS) return 'macOS';
    if (isLinux) return 'Linux';
    if (isWeb) return 'Web';
    return 'Unknown';
  }

  // Check if device is tablet
  bool isTablet() {
    final context = _context;
    if (context == null) return false;

    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;
    return shortestSide > 600; // 600dp is typical tablet threshold
  }

  // Get device type (phone/tablet)
  String getDeviceType() {
    if (isTablet()) return 'tablet';
    return 'phone';
  }

  // Get screen size category
  String getScreenSizeCategory() {
    final context = _context;
    if (context == null) return 'unknown';

    final double width = MediaQuery.of(context).size.width;
    if (width < 360) return 'small';
    if (width < 600) return 'normal';
    if (width < 900) return 'large';
    return 'xlarge';
  }

  // Get screen density
  double getScreenDensity() {
    final context = _context;
    if (context == null) return 1.0;
    return MediaQuery.of(context).devicePixelRatio;
  }

  // Get app version info
  Future<Map<String, String>> getAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return {
        'appName': packageInfo.appName,
        'packageName': packageInfo.packageName,
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
        'buildSignature': packageInfo.buildSignature,
      };
    } catch (e) {
      _logger.error('Failed to get app info', error: e);
      return {};
    }
  }

  // Check if device is physical or emulator
  bool get isPhysicalDevice {
    if (isAndroid || isIOS) {
      return _deviceInfoData['isPhysicalDevice'] as bool? ?? false;
    }
    return true;
  }

  // Get all device info as formatted string
  String getDeviceInfoString() {
    final buffer = StringBuffer();
    buffer.writeln('Platform: ${getPlatformName()}');
    buffer.writeln('Device: ${getDeviceModel()}');
    buffer.writeln('OS: ${getOsVersion()}');
    buffer.writeln('Type: ${getDeviceType()}');
    buffer.writeln('Screen: ${getScreenSizeCategory()}');
    buffer.writeln('Density: ${getScreenDensity()}x');
    buffer.writeln('Physical Device: ${isPhysicalDevice ? 'Yes' : 'No'}');
    return buffer.toString();
  }

  // Check if initialized
  bool get isInitialized => _isInitialized;

  // Get browser name (for web)
  String getBrowserName() {
    if (!isWeb) return '';
    return _deviceInfoData['browserName'] as String? ?? 'Unknown';
  }

  // Get user agent (for web)
  String getUserAgent() {
    return _deviceInfoData['userAgent'] as String? ?? '';
  }

  // Get CPU info
  String? getCpuInfo() {
    if (isMacOS) {
      return _deviceInfoData['arch'] as String?;
    } else if (isAndroid) {
      final abis = _deviceInfoData['supportedAbis'] as List?;
      return abis?.join(', ');
    }
    return null;
  }

  // Get Windows registered owner
  String? getRegisteredOwner() {
    if (isWindows) {
      return _deviceInfoData['registeredOwner'] as String?;
    }
    return null;
  }
}