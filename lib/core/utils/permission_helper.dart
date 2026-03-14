import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  // Request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    final PermissionStatus status = await Permission.microphone.request();
    return status.isGranted;
  }

  // Request camera permission
  static Future<bool> requestCameraPermission() async {
    final PermissionStatus status = await Permission.camera.request();
    return status.isGranted;
  }

  // Request storage permission
  static Future<bool> requestStoragePermission() async {
    final PermissionStatus status = await Permission.storage.request();
    return status.isGranted;
  }

  // Request location permission
  static Future<bool> requestLocationPermission() async {
    final PermissionStatus status = await Permission.location.request();
    return status.isGranted;
  }

  // Request notification permission
  static Future<bool> requestNotificationPermission() async {
    final PermissionStatus status = await Permission.notification.request();
    return status.isGranted;
  }

  // Request multiple permissions
  static Future<Map<Permission, PermissionStatus>> requestMultiple(
    List<Permission> permissions,
  ) async {
    return permissions.request();
  }

  // Check if all permissions are granted
  static Future<bool> areAllGranted(List<Permission> permissions) async {
    final Map<Permission, PermissionStatus> statuses = await permissions.request();
    return statuses.values.every((PermissionStatus status) => status.isGranted);
  }

  // Open app settings
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  // Show permission dialog
  static Future<void> showPermissionDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
}