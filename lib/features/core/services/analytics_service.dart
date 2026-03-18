import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/models/user_models.dart';
import '../../../core/services/logger_service.dart';

class AnalyticsService {
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();
  static final AnalyticsService _instance = AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final LoggerService _logger = ServiceLocator().get<LoggerService>();

  // Initialize
  Future<void> initialize() async {
    await _analytics.setAnalyticsCollectionEnabled(true);
    _logger.info('Analytics service initialized');
  }

  // Track screen view
  Future<void> trackScreen(String screenName, {String? screenClass}) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      _logger.debug('Screen tracked: $screenName');
    } catch (e) {
      _logger.error('Failed to track screen: $screenName', error: e);
    }
  }

  // Track event
  Future<void> trackEvent(String eventName, {Map<String, Object?>? parameters}) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
      _logger.debug('Event tracked: $eventName');
    } catch (e) {
      _logger.error('Failed to track event: $eventName', error: e);
    }
  }

  // Track user login
  Future<void> trackLogin(String method) async {
    await trackEvent('login', parameters: {'method': method});
  }

  // Track sign up
  Future<void> trackSignUp(String method) async {
    await trackEvent('sign_up', parameters: {'method': method});
  }

  // Track user logout
  Future<void> trackLogout() async {
    await trackEvent('logout');
  }

  // Set user ID
  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
    if (userId != null) {
      _logger.info('Analytics user ID set: $userId');
    }
  }

  // Set user properties
  Future<void> setUserProperties(User user) async {
    try {
      await _analytics.setUserProperty(
        name: 'tier',
        value: user.tier.toString(),
      );
      await _analytics.setUserProperty(
        name: 'country',
        value: user.countryId,
      );
      await _analytics.setUserProperty(
        name: 'role',
        value: user.role.toString(),
      );
      await _analytics.setUserProperty(
        name: 'coins_balance',
        value: user.coins.toString(),
      );
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
      if (roomId != null) 'room_id': roomId,
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
      if (winAmount != null) 'win_amount': winAmount,
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
    });
  }

  // Track call ended
  Future<void> trackCallEnded({
    required String callType,
    required int duration,
  }) async {
    await trackEvent('call_ended', parameters: {
      'call_type': callType,
      'duration': duration,
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
    });
  }

  // Track room joined
  Future<void> trackRoomJoined(String roomId) async {
    await trackEvent('room_joined', parameters: {'room_id': roomId});
  }

  // Track purchase
  Future<void> trackPurchase({
    required String productId,
    required String productName,
    required double price,
    required String currency,
  }) async {
    await trackEvent('purchase', parameters: {
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'currency': currency,
    });
  }

  // Track level up
  Future<void> trackLevelUp(int newLevel) async {
    await trackEvent('level_up', parameters: {'new_level': newLevel});
  }

  // Track achievement unlocked
  Future<void> trackAchievementUnlocked(String achievementId) async {
    await trackEvent('achievement_unlocked', parameters: {
      'achievement_id': achievementId,
    });
  }

  // Track friend added
  Future<void> trackFriendAdded(String friendId) async {
    await trackEvent('friend_added', parameters: {'friend_id': friendId});
  }

  // Track clan joined
  Future<void> trackClanJoined(String clanId) async {
    await trackEvent('clan_joined', parameters: {'clan_id': clanId});
  }

  // Track PK battle
  Future<void> trackPKBattle({
    required String battleId,
    required bool won,
    required int score,
  }) async {
    await trackEvent('pk_battle', parameters: {
      'battle_id': battleId,
      'won': won,
      'score': score,
    });
  }

  // Track error
  Future<void> trackError({
    required String errorMessage,
    required String screen,
    StackTrace? stackTrace,
  }) async {
    await trackEvent('error', parameters: {
      'error_message': errorMessage,
      'screen': screen,
      if (stackTrace != null) 'stack_trace': stackTrace.toString(),
    });
  }

  // Get analytics observer for navigation
  FirebaseAnalyticsObserver getAnalyticsObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }

  // Reset analytics (for logout)
  Future<void> reset() async {
    await setUserId(null);
    _logger.info('Analytics reset');
  }
}