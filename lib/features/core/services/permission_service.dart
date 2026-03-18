import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import '../../../core/di/service_locator.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/navigation_service.dart';

enum PermissionType {
  camera,
  microphone,
  storage,
  location,
  contacts,
  notifications,
  photos,
  calendar,
  reminders,
  bluetooth,
}

class PermissionService {
  factory PermissionService() => _instance;
  PermissionService._internal();
  static final PermissionService _instance = PermissionService._internal();

  final LoggerService _logger = ServiceLocator().get<LoggerService>();

  final Map<PermissionType, ph.PermissionStatus> _cachedStatus = {};

  // Get current context from NavigationService
  BuildContext? get _context => NavigationService.navigatorKey.currentContext;

  // Check permission
  Future<ph.PermissionStatus> checkPermission(PermissionType type) async {
    final ph.Permission permission = _getPermission(type);
    final ph.PermissionStatus status = await permission.status;
    _cachedStatus[type] = status;
    return status;
  }

  // Request permission
  Future<ph.PermissionStatus> requestPermission(PermissionType type) async {
    try {
      final ph.Permission permission = _getPermission(type);
      final ph.PermissionStatus status = await permission.request();
      _cachedStatus[type] = status;
      _logger.info('Permission $type requested, status: ${status.toString()}');
      return status;
    } catch (e) {
      _logger.error('Failed to request permission $type', error: e);
      return ph.PermissionStatus.denied;
    }
  }

  // Request multiple permissions
  Future<Map<PermissionType, ph.PermissionStatus>> requestPermissions(
      List<PermissionType> types,
      ) async {
    try {
      final List<ph.Permission> permissions = types.map(_getPermission).toList();
      final Map<ph.Permission, ph.PermissionStatus> statuses = await permissions.request();

      final result = <PermissionType, ph.PermissionStatus>{};
      for (var i = 0; i < types.length; i++) {
        final PermissionType type = types[i];
        final ph.PermissionStatus? status = statuses[permissions[i]];
        if (status != null) {
          result[type] = status;
          _cachedStatus[type] = status;
        }
      }

      return result;
    } catch (e) {
      _logger.error('Failed to request permissions', error: e);
      return {};
    }
  }

  // Check if permission is granted
  Future<bool> isPermissionGranted(PermissionType type) async {
    final ph.PermissionStatus status = await checkPermission(type);
    return status.isGranted;
  }

  // Check if all permissions are granted
  Future<bool> areAllGranted(List<PermissionType> types) async {
    for (final type in types) {
      if (!await isPermissionGranted(type)) {
        return false;
      }
    }
    return true;
  }

  // Check if permission is permanently denied
  Future<bool> isPermanentlyDenied(PermissionType type) async {
    final ph.Permission permission = _getPermission(type);
    final ph.PermissionStatus status = await permission.status;
    return status.isPermanentlyDenied;
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  // Show permission dialog
  Future<bool> showPermissionDialog(
      BuildContext context,
      PermissionType type, {
        String? title,
        String? message,
      }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title ?? 'Permission Required'),
        content: Text(message ?? 'This feature requires ${type.toString().split('.').last} permission.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Grant'),
          ),
        ],
      ),
    );

    if (result ?? false) {
      final ph.PermissionStatus status = await requestPermission(type);
      return status.isGranted;
    }
    return false;
  }

  // Show settings dialog (for permanently denied)
  Future<void> showSettingsDialog(
      BuildContext context,
      PermissionType type, {
        String? title,
        String? message,
      }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title ?? 'Permission Required'),
        content: Text(message ?? 'This permission is permanently denied. Please enable it in settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );

    if (result ?? false) {
      await openAppSettings();
    }
  }

  // Get cached status
  ph.PermissionStatus? getCachedStatus(PermissionType type) {
    return _cachedStatus[type];
  }

  // Get permission status text
  String getStatusText(ph.PermissionStatus status) {
    if (status.isGranted) return 'Granted';
    if (status.isPermanentlyDenied) return 'Permanently Denied';
    if (status.isDenied) return 'Denied';
    if (status.isRestricted) return 'Restricted';
    if (status.isLimited) return 'Limited';
    return 'Unknown';
  }

  // Get permission status color
  Color getStatusColor(ph.PermissionStatus status) {
    if (status.isGranted) return Colors.green;
    if (status.isPermanentlyDenied) return Colors.red;
    if (status.isDenied) return Colors.orange;
    return Colors.grey;
  }

  // Get permission by type
  ph.Permission _getPermission(PermissionType type) {
    switch (type) {
      case PermissionType.camera:
        return ph.Permission.camera;
      case PermissionType.microphone:
        return ph.Permission.microphone;
      case PermissionType.storage:
        return ph.Permission.storage;
      case PermissionType.location:
        return ph.Permission.location;
      case PermissionType.contacts:
        return ph.Permission.contacts;
      case PermissionType.notifications:
        return ph.Permission.notification;
      case PermissionType.photos:
        final context = _context;
        if (context != null && Theme.of(context).platform == TargetPlatform.iOS) {
          return ph.Permission.photos;
        }
        return ph.Permission.storage;
      case PermissionType.calendar:
        return ph.Permission.calendar;
      case PermissionType.reminders:
        return ph.Permission.reminders;
      case PermissionType.bluetooth:
        return ph.Permission.bluetooth;
    }
  }

  // Reset cached permissions
  void resetCache() {
    _cachedStatus.clear();
  }
}