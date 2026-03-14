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
        actions: <>[
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

  // Storage permission
  Future<bool> requestStoragePermission() {
    return requestPermission(Permission.storage);
  }

  // Location permission
  Future<bool> requestLocationPermission() {
    return requestPermission(Permission.location);
  }
}