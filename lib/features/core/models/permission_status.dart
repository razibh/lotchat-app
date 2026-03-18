import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:provider/provider.dart';

class PermissionStatus extends ChangeNotifier {
  // Singleton pattern
  static final PermissionStatus _instance = PermissionStatus._internal();
  factory PermissionStatus() => _instance;
  PermissionStatus._internal();

  // Permission statuses
  bool _cameraGranted = false;
  bool _microphoneGranted = false;
  bool _storageGranted = false;
  bool _locationGranted = false;
  bool _contactsGranted = false;
  bool _phoneGranted = false;
  bool _smsGranted = false;
  bool _notificationGranted = false;
  bool _bluetoothGranted = false;
  bool _calendarGranted = false;
  bool _remindersGranted = false;
  bool _sensorsGranted = false;

  // Getters
  bool get cameraGranted => _cameraGranted;
  bool get microphoneGranted => _microphoneGranted;
  bool get storageGranted => _storageGranted;
  bool get locationGranted => _locationGranted;
  bool get contactsGranted => _contactsGranted;
  bool get phoneGranted => _phoneGranted;
  bool get smsGranted => _smsGranted;
  bool get notificationGranted => _notificationGranted;
  bool get bluetoothGranted => _bluetoothGranted;
  bool get calendarGranted => _calendarGranted;
  bool get remindersGranted => _remindersGranted;
  bool get sensorsGranted => _sensorsGranted;

  // Check if all required permissions are granted
  bool areAllGranted(List<ph.Permission> permissions) {
    for (var permission in permissions) {
      if (!_isPermissionGranted(permission)) return false;
    }
    return true;
  }

  // Check single permission
  bool _isPermissionGranted(ph.Permission permission) {
    if (permission == ph.Permission.camera) {
      return _cameraGranted;
    } else if (permission == ph.Permission.microphone) {
      return _microphoneGranted;
    } else if (permission == ph.Permission.storage) {
      return _storageGranted;
    } else if (permission == ph.Permission.location ||
        permission == ph.Permission.locationWhenInUse ||
        permission == ph.Permission.locationAlways) {
      return _locationGranted;
    } else if (permission == ph.Permission.contacts) {
      return _contactsGranted;
    } else if (permission == ph.Permission.phone) {
      return _phoneGranted;
    } else if (permission == ph.Permission.sms) {
      return _smsGranted;
    } else if (permission == ph.Permission.notification) {
      return _notificationGranted;
    } else if (permission == ph.Permission.bluetooth) {
      return _bluetoothGranted;
    } else if (permission == ph.Permission.calendar) {
      return _calendarGranted;
    } else if (permission == ph.Permission.reminders) {
      return _remindersGranted;
    } else if (permission == ph.Permission.sensors) {
      return _sensorsGranted;
    }
    return false;
  }

  // Update permission status
  void _updatePermissionStatus(ph.Permission permission, bool granted) {
    if (permission == ph.Permission.camera) {
      _cameraGranted = granted;
    } else if (permission == ph.Permission.microphone) {
      _microphoneGranted = granted;
    } else if (permission == ph.Permission.storage) {
      _storageGranted = granted;
    } else if (permission == ph.Permission.location ||
        permission == ph.Permission.locationWhenInUse ||
        permission == ph.Permission.locationAlways) {
      _locationGranted = granted;
    } else if (permission == ph.Permission.contacts) {
      _contactsGranted = granted;
    } else if (permission == ph.Permission.phone) {
      _phoneGranted = granted;
    } else if (permission == ph.Permission.sms) {
      _smsGranted = granted;
    } else if (permission == ph.Permission.notification) {
      _notificationGranted = granted;
    } else if (permission == ph.Permission.bluetooth) {
      _bluetoothGranted = granted;
    } else if (permission == ph.Permission.calendar) {
      _calendarGranted = granted;
    } else if (permission == ph.Permission.reminders) {
      _remindersGranted = granted;
    } else if (permission == ph.Permission.sensors) {
      _sensorsGranted = granted;
    }
    notifyListeners();
  }

  // Request single permission
  Future<bool> requestPermission(ph.Permission permission) async {
    final status = await permission.request();
    final granted = status.isGranted;
    _updatePermissionStatus(permission, granted);
    return granted;
  }

  // Request multiple permissions
  Future<Map<ph.Permission, ph.PermissionStatus>> requestPermissions(
      List<ph.Permission> permissions,
      ) async {
    final results = await permissions.request();

    for (var entry in results.entries) {
      _updatePermissionStatus(entry.key, entry.value.isGranted);
    }

    return results;
  }

  // Check permission status
  Future<bool> checkPermission(ph.Permission permission) async {
    final status = await permission.status;
    final granted = status.isGranted;
    _updatePermissionStatus(permission, granted);
    return granted;
  }

  // Check multiple permissions
  Future<Map<ph.Permission, ph.PermissionStatus>> checkPermissions(
      List<ph.Permission> permissions,
      ) async {
    final results = <ph.Permission, ph.PermissionStatus>{};

    for (var permission in permissions) {
      final status = await permission.status;
      results[permission] = status;
      _updatePermissionStatus(permission, status.isGranted);
    }

    return results;
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  // Check if permission is permanently denied
  Future<bool> isPermanentlyDenied(ph.Permission permission) async {
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }

  // Show permission dialog
  Future<bool> showPermissionDialog({
    required BuildContext context,
    required String title,
    required String message,
    required ph.Permission permission,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Allow'),
          ),
        ],
      ),
    );

    if (result == true) {
      return requestPermission(permission);
    }
    return false;
  }

  // Show settings dialog
  Future<void> showSettingsDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );

    if (result == true) {
      await openAppSettings();
    }
  }

  // Reset all permissions
  void reset() {
    _cameraGranted = false;
    _microphoneGranted = false;
    _storageGranted = false;
    _locationGranted = false;
    _contactsGranted = false;
    _phoneGranted = false;
    _smsGranted = false;
    _notificationGranted = false;
    _bluetoothGranted = false;
    _calendarGranted = false;
    _remindersGranted = false;
    _sensorsGranted = false;
    notifyListeners();
  }
}

// Permission Request Widget
class PermissionRequestWidget extends StatelessWidget {
  final ph.Permission permission;
  final String title;
  final String description;
  final String? deniedMessage;
  final String? permanentlyDeniedMessage;
  final Widget child;
  final VoidCallback? onGranted;
  final VoidCallback? onDenied;

  const PermissionRequestWidget({
    required this.permission,
    required this.title,
    required this.description,
    required this.child,
    this.deniedMessage,
    this.permanentlyDeniedMessage,
    this.onGranted,
    this.onDenied,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PermissionStatus>(
      builder: (context, permissionStatus, _) {
        return FutureBuilder<ph.PermissionStatus>(
          future: permission.status,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final status = snapshot.data!;

            if (status.isGranted) {
              return child;
            }

            return _buildPermissionRequest(context, permissionStatus, status);
          },
        );
      },
    );
  }

  Widget _buildPermissionRequest(
      BuildContext context,
      PermissionStatus permissionStatus,
      ph.PermissionStatus status,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getPermissionIcon(permission),
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            if (status.isPermanentlyDenied) ...[
              Text(
                permanentlyDeniedMessage ??
                    'Permission permanently denied. Please enable in settings.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final shouldOpen = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Open Settings'),
                      content: const Text(
                        'This permission is permanently denied. '
                            'Please enable it in app settings.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Open Settings'),
                        ),
                      ],
                    ),
                  );

                  if (shouldOpen == true) {
                    await permissionStatus.openAppSettings();
                  }
                },
                child: const Text('Open Settings'),
              ),
            ] else ...[
              Text(
                deniedMessage ?? 'Permission not granted',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.orange),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final granted = await permissionStatus.requestPermission(permission);
                  if (granted) {
                    onGranted?.call();
                  } else {
                    onDenied?.call();
                  }
                },
                child: const Text('Grant Permission'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getPermissionIcon(ph.Permission permission) {
    if (permission == ph.Permission.camera) {
      return Icons.camera_alt;
    } else if (permission == ph.Permission.microphone) {
      return Icons.mic;
    } else if (permission == ph.Permission.storage) {
      return Icons.storage;
    } else if (permission == ph.Permission.location ||
        permission == ph.Permission.locationWhenInUse ||
        permission == ph.Permission.locationAlways) {
      return Icons.location_on;
    } else if (permission == ph.Permission.contacts) {
      return Icons.contacts;
    } else if (permission == ph.Permission.phone) {
      return Icons.phone;
    } else if (permission == ph.Permission.sms) {
      return Icons.sms;
    } else if (permission == ph.Permission.notification) {
      return Icons.notifications;
    } else if (permission == ph.Permission.bluetooth) {
      return Icons.bluetooth;
    } else if (permission == ph.Permission.calendar) {
      return Icons.calendar_today;
    } else if (permission == ph.Permission.reminders) {
      return Icons.alarm;
    } else if (permission == ph.Permission.sensors) {
      return Icons.sensors;
    }
    return Icons.security;
  }
}

// Permission Checker Mixin
mixin PermissionMixin<T extends StatefulWidget> on State<T> {
  final PermissionStatus _permissionStatus = PermissionStatus();

  @override
  void dispose() {
    _permissionStatus.dispose();
    super.dispose();
  }

  // Check permission
  Future<bool> checkPermission(ph.Permission permission) {
    return _permissionStatus.checkPermission(permission);
  }

  // Request permission
  Future<bool> requestPermission(ph.Permission permission) {
    return _permissionStatus.requestPermission(permission);
  }

  // Request multiple permissions
  Future<Map<ph.Permission, ph.PermissionStatus>> requestPermissions(
      List<ph.Permission> permissions,
      ) {
    return _permissionStatus.requestPermissions(permissions);
  }

  // Show permission dialog
  Future<bool> showPermissionDialog({
    required String title,
    required String message,
    required ph.Permission permission,
  }) {
    return _permissionStatus.showPermissionDialog(
      context: context,
      title: title,
      message: message,
      permission: permission,
    );
  }

  // Show settings dialog
  Future<void> showSettingsDialog({
    required String title,
    required String message,
  }) {
    return _permissionStatus.showSettingsDialog(
      context: context,
      title: title,
      message: message,
    );
  }

  // Ensure permission before action
  Future<bool> ensurePermission(ph.Permission permission) async {
    if (await checkPermission(permission)) return true;

    final granted = await requestPermission(permission);
    if (!granted && mounted) {
      if (await _permissionStatus.isPermanentlyDenied(permission)) {
        await showSettingsDialog(
          title: 'Permission Required',
          message: 'This permission is required for this feature. '
              'Please enable it in settings.',
        );
      }
    }
    return granted;
  }

  // Execute action with permission check
  Future<void> withPermissionCheck(
      ph.Permission permission,
      Future<void> Function() action,
      ) async {
    if (await ensurePermission(permission)) {
      await action();
    }
  }
}

// Permission List Widget
class PermissionListWidget extends StatelessWidget {
  final List<PermissionItem> permissions;
  final VoidCallback? onComplete;

  const PermissionListWidget({
    required this.permissions,
    this.onComplete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PermissionStatus>(
      builder: (context, permissionStatus, child) {
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: permissions.length,
                itemBuilder: (context, index) {
                  final item = permissions[index];
                  return FutureBuilder<ph.PermissionStatus>(
                    future: item.permission.status,
                    builder: (context, snapshot) {
                      final status = snapshot.data;
                      final isGranted = status?.isGranted ?? false;
                      final isPermanentlyDenied = status?.isPermanentlyDenied ?? false;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Icon(
                            item.icon,
                            color: isGranted
                                ? Colors.green
                                : isPermanentlyDenied
                                ? Colors.red
                                : Colors.orange,
                          ),
                          title: Text(item.title),
                          subtitle: Text(item.description),
                          trailing: isGranted
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : ElevatedButton(
                            onPressed: () async {
                              await permissionStatus.requestPermission(item.permission);
                              if (permissionStatus.areAllGranted(
                                permissions.map((p) => p.permission).toList(),
                              )) {
                                onComplete?.call();
                              }
                            },
                            child: const Text('Allow'),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (permissionStatus.areAllGranted(
              permissions.map((p) => p.permission).toList(),
            ))
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: onComplete,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Continue'),
                ),
              ),
          ],
        );
      },
    );
  }
}

class PermissionItem {
  final ph.Permission permission;
  final String title;
  final String description;
  final IconData icon;

  PermissionItem({
    required this.permission,
    required this.title,
    required this.description,
    required this.icon,
  });
}