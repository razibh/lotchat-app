import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class ConfigService {
  factory ConfigService() => _instance;
  ConfigService._internal();
  static final ConfigService _instance = ConfigService._internal();

  late FirebaseRemoteConfig _remoteConfig;
  late SharedPreferences _prefs;

  // Local config cache
  final Map<String, dynamic> _localConfig = {};

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

    // Initialize Remote Config
    _remoteConfig = FirebaseRemoteConfig.instance;

    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await _remoteConfig.setDefaults(_defaultConfig);

    // Fetch remote config
    await _fetchRemoteConfig();

    // Load local config
    _loadLocalConfig();
  }

  Future<void> _fetchRemoteConfig() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Failed to fetch remote config: $e');
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
      return _localConfig[key] as T;
    }

    // Check remote config
    try {
      final value = _remoteConfig.getValue(key);

      if (T == String) {
        return value.asString() as T;
      } else if (T == bool) {
        return value.asBool() as T;
      } else if (T == int) {
        return value.asInt() as T;
      } else if (T == double) {
        return value.asDouble() as T;
      }
    } catch (e) {
      // Fall back to default
    }

    // Check default values
    if (_defaultConfig.containsKey(key)) {
      return _defaultConfig[key] as T;
    }

    if (defaultValue != null) {
      return defaultValue;
    }

    throw Exception('Config key not found: $key');
  }

  // ==================== FEATURE FLAGS ====================

  bool isFeatureEnabled(String featureName) {
    return get<bool>('enable_$featureName');
  }

  // ==================== LOCAL OVERRIDES ====================

  Future<void> setLocalOverride(String key, dynamic value) async {
    _localConfig[key] = value;

    // 🟢 Fixed: SharedPreferences set method
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

  // ==================== DYNAMIC CONFIG ====================

  // Get config for specific user tier
  Map<String, dynamic> getConfigForTier(String tier) {
    final Map<String, dynamic> config = {};

    // Tier-specific limits
    config['max_gifts_per_minute'] = get<int>('max_gifts_per_minute') * _getTierMultiplier(tier);
    config['max_friends'] = get<int>('max_friends') * _getTierMultiplier(tier);

    return config;
  }

  int _getTierMultiplier(String tier) {
    if (tier.startsWith('svip')) return 3;
    if (tier.startsWith('vip')) return 2;
    return 1;
  }

  // ==================== MAINTENANCE MODE ====================

  bool get isInMaintenanceMode => get<bool>('is_maintenance_mode');

  String get maintenanceMessage => get<String>('maintenance_message');

  // ==================== VERSION CHECK ====================

  bool isAppVersionSupported(String currentVersion) {
    final String minVersion = get<String>('min_app_version');
    return _compareVersions(currentVersion, minVersion) >= 0;
  }

  int _compareVersions(String v1, String v2) {
    final List<int> parts1 = v1.split('.').map(int.parse).toList();
    final List<int> parts2 = v2.split('.').map(int.parse).toList();

    for (var i = 0; i < parts1.length; i++) {
      if (i >= parts2.length) return 1;
      if (parts1[i] > parts2[i]) return 1;
      if (parts1[i] < parts2[i]) return -1;
    }

    return parts1.length == parts2.length ? 0 : -1;
  }

  // ==================== REFRESH CONFIG ====================

  Future<void> refreshConfig() async {
    await _fetchRemoteConfig();
  }

  // ==================== GET ALL CONFIG ====================

  Map<String, dynamic> getAllConfig() {
    final Map<String, dynamic> config = {};

    // Add default values
    config.addAll(_defaultConfig);

    // Override with remote values
    for (String key in _defaultConfig.keys) {
      try {
        final value = _remoteConfig.getValue(key);
        // 🟢 Fixed: Always use remote value if available
        config[key] = _getValueAsDynamic(value);
      } catch (e) {
        // Skip
      }
    }

    // Override with local values
    config.addAll(_localConfig);

    return config;
  }

  dynamic _getValueAsDynamic(RemoteConfigValue value) {
    // 🟢 Fixed: Correct way to get value
    try {
      return value.asString();
    } catch (e) {
      try {
        return value.asBool();
      } catch (e) {
        try {
          return value.asInt();
        } catch (e) {
          try {
            return value.asDouble();
          } catch (e) {
            return null;
          }
        }
      }
    }
  }

  // ==================== RESET ====================

  Future<void> resetToDefault() async {
    clearLocalOverrides();
    await _remoteConfig.setDefaults(_defaultConfig);
    await _remoteConfig.fetchAndActivate();
  }
}