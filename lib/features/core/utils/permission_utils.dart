import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/permission_service.dart';
import '../../../core/di/service_locator.dart';

class PermissionUtils {
  static final PermissionService _permissionService = 
      ServiceLocator().get<PermissionService>();

  // Camera permission
  static Future<bool> requestCameraPermission() async {
    final PermissionStatus status = await _permissionService.requestPermission(PermissionType.camera);
    return status.isGranted;
  }

  static Future<bool> checkCameraPermission() async {
    final PermissionStatus status = await _permissionService.checkPermission(PermissionType.camera);
    return status.isGranted;
  }

  // Microphone permission
  static Future<bool> requestMicrophonePermission() async {
    final PermissionStatus status = await _permissionService.requestPermission(PermissionType.microphone);
    return status.isGranted;
  }

  static Future<bool> checkMicrophonePermission() async {
    final PermissionStatus status = await _permissionService.checkPermission(PermissionType.microphone);
    return status.isGranted;
  }

  // Storage permission
  static Future<bool> requestStoragePermission() async {
    final PermissionStatus status = await _permissionService.requestPermission(PermissionType.storage);
    return status.isGranted;
  }

  static Future<bool> checkStoragePermission() async {
    final PermissionStatus status = await _permissionService.checkPermission(PermissionType.storage);
    return status.isGranted;
  }

  // Location permission
  static Future<bool> requestLocationPermission() async {
    final PermissionStatus status = await _permissionService.requestPermission(PermissionType.location);
    return status.isGranted;
  }

  static Future<bool> checkLocationPermission() async {
    final PermissionStatus status = await _permissionService.checkPermission(PermissionType.location);
    return status.isGranted;
  }

  // Contacts permission
  static Future<bool> requestContactsPermission() async {
    final PermissionStatus status = await _permissionService.requestPermission(PermissionType.contacts);
    return status.isGranted;
  }

  static Future<bool> checkContactsPermission() async {
    final PermissionStatus status = await _permissionService.checkPermission(PermissionType.contacts);
    return status.isGranted;
  }

  // Notifications permission
  static Future<bool> requestNotificationsPermission() async {
    final PermissionStatus status = await _permissionService.requestPermission(PermissionType.notifications);
    return status.isGranted;
  }

  static Future<bool> checkNotificationsPermission() async {
    final PermissionStatus status = await _permissionService.checkPermission(PermissionType.notifications);
    return status.isGranted;
  }

  // Photos permission (iOS specific)
  static Future<bool> requestPhotosPermission() async {
    final PermissionStatus status = await _permissionService.requestPermission(PermissionType.photos);
    return status.isGranted;
  }

  static Future<bool> checkPhotosPermission() async {
    final PermissionStatus status = await _permissionService.checkPermission(PermissionType.photos);
    return status.isGranted;
  }

  // Request multiple permissions
  static Future<Map<PermissionType, bool>> requestPermissions(
    List<PermissionType> types,
  ) async {
    final Map<PermissionType, PermissionStatus> statuses = await _permissionService.requestPermissions(types);
    return statuses.map((PermissionType key, PermissionStatus value) => MapEntry(key, value.isGranted));
  }

  // Check if all permissions are granted
  static Future<bool> areAllGranted(List<PermissionType> types) async {
    return _permissionService.areAllGranted(types);
  }

  // Show permission dialog
  static Future<bool> showPermissionDialog(
    BuildContext context,
    PermissionType type, {
    String? title,
    String? message,
  }) async {
    return _permissionService.showPermissionDialog(
      context,
      type,
      title: title,
      message: message,
    );
  }

  // Get permission name
  static String getPermissionName(PermissionType type) {
    switch (type) {
      case PermissionType.camera:
        return 'Camera';
      case PermissionType.microphone:
        return 'Microphone';
      case PermissionType.storage:
        return 'Storage';
      case PermissionType.location:
        return 'Location';
      case PermissionType.contacts:
        return 'Contacts';
      case PermissionType.notifications:
        return 'Notifications';
      case PermissionType.photos:
        return 'Photos';
      case PermissionType.calendar:
        return 'Calendar';
      case PermissionType.reminders:
        return 'Reminders';
      case PermissionType.bluetooth:
        return 'Bluetooth';
    }
  }

  // Get permission icon
  static IconData getPermissionIcon(PermissionType type) {
    switch (type) {
      case PermissionType.camera:
        return Icons.camera_alt;
      case PermissionType.microphone:
        return Icons.mic;
      case PermissionType.storage:
        return Icons.storage;
      case PermissionType.location:
        return Icons.location_on;
      case PermissionType.contacts:
        return Icons.contacts;
      case PermissionType.notifications:
        return Icons.notifications;
      case PermissionType.photos:
        return Icons.photo;
      case PermissionType.calendar:
        return Icons.calendar_today;
      case PermissionType.reminders:
        return Icons.alarm;
      case PermissionType.bluetooth:
        return Icons.bluetooth;
    }
  }

  // Get permission description
  static String getPermissionDescription(PermissionType type) {
    switch (type) {
      case PermissionType.camera:
        return 'Allow access to your camera to take photos and videos';
      case PermissionType.microphone:
        return 'Allow access to your microphone for voice calls and recordings';
      case PermissionType.storage:
        return 'Allow access to your storage to save and share files';
      case PermissionType.location:
        return 'Allow access to your location to find nearby users';
      case PermissionType.contacts:
        return 'Allow access to your contacts to find friends';
      case PermissionType.notifications:
        return 'Allow notifications to stay updated';
      case PermissionType.photos:
        return 'Allow access to your photos to share images';
      case PermissionType.calendar:
        return 'Allow access to your calendar for events';
      case PermissionType.reminders:
        return 'Allow access to your reminders';
      case PermissionType.bluetooth:
        return 'Allow bluetooth access for nearby connections';
    }
  }
}