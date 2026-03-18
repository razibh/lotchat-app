import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import '../../../core/services/logger_service.dart';
import '../../../core/di/service_locator.dart';
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

class PermissionProvider extends ChangeNotifier {
  final LoggerService _logger = ServiceLocator().get<LoggerService>();

  final Map<PermissionType, ph.PermissionStatus> _permissionStatus = {};
  bool _isLoading = false;

  Map<PermissionType, ph.PermissionStatus> get permissionStatus => _permissionStatus;
  bool get isLoading => _isLoading;

  // Get current context from NavigationService (static access)
  BuildContext? _getContext() {
    return NavigationService.navigatorKey.currentContext;
  }

  // Check single permission
  Future<bool> checkPermission(PermissionType type) async {
    final ph.Permission permission = _getPermission(type);
    final ph.PermissionStatus status = await permission.status;
    _updateStatus(type, status);
    return status.isGranted;
  }

  // Request single permission
  Future<bool> requestPermission(PermissionType type) async {
    _isLoading = true;
    notifyListeners();

    try {
      final ph.Permission permission = _getPermission(type);
      final ph.PermissionStatus status = await permission.request();
      _updateStatus(type, status);

      _logger.info('Permission $type requested, status: ${status.toString()}');
      return status.isGranted;
    } catch (e) {
      _logger.error('Failed to request permission $type', error: e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Request multiple permissions
  Future<Map<PermissionType, bool>> requestPermissions(List<PermissionType> types) async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<ph.Permission> permissions = types.map(_getPermission).toList();
      final Map<ph.Permission, ph.PermissionStatus> statuses = await permissions.request();

      final result = <PermissionType, bool>{};
      for (var i = 0; i < types.length; i++) {
        final PermissionType type = types[i];
        final ph.PermissionStatus? status = statuses[permissions[i]];
        if (status != null) {
          _updateStatus(type, status);
          result[type] = status.isGranted;
        }
      }

      return result;
    } catch (e) {
      _logger.error('Failed to request permissions', error: e);
      return {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  // Show permission dialog
  Future<void> showPermissionDialog(
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
      await requestPermission(type);
    }
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

  // Check if all permissions are granted
  bool areAllGranted(List<PermissionType> types) {
    for (PermissionType type in types) {
      final ph.PermissionStatus? status = _permissionStatus[type];
      if (status == null || !status.isGranted) {
        return false;
      }
    }
    return true;
  }

  // Check if any permission is permanently denied
  Future<bool> isPermanentlyDenied(PermissionType type) async {
    final ph.Permission permission = _getPermission(type);
    final ph.PermissionStatus status = await permission.status;
    return status.isPermanentlyDenied;
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
      // For iOS, use photos permission, for Android use storage
        final context = _getContext();
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

  void _updateStatus(PermissionType type, ph.PermissionStatus status) {
    _permissionStatus[type] = status;
    notifyListeners();
  }

  // Get permission status text
  String getStatusText(PermissionType type) {
    final status = _permissionStatus[type];
    if (status == null) return 'Unknown';
    if (status.isGranted) return 'Granted';
    if (status.isPermanentlyDenied) return 'Permanently Denied';
    if (status.isDenied) return 'Denied';
    if (status.isRestricted) return 'Restricted';
    if (status.isLimited) return 'Limited';
    return 'Unknown';
  }

  // Get permission status color
  Color getStatusColor(PermissionType type) {
    final status = _permissionStatus[type];
    if (status == null) return Colors.grey;
    if (status.isGranted) return Colors.green;
    if (status.isPermanentlyDenied) return Colors.red;
    if (status.isDenied) return Colors.orange;
    return Colors.grey;
  }

  // Reset all permissions
  void reset() {
    _permissionStatus.clear();
    notifyListeners();
  }
}