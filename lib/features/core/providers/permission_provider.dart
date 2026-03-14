import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/di/service_locator.dart';

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
  
  final Map<PermissionType, PermissionStatus> _permissionStatus = <PermissionType, >{};
  bool _isLoading = false;

  Map<PermissionType, PermissionStatus> get permissionStatus => _permissionStatus;
  bool get isLoading => _isLoading;

  // Check single permission
  Future<bool> checkPermission(PermissionType type) async {
    final Permission permission = _getPermission(type);
    final PermissionStatus status = await permission.status;
    _updateStatus(type, status);
    return status.isGranted;
  }

  // Request single permission
  Future<bool> requestPermission(PermissionType type) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Permission permission = _getPermission(type);
      final PermissionStatus status = await permission.request();
      _updateStatus(type, status);
      
      _logger.info('Permission $type requested, status: $status');
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
      final List<Permission> permissions = types.map(_getPermission).toList();
      final Map<Permission, PermissionStatus> statuses = await permissions.request();
      
      final Map<PermissionType, bool> result = <PermissionType, bool>{};
      for (var i = 0; i < types.length; i++) {
        final PermissionType type = types[i];
        final PermissionStatus? status = statuses[permissions[i]];
        if (status != null) {
          _updateStatus(type, status);
          result[type] = status.isGranted;
        }
      }
      
      return result;
    } catch (e) {
      _logger.error('Failed to request permissions', error: e);
      return <PermissionType, bool>{};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  // Show permission dialog
  Future<void> showPermissionDialog(
    BuildContext context,
    PermissionType type,
    {String? title, String? message,}
  ) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title ?? 'Permission Required'),
        content: Text(message ?? 'This feature requires ${type.toString().split('.').last} permission.'),
        actions: <>[
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

  // Check if all permissions are granted
  bool areAllGranted(List<PermissionType> types) {
    for (PermissionType type in types) {
      final PermissionStatus? status = _permissionStatus[type];
      if (status == null || !status.isGranted) {
        return false;
      }
    }
    return true;
  }

  // Get permission by type
  Permission _getPermission(PermissionType type) {
    switch (type) {
      case PermissionType.camera:
        return Permission.camera;
      case PermissionType.microphone:
        return Permission.microphone;
      case PermissionType.storage:
        return Permission.storage;
      case PermissionType.location:
        return Permission.location;
      case PermissionType.contacts:
        return Permission.contacts;
      case PermissionType.notifications:
        return Permission.notification;
      case PermissionType.photos:
        if (Theme.of(_getContext()).platform == TargetPlatform.iOS) {
          return Permission.photos;
        }
        return Permission.storage;
      case PermissionType.calendar:
        return Permission.calendar;
      case PermissionType.reminders:
        return Permission.reminders;
      case PermissionType.bluetooth:
        return Permission.bluetooth;
    }
  }

  void _updateStatus(PermissionType type, PermissionStatus status) {
    _permissionStatus[type] = status;
  }

  BuildContext? _getContext() {
    // This would need navigation service
    return null;
  }
}