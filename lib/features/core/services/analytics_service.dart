import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/models/user_models.dart' as app;
import '../../../core/services/logger_service.dart';

class AnalyticsService {
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();
  static final AnalyticsService _instance = AnalyticsService._internal();

  late final SupabaseClient _supabase;
  final LoggerService _logger = ServiceLocator().get<LoggerService>();

  // Cache for current session
  String? _sessionId;
  String? _currentUserId;
  final List<Map<String, dynamic>> _eventBuffer = [];
  static const int _flushInterval = 30; // seconds
  static const int _batchSize = 20;

  // Initialize
  Future<void> initialize() async {
    try {
      _supabase = ServiceLocator().get<SupabaseClient>();
      _sessionId = _generateSessionId();

      // Start periodic flush
      _startPeriodicFlush();

      _logger.info('Analytics service initialized with Supabase');
    } catch (e) {
      _logger.error('Failed to initialize analytics', error: e);
    }
  }

  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}';
  }

  void _startPeriodicFlush() {
    Future.delayed(Duration(seconds: _flushInterval), () {
      _flushEvents();
      _startPeriodicFlush();
    });
  }

  Future<void> _flushEvents() async {
    if (_eventBuffer.isEmpty) return;

    final eventsToFlush = List<Map<String, dynamic>>.from(_eventBuffer);
    _eventBuffer.clear();

    try {
      await _supabase.from('analytics_events').insert(eventsToFlush);
      _logger.debug('Flushed ${eventsToFlush.length} analytics events');
    } catch (e) {
      // If flush fails, add back to buffer
      _eventBuffer.insertAll(0, eventsToFlush);
      if (_eventBuffer.length > 1000) {
        _eventBuffer.removeRange(1000, _eventBuffer.length);
      }
      _logger.error('Failed to flush analytics events', error: e);
    }
  }

  Future<void> _track({
    required String eventType,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final event = {
        'event_type': eventType,
        'session_id': _sessionId,
        'user_id': _currentUserId,
        'timestamp': DateTime.now().toIso8601String(),
        'platform': defaultTargetPlatform.name,
        'parameters': parameters ?? {},
        'app_version': await _getAppVersion(),
      };

      _eventBuffer.add(event);

      // Flush if buffer is full
      if (_eventBuffer.length >= _batchSize) {
        await _flushEvents();
      }
    } catch (e) {
      _logger.error('Failed to track event: $eventType', error: e);
    }
  }

  Future<String> _getAppVersion() async {
    // You can get this from pubspec.yaml or a config file
    return '1.0.0'; // Replace with actual app version
  }

  // Public tracking methods

  /// Track screen view
  Future<void> trackScreen(String screenName, {String? screenClass}) async {
    await _track(
      eventType: 'screen_view',
      parameters: {
        'screen_name': screenName,
        'screen_class': screenClass ?? screenName,
      },
    );
    _logger.debug('Screen tracked: $screenName');
  }

  /// Track custom event
  Future<void> trackEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    await _track(
      eventType: eventName,
      parameters: parameters,
    );
    _logger.debug('Event tracked: $eventName');
  }

  /// Track user login
  Future<void> trackLogin(String method) async {
    await _track(
      eventType: 'login',
      parameters: {'method': method},
    );
  }

  /// Track sign up
  Future<void> trackSignUp(String method) async {
    await _track(
      eventType: 'sign_up',
      parameters: {'method': method},
    );
  }

  /// Track user logout
  Future<void> trackLogout() async {
    await _track(eventType: 'logout');
    _currentUserId = null;
    _sessionId = _generateSessionId(); // New session on logout
  }

  /// Set user ID
  Future<void> setUserId(String? userId) async {
    _currentUserId = userId;
    if (userId != null) {
      await _track(
        eventType: 'user_identified',
        parameters: {'user_id': userId},
      );
      _logger.info('Analytics user ID set: $userId');
    }
  }

  /// Set user properties
  Future<void> setUserProperties(app.User user) async {
    try {
      await _track(
        eventType: 'user_properties',
        parameters: {
          'tier': user.tier.toString(),
          'country': user.countryId,
          'role': user.role.toString(),
          'coins_balance': user.coins,
          'username': user.username,
          'is_verified': user.isVerified,
        },
      );
      _logger.debug('User properties set');
    } catch (e) {
      _logger.error('Failed to set user properties', error: e);
    }
  }

  /// Track gift sent
  Future<void> trackGiftSent({
    required String giftId,
    required String giftName,
    required int price,
    required String receiverId,
    String? roomId,
  }) async {
    await _track(
      eventType: 'gift_sent',
      parameters: {
        'gift_id': giftId,
        'gift_name': giftName,
        'price': price,
        'receiver_id': receiverId,
        if (roomId != null) 'room_id': roomId,
      },
    );
  }

  /// Track game played
  Future<void> trackGamePlayed({
    required String gameName,
    required int betAmount,
    required bool won,
    int? winAmount,
  }) async {
    await _track(
      eventType: 'game_played',
      parameters: {
        'game_name': gameName,
        'bet_amount': betAmount,
        'won': won,
        if (winAmount != null) 'win_amount': winAmount,
        'net_result': (winAmount ?? 0) - betAmount,
      },
    );
  }

  /// Track call started
  Future<void> trackCallStarted({
    required String callType,
    required String targetId,
    bool isGroupCall = false,
  }) async {
    await _track(
      eventType: 'call_started',
      parameters: {
        'call_type': callType,
        'target_id': targetId,
        'is_group_call': isGroupCall,
      },
    );
  }

  /// Track call ended
  Future<void> trackCallEnded({
    required String callType,
    required int duration,
  }) async {
    await _track(
      eventType: 'call_ended',
      parameters: {
        'call_type': callType,
        'duration': duration,
      },
    );
  }

  /// Track room created
  Future<void> trackRoomCreated({
    required String roomId,
    required String roomName,
    required String category,
  }) async {
    await _track(
      eventType: 'room_created',
      parameters: {
        'room_id': roomId,
        'room_name': roomName,
        'category': category,
      },
    );
  }

  /// Track room joined
  Future<void> trackRoomJoined(String roomId) async {
    await _track(
      eventType: 'room_joined',
      parameters: {'room_id': roomId},
    );
  }

  /// Track purchase
  Future<void> trackPurchase({
    required String productId,
    required String productName,
    required double price,
    required String currency,
  }) async {
    await _track(
      eventType: 'purchase',
      parameters: {
        'product_id': productId,
        'product_name': productName,
        'price': price,
        'currency': currency,
        'revenue': price,
      },
    );
  }

  /// Track level up
  Future<void> trackLevelUp(int newLevel) async {
    await _track(
      eventType: 'level_up',
      parameters: {'new_level': newLevel},
    );
  }

  /// Track achievement unlocked
  Future<void> trackAchievementUnlocked(String achievementId) async {
    await _track(
      eventType: 'achievement_unlocked',
      parameters: {'achievement_id': achievementId},
    );
  }

  /// Track friend added
  Future<void> trackFriendAdded(String friendId) async {
    await _track(
      eventType: 'friend_added',
      parameters: {'friend_id': friendId},
    );
  }

  /// Track clan joined
  Future<void> trackClanJoined(String clanId) async {
    await _track(
      eventType: 'clan_joined',
      parameters: {'clan_id': clanId},
    );
  }

  /// Track PK battle
  Future<void> trackPKBattle({
    required String battleId,
    required bool won,
    required int score,
  }) async {
    await _track(
      eventType: 'pk_battle',
      parameters: {
        'battle_id': battleId,
        'won': won,
        'score': score,
      },
    );
  }

  /// Track error
  Future<void> trackError({
    required String errorMessage,
    required String screen,
    StackTrace? stackTrace,
  }) async {
    await _track(
      eventType: 'error',
      parameters: {
        'error_message': errorMessage,
        'screen': screen,
        if (stackTrace != null) 'stack_trace': stackTrace.toString(),
      },
    );
  }

  /// Force flush events
  Future<void> flush() async {
    await _flushEvents();
  }

  /// Get analytics reports (admin only) - FIXED
  Future<List<Map<String, dynamic>>> getAnalyticsReport({
    required DateTime startDate,
    required DateTime endDate,
    String? eventType,
    String? userId,
    int limit = 1000,
  }) async {
    try {
      var query = _supabase
          .from('analytics_events')
          .select()
          .gte('timestamp', startDate.toIso8601String())
          .lte('timestamp', endDate.toIso8601String())
          .order('timestamp', ascending: false)
          .limit(limit);

      if (eventType != null) {
        // FIXED: আলাদা কোয়েরি
        final response = await _supabase
            .from('analytics_events')
            .select()
            .gte('timestamp', startDate.toIso8601String())
            .lte('timestamp', endDate.toIso8601String())
            .eq('event_type', eventType)
            .order('timestamp', ascending: false)
            .limit(limit);
        return List<Map<String, dynamic>>.from(response);
      }

      if (userId != null) {
        // FIXED: আলাদা কোয়েরি
        final response = await _supabase
            .from('analytics_events')
            .select()
            .gte('timestamp', startDate.toIso8601String())
            .lte('timestamp', endDate.toIso8601String())
            .eq('user_id', userId)
            .order('timestamp', ascending: false)
            .limit(limit);
        return List<Map<String, dynamic>>.from(response);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.error('Failed to get analytics report', error: e);
      return [];
    }
  }

  /// Get user journey
  Future<List<Map<String, dynamic>>> getUserJourney(String userId) async {
    try {
      final response = await _supabase
          .from('analytics_events')
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: true)
          .limit(1000);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.error('Failed to get user journey', error: e);
      return [];
    }
  }

  /// Get event count by type
  Future<Map<String, int>> getEventCounts({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _supabase
          .from('analytics_events')
          .select('event_type')
          .gte('timestamp', startDate.toIso8601String())
          .lte('timestamp', endDate.toIso8601String());

      final Map<String, int> counts = {};
      for (var event in response) {
        final type = event['event_type'] as String;
        counts[type] = (counts[type] ?? 0) + 1;
      }
      return counts;
    } catch (e) {
      _logger.error('Failed to get event counts', error: e);
      return {};
    }
  }

  /// Get daily active users
  Future<Map<String, int>> getDailyActiveUsers({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _supabase
          .from('analytics_events')
          .select('user_id, timestamp')
          .gte('timestamp', startDate.toIso8601String())
          .lte('timestamp', endDate.toIso8601String());

      final Map<String, Set<String>> dailyUsers = {};

      for (var event in response) {
        final date = DateTime.parse(event['timestamp']).toIso8601String().substring(0, 10);
        final userId = event['user_id'] as String?;

        if (userId != null) {
          dailyUsers.putIfAbsent(date, () => {}).add(userId);
        }
      }

      return dailyUsers.map((date, users) => MapEntry(date, users.length));
    } catch (e) {
      _logger.error('Failed to get daily active users', error: e);
      return {};
    }
  }

  /// Reset analytics (for logout)
  Future<void> reset() async {
    await flush();
    _currentUserId = null;
    _sessionId = _generateSessionId();
    _logger.info('Analytics reset');
  }

  /// Dispose
  Future<void> dispose() async {
    await flush();
    _eventBuffer.clear();
  }
}

// FIXED: Navigation observer for automatic screen tracking
class AnalyticsRouteObserver extends NavigatorObserver {
  final AnalyticsService _analytics;

  AnalyticsRouteObserver(this._analytics);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _sendScreenView(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      _sendScreenView(previousRoute);
    }
  }

  void _sendScreenView(Route<dynamic> route) {
    if (route.settings.name != null) {
      _analytics.trackScreen(route.settings.name!);
    }
  }
}