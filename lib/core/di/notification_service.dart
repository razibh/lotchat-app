import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Safe navigator getter
  static NavigatorState? get _navigator {
    final state = navigatorKey.currentState;
    if (state == null) {
      debugPrint('❌ NavigationService: NavigatorState is NULL. Did you wrap MaterialApp with navigatorKey?');
    }
    return state;
  }

  /// Run navigation safely (post-frame)
  static Future<T?>? _safeNavigate<T>(Future<T?> Function() navCall) {
    final nav = _navigator;
    if (nav == null) return null;

    return WidgetsBinding.instance.addPostFrameCallback((_) => navCall()) as Future<T?>?;
  }

  /// Navigate to a new screen
  static Future<dynamic>? navigateTo(String routeName, {dynamic arguments}) {
    return _safeNavigate(() => _navigator!.pushNamed(routeName, arguments: arguments));
  }

  /// Replace current screen
  static Future<dynamic>? navigateToReplacement(String routeName, {dynamic arguments}) {
    return _safeNavigate(() => _navigator!.pushReplacementNamed(routeName, arguments: arguments));
  }

  /// Navigate and remove all previous screens
  static Future<dynamic>? navigateToAndRemoveUntil(String routeName, {dynamic arguments}) {
    return _safeNavigate(() => _navigator!.pushNamedAndRemoveUntil(
      routeName,
          (Route<dynamic> route) => false,
      arguments: arguments,
    ));
  }

  /// Go back
  static void goBack() {
    final nav = _navigator;
    if (nav == null) return;

    if (nav.canPop()) {
      nav.pop();
    } else {
      debugPrint('⚠️ NavigationService: No screen to go back');
    }
  }

  /// Go back with result
  static void goBackWithResult(dynamic result) {
    final nav = _navigator;
    if (nav == null) return;

    if (nav.canPop()) {
      nav.pop(result);
    } else {
      debugPrint('⚠️ NavigationService: No screen to go back with result');
    }
  }

  /// Check if can go back
  static bool canGoBack() {
    final nav = _navigator;
    if (nav == null) return false;

    return nav.canPop();
  }

  /// Get current route name (SAFE)
  static String? getCurrentRouteName() {
    final nav = _navigator;
    if (nav == null) return null;

    String? routeName;
    nav.popUntil((route) {
      routeName = route.settings.name;
      return true;
    });

    return routeName;
  }

  /// Pop until a specific route
  static void popUntil(String routeName) {
    final nav = _navigator;
    if (nav == null) return;

    nav.popUntil((route) => route.settings.name == routeName);
  }

  /// Shortcut methods
  static Future<dynamic>? pushReplacement(String routeName, {dynamic arguments}) {
    return navigateToReplacement(routeName, arguments: arguments);
  }

  static Future<dynamic>? pushAndRemoveUntil(String routeName, {dynamic arguments}) {
    return navigateToAndRemoveUntil(routeName, arguments: arguments);
  }
}