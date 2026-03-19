import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../di/service_locator.dart';

class ConfigService {
  factory ConfigService() => _instance;
  ConfigService._internal();
  static final ConfigService _instance = ConfigService._internal();

  late final SupabaseClient _supabase;
  late SharedPreferences _prefs;

  // Local config cache
  final Map<String, dynamic> _localConfig = {};

  // Remote config cache
  Map<String, dynamic> _remoteConfig = {};

  // Last fetch time
  DateTime? _lastFetchTime;

  // Cache duration
  static const Duration _cacheDuration = Duration(hours: 1);


  // Default values
  static const Map<String, dynamic> _defaultConfig = {
    // App settings
    'app_name': 'LotChat',
    'app_version': '1.0.0',
    'min_app_version': '1.0.0',

    // Feature flags
    'enable_games': true,
    'enable_pk_battle': true,
    'enable_clan_system': true,
    'enable_voice_translation': false,
    'enable_screen_recording': true,
    'enable_auto_moderation': true,

    // Limits
    'max_room_viewers': 1000,
    'max_room_seats': 9,
    'max_gifts_per_minute': 10,
    'max_messages_per_minute': 30,
    'max_friends': 5000,

    // Coins & diamonds
    'coin_per_dollar': 10000,
    'diamond_per_coin': 2,
    'gift_commission_rate': 0.1,
    'withdrawal_minimum': 1000,

    // Games
    'roulette_min_bet': 100,
    'roulette_max_bet': 10000,
    'three_patti_min_bet': 500,
    'three_patti_max_bet': 50000,

    // Maintenance
    'is_maintenance_mode': false,
    'maintenance_message': 'Under maintenance',

    // Ad settings
    'show_ads': false,
    'ad_frequency': 5,

    // AI recommendations
    'enable_ai_recommendations': true,
    'recommendation_count': 20,

    // Security
    'max_login_attempts': 5,
    'session_timeout_minutes': 60,
    'require_email_verification': false,

    // Moderation
    'auto_ban_threshold': 5,
    'enable_slang_detection': true,

    // Performance
    'cache_max_age_hours': 24,
    'image_cache_size_mb': 100,

    // API endpoints
    'api_base_url': 'https://api.lotchat.com/v1',
    'socket_url': 'wss://socket.lotchat.com',
  };

  // ==================== INITIALIZATION ====================
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _supabase = getService<SupabaseClient>();

    // Load local config
    _loadLocalConfig();

    // Fetch remote config
    await _fetchRemoteConfig();

    debugPrint(' ConfigService initialized with Supabase');
  }

  Future<void> _fetchRemoteConfig() async {
    try {
      // Check cache first
      if (_lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        return;
      }

      final response = await _supabase
          .from('app_config')
          .select();

      _remoteConfig = {};
      for (var item in response) {
        final key = item['key'] as String;
        final value = item['value'];
        final type = item['type'] as String? ?? 'string';

        _remoteConfig[key] = _parseValue(value, type);
      }

      _lastFetchTime = DateTime.now();
      debugPrint(' Remote config fetched: ${_remoteConfig.length} items');
    } catch (e) {
      debugPrint(' Failed to fetch remote config: $e');
    }
  }

  dynamic _parseValue(dynamic value, String type) {
    try {
      switch (type) {
        case 'boolean':
          if (value is bool) return value;
          if (value is String) return value.toLowerCase() == 'true';
          if (value is num) return value == 1;
          return false;

        case 'integer':
          if (value == null) return 0;
          if (value is int) return value;
          if (value is double) return value.toInt();
          if (value is String) return int.tryParse(value) ?? 0;
          if (value is num) return value.toInt();
          return 0;

        case 'float':
        case 'double':
          if (value == null) return 0.0;
          if (value is double) return value;
          if (value is int) return value.toDouble();
          if (value is String) return double.tryParse(value) ?? 0.0;
          if (value is num) return value.toDouble();
          return 0.0;

        case 'json':
          if (value is String) {
            try {
              return json.decode(value);
            } catch (e) {
              return {};
            }
          }
          return value ?? {};

        case 'array':
          if (value is String) {
            try {
              final decoded = json.decode(value);
              return decoded is List ? decoded : [];
            } catch (e) {
              return [];
            }
          }
          return value is List ? value : [];

        default:
          return value?.toString() ?? '';
      }
    } catch (e) {
      debugPrint('Error parsing value: $e');
      return value;
    }
  }

  void _loadLocalConfig() {
    final Set<String> keys = _prefs.getKeys();
    for (final String key in keys) {
      if (key.startsWith('config_')) {
        final String configKey = key.substring(7);
        _localConfig[configKey] = _prefs.get(key);
      }
    }
  }

  // ==================== GET CONFIG ====================

  T get<T>(String key, {T? defaultValue}) {
    // Check local override first
    if (_localConfig.containsKey(key)) {
      final value = _localConfig[key];
      if (value is T) return value;
    }

    // Check remote config
    if (_remoteConfig.containsKey(key)) {
      final value = _remoteConfig[key];
      if (value is T) return value;
    }

    // Check default values
    if (_defaultConfig.containsKey(key)) {
      final value = _defaultConfig[key];
      if (value is T) return value;
    }

    if (defaultValue != null) {
      return defaultValue;
    }

    throw Exception('Config key not found: $key or type mismatch');
  }

  // Type-specific getters for convenience
  String getString(String key, {String? defaultValue}) {
    return get<String>(key, defaultValue: defaultValue) ?? defaultValue ?? '';
  }

  int getInt(String key, {int? defaultValue}) {
    return get<int>(key, defaultValue: defaultValue) ?? defaultValue ?? 0;
  }

  double getDouble(String key, {double? defaultValue}) {
    return get<double>(key, defaultValue: defaultValue) ?? defaultValue ?? 0.0;
  }

  bool getBool(String key, {bool? defaultValue}) {
    return get<bool>(key, defaultValue: defaultValue) ?? defaultValue ?? false;
  }

  // ==================== FEATURE FLAGS ====================

  bool isFeatureEnabled(String featureName) {
    return getBool('enable_$featureName', defaultValue: false);
  }

  // ==================== LOCAL OVERRIDES ====================

  Future<void> setLocalOverride(String key, dynamic value) async {
    _localConfig[key] = value;

    if (value is String) {
      await _prefs.setString('config_$key', value);
    } else if (value is bool) {
      await _prefs.setBool('config_$key', value);
    } else if (value is int) {
      await _prefs.setInt('config_$key', value);
    } else if (value is double) {
      await _prefs.setDouble('config_$key', value);
    } else if (value is List<String>) {
      await _prefs.setStringList('config_$key', value);
    } else {
      // For other types, convert to string
      await _prefs.setString('config_$key', value.toString());
    }
  }

  Future<void> removeLocalOverride(String key) async {
    _localConfig.remove(key);
    await _prefs.remove('config_$key');
  }

  void clearLocalOverrides() {
    final Iterable<String> keys = _prefs.getKeys().where((String k) => k.startsWith('config_'));
    for (final String key in keys) {
      _prefs.remove(key);
    }
    _localConfig.clear();
  }

  // ==================== REMOTE CONFIG UPDATE (Admin only) ====================

  Future<void> updateRemoteConfig(String key, dynamic value, {String? type}) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) throw Exception('Not authenticated');

      // Check if user is admin
      final isAdmin = await _isUserAdmin(session.user.id);
      if (!isAdmin) throw Exception('Admin access required');

      final detectedType = type ?? _detectType(value);
      final processedValue = _processValueForStorage(value, detectedType);

      final existing = await _supabase
          .from('app_config')
          .select()
          .eq('key', key)
          .maybeSingle();

      if (existing != null) {

        await _saveConfigHistory(key, existing['value'], processedValue, session.user.id);

        // Update existing
        await _supabase
            .from('app_config')
            .update({
          'value': processedValue,
          'type': detectedType,
          'updated_by': session.user.id,
          'updated_at': DateTime.now().toIso8601String(),
        })
            .eq('key', key);
      } else {
        // Insert new
        await _supabase.from('app_config').insert({
          'key': key,
          'value': processedValue,
          'type': detectedType,
          'description': 'Auto-generated config',
          'created_by': session.user.id,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Update local cache
      _remoteConfig[key] = value;
      _lastFetchTime = null; // Force refresh next time

      debugPrint(' Remote config updated: $key');
    } catch (e) {
      debugPrint(' Failed to update remote config: $e');
      rethrow;
    }
  }

  Future<void> _saveConfigHistory(String key, String? oldValue, String newValue, String userId) async {
    try {
      await _supabase.from('app_config_history').insert({
        'key': key,
        'old_value': oldValue,
        'new_value': newValue,
        'changed_by': userId,
        'changed_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error saving config history: $e');
    }
  }

  Future<bool> _isUserAdmin(String userId) async {
    try {
      final response = await _supabase
          .from('user_roles')
          .select('role')
          .eq('user_id', userId)
          .eq('role', 'admin')
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  String _detectType(dynamic value) {
    if (value is bool) return 'boolean';
    if (value is int) return 'integer';
    if (value is double) return 'float';
    if (value is List) return 'array';
    if (value is Map) return 'json';
    return 'string';
  }

  String _processValueForStorage(dynamic value, String type) {
    if (type == 'json' || type == 'array') {
      return json.encode(value);
    }
    return value?.toString() ?? '';
  }

  // ==================== DYNAMIC CONFIG ====================


  Map<String, dynamic> getConfigForTier(String tier) {
    final Map<String, dynamic> config = {};


    config['max_gifts_per_minute'] = getInt('max_gifts_per_minute') * _getTierMultiplier(tier);
    config['max_friends'] = getInt('max_friends') * _getTierMultiplier(tier);

    // Get tier-specific config if exists
    final tierConfig = _remoteConfig['tier_${tier}_config'];
    if (tierConfig != null && tierConfig is Map) {
      config.addAll(tierConfig as Map<String, dynamic>);
    }

    return config;
  }

  int _getTierMultiplier(String tier) {
    if (tier.startsWith('svip')) return 3;
    if (tier.startsWith('vip')) return 2;
    return 1;
  }

  // ==================== MAINTENANCE MODE ====================

  bool get isInMaintenanceMode => getBool('is_maintenance_mode', defaultValue: false);

  String get maintenanceMessage => getString('maintenance_message', defaultValue: 'Under maintenance');

  // ==================== VERSION CHECK ====================

  bool isAppVersionSupported(String currentVersion) {
    try {
      final String minVersion = getString('min_app_version');
      return _compareVersions(currentVersion, minVersion) >= 0;
    } catch (e) {
      return true;
    }
  }

  int _compareVersions(String v1, String v2) {
    try {
      final List<int> parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final List<int> parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      for (var i = 0; i < parts1.length; i++) {
        if (i >= parts2.length) return 1;
        if (parts1[i] > parts2[i]) return 1;
        if (parts1[i] < parts2[i]) return -1;
      }

      return parts1.length == parts2.length ? 0 : -1;
    } catch (e) {
      return 0;
    }
  }

  // ==================== REFRESH CONFIG ====================

  Future<void> refreshConfig() async {
    _lastFetchTime = null;
    await _fetchRemoteConfig();
  }

  // ==================== GET ALL CONFIG ====================

  Map<String, dynamic> getAllConfig() {
    final Map<String, dynamic> config = {};

    // Add default values
    config.addAll(_defaultConfig);

    // Override with remote values
    config.addAll(_remoteConfig);

    // Override with local values
    config.addAll(_localConfig);

    return config;
  }

  // ==================== CONFIG HISTORY ====================

  Future<List<Map<String, dynamic>>> getConfigHistory(String key) async {
    try {
      final response = await _supabase
          .from('app_config_history')
          .select()
          .eq('key', key)
          .order('changed_at', ascending: false)
          .limit(50);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Failed to get config history: $e');
      return [];
    }
  }

  // ==================== BULK CONFIG UPDATE ====================

  Future<void> updateBulkConfig(Map<String, dynamic> configs) async {
    for (var entry in configs.entries) {
      try {
        await updateRemoteConfig(entry.key, entry.value);
      } catch (e) {
        debugPrint('Failed to update ${entry.key}: $e');
      }
    }
  }

  // ==================== RESET ====================

  Future<void> resetToDefault() async {
    clearLocalOverrides();
    _remoteConfig.clear();
    _lastFetchTime = null;
    await _fetchRemoteConfig();

    debugPrint('✅ Config reset to default');
  }

  // ==================== EXPORT/IMPORT ====================

  String exportConfig() {
    return json.encode({
      'remote': _remoteConfig,
      'local': _localConfig,
      'default': _defaultConfig,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> importConfig(String jsonString) async {
    try {
      final Map<String, dynamic> data = json.decode(jsonString);
      if (data.containsKey('local')) {
        final local = data['local'] as Map;
        for (var entry in local.entries) {
          await setLocalOverride(entry.key, entry.value);
        }
      }
      debugPrint('✅ Config imported');
    } catch (e) {
      debugPrint('❌ Failed to import config: $e');
    }
  }

  // ==================== STREAM CONFIG CHANGES (Alternative to Realtime) ====================

  Stream<Map<String, dynamic>> watchConfigChanges() {

    return Stream.periodic(const Duration(minutes: 5), (_) {
      refreshConfig();
      return getAllConfig();
    });
  }
}