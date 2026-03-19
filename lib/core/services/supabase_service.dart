import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import '../di/service_locator.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _supabase;
  late final GoTrueClient _auth;

  static const String _storageBucket = 'app_files';

  Future<void> initialize() async {
    _supabase = getService<SupabaseClient>();
    _auth = _supabase.auth;
    await _ensureStorageBucket();
    debugPrint('✅ SupabaseService initialized');
  }

  // ==================== AUTH METHODS ====================

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      debugPrint('Sign in error: $e');
      return null;
    }
  }

  Future<User?> signUpWithEmail(String email, String password, {Map<String, dynamic>? data}) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: data,
      );
      return response.user;
    } catch (e) {
      debugPrint('Sign up error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;

  // ==================== DATABASE METHODS ====================

  Future<Map<String, dynamic>?> insert(String table, Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from(table)
          .insert(data)
          .select()
          .single();
      return response;
    } catch (e) {
      debugPrint('Insert error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> selectAll(String table) async {
    try {
      final response = await _supabase.from(table).select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Select all error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> selectWhere(
      String table,
      String column,
      dynamic value,
      ) async {
    try {
      final response = await _supabase
          .from(table)
          .select()
          .eq(column, value);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Select where error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> selectById(String table, String id) async {
    try {
      final response = await _supabase
          .from(table)
          .select()
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('Select by id error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> update(
      String table,
      Map<String, dynamic> data,
      String column,
      dynamic value,
      ) async {
    try {
      final response = await _supabase
          .from(table)
          .update(data)
          .eq(column, value)
          .select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Update error: $e');
      return null;
    }
  }

  Future<void> delete(String table, String column, dynamic value) async {
    try {
      await _supabase
          .from(table)
          .delete()
          .eq(column, value);
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  // ==================== STREAM METHODS - COMPLETELY FIXED ====================

  /// Stream entire table - FIXED
  Stream<List<Map<String, dynamic>>> streamTable(String table) {
    try {
      // সরাসরি stream return করছি, কোনো variable assign করছি না
      return _supabase
          .from(table)
          .stream(primaryKey: ['id'])
          .map((data) {
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      });
    } catch (e) {
      debugPrint('Stream table error: $e');
      return Stream.error('Failed to stream table');
    }
  }

  /// Stream with filter - FIXED (alternative approach)
  Stream<List<Map<String, dynamic>>> streamFiltered(
      String table,
      String column,
      dynamic value,
      ) {
    try {
      // সরাসরি stream return করছি
      return _supabase
          .from(table)
          .stream(primaryKey: ['id'])
          .map((data) {
        // FIX: manually filter the data
        final filtered = data.where((item) => item[column] == value).toList();
        return filtered.map((item) => Map<String, dynamic>.from(item)).toList();
      });
    } catch (e) {
      debugPrint('Stream filtered error: $e');
      return Stream.error('Failed to stream filtered data');
    }
  }

  /// Stream by id - FIXED
  Stream<Map<String, dynamic>?> streamById(String table, String id) {
    try {
      return _supabase
          .from(table)
          .stream(primaryKey: ['id'])
          .map((data) {
        // FIX: manually find the record
        try {
          final record = data.firstWhere((item) => item['id'] == id);
          return Map<String, dynamic>.from(record);
        } catch (e) {
          return null;
        }
      });
    } catch (e) {
      debugPrint('Stream by id error: $e');
      return Stream.error('Failed to stream record');
    }
  }

  /// Stream with multiple filters - FIXED
  Stream<List<Map<String, dynamic>>> streamWithFilters(
      String table,
      Map<String, dynamic> filters,
      ) {
    try {
      return _supabase
          .from(table)
          .stream(primaryKey: ['id'])
          .map((data) {
        // FIX: manually apply all filters
        var filtered = data;
        filters.forEach((key, value) {
          filtered = filtered.where((item) => item[key] == value).toList();
        });
        return filtered.map((item) => Map<String, dynamic>.from(item)).toList();
      });
    } catch (e) {
      debugPrint('Stream with filters error: $e');
      return Stream.error('Failed to stream filtered data');
    }
  }

  /// Stream with ordering - FIXED
  Stream<List<Map<String, dynamic>>> streamOrdered(
      String table,
      String orderBy, {
        bool ascending = true,
        int? limit,
      }) {
    try {
      return _supabase
          .from(table)
          .stream(primaryKey: ['id'])
          .map((data) {
        // FIX: manually sort
        var sorted = List.from(data);
        sorted.sort((a, b) {
          final aVal = a[orderBy];
          final bVal = b[orderBy];

          if (aVal == null && bVal == null) return 0;
          if (aVal == null) return ascending ? -1 : 1;
          if (bVal == null) return ascending ? 1 : -1;

          final comparison = aVal.toString().compareTo(bVal.toString());
          return ascending ? comparison : -comparison;
        });

        // Apply limit
        if (limit != null && sorted.length > limit) {
          sorted = sorted.take(limit).toList();
        }

        return sorted.map((item) => Map<String, dynamic>.from(item)).toList();
      });
    } catch (e) {
      debugPrint('Stream ordered error: $e');
      return Stream.error('Failed to stream ordered data');
    }
  }

  // ==================== STORAGE METHODS ====================

  Future<void> _ensureStorageBucket() async {
    try {
      final buckets = await _supabase.storage.listBuckets();
      final exists = buckets.any((b) => b.name == _storageBucket);
      if (!exists) {
        await _supabase.storage.createBucket(_storageBucket);
      }
    } catch (e) {
      debugPrint('Storage bucket error: $e');
    }
  }

  Future<String?> uploadFile(
      String folder,
      String fileName,
      Uint8List bytes,
      ) async {
    try {
      final fullPath = '$folder/$fileName';
      await _supabase.storage
          .from(_storageBucket)
          .uploadBinary(fullPath, bytes);

      return _supabase.storage
          .from(_storageBucket)
          .getPublicUrl(fullPath);
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  Future<String?> uploadFileFromPath(
      String folder,
      String fileName,
      String filePath,
      ) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final fullPath = '$folder/$fileName';
      await _supabase.storage
          .from(_storageBucket)
          .upload(fullPath, file);

      return _supabase.storage
          .from(_storageBucket)
          .getPublicUrl(fullPath);
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  Future<void> deleteFile(String url) async {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      final bucketIndex = segments.indexOf('object');

      if (bucketIndex >= 0 && bucketIndex + 1 < segments.length) {
        final bucket = segments[bucketIndex + 1];
        final filePath = segments.sublist(bucketIndex + 2).join('/');
        await _supabase.storage.from(bucket).remove([filePath]);
      }
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  String? getPublicUrl(String folder, String fileName) {
    try {
      final fullPath = '$folder/$fileName';
      return _supabase.storage
          .from(_storageBucket)
          .getPublicUrl(fullPath);
    } catch (e) {
      debugPrint('Get URL error: $e');
      return null;
    }
  }
}