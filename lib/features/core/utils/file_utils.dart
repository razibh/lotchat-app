import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FileUtils {
  // Get temporary directory
  static Future<Directory> getTempDirectory() async {
    return await getTemporaryDirectory();
  }

  // Get documents directory
  static Future<Directory> getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  // Get downloads directory
  static Future<Directory> getDownloadsDirectory() async {
    return await getDownloadsDirectory() ?? await getTemporaryDirectory();
  }

  // Create file
  static Future<File> createFile(String fileName, {Directory? directory}) async {
    final Directory dir = directory ?? await getDocumentsDirectory();
    final File file = File(path.join(dir.path, fileName));
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    return file;
  }

  // Write string to file
  static Future<bool> writeString(String fileName, String content) async {
    try {
      final File file = await createFile(fileName);
      await file.writeAsString(content);
      return true;
    } catch (e) {
      print('Error writing file: $e');
      return false;
    }
  }

  // Read string from file
  static Future<String?> readString(String fileName) async {
    try {
      final File file = await createFile(fileName);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      print('Error reading file: $e');
      return null;
    }
  }

  // Write bytes to file
  static Future<bool> writeBytes(String fileName, List<int> bytes) async {
    try {
      final File file = await createFile(fileName);
      await file.writeAsBytes(bytes);
      return true;
    } catch (e) {
      print('Error writing file: $e');
      return false;
    }
  }

  // Read bytes from file
  static Future<List<int>?> readBytes(String fileName) async {
    try {
      final File file = await createFile(fileName);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      print('Error reading file: $e');
      return null;
    }
  }

  // Delete file
  static Future<bool> deleteFile(String fileName) async {
    try {
      final File file = await createFile(fileName);
      if (await file.exists()) {
        await file.delete();
      }
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  // Check if file exists
  static Future<bool> fileExists(String fileName) async {
    try {
      final File file = await createFile(fileName);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // Get file size
  static Future<int?> getFileSize(String fileName) async {
    try {
      final File file = await createFile(fileName);
      if (await file.exists()) {
        final FileStat stat = await file.stat();
        return stat.size;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Get file extension
  static String getFileExtension(String fileName) {
    return path.extension(fileName).toLowerCase();
  }

  // Get file name without extension
  static String getFileNameWithoutExtension(String fileName) {
    return path.basenameWithoutExtension(fileName);
  }

  // Get file name from path
  static String getFileName(String filePath) {
    return path.basename(filePath);
  }

  // Get directory from path
  static String getDirectory(String filePath) {
    return path.dirname(filePath);
  }

  // Join paths
  static String joinPaths(String part1, String part2) {
    return path.join(part1, part2);
  }

  // Check if file is image
  static bool isImage(String fileName) {
    final String ext = getFileExtension(fileName);
    return <String>['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].contains(ext);
  }

  // Check if file is video
  static bool isVideo(String fileName) {
    final String ext = getFileExtension(fileName);
    return <String>['.mp4', '.mov', '.avi', '.mkv', '.webm'].contains(ext);
  }

  // Check if file is audio
  static bool isAudio(String fileName) {
    final String ext = getFileExtension(fileName);
    return <String>['.mp3', '.wav', '.aac', '.flac', '.m4a'].contains(ext);
  }

  // Check if file is document
  static bool isDocument(String fileName) {
    final String ext = getFileExtension(fileName);
    return <String>['.pdf', '.doc', '.docx', '.txt', '.xls', '.xlsx'].contains(ext);
  }
}