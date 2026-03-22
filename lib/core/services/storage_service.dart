import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_models.dart' as app;
import '../models/gift_model.dart';
import '../constants/shared_preference_keys.dart';
import '../di/service_locator.dart';

class StorageService {
  factory StorageService() => _instance;
  StorageService._internal();
  static final StorageService _instance = StorageService._internal();

  late SharedPreferences _prefs;
  late Box _hiveBox;

  // Lazy getter — only resolves when first used, never at init() time
  SupabaseClient get _supabase => getService<SupabaseClient>();

  // ==================== INITIALIZATION ====================
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _hiveBox = await Hive.openBox('appBox');
    // Removed: _supabase = getService<SupabaseClient>();
    // SupabaseClient is resolved lazily above so it's never
    // accessed before it's registered in GetIt
  }

  // ==================== SHARED PREFERENCES ====================
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }

  // ==================== HIVE STORAGE ====================
  Future<void> saveObject(String key, dynamic value) async {
    await _hiveBox.put(key, value);
  }

  dynamic getObject(String key) {
    return _hiveBox.get(key);
  }

  Future<void> saveMap(String key, Map<String, dynamic> value) async {
    await _hiveBox.put(key, value);
  }

  Map<String, dynamic>? getMap(String key) {
    final value = _hiveBox.get(key);
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  Future<void> saveList(String key, List<dynamic> value) async {
    await _hiveBox.put(key, value);
  }

  List<dynamic>? getList(String key) {
    final value = _hiveBox.get(key);
    if (value is List) {
      return value;
    }
    return null;
  }

  Future<void> delete(String key) async {
    await _hiveBox.delete(key);
  }

  bool containsKey(String key) {
    return _hiveBox.containsKey(key);
  }

  Iterable<String> getKeys() {
    return _hiveBox.keys.cast<String>();
  }

  Future<void> clearHive() async {
    await _hiveBox.clear();
  }

  // ==================== SUPABASE STORAGE (FILE UPLOAD) ====================
  Future<String?> uploadFile({
    required File file,
    required String bucket,
    required String path,
    String? fileName,
  }) async {
    try {
      final String finalFileName = fileName ?? file.path.split('/').last;
      final String filePath = '$path/$finalFileName';
      debugPrint('📤 Uploading file to Supabase: $bucket/$filePath');

      await _supabase.storage.from(bucket).upload(filePath, file);

      final String publicUrl =
      _supabase.storage.from(bucket).getPublicUrl(filePath);
      debugPrint('✅ File uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Failed to upload file: $e');
      return null;
    }
  }

  Future<String?> uploadImage({
    required File image,
    required String userId,
    required String type,
  }) async {
    try {
      return await uploadFile(
        file: image,
        bucket: 'images',
        path: 'users/$userId/$type',
        fileName: '${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    } catch (e) {
      debugPrint('Failed to upload image: $e');
      return null;
    }
  }

  Future<String?> uploadGiftImage({
    required File image,
    required String giftId,
  }) async {
    try {
      return await uploadFile(
        file: image,
        bucket: 'gifts',
        path: giftId,
        fileName: '${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    } catch (e) {
      debugPrint('Failed to upload gift image: $e');
      return null;
    }
  }

  Future<String?> uploadRoomCover({
    required File image,
    required String roomId,
  }) async {
    try {
      return await uploadFile(
        file: image,
        bucket: 'rooms',
        path: roomId,
        fileName: 'cover_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    } catch (e) {
      debugPrint('Failed to upload room cover: $e');
      return null;
    }
  }

  Future<bool> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      debugPrint('🗑️ Deleting file from Supabase: $bucket/$path');
      await _supabase.storage.from(bucket).remove([path]);
      debugPrint('✅ File deleted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete file: $e');
      return false;
    }
  }

  Future<List<String>> listFiles({
    required String bucket,
    required String path,
  }) async {
    try {
      final response =
      await _supabase.storage.from(bucket).list(path: path);
      return response.map((file) => file.name).toList();
    } catch (e) {
      debugPrint('Failed to list files: $e');
      return [];
    }
  }

  String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    return _supabase.storage.from(bucket).getPublicUrl(path);
  }

  Future<String?> getDownloadUrl({
    required String bucket,
    required String path,
    int expiresIn = 60,
  }) async {
    try {
      return await _supabase.storage
          .from(bucket)
          .createSignedUrl(path, expiresIn);
    } catch (e) {
      debugPrint('Failed to get download URL: $e');
      return null;
    }
  }

  Future<String?> uploadBytes({
    required Uint8List bytes,
    required String bucket,
    required String path,
    String? fileName,
  }) async {
    try {
      final String finalFileName =
          fileName ?? 'file_${DateTime.now().millisecondsSinceEpoch}';
      final String filePath = '$path/$finalFileName';
      debugPrint('📤 Uploading bytes to Supabase: $bucket/$filePath');

      await _supabase.storage.from(bucket).uploadBinary(filePath, bytes);

      final String publicUrl =
      _supabase.storage.from(bucket).getPublicUrl(filePath);
      debugPrint('✅ Bytes uploaded successfully');
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Failed to upload bytes: $e');
      return null;
    }
  }

  // ==================== USER DATA ====================
  Future<void> saveUser(app.User user) async {
    final String userJson = jsonEncode(user.toJson());
    await setString(PrefKeys.userData, userJson);
    await setString(PrefKeys.userId, user.id);
    await setString(PrefKeys.userName, user.username);
    await setString(PrefKeys.userEmail, user.email);
    await setInt(PrefKeys.userCoins, user.coins);
    await setInt(PrefKeys.userDiamonds, user.diamonds);
    if (user.tier != null) {
      await setInt(PrefKeys.userTier, user.tier!.index);
    }
  }

  app.User? getUser() {
    final String? userJson = getString(PrefKeys.userData);
    if (userJson != null) {
      try {
        final Map<String, dynamic> userMap = jsonDecode(userJson);
        return app.User.fromJson(userMap);
      } catch (e) {
        debugPrint('Error parsing user: $e');
      }
    }
    return null;
  }

  Future<String?> getUserId() async {
    return getString(PrefKeys.userId);
  }

  Future<void> setUserId(String userId) async {
    await setString(PrefKeys.userId, userId);
  }

  Future<void> updateUserCoins(int coins) async {
    await setInt(PrefKeys.userCoins, coins);
    final app.User? user = getUser();
    if (user != null) {
      await saveUser(user.copyWith(coins: coins));
    }
  }

  Future<void> updateUserDiamonds(int diamonds) async {
    await setInt(PrefKeys.userDiamonds, diamonds);
    final app.User? user = getUser();
    if (user != null) {
      await saveUser(user.copyWith(diamonds: diamonds));
    }
  }

  // ==================== AUTH DATA ====================
  Future<void> saveAuthToken(String token) async {
    await setString(PrefKeys.authToken, token);
  }

  String? getAuthToken() {
    return getString(PrefKeys.authToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await setString(PrefKeys.refreshToken, token);
  }

  String? getRefreshToken() {
    return getString(PrefKeys.refreshToken);
  }

  Future<void> setLoggedIn(bool value) async {
    await setBool(PrefKeys.isLoggedIn, value);
  }

  bool isLoggedIn() {
    return getBool(PrefKeys.isLoggedIn) ?? false;
  }

  // ==================== APP SETTINGS ====================
  Future<void> setThemeMode(String mode) async {
    await setString(PrefKeys.themeMode, mode);
  }

  String getThemeMode() {
    return getString(PrefKeys.themeMode) ?? 'system';
  }

  Future<void> setLanguage(String language) async {
    await setString(PrefKeys.language, language);
  }

  String getLanguage() {
    return getString(PrefKeys.language) ?? 'en';
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await setBool(PrefKeys.notificationsEnabled, enabled);
  }

  bool areNotificationsEnabled() {
    return getBool(PrefKeys.notificationsEnabled) ?? true;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await setBool(PrefKeys.soundEnabled, enabled);
  }

  bool isSoundEnabled() {
    return getBool(PrefKeys.soundEnabled) ?? true;
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    await setBool(PrefKeys.vibrationEnabled, enabled);
  }

  bool isVibrationEnabled() {
    return getBool(PrefKeys.vibrationEnabled) ?? true;
  }

  // ==================== LOCATION DATA ====================
  Future<void> saveCountry(String country) async {
    await setString(PrefKeys.country, country);
  }

  String? getCountry() {
    return getString(PrefKeys.country);
  }

  Future<void> saveRegion(String region) async {
    await setString(PrefKeys.region, region);
  }

  String? getRegion() {
    return getString(PrefKeys.region);
  }

  Future<void> saveLastLocation(Map<String, double> location) async {
    await saveMap(PrefKeys.lastLocation, location.cast<String, dynamic>());
  }

  Map<String, double>? getLastLocation() {
    final Map<String, dynamic>? location = getMap(PrefKeys.lastLocation);
    if (location != null) {
      return location.map(
              (key, value) => MapEntry(key, (value as num).toDouble()));
    }
    return null;
  }

  // ==================== CACHE DATA ====================
  Future<void> cacheRooms(List<Map<String, dynamic>> rooms) async {
    await saveList(PrefKeys.cachedRooms, rooms);
    await setInt(PrefKeys.lastSync, DateTime.now().millisecondsSinceEpoch);
  }

  List<Map<String, dynamic>>? getCachedRooms() {
    final List<dynamic>? rooms = getList(PrefKeys.cachedRooms);
    if (rooms != null) {
      return rooms.cast<Map<String, dynamic>>();
    }
    return null;
  }

  Future<void> cacheGifts(List<Map<String, dynamic>> gifts) async {
    await saveList(PrefKeys.cachedGifts, gifts);
  }

  List<Map<String, dynamic>>? getCachedGifts() {
    final List<dynamic>? gifts = getList(PrefKeys.cachedGifts);
    if (gifts != null) {
      return gifts.cast<Map<String, dynamic>>();
    }
    return null;
  }

  int? getLastSyncTime() {
    return getInt(PrefKeys.lastSync);
  }

  bool isCacheValid({int maxAgeHours = 24}) {
    final int? lastSync = getLastSyncTime();
    if (lastSync == null) return false;
    final int age = DateTime.now().millisecondsSinceEpoch - lastSync;
    return age < (maxAgeHours * 60 * 60 * 1000);
  }

  // ==================== ONBOARDING ====================
  Future<void> setHasSeenOnboarding(bool value) async {
    await setBool(PrefKeys.hasSeenOnboarding, value);
  }

  bool hasSeenOnboarding() {
    return getBool(PrefKeys.hasSeenOnboarding) ?? false;
  }

  Future<void> setHasCompletedProfile(bool value) async {
    await setBool(PrefKeys.hasCompletedProfile, value);
  }

  bool hasCompletedProfile() {
    return getBool(PrefKeys.hasCompletedProfile) ?? false;
  }

  // ==================== GAME STATS ====================
  Future<void> saveGameStats(Map<String, dynamic> stats) async {
    await saveMap(PrefKeys.gameStats, stats);
  }

  Map<String, dynamic>? getGameStats() {
    return getMap(PrefKeys.gameStats);
  }

  Future<void> setLastGamePlayed(String game) async {
    await setString(PrefKeys.lastGamePlayed, game);
  }

  String? getLastGamePlayed() {
    return getString(PrefKeys.lastGamePlayed);
  }

  // ==================== SECURITY ====================
  Future<void> setBiometricEnabled(bool enabled) async {
    await setBool(PrefKeys.biometricEnabled, enabled);
  }

  bool isBiometricEnabled() {
    return getBool(PrefKeys.biometricEnabled) ?? false;
  }

  Future<void> setPinCode(String pin) async {
    await setString(PrefKeys.pinCode, pin);
  }

  String? getPinCode() {
    return getString(PrefKeys.pinCode);
  }

  bool verifyPin(String inputPin) {
    final String? savedPin = getPinCode();
    return savedPin != null && savedPin == inputPin;
  }

  // ==================== CLEAR DATA ====================
  Future<void> clearUserData() async {
    await remove(PrefKeys.userData);
    await remove(PrefKeys.userId);
    await remove(PrefKeys.userName);
    await remove(PrefKeys.userEmail);
    await remove(PrefKeys.userCoins);
    await remove(PrefKeys.userDiamonds);
    await remove(PrefKeys.userTier);
    await remove(PrefKeys.authToken);
    await remove(PrefKeys.refreshToken);
    await setBool(PrefKeys.isLoggedIn, false);
  }

  Future<void> clearAllData() async {
    await clear();
    await clearHive();
  }
}