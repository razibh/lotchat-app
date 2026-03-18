import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart'; // 🟢 debugPrint এর জন্য

import '../di/service_locator.dart';
import 'logger_service.dart';

class UploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  late final LoggerService _logger;

  UploadService() {
    _initializeServices();
  }

  void _initializeServices() {
    try {
      _logger = ServiceLocator.instance.get<LoggerService>();
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  // Upload file
  Future<String?> uploadFile({
    required String filePath,
    required String folder,
    String? fileName,
    Map<String, String>? metadata,
  }) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      final String ext = path.extension(filePath);
      final String finalFileName = fileName ?? '${DateTime.now().millisecondsSinceEpoch}$ext';
      final String storagePath = '$folder/$finalFileName';

      final Reference ref = _storage.ref().child(storagePath);

      // Upload with metadata
      final SettableMetadata settableMetadata = SettableMetadata(
        customMetadata: metadata,
        contentType: _getContentType(ext),
      );

      final UploadTask uploadTask = ref.putFile(file, settableMetadata);

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      _logger?.info('File uploaded successfully: $storagePath');
      return downloadUrl;
    } catch (e) {
      _logger?.error('Failed to upload file', error: e);
      return null;
    }
  }

  // Upload image from picker
  Future<String?> uploadImage({
    required XFile image,
    required String folder,
    String? fileName,
  }) async {
    return uploadFile(
      filePath: image.path,
      folder: folder,
      fileName: fileName,
      metadata: {'type': 'image'},
    );
  }

  // Upload multiple images
  Future<List<String?>> uploadMultipleImages({
    required List<XFile> images,
    required String folder,
  }) async {
    final List<Future<String?>> futures = images.map((XFile image) => uploadImage(
      image: image,
      folder: folder,
      fileName: '${DateTime.now().millisecondsSinceEpoch}_${images.indexOf(image)}',
    )).toList();

    return Future.wait(futures);
  }

  // Upload video
  Future<String?> uploadVideo({
    required File video,
    required String folder,
    String? fileName,
  }) async {
    return uploadFile(
      filePath: video.path,
      folder: folder,
      fileName: fileName,
      metadata: {'type': 'video'},
    );
  }

  // Upload audio
  Future<String?> uploadAudio({
    required File audio,
    required String folder,
    String? fileName,
  }) async {
    return uploadFile(
      filePath: audio.path,
      folder: folder,
      fileName: fileName,
      metadata: {'type': 'audio'},
    );
  }

  // Upload profile picture
  Future<String?> uploadProfilePicture({
    required XFile image,
    required String userId,
  }) async {
    final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return uploadImage(
      image: image,
      folder: 'users/$userId/profile',
      fileName: fileName,
    );
  }

  // Upload room cover
  Future<String?> uploadRoomCover({
    required XFile image,
    required String roomId,
  }) async {
    final String fileName = 'cover_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return uploadImage(
      image: image,
      folder: 'rooms/$roomId/cover',
      fileName: fileName,
    );
  }

  // Upload gift animation
  Future<String?> uploadGiftAnimation({
    required File animation,
    required String giftId,
  }) async {
    final String fileName = 'animation_${DateTime.now().millisecondsSinceEpoch}.json';
    return uploadFile(
      filePath: animation.path,
      folder: 'gifts/$giftId/animations',
      fileName: fileName,
      metadata: {'type': 'animation'},
    );
  }

  // Upload post media
  Future<String?> uploadPostMedia({
    required XFile media,
    required String postId,
  }) async {
    final bool isVideo = media.path.endsWith('.mp4') || media.path.endsWith('.mov');
    final String fileName = '${isVideo ? 'video' : 'image'}_${DateTime.now().millisecondsSinceEpoch}${path.extension(media.path)}';

    return uploadFile(
      filePath: media.path,
      folder: 'posts/$postId/media',
      fileName: fileName,
      metadata: {'type': isVideo ? 'video' : 'image'},
    );
  }

  // Upload chat attachment
  Future<String?> uploadChatAttachment({
    required File file,
    required String chatId,
    required String messageId,
  }) async {
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';

    return uploadFile(
      filePath: file.path,
      folder: 'chats/$chatId/$messageId',
      fileName: fileName,
    );
  }

  // Delete file
  Future<bool> deleteFile(String url) async {
    try {
      final Reference ref = _storage.refFromURL(url);
      await ref.delete();
      _logger?.info('File deleted successfully');
      return true;
    } catch (e) {
      _logger?.error('Failed to delete file', error: e);
      return false;
    }
  }

  // Get file metadata
  Future<FullMetadata?> getFileMetadata(String url) async {
    try {
      final Reference ref = _storage.refFromURL(url);
      return await ref.getMetadata();
    } catch (e) {
      _logger?.error('Failed to get file metadata', error: e);
      return null;
    }
  }

  // Get download URL
  Future<String?> getDownloadUrl(String path) async {
    try {
      final Reference ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      _logger?.error('Failed to get download URL', error: e);
      return null;
    }
  }

  // List files in folder
  Future<List<Reference>> listFiles(String folder) async {
    try {
      final Reference ref = _storage.ref().child(folder);
      final ListResult result = await ref.listAll();
      return result.items;
    } catch (e) {
      _logger?.error('Failed to list files', error: e);
      return [];
    }
  }

  // Get file size
  Future<int?> getFileSize(String url) async {
    try {
      final FullMetadata? metadata = await getFileMetadata(url);
      return metadata?.size;
    } catch (e) {
      return null;
    }
  }

  // Update file metadata
  Future<bool> updateFileMetadata(String url, Map<String, String> metadata) async {
    try {
      final Reference ref = _storage.refFromURL(url);
      final SettableMetadata settableMetadata = SettableMetadata(
        customMetadata: metadata,
      );
      await ref.updateMetadata(settableMetadata);
      return true;
    } catch (e) {
      _logger?.error('Failed to update file metadata', error: e);
      return false;
    }
  }

  // Get content type from extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.mp4':
        return 'video/mp4';
      case '.mov':
        return 'video/quicktime';
      case '.mp3':
        return 'audio/mpeg';
      case '.wav':
        return 'audio/wav';
      case '.json':
        return 'application/json';
      default:
        return 'application/octet-stream';
    }
  }

  // Compress image before upload
  Future<XFile?> compressImage(XFile image, {int quality = 80}) async {
    // Implementation using flutter_image_compress
    // This would require additional package
    return image;
  }

  // Generate thumbnail for video
  Future<File?> generateVideoThumbnail(String videoPath) async {
    // Implementation using video_thumbnail package
    // This would require additional package
    return null;
  }

  // Clean up old files
  Future<void> cleanupOldFiles(String folder, {Duration olderThan = const Duration(days: 30)}) async {
    try {
      final List<Reference> files = await listFiles(folder);
      final DateTime cutoff = DateTime.now().subtract(olderThan);

      for (final Reference file in files) {
        final FullMetadata metadata = await file.getMetadata();
        if (metadata.timeCreated != null && metadata.timeCreated!.isBefore(cutoff)) {
          await file.delete();
          _logger?.info('Deleted old file: ${file.name}');
        }
      }
    } catch (e) {
      _logger?.error('Failed to cleanup old files', error: e);
    }
  }
}