import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/logger_service.dart';

class AppInfoService {
  factory AppInfoService() => _instance;
  AppInfoService._internal();
  static final AppInfoService _instance = AppInfoService._internal();

  final LoggerService _logger = ServiceLocator().get<LoggerService>();
  
  PackageInfo? _packageInfo;
  bool _isInitialized = false;

  // App Info
  String? get appName => _packageInfo?.appName;
  String? get packageName => _packageInfo?.packageName;
  String? get version => _packageInfo?.version;
  String? get buildNumber => _packageInfo?.buildNumber;
  bool get isInitialized => _isInitialized;

  // Initialize
  Future<void> initialize() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      _isInitialized = true;
      _logger.info('App info loaded: ${_packageInfo?.appName} v${_packageInfo?.version}');
    } catch (e) {
      _logger.error('Failed to load app info', error: e);
    }
  }

  // Get app info map
  Map<String, String> getAppInfo() {
    return <String, String>{
      'appName': appName ?? 'Unknown',
      'packageName': packageName ?? 'Unknown',
      'version': version ?? 'Unknown',
      'buildNumber': buildNumber ?? 'Unknown',
    };
  }

  // Check if app is up to date
  Future<bool> isUpToDate(String minimumVersion) async {
    if (version == null) return true;
    
    try {
      final List<int> currentParts = version!.split('.').map(int.parse).toList();
      final List<int> minimumParts = minimumVersion.split('.').map(int.parse).toList();
      
      for (var i = 0; i < currentParts.length; i++) {
        if (i >= minimumParts.length) return true;
        if (currentParts[i] > minimumParts[i]) return true;
        if (currentParts[i] < minimumParts[i]) return false;
      }
      return true;
    } catch (e) {
      _logger.error('Failed to compare versions', error: e);
      return true;
    }
  }

  // Get version string for display
  String getVersionString({bool includeBuildNumber = false}) {
    if (version == null) return 'Unknown';
    if (includeBuildNumber && buildNumber != null) {
      return '$version (build $buildNumber)';
    }
    return version!;
  }

  // Get app name with version
  String getAppNameWithVersion() {
    return '$appName v$version';
  }
}