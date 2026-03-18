import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

mixin AnalyticsMixin {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Track screen view
  Future<void> trackScreen(String screenName) {
    return _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );
  }

  // Track event
  Future<void> trackEvent(String eventName, {Map<String, dynamic>? parameters}) {
    return _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }

  // Track user login
  Future<void> trackLogin(String method) {
    return _analytics.logLogin(loginMethod: method);
  }

  // Track sign up
  Future<void> trackSignUp(String method) {
    return _analytics.logSignUp(signUpMethod: method);
  }

  // Track share
  Future<void> trackShare(String contentType, String itemId) {
    return _analytics.logShare(
      contentType: contentType,
      itemId: itemId, method: '',
    );
  }

  // Track purchase
  Future<void> trackPurchase({
    required double value,
    required String currency,
    required String transactionId,
  }) {
    return _analytics.logPurchase(
      value: value,
      currency: currency,
      transactionId: transactionId,
    );
  }

  // Track gift send
  Future<void> trackGiftSend(String giftId, int coins) {
    return trackEvent('gift_send', parameters: <String, dynamic>{
      'gift_id': giftId,
      'coins': coins,
    },);
  }

  // Track game play
  Future<void> trackGamePlay(String gameName, bool won, int bet) {
    return trackEvent('game_play', parameters: <String, dynamic>{
      'game_name': gameName,
      'won': won,
      'bet': bet,
    },);
  }

  // Set user properties
  Future<void> setUserProperties({
    required String userId,
    required String tier,
    required String country,
  }) {
    return _analytics.setUserProperty(name: 'tier', value: tier);
    // Note: Firebase Analytics has limited user properties
    // For more, use setUserId and custom events
  }
}