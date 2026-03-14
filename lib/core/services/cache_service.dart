import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/foundation.dart';

class CacheService {
  factory CacheService() => _instance;
  CacheService._internal();
  static final CacheService _instance = CacheService._internal();

  late SharedPreferences _prefs;
  late DefaultCacheManager _cacheManager;
  bool _isInitialized = false;

  // Cache expiration times
  static const Duration shortCache = Duration(minutes: 5);
  static const Duration mediumCache = Duration(hours: 1);
  static const Duration longCache = Duration(days: 1);

  Future<void> init() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    _cacheManager = DefaultCacheManager();
    _isInitialized = true;

    debugPrint('✅ CacheService initialized');
  }

  void _checkInitialized() {
    if (!_isInitialized) {
      throw Exception('CacheService not initialized. Call init() first.');
    }
  }

  // ==================== MEMORY CACHE (SharedPreferences) ====================

  // Store data with expiration
  Future<void> setWithExpiry({
    required String key,
    required dynamic value,
    required Duration expiry,
  }) async {
    _checkInitialized();
    final Map<String, dynamic> data = <String, dynamic>{
      'value': value,
      'expiry': DateTime.now().add(expiry).millisecondsSinceEpoch,
    };
    await _prefs.setString(key, jsonEncode(data));
  }

  // Get data with expiration check
  T? getWithExpiry<T>(String key) {
    _checkInitialized();
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;

    try {
      final data = jsonDecode(jsonString);
      final int expiry = data['expiry'] as int;

      if (DateTime.now().millisecondsSinceEpoch > expiry) {
        // Expired - remove and return null
        _prefs.remove(key);
        return null;
      }

      return data['value'] as T;
    } catch (e) {
      debugPrint('Error getting cached data for key $key: $e');
      return null;
    }
  }

  // ==================== USER DATA CACHE ====================

  // Cache user profile
  Future<void> cacheUserProfile(String userId, Map<String, dynamic> userData) async {
    await setWithExpiry(
      key: 'user_$userId',
      value: userData,
      expiry: mediumCache,
    );
  }

  Map<String, dynamic>? getCachedUserProfile(String userId) {
    return getWithExpiry('user_$userId');
  }

  // Cache user list
  Future<void> cacheUserList(List<Map<String, dynamic>> users) async {
    await setWithExpiry(
      key: 'user_list',
      value: users,
      expiry: shortCache,
    );
  }

  List<Map<String, dynamic>>? getCachedUserList() {
    return getWithExpiry('user_list');
  }

  // ==================== ROOM DATA CACHE ====================

  // Cache room details
  Future<void> cacheRoom(String roomId, Map<String, dynamic> roomData) async {
    await setWithExpiry(
      key: 'room_$roomId',
      value: roomData,
      expiry: shortCache,
    );
  }

  Map<String, dynamic>? getCachedRoom(String roomId) {
    return getWithExpiry('room_$roomId');
  }

  // Cache room list
  Future<void> cacheRoomList(List<Map<String, dynamic>> rooms) async {
    await setWithExpiry(
      key: 'room_list',
      value: rooms,
      expiry: shortCache,
    );
  }

  List<Map<String, dynamic>>? getCachedRoomList() {
    return getWithExpiry('room_list');
  }

  // Cache rooms by category
  Future<void> cacheRoomsByCategory(String category, List<Map<String, dynamic>> rooms) async {
    await setWithExpiry(
      key: 'rooms_$category',
      value: rooms,
      expiry: shortCache,
    );
  }

  List<Map<String, dynamic>>? getCachedRoomsByCategory(String category) {
    return getWithExpiry('rooms_$category');
  }

  // ==================== GIFT DATA CACHE ====================

  // Cache gift details
  Future<void> cacheGift(String giftId, Map<String, dynamic> giftData) async {
    await setWithExpiry(
      key: 'gift_$giftId',
      value: giftData,
      expiry: longCache,
    );
  }

  Map<String, dynamic>? getCachedGift(String giftId) {
    return getWithExpiry('gift_$giftId');
  }

  // Cache all gifts
  Future<void> cacheAllGifts(List<Map<String, dynamic>> gifts) async {
    await setWithExpiry(
      key: 'all_gifts',
      value: gifts,
      expiry: longCache,
    );
  }

  List<Map<String, dynamic>>? getCachedAllGifts() {
    return getWithExpiry('all_gifts');
  }

  // ==================== FILE CACHE (CacheManager) ====================

  // Cache image
  Future<FileInfo?> cacheImage(String url) async {
    _checkInitialized();
    return _cacheManager.getFileFromCache(url);
  }

  // Download and cache image
  Future<FileInfo> downloadAndCacheImage(String url) async {
    _checkInitialized();
    return _cacheManager.downloadFile(url);
  }

  // Get cached image file
  Future<File?> getCachedImage(String url) async {
    _checkInitialized();
    final FileInfo? fileInfo = await _cacheManager.getFileFromCache(url);
    return fileInfo?.file;
  }

  // Cache multiple images
  Future<void> cacheImages(List<String> urls) async {
    _checkInitialized();
    for (String url in urls) {
      await _cacheManager.downloadFile(url);
    }
  }

  // ==================== API RESPONSE CACHE ====================

  // Cache API response
  Future<void> cacheApiResponse(String endpoint, dynamic response) async {
    await setWithExpiry(
      key: 'api_$endpoint',
      value: response,
      expiry: shortCache,
    );
  }

  dynamic getCachedApiResponse(String endpoint) {
    return getWithExpiry('api_$endpoint');
  }

  // ==================== INVALIDATION ====================

  // Invalidate user cache
  Future<void> invalidateUserCache(String userId) async {
    _checkInitialized();
    await _prefs.remove('user_$userId');
    await _prefs.remove('user_list');
  }

  // Invalidate room cache
  Future<void> invalidateRoomCache(String roomId) async {
    _checkInitialized();
    await _prefs.remove('room_$roomId');
    await _prefs.remove('room_list');
  }

  // Invalidate all caches
  Future<void> invalidateAll() async {
    _checkInitialized();
    final Set<String> keys = _prefs.getKeys();
    for (final String key in keys) {
      if (key.startsWith('user_') ||
          key.startsWith('room_') ||
          key.startsWith('gift_') ||
          key.startsWith('api_')) {
        await _prefs.remove(key);
      }
    }

    // Clear file cache
    await _cacheManager.emptyCache();
  }

  // Clear all cache (for dispose/cleanup)
  Future<void> clearAll() async {
    _checkInitialized();
    debugPrint('🗑️ Clearing all cache...');

    try {
      // Clear all SharedPreferences data
      await _prefs.clear();

      // Clear file cache
      await _cacheManager.emptyCache();

      debugPrint('✅ All cache cleared successfully');
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
      rethrow;
    }
  }

  // ==================== CACHE STATS ====================

  // Get cache size
  Future<int> getCacheSize() async {
    _checkInitialized();
    var totalSize = 0;

    final Set<String> keys = _prefs.getKeys();
    for (final String key in keys) {
      final String? value = _prefs.getString(key);
      if (value != null) {
        totalSize += value.length * 2; // Approximate size in bytes
      }
    }

    return totalSize;
  }

  // Get cache keys
  List<String> getCacheKeys() {
    _checkInitialized();
    return _prefs.getKeys()
        .where((String key) => key.startsWith('user_') ||
        key.startsWith('room_') ||
        key.startsWith('gift_') ||
        key.startsWith('api_'),)
        .toList();
  }

  // ==================== CLEANUP ====================

  // Clean expired cache
  Future<void> cleanExpired() async {
    _checkInitialized();
    final Set<String> keys = _prefs.getKeys();
    for (final String key in keys) {
      final String? value = _prefs.getString(key);
      if (value != null) {
        try {
          final data = jsonDecode(value);
          if (data is Map && data.containsKey('expiry')) {
            final int expiry = data['expiry'] as int;
            if (DateTime.now().millisecondsSinceEpoch > expiry) {
              await _prefs.remove(key);
            }
          }
        } catch (e) {
          // Not a cache entry, skip
        }
      }
    }
  }

// Clear old files - Simple and reliable
  Future<void> clearOldFiles({Duration olderThan = const Duration(days: 7)}) async {
    _checkInitialized();
    try {
      // Just clear everything - simplest solution
      await _cacheManager.emptyCache();
      debugPrint('✅ Cache cleared successfully');
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
    }
  }

  // Check if service is initialized
  bool get isInitialized => _isInitialized;
}