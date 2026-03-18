import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

mixin PermissionMixin {
  // Request single permission
  Future<bool> requestPermission(Permission permission) async {
    final PermissionStatus status = await permission.request();
    return status.isGranted;
  }

  // Request multiple permissions
  Future<Map<Permission, PermissionStatus>> requestPermissions(
      List<Permission> permissions,
      ) async {
    return permissions.request();
  }

  // Check if permission is granted
  Future<bool> isPermissionGranted(Permission permission) async {
    final PermissionStatus status = await permission.status;
    return status.isGranted;
  }

  // Check if all permissions are granted
  Future<bool> areAllPermissionsGranted(List<Permission> permissions) async {
    for (final Permission permission in permissions) {
      if (!await isPermissionGranted(permission)) {
        return false;
      }
    }
    return true;
  }

  // Show permission dialog
  Future<void> showPermissionDialog(
      BuildContext context,
      String title,
      String message,
      ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // Camera permission
  Future<bool> requestCameraPermission() {
    return requestPermission(Permission.camera);
  }

  // Microphone permission
  Future<bool> requestMicrophonePermission() {
    return requestPermission(Permission.microphone);
  }

  // Storage permission (for Android)
  Future<bool> requestStoragePermission() {
    return requestPermission(Permission.storage);
  }

  // Location permission
  Future<bool> requestLocationPermission() {
    return requestPermission(Permission.location);
  }

  // Photos permission (for iOS 14+)
  Future<bool> requestPhotosPermission() {
    return requestPermission(Permission.photos);
  }

  // Notifications permission
  Future<bool> requestNotificationPermission() {
    return requestPermission(Permission.notification);
  }

  // Contacts permission
  Future<bool> requestContactsPermission() {
    return requestPermission(Permission.contacts);
  }

  // Calendar permission
  Future<bool> requestCalendarPermission() {
    return requestPermission(Permission.calendar);
  }

  // Reminders permission (iOS only)
  Future<bool> requestRemindersPermission() {
    return requestPermission(Permission.reminders);
  }

  // Bluetooth permission
  Future<bool> requestBluetoothPermission() {
    return requestPermission(Permission.bluetooth);
  }

  // Check permission status with more details
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    return await permission.status;
  }

  // Show rationale for permission (useful for educational purposes)
  Future<void> showPermissionRationale(
      BuildContext context,
      String title,
      String message,
      Permission permission,
      ) async {
    final bool shouldShowRationale = await permission.shouldShowRequestRationale;

    if (shouldShowRationale) {
      await showPermissionDialog(
        context,
        title,
        message,
      );
    }
  }

  // Handle permission result with custom logic
  Future<bool> handlePermissionResult(
      Permission permission,
      PermissionStatus status, {
        required BuildContext context,
        required String deniedMessage,
        required String permanentlyDeniedMessage,
      }) async {
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      // Show denied message and request again
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(deniedMessage)),
      );
      final newStatus = await permission.request();
      return newStatus.isGranted;
    } else if (status.isPermanentlyDenied) {
      // Show permanently denied message and open settings
      await showPermissionDialog(
        context,
        'Permission Required',
        permanentlyDeniedMessage,
      );
      return false;
    }
    return false;
  }
}