import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../di/service_locator.dart';
import '../models/user_models.dart' as app;
import 'logger_service.dart';

class AnalyticsService {
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();
  static final AnalyticsService _instance = AnalyticsService._internal();

  late final SupabaseClient _supabase;
  late final LoggerService _logger;

  // Cache for user properties
  String? _currentUserId;
  Map<String, dynamic> _userProperties = {};

  // Initialize
  Future<void> initialize() async {
    try {
      _supabase = getService<SupabaseClient>();
      _logger = getService<LoggerService>();

      // Create analytics table if not exists (optional - can be done via migration)
      await _ensureAnalyticsTable();

      _logger.info('Supabase Analytics service initialized');
    } catch (e) {
      debugPrint('Error initializing analytics: $e');
    }
  }

  // Ensure analytics table exists
  Future<void> _ensureAnalyticsTable() async {
    try {
      // Check if table exists by trying to select from it
      await _supabase.from('analytics_events').select('id').limit(1);
    } catch (e) {
      // Table doesn't exist, create it via RPC or migration
      debugPrint('Analytics table not found. Please run migrations.');
      // You can optionally create it via SQL RPC if you have the permission
    }
  }

  // Track screen view
  Future<void> trackScreen(String screenName, {String? screenClass, Map<String, dynamic>? parameters}) async {
    try {
      final eventData = {
        'event_type': 'screen_view',
        'screen_name': screenName,
        'screen_class': screenClass ?? screenName,
        'timestamp': DateTime.now().toIso8601String(),
        'user_id': _currentUserId,
        'parameters': parameters ?? {},
      };

      await _insertAnalyticsEvent(eventData);
      _logger.debug('Screen tracked: $screenName');

      // Track with additional parameters if provided
      if (parameters != null && parameters.isNotEmpty) {
        await trackEvent('screen_view_details', parameters: {
          'screen_name': screenName,
          ...parameters,
        });
      }
    } catch (e) {
      _logger.error('Failed to track screen: $screenName', error: e);
    }
  }

  // Track custom event
  Future<void> trackEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    try {
      final eventData = {
        'event_type': eventName,
        'timestamp': DateTime.now().toIso8601String(),
        'user_id': _currentUserId,
        'parameters': parameters ?? {},
        'user_properties': _userProperties,
        'device_info': await _getDeviceInfo(),
      };

      await _insertAnalyticsEvent(eventData);
      _logger.debug('Event tracked: $eventName');
    } catch (e) {
      _logger.error('Failed to track event: $eventName', error: e);
    }
  }

  // Insert analytics event to Supabase
  Future<void> _insertAnalyticsEvent(Map<String, dynamic> eventData) async {
    try {
      await _supabase.from('analytics_events').insert({
        'event_type': eventData['event_type'],
        'user_id': eventData['user_id'],
        'session_id': await _getSessionId(),
        'timestamp': eventData['timestamp'],
        'data': eventData, // Store full event data as JSON
        'platform': defaultTargetPlatform.name,
        'app_version': await _getAppVersion(),
      });
    } catch (e) {
      // Log locally if insert fails (offline support)
      _logLocalEvent(eventData);
    }
  }

  // Get device info
  Future<Map<String, String>> _getDeviceInfo() async {
    return {
      'platform': defaultTargetPlatform.name,
      'is_web': kIsWeb.toString(),
      'is_debug': kDebugMode.toString(),
    };
  }

  // Get session ID
  Future<String> _getSessionId() async {
    // You can implement session management here
    // For now, generate a simple session ID
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Get app version
  Future<String> _getAppVersion() async {
    // Implement app version retrieval
    return '1.0.0'; // Replace with actual app version
  }

  // Log event locally when offline
  void _logLocalEvent(Map<String, dynamic> eventData) {
    // Store in local storage for later sync
    // You can implement using SharedPreferences or Hive
    debugPrint('Local analytics event: $eventData');
  }

  // Track user login
  Future<void> trackLogin(String method, {String? userId}) async {
    await trackEvent('login', parameters: {
      'method': method,
      'user_id': userId,
    });
  }

  // Track sign up
  Future<void> trackSignUp(String method, {String? userId}) async {
    await trackEvent('sign_up', parameters: {
      'method': method,
      'user_id': userId,
    });
  }

  // Track user logout
  Future<void> trackLogout() async {
    await trackEvent('logout');
    _currentUserId = null;
    _userProperties.clear();
  }

  // Set user ID
  Future<void> setUserId(String? userId) async {
    _currentUserId = userId;
    if (userId != null) {
      _logger.info('Analytics user ID set: $userId');

      // Track user session start
      await trackEvent('session_start', parameters: {
        'user_id': userId,
      });
    }
  }

  // Set user properties
  Future<void> setUserProperties(app.User user) async {
    try {
      _userProperties = {
        'tier': user.tier?.toString() ?? 'normal',
        'country': user.countryId,
        'role': user.role.toString().split('.').last,
        'coins_balance': user.coins,
        'username': user.username,
        'is_verified': user.isVerified,
        'created_at': user.createdAt.toIso8601String(),
      };

      // Update user profile in users table with analytics properties
      await _supabase.from('users').update({
        'last_active_at': DateTime.now().toIso8601String(),
        'analytics_properties': _userProperties,
      }).eq('id', user.id);

      // Track user property update
      await trackEvent('user_properties_updated', parameters: _userProperties);

      _logger.debug('User properties set');
    } catch (e) {
      _logger.error('Failed to set user properties', error: e);
    }
  }

  // Track gift sent
  Future<void> trackGiftSent({
    required String giftId,
    required String giftName,
    required int price,
    required String receiverId,
    String? roomId,
  }) async {
    await trackEvent('gift_sent', parameters: {
      'gift_id': giftId,
      'gift_name': giftName,
      'price': price,
      'receiver_id': receiverId,
      'room_id': roomId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Track game played
  Future<void> trackGamePlayed({
    required String gameName,
    required int betAmount,
    required bool won,
    int? winAmount,
  }) async {
    await trackEvent('game_played', parameters: {
      'game_name': gameName,
      'bet_amount': betAmount,
      'won': won,
      'win_amount': winAmount ?? 0,
      'net_result': (winAmount ?? 0) - betAmount,
    });
  }

  // Track call started
  Future<void> trackCallStarted({
    required String callType,
    required String targetId,
    bool isGroupCall = false,
  }) async {
    await trackEvent('call_started', parameters: {
      'call_type': callType,
      'target_id': targetId,
      'is_group_call': isGroupCall,
      'start_time': DateTime.now().toIso8601String(),
    });
  }

  // Track call ended
  Future<void> trackCallEnded({
    required String callType,
    required int duration,
    String? callQuality,
  }) async {
    await trackEvent('call_ended', parameters: {
      'call_type': callType,
      'duration': duration,
      'call_quality': callQuality ?? 'unknown',
      'end_time': DateTime.now().toIso8601String(),
    });
  }

  // Track room created
  Future<void> trackRoomCreated({
    required String roomId,
    required String roomName,
    required String category,
  }) async {
    await trackEvent('room_created', parameters: {
      'room_id': roomId,
      'room_name': roomName,
      'category': category,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Track room joined
  Future<void> trackRoomJoined(String roomId, {String? userId}) async {
    await trackEvent('room_joined', parameters: {
      'room_id': roomId,
      'user_id': userId ?? _currentUserId,
    });
  }

  // Track purchase
  Future<void> trackPurchase({
    required String productId,
    required String productName,
    required double price,
    required String currency,
    String? transactionId,
  }) async {
    await trackEvent('purchase', parameters: {
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'currency': currency,
      'transaction_id': transactionId,
      'revenue': price, // For revenue tracking
    });
  }

  // Track level up
  Future<void> trackLevelUp(int newLevel, {String? gameType}) async {
    await trackEvent('level_up', parameters: {
      'new_level': newLevel,
      'game_type': gameType ?? 'general',
      'previous_level': newLevel - 1,
    });
  }

  // Track achievement unlocked
  Future<void> trackAchievementUnlocked(String achievementId, {String? achievementName}) async {
    await trackEvent('achievement_unlocked', parameters: {
      'achievement_id': achievementId,
      'achievement_name': achievementName ?? achievementId,
    });
  }

  // Track friend added
  Future<void> trackFriendAdded(String friendId, {String? method}) async {
    await trackEvent('friend_added', parameters: {
      'friend_id': friendId,
      'method': method ?? 'search',
    });
  }

  // Track agency joined
  Future<void> trackAgencyJoined(String agencyId, {String? agencyName}) async {
    await trackEvent('agency_joined', parameters: {
      'agency_id': agencyId,
      'agency_name': agencyName ?? agencyId,
    });
  }

  // Track PK battle
  Future<void> trackPKBattle({
    required String battleId,
    required bool won,
    required int score,
    String? opponentId,
  }) async {
    await trackEvent('pk_battle', parameters: {
      'battle_id': battleId,
      'won': won,
      'score': score,
      'opponent_id': opponentId,
      'result': won ? 'win' : 'loss',
    });
  }

  // Track error
  Future<void> trackError({
    required String errorMessage,
    required String screen,
    StackTrace? stackTrace,
    String? errorCode,
  }) async {
    await trackEvent('error', parameters: {
      'error_message': errorMessage,
      'screen': screen,
      'error_code': errorCode ?? 'unknown',
      'stack_trace': stackTrace?.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Get analytics reports (for admin)
  Future<List<Map<String, dynamic>>> getAnalyticsReport({
    required DateTime startDate,
    required DateTime endDate,
    String? eventType,
    String? userId,
  }) async {
    try {
      var query = _supabase
          .from('analytics_events')
          .select()
          .gte('timestamp', startDate.toIso8601String())
          .lte('timestamp', endDate.toIso8601String());

      if (eventType != null) {
        query = query.eq('event_type', eventType);
      }

      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      final response = await query.order('timestamp', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.error('Failed to get analytics report', error: e);
      return [];
    }
  }

  // Get user journey
  Future<List<Map<String, dynamic>>> getUserJourney(String userId) async {
    try {
      final response = await _supabase
          .from('analytics_events')
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.error('Failed to get user journey', error: e);
      return [];
    }
  }

  // Reset analytics (for logout)
  Future<void> reset() async {
    await trackEvent('session_end', parameters: {
      'user_id': _currentUserId,
      'duration_ms': DateTime.now().millisecondsSinceEpoch,
    });

    _currentUserId = null;
    _userProperties.clear();
    _logger.info('Analytics reset');
  }
}

// Extension for easier navigation tracking (Fixed)
extension NavigationTracking on NavigatorObserver {
  void trackPageView(String routeName) {
    final analytics = getService<AnalyticsService>();
    analytics.trackScreen(routeName);
  }
}

// Or alternatively, create a widget for automatic tracking
class AnalyticsRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    _sendScreenView(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute != null) {
      _sendScreenView(previousRoute);
    }
  }

  void _sendScreenView(Route route) {
    if (route.settings.name != null) {
      final analytics = getService<AnalyticsService>();
      analytics.trackScreen(route.settings.name!);
    }
  }
}