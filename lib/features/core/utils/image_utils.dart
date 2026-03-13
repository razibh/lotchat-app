import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/logger_service.dart';

class ImageUtils {
  static final LoggerService _logger = ServiceLocator().get<LoggerService>();

  // Pick image from gallery
  static Future<File?> pickImageFromGallery({
    double? maxWidth,
    double? maxHeight,
    int? quality,
  }) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: quality ?? 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      _logger.error('Error picking image from gallery', error: e);
      return null;
    }
  }

  // Pick image from camera
  static Future<File?> pickImageFromCamera({
    double? maxWidth,
    double? maxHeight,
    int? quality,
  }) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: quality ?? 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      _logger.error('Error picking image from camera', error: e);
      return null;
    }
  }

  // Pick multiple images
  static Future<List<File>> pickMultipleImages({
    double? maxWidth,
    double? maxHeight,
    int? quality,
  }) async {
    try {
      final picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: quality ?? 85,
      );
      
      return images.map((Object? image) => File(image.path)).toList();
    } catch (e) {
      _logger.error('Error picking multiple images', error: e);
      return <File>[];
    }
  }

  // Compress image
  static Future<File?> compressImage(
    File file, {
    int quality = 85,
    int? minWidth,
    int? minHeight,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final String targetPath = '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
      );
      
      if (result != null) {
        return File(result.path);
      }
      return null;
    } catch (e) {
      _logger.error('Error compressing image', error: e);
      return null;
    }
  }

  // Get image dimensions
  static Future<Size?> getImageDimensions(File file) async {
    try {
      final image = await decodeImageFromList(file.readAsBytesSync());
      return Size(image.width.toDouble(), image.height.toDouble());
    } catch (e) {
      _logger.error('Error getting image dimensions', error: e);
      return null;
    }
  }

  // Create thumbnail
  static Future<File?> createThumbnail(
    File file, {
    int width = 200,
    int height = 200,
    int quality = 70,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final String targetPath = '${dir.path}/thumb_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        minWidth: width,
        minHeight: height,
        quality: quality,
      );
      
      if (result != null) {
        return File(result.path);
      }
      return null;
    } catch (e) {
      _logger.error('Error creating thumbnail', error: e);
      return null;
    }
  }

  // Resize image
  static Future<File?> resizeImage(
    File file, {
    required int width,
    required int height,
    int quality = 85,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final String targetPath = '${dir.path}/resized_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        width: width,
        height: height,
        quality: quality,
      );
      
      if (result != null) {
        return File(result.path);
      }
      return null;
    } catch (e) {
      _logger.error('Error resizing image', error: e);
      return null;
    }
  }

  // Rotate image
  static Future<File?> rotateImage(File file, int angle) async {
    try {
      final dir = await getTemporaryDirectory();
      final String targetPath = '${dir.path}/rotated_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        rotate: angle,
      );
      
      if (result != null) {
        return File(result.path);
      }
      return null;
    } catch (e) {
      _logger.error('Error rotating image', error: e);
      return null;
    }
  }

  // Convert to base64
  static Future<String?> imageToBase64(File file) async {
    try {
      final Uint8List bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      _logger.error('Error converting image to base64', error: e);
      return null;
    }
  }

  // Convert from base64
  static Future<File?> base64ToImage(String base64String, String fileName) async {
    try {
      final dir = await getTemporaryDirectory();
      final File file = File('${dir.path}/$fileName');
      final bytes = base64Decode(base64String);
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      _logger.error('Error converting base64 to image', error: e);
      return null;
    }
  }

  // Show image picker dialog
  static Future<File?> showImagePickerDialog(BuildContext context) async {
    return showDialog<File?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final File? file = await pickImageFromGallery();
                Navigator.pop(context, file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final File? file = await pickImageFromCamera();
                Navigator.pop(context, file);
              },
            ),
          ],
        ),
      ),
    );
  }
}