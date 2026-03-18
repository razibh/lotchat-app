import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart'; // 🟢 debugPrint এর জন্য

class PermissionHelper {
  // Request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    try {
      final PermissionStatus status = await Permission.microphone.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting microphone permission: $e');
      return false;
    }
  }

  // Request camera permission
  static Future<bool> requestCameraPermission() async {
    try {
      final PermissionStatus status = await Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting camera permission: $e');
      return false;
    }
  }

  // Request storage permission (for Android)
  static Future<bool> requestStoragePermission() async {
    try {
      final PermissionStatus status = await Permission.storage.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
      return false;
    }
  }

  // Request photos permission (for iOS 14+)
  static Future<bool> requestPhotosPermission() async {
    try {
      final PermissionStatus status = await Permission.photos.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting photos permission: $e');
      return false;
    }
  }

  // Request location permission
  static Future<bool> requestLocationPermission() async {
    try {
      final PermissionStatus status = await Permission.location.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }

  // Request location when in use
  static Future<bool> requestLocationWhenInUsePermission() async {
    try {
      final PermissionStatus status = await Permission.locationWhenInUse.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting location when in use permission: $e');
      return false;
    }
  }

  // Request notification permission
  static Future<bool> requestNotificationPermission() async {
    try {
      final PermissionStatus status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  // Request contacts permission
  static Future<bool> requestContactsPermission() async {
    try {
      final PermissionStatus status = await Permission.contacts.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting contacts permission: $e');
      return false;
    }
  }

  // Request calendar permission
  static Future<bool> requestCalendarPermission() async {
    try {
      final PermissionStatus status = await Permission.calendar.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting calendar permission: $e');
      return false;
    }
  }

  // Request reminders permission (iOS only)
  static Future<bool> requestRemindersPermission() async {
    try {
      final PermissionStatus status = await Permission.reminders.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting reminders permission: $e');
      return false;
    }
  }

  // Request bluetooth permission
  static Future<bool> requestBluetoothPermission() async {
    try {
      final PermissionStatus status = await Permission.bluetooth.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting bluetooth permission: $e');
      return false;
    }
  }

  // Request phone permission
  static Future<bool> requestPhonePermission() async {
    try {
      final PermissionStatus status = await Permission.phone.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting phone permission: $e');
      return false;
    }
  }

  // Request SMS permission
  static Future<bool> requestSmsPermission() async {
    try {
      final PermissionStatus status = await Permission.sms.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting SMS permission: $e');
      return false;
    }
  }

  // Request multiple permissions
  static Future<Map<Permission, PermissionStatus>> requestMultiple(
      List<Permission> permissions,
      ) async {
    try {
      return await permissions.request();
    } catch (e) {
      debugPrint('Error requesting multiple permissions: $e');
      return {};
    }
  }

  // Check if all permissions are granted
  static Future<bool> areAllGranted(List<Permission> permissions) async {
    try {
      final statuses = await permissions.request();
      return statuses.values.every((status) => status.isGranted);
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      return false;
    }
  }

  // Check if any permission is denied
  static Future<bool> isAnyDenied(List<Permission> permissions) async {
    try {
      final statuses = await permissions.request();
      return statuses.values.any((status) => status.isDenied);
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      return true;
    }
  }

  // Check if any permission is permanently denied
  static Future<bool> isAnyPermanentlyDenied(List<Permission> permissions) async {
    try {
      final statuses = await permissions.request();
      return statuses.values.any((status) => status.isPermanentlyDenied);
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      return false;
    }
  }

  // Get permission status
  static Future<PermissionStatus> getPermissionStatus(Permission permission) async {
    try {
      return await permission.status;
    } catch (e) {
      debugPrint('Error getting permission status: $e');
      return PermissionStatus.denied;
    }
  }

  // 🟢 Fix: Open app settings
  static Future<void> openAppSettings() async {
    try {
      await openAppSettings(); // This is a top-level function
    } catch (e) {
      debugPrint('Error opening app settings: $e');
    }
  }

  // 🟢 Fix: Show permission dialog
  static Future<void> showPermissionDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    await showDialog(
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
              PermissionHelper.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // Show permission rationale (educational dialog)
  static Future<void> showPermissionRationale({
    required BuildContext context,
    required String title,
    required String message,
    required Permission permission,
  }) async {
    final bool shouldShowRationale = await permission.shouldShowRequestRationale;

    if (shouldShowRationale) {
      await showPermissionDialog(
        context: context,
        title: title,
        message: message,
      );
    }
  }

  // Handle permission result with custom logic
  static Future<bool> handlePermissionResult({
    required BuildContext context,
    required Permission permission,
    required String deniedMessage,
    required String permanentlyDeniedMessage,
  }) async {
    try {
      final status = await permission.status;

      if (status.isGranted) {
        return true;
      } else if (status.isDenied) {
        // Show denied message and request again
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(deniedMessage)),
          );
        }
        final newStatus = await permission.request();
        return newStatus.isGranted;
      } else if (status.isPermanentlyDenied) {
        // Show permanently denied message and open settings
        await showPermissionDialog(
          context: context,
          title: 'Permission Required',
          message: permanentlyDeniedMessage,
        );
        return false;
      }
      return false;
    } catch (e) {
      debugPrint('Error handling permission result: $e');
      return false;
    }
  }
}