import 'package:flutter/foundation.dart';
import '../../core/services/analytics_service.dart';
import '../../core/di/service_locator.dart';
import '../../core/models/user_models.dart' as app;

mixin AnalyticsMixin {
  AnalyticsService? _analytics;

  // Lazy initialization with null check
  AnalyticsService get _analyticsService {
    _analytics ??= ServiceLocator().get<AnalyticsService>();
    return _analytics!;
  }

  // Safe track screen
  Future<void> trackScreen(String screenName) async {
    if (screenName.isEmpty) {
      debugPrint('⚠️ trackScreen called with empty screenName');
      return;
    }

    try {
      await _analyticsService.trackScreen(screenName);
    } catch (e, stack) {
      debugPrint('❌ Error tracking screen: $e');
      debugPrint('Stack trace: $stack');
    }
  }

  // Safe track event
  Future<void> trackEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    if (eventName.isEmpty) {
      debugPrint('⚠️ trackEvent called with empty eventName');
      return;
    }

    try {
      await _analyticsService.trackEvent(
        eventName,
        parameters: parameters ?? {},
      );
    } catch (e, stack) {
      debugPrint('❌ Error tracking event: $e');
      debugPrint('Stack trace: $stack');
    }
  }

  // Track user login
  Future<void> trackLogin(String method) async {
    if (method.isEmpty) {
      debugPrint('⚠️ trackLogin called with empty method');
      return;
    }

    try {
      await _analyticsService.trackLogin(method);
    } catch (e, stack) {
      debugPrint('❌ Error tracking login: $e');
      debugPrint('Stack trace: $stack');
    }
  }

  // Track sign up
  Future<void> trackSignUp(String method) async {
    if (method.isEmpty) {
      debugPrint('⚠️ trackSignUp called with empty method');
      return;
    }

    try {
      await _analyticsService.trackSignUp(method);
    } catch (e, stack) {
      debugPrint('❌ Error tracking sign up: $e');
      debugPrint('Stack trace: $stack');
    }
  }

  // Track share
  Future<void> trackShare(String contentType, String itemId) async {
    try {
      await _analyticsService.trackEvent('share', parameters: {
        'content_type': contentType ?? '',
        'item_id': itemId ?? '',
        'method': '',
      });
    } catch (e, stack) {
      debugPrint('❌ Error tracking share: $e');
      debugPrint('Stack trace: $stack');
    }
  }

  // Track purchase
  Future<void> trackPurchase({
    double? value,
    String? currency,
    String? transactionId,
  }) async {
    // Null check for required parameters
    if (value == null || currency == null || transactionId == null) {
      debugPrint('⚠️ trackPurchase called with null parameters');
      return;
    }

    try {
      await _analyticsService.trackPurchase(
        productId: transactionId,
        productName: 'purchase',
        price: value,
        currency: currency,
      );
    } catch (e, stack) {
      debugPrint('❌ Error tracking purchase: $e');
      debugPrint('Stack trace: $stack');
    }
  }

  // Track gift send
  Future<void> trackGiftSend(String? giftId, int? coins) async {
    if (giftId == null || giftId.isEmpty || coins == null) {
      debugPrint('⚠️ trackGiftSend called with null parameters');
      return;
    }

    try {
      await _analyticsService.trackGiftSent(
        giftId: giftId,
        giftName: '',
        price: coins,
        receiverId: '',
      );
    } catch (e, stack) {
      debugPrint('❌ Error tracking gift send: $e');
      debugPrint('Stack trace: $stack');
    }
  }

  // Track game play
  Future<void> trackGamePlay(String? gameName, bool? won, int? bet) async {
    if (gameName == null || gameName.isEmpty || won == null || bet == null) {
      debugPrint('⚠️ trackGamePlay called with null parameters');
      return;
    }

    try {
      await _analyticsService.trackGamePlayed(
        gameName: gameName,
        betAmount: bet,
        won: won,
      );
    } catch (e, stack) {
      debugPrint('❌ Error tracking game play: $e');
      debugPrint('Stack trace: $stack');
    }
  }


  Future<void> setUserProperties({
    String? userId,
    String? tier,
    String? country,
  }) async {

    if (userId == null || userId.isEmpty) {
      debugPrint('⚠️ setUserProperties called with null userId');
      return;
    }

    try {

      await _analyticsService.trackEvent('user_properties', parameters: {
        'user_id': userId,
        'tier': tier ?? 'normal',
        'country': country ?? '',
      });
    } catch (e, stack) {
      debugPrint('❌ Error setting user properties: $e');
      debugPrint('Stack trace: $stack');
    }
  }

  // Parse tier string to enum
  app.UserTier _parseTier(String tier) {
    if (tier.isEmpty) return app.UserTier.normal;

    switch (tier.toLowerCase()) {
      case 'vip':
        return app.UserTier.vip;
      case 'svip':
        return app.UserTier.svip;
      default:
        return app.UserTier.normal;
    }
  }
}

// Debug print helper
void debugPrint(String message) {
  if (kDebugMode) {
    print(message);
  }
}