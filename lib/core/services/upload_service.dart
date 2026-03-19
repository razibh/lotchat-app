import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../di/service_locator.dart';
import 'logger_service.dart';

class UploadService {
  late final SupabaseClient _supabase;
  late final LoggerService _logger;

  // Default storage bucket
  static const String _defaultBucket = 'app_uploads';

  UploadService() {
    _initializeServices();
  }

  void _initializeServices() {
    try {
      _supabase = getService<SupabaseClient>();
      _logger = ServiceLocator.instance.get<LoggerService>();
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  // Helper to get current user
  String? get _currentUserId => _supabase.auth.currentSession?.user.id;

  // Helper to parse date
  DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is DateTime) return date;
    if (date is String) return DateTime.parse(date);
    return DateTime.now();
  }

  // ==================== UPLOAD METHODS ====================

  /// Upload file (from file path)
  Future<String?> uploadFile({
    required String filePath,
    required String folder,
    String? fileName,
    Map<String, String>? metadata,
    String? bucket = _defaultBucket,
  }) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      final String ext = path.extension(filePath);
      final String finalFileName = fileName ?? '${DateTime.now().millisecondsSinceEpoch}$ext';
      final String storagePath = '$folder/$finalFileName';

      // Upload file to Supabase Storage
      await _supabase.storage
          .from(bucket!)
          .upload(
        storagePath,
        file,
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: true,
          metadata: metadata,
          contentType: _getContentType(ext),
        ),
      );

      // Get public URL
      final String publicUrl = _supabase.storage
          .from(bucket)
          .getPublicUrl(storagePath);

      _logger?.info('File uploaded successfully: $storagePath');
      return publicUrl;
    } catch (e) {
      _logger?.error('Failed to upload file', error: e);
      return null;
    }
  }

  /// Upload file bytes
  Future<String?> uploadFileBytes({
    required Uint8List bytes,
    required String folder,
    required String fileName,
    Map<String, String>? metadata,
    String? bucket = _defaultBucket,
  }) async {
    try {
      final String ext = path.extension(fileName);
      final String storagePath = '$folder/$fileName';

      await _supabase.storage
          .from(bucket!)
          .uploadBinary(
        storagePath,
        bytes,
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: true,
          metadata: metadata,
          contentType: _getContentType(ext),
        ),
      );

      final String publicUrl = _supabase.storage
          .from(bucket)
          .getPublicUrl(storagePath);

      _logger?.info('File bytes uploaded successfully: $storagePath');
      return publicUrl;
    } catch (e) {
      _logger?.error('Failed to upload file bytes', error: e);
      return null;
    }
  }

  // ==================== IMAGE UPLOADS ====================

  /// Upload image from picker
  Future<String?> uploadImage({
    required XFile image,
    required String folder,
    String? fileName,
    String? bucket = _defaultBucket,
  }) async {
    return uploadFile(
      filePath: image.path,
      folder: folder,
      fileName: fileName,
      metadata: {'type': 'image'},
      bucket: bucket,
    );
  }

  /// Upload multiple images
  Future<List<String?>> uploadMultipleImages({
    required List<XFile> images,
    required String folder,
    String? bucket = _defaultBucket,
  }) async {
    final List<Future<String?>> futures = images.map((XFile image) => uploadImage(
      image: image,
      folder: folder,
      fileName: '${DateTime.now().millisecondsSinceEpoch}_${images.indexOf(image)}${path.extension(image.path)}',
      bucket: bucket,
    )).toList();

    return Future.wait(futures);
  }

  // ==================== VIDEO UPLOADS ====================

  /// Upload video
  Future<String?> uploadVideo({
    required File video,
    required String folder,
    String? fileName,
    String? bucket = _defaultBucket,
  }) async {
    return uploadFile(
      filePath: video.path,
      folder: folder,
      fileName: fileName,
      metadata: {'type': 'video'},
      bucket: bucket,
    );
  }

  // ==================== AUDIO UPLOADS ====================

  /// Upload audio
  Future<String?> uploadAudio({
    required File audio,
    required String folder,
    String? fileName,
    String? bucket = _defaultBucket,
  }) async {
    return uploadFile(
      filePath: audio.path,
      folder: folder,
      fileName: fileName,
      metadata: {'type': 'audio'},
      bucket: bucket,
    );
  }

  // ==================== PROFILE PICTURE ====================

  /// Upload profile picture
  Future<String?> uploadProfilePicture({
    required XFile image,
    required String userId,
    String? bucket = _defaultBucket,
  }) async {
    final String ext = path.extension(image.path);
    final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}$ext';
    return uploadImage(
      image: image,
      folder: 'users/$userId/profile',
      fileName: fileName,
      bucket: bucket,
    );
  }

  // ==================== ROOM COVER ====================

  /// Upload room cover
  Future<String?> uploadRoomCover({
    required XFile image,
    required String roomId,
    String? bucket = _defaultBucket,
  }) async {
    final String ext = path.extension(image.path);
    final String fileName = 'cover_${DateTime.now().millisecondsSinceEpoch}$ext';
    return uploadImage(
      image: image,
      folder: 'rooms/$roomId/cover',
      fileName: fileName,
      bucket: bucket,
    );
  }

  // ==================== GIFT ANIMATION ====================

  /// Upload gift animation
  Future<String?> uploadGiftAnimation({
    required File animation,
    required String giftId,
    String? bucket = _defaultBucket,
  }) async {
    final String ext = path.extension(animation.path);
    final String fileName = 'animation_${DateTime.now().millisecondsSinceEpoch}$ext';
    return uploadFile(
      filePath: animation.path,
      folder: 'gifts/$giftId/animations',
      fileName: fileName,
      metadata: {'type': 'animation'},
      bucket: bucket,
    );
  }

  // ==================== POST MEDIA ====================

  /// Upload post media
  Future<String?> uploadPostMedia({
    required XFile media,
    required String postId,
    String? bucket = _defaultBucket,
  }) async {
    final bool isVideo = media.path.endsWith('.mp4') || media.path.endsWith('.mov');
    final String ext = path.extension(media.path);
    final String fileName = '${isVideo ? 'video' : 'image'}_${DateTime.now().millisecondsSinceEpoch}$ext';

    return uploadFile(
      filePath: media.path,
      folder: 'posts/$postId/media',
      fileName: fileName,
      metadata: {'type': isVideo ? 'video' : 'image'},
      bucket: bucket,
    );
  }

  // ==================== CHAT ATTACHMENT ====================

  /// Upload chat attachment
  Future<String?> uploadChatAttachment({
    required File file,
    required String chatId,
    required String messageId,
    String? bucket = _defaultBucket,
  }) async {
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
    final String folder = 'chats/$chatId/$messageId';

    return uploadFile(
      filePath: file.path,
      folder: folder,
      fileName: fileName,
      bucket: bucket,
    );
  }

  // ==================== DELETE FILE ====================

  /// Delete file by URL
  Future<bool> deleteFile(String url, {String? bucket = _defaultBucket}) async {
    try {
      // Extract path from URL
      final String path = _extractPathFromUrl(url);
      if (path.isEmpty) throw Exception('Could not extract path from URL');

      await _supabase.storage
          .from(bucket!)
          .remove([path]);

      _logger?.info('File deleted successfully: $path');
      return true;
    } catch (e) {
      _logger?.error('Failed to delete file', error: e);
      return false;
    }
  }

  /// Extract path from Supabase storage URL
  String _extractPathFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;

      // Find the bucket name in path
      final bucketIndex = segments.indexOf('object');
      if (bucketIndex >= 0 && bucketIndex + 1 < segments.length) {
        // Skip bucket name and get the rest as path
        return segments.sublist(bucketIndex + 2).join('/');
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  // ==================== FILE METADATA ====================

  /// Get file metadata
  Future<FileObject?> getFileMetadata(String path, {String? bucket = _defaultBucket}) async {
    try {
      final List<FileObject> files = await _supabase.storage
          .from(bucket!)
          .list(path: path);

      if (files.isNotEmpty) {
        return files.first;
      }
      return null;
    } catch (e) {
      _logger?.error('Failed to get file metadata', error: e);
      return null;
    }
  }

  // ==================== DOWNLOAD URL ====================

  /// Get download URL
  Future<String?> getDownloadUrl(String path, {String? bucket = _defaultBucket}) async {
    try {
      return _supabase.storage
          .from(bucket!)
          .getPublicUrl(path);
    } catch (e) {
      _logger?.error('Failed to get download URL', error: e);
      return null;
    }
  }

  // ==================== LIST FILES ====================

  /// List files in folder
  Future<List<FileObject>> listFiles(String folder, {String? bucket = _defaultBucket}) async {
    try {
      return await _supabase.storage
          .from(bucket!)
          .list(path: folder);
    } catch (e) {
      _logger?.error('Failed to list files', error: e);
      return [];
    }
  }

  // ==================== FILE SIZE ====================

  /// Get file size
  Future<int?> getFileSize(String path, {String? bucket = _defaultBucket}) async {
    try {
      final fileInfo = await getFileMetadata(path, bucket: bucket);
      return fileInfo?.metadata?['size'] as int?;
    } catch (e) {
      return null;
    }
  }

  // ==================== UPDATE METADATA ====================

  /// Update file metadata
  Future<bool> updateFileMetadata(String path, Map<String, String> metadata, {String? bucket = _defaultBucket}) async {
    try {
      // Note: Supabase Storage doesn't directly support updating metadata
      // You would need to re-upload the file
      _logger?.warning('Update metadata not directly supported in Supabase Storage');
      return false;
    } catch (e) {
      _logger?.error('Failed to update file metadata', error: e);
      return false;
    }
  }

  // ==================== MOVE/COPY FILE ====================

  /// Move file
  Future<String?> moveFile(String fromPath, String toPath, {String? bucket = _defaultBucket}) async {
    try {
      // Download and re-upload
      final bytes = await _supabase.storage
          .from(bucket!)
          .download(fromPath);

      // Upload to new location
      await _supabase.storage
          .from(bucket)
          .uploadBinary(toPath, bytes);

      // Delete old file
      await _supabase.storage
          .from(bucket)
          .remove([fromPath]);

      return _supabase.storage
          .from(bucket)
          .getPublicUrl(toPath);
    } catch (e) {
      _logger?.error('Failed to move file', error: e);
      return null;
    }
  }

  /// Copy file
  Future<String?> copyFile(String fromPath, String toPath, {String? bucket = _defaultBucket}) async {
    try {
      final bytes = await _supabase.storage
          .from(bucket!)
          .download(fromPath);

      await _supabase.storage
          .from(bucket)
          .uploadBinary(toPath, bytes);

      return _supabase.storage
          .from(bucket)
          .getPublicUrl(toPath);
    } catch (e) {
      _logger?.error('Failed to copy file', error: e);
      return null;
    }
  }

  // ==================== CONTENT TYPE ====================

  /// Get content type from extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.svg':
        return 'image/svg+xml';
      case '.mp4':
        return 'video/mp4';
      case '.mov':
        return 'video/quicktime';
      case '.avi':
        return 'video/x-msvideo';
      case '.mkv':
        return 'video/x-matroska';
      case '.mp3':
        return 'audio/mpeg';
      case '.wav':
        return 'audio/wav';
      case '.ogg':
        return 'audio/ogg';
      case '.aac':
        return 'audio/aac';
      case '.json':
        return 'application/json';
      case '.pdf':
        return 'application/pdf';
      case '.doc':
      case '.docx':
        return 'application/msword';
      case '.txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  // ==================== COMPRESSION ====================

  /// Compress image before upload
  Future<XFile?> compressImage(XFile image, {int quality = 80}) async {
    // This would require flutter_image_compress package
    // For now, return original
    _logger?.warning('Image compression not implemented');
    return image;
  }

  // ==================== THUMBNAIL ====================

  /// Generate thumbnail for video
  Future<File?> generateVideoThumbnail(String videoPath) async {
    // This would require video_thumbnail package
    // For now, return null
    _logger?.warning('Video thumbnail generation not implemented');
    return null;
  }

  // ==================== CLEANUP - FIXED ====================

  /// Clean up old files - FIXED (date parsing issue)
  Future<void> cleanupOldFiles(String folder, {Duration olderThan = const Duration(days: 30), String? bucket = _defaultBucket}) async {
    try {
      final List<FileObject> files = await listFiles(folder, bucket: bucket);
      final DateTime cutoff = DateTime.now().subtract(olderThan);

      for (final FileObject file in files) {
        // FIX: Parse created_at string to DateTime
        if (file.createdAt != null) {
          final DateTime createdAt = _parseDate(file.createdAt);
          if (createdAt.isBefore(cutoff)) {
            await _supabase.storage
                .from(bucket!)
                .remove(['$folder/${file.name}']);
            _logger?.info('Deleted old file: ${file.name}');
          }
        }
      }
    } catch (e) {
      _logger?.error('Failed to cleanup old files', error: e);
    }
  }

  // ==================== BUCKET MANAGEMENT ====================

  /// Create bucket
  Future<bool> createBucket(String bucketName) async {
    try {
      await _supabase.storage.createBucket(bucketName);
      _logger?.info('Bucket created: $bucketName');
      return true;
    } catch (e) {
      _logger?.error('Failed to create bucket', error: e);
      return false;
    }
  }

  /// List all buckets
  Future<List<Bucket>> listBuckets() async {
    try {
      return await _supabase.storage.listBuckets();
    } catch (e) {
      _logger?.error('Failed to list buckets', error: e);
      return [];
    }
  }

  /// Empty bucket
  Future<bool> emptyBucket(String bucketName) async {
    try {
      final List<FileObject> files = await _supabase.storage
          .from(bucketName)
          .list();

      if (files.isNotEmpty) {
        final List<String> paths = files.map((f) => f.name).toList();
        await _supabase.storage
            .from(bucketName)
            .remove(paths);
      }

      _logger?.info('Bucket emptied: $bucketName');
      return true;
    } catch (e) {
      _logger?.error('Failed to empty bucket', error: e);
      return false;
    }
  }

  /// Delete bucket
  Future<bool> deleteBucket(String bucketName) async {
    try {
      await emptyBucket(bucketName);
      await _supabase.storage.deleteBucket(bucketName);
      _logger?.info('Bucket deleted: $bucketName');
      return true;
    } catch (e) {
      _logger?.error('Failed to delete bucket', error: e);
      return false;
    }
  }
}