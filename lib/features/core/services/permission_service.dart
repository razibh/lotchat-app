import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/logger_service.dart';

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
  
  final Map<PermissionType, PermissionStatus> _cachedStatus = <PermissionType, >{};

  // Check permission
  Future<PermissionStatus> checkPermission(PermissionType type) async {
    final Permission permission = _getPermission(type);
    final PermissionStatus status = await permission.status;
    _cachedStatus[type] = status;
    return status;
  }

  // Request permission
  Future<PermissionStatus> requestPermission(PermissionType type) async {
    try {
      final Permission permission = _getPermission(type);
      final PermissionStatus status = await permission.request();
      _cachedStatus[type] = status;
      _logger.info('Permission $type requested, status: $status');
      return status;
    } catch (e) {
      _logger.error('Failed to request permission $type', error: e);
      return PermissionStatus.denied;
    }
  }

  // Request multiple permissions
  Future<Map<PermissionType, PermissionStatus>> requestPermissions(
    List<PermissionType> types,
  ) async {
    try {
      final List<Permission> permissions = types.map(_getPermission).toList();
      final Map<Permission, PermissionStatus> statuses = await permissions.request();
      
      final Map<PermissionType, PermissionStatus> result = <PermissionType, PermissionStatus>{};
      for (var i = 0; i < types.length; i++) {
        final PermissionType type = types[i];
        final PermissionStatus? status = statuses[permissions[i]];
        if (status != null) {
          result[type] = status;
          _cachedStatus[type] = status;
        }
      }
      
      return result;
    } catch (e) {
      _logger.error('Failed to request permissions', error: e);
      return <PermissionType, >{};
    }
  }

  // Check if permission is granted
  Future<bool> isPermissionGranted(PermissionType type) async {
    final PermissionStatus status = await checkPermission(type);
    return status.isGranted;
  }

  // Check if all permissions are granted
  Future<bool> areAllGranted(List<PermissionType> types) async {
    for (PermissionType type in types) {
      if (!await isPermissionGranted(type)) {
        return false;
      }
    }
    return true;
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await openAppSettings();
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
      final PermissionStatus status = await requestPermission(type);
      return status.isGranted;
    }
    return false;
  }

  // Get cached status
  PermissionStatus? getCachedStatus(PermissionType type) {
    return _cachedStatus[type];
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

  BuildContext? _getContext() {
    // This would need navigation service
    return null;
  }
}