import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  static Future<File?> pickImageFromGallery() async {
    try {
      // Check permission (for Android 13+)
      PermissionStatus status;

      if (await Permission.photos.isGranted) {
        status = PermissionStatus.granted;
      } else {
        status = await Permission.photos.request();
      }

      if (!status.isGranted) {
        throw Exception('Permission denied');
      }

      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
    return null;
  }

  // Pick image from camera
  static Future<File?> pickImageFromCamera() async {
    try {
      // Check camera permission
      PermissionStatus status;

      if (await Permission.camera.isGranted) {
        status = PermissionStatus.granted;
      } else {
        status = await Permission.camera.request();
      }

      if (!status.isGranted) {
        throw Exception('Camera permission denied');
      }

      final image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
    }
    return null;
  }

  // Pick video from gallery
  static Future<File?> pickVideoFromGallery() async {
    try {
      // Check storage permission
      if (await Permission.photos.isDenied) {
        final PermissionStatus status = await Permission.photos.request();
        if (!status.isGranted) {
          throw Exception('Permission denied');
        }
      }

      final video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        return File(video.path);
      }
    } catch (e) {
      debugPrint('Error picking video: $e');
    }
    return null;
  }

  // Pick multiple images
  static Future<List<File>> pickMultipleImages() async {
    try {
      // Check permission
      if (await Permission.photos.isDenied) {
        final PermissionStatus status = await Permission.photos.request();
        if (!status.isGranted) {
          throw Exception('Permission denied');
        }
      }

      final images = await _picker.pickMultiImage(
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      return images.map((XFile image) => File(image.path)).toList();
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return <File>[];
    }
  }

  // Show image picker dialog
  static Future<File?> showImagePickerDialog(BuildContext context) async {
    final File? result = await showDialog<File?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context); // Close dialog
                  final File? file = await pickImageFromGallery();
                  if (context.mounted) {
                    Navigator.pop(context, file);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context); // Close dialog
                  final File? file = await pickImageFromCamera();
                  if (context.mounted) {
                    Navigator.pop(context, file);
                  }
                },
              ),
            ],
          ),
        );
      },
    );

    return result;
  }

  // Check and request permissions
  static Future<bool> checkAndRequestPermission(Permission permission) async {
    final PermissionStatus status = await permission.status;

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      final PermissionStatus result = await permission.request();
      return result.isGranted;
    } else if (status.isPermanentlyDenied) {
      // Open app settings
      await openAppSettings();
      return false;
    }

    return false;
  }

  // Clear temporary files (optional)
  static Future<void> clearTempFiles() async {
    try {
      final Directory tempDir = Directory.systemTemp;
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Error clearing temp files: $e');
    }
  }
}