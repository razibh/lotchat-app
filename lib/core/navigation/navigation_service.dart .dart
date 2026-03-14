import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Navigate to a named route
  static Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  // Navigate and replace current route
  static Future<dynamic> navigateToReplacement(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(routeName, arguments: arguments);
  }

  // Navigate and remove all previous routes
  static Future<dynamic> navigateToAndRemoveUntil(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  // Navigate and remove until specific route
  static Future<dynamic> navigateToAndRemoveUntilRoute(
    String routeName, 
    String untilRoute, {
    dynamic arguments,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      ModalRoute.withName(untilRoute),
      arguments: arguments,
    );
  }

  // Go back to previous screen
  static void goBack({dynamic result}) {
    if (canGoBack()) {
      navigatorKey.currentState!.pop(result);
    }
  }

  // Check if can go back
  static bool canGoBack() {
    return navigatorKey.currentState!.canPop();
  }

  // Pop until specific route
  static void popUntil(String routeName) {
    navigatorKey.currentState!.popUntil(ModalRoute.withName(routeName));
  }

  // Pop all and go to first screen
  static void popToRoot() {
    navigatorKey.currentState!.popUntil((Route<dynamic> route) => route.isFirst);
  }

  // Get current route name
  static String? getCurrentRoute() {
    final ModalRoute<Object?>? modalRoute = ModalRoute.of(navigatorKey.currentContext!);
    return modalRoute?.settings.name;
  }

  // Get current route arguments
  static dynamic getCurrentArguments() {
    final ModalRoute<Object?>? modalRoute = ModalRoute.of(navigatorKey.currentContext!);
    return modalRoute?.settings.arguments;
  }

  // Push a custom route
  static Future<dynamic> pushRoute(Widget page) {
    return navigatorKey.currentState!.push(
      MaterialPageRoute(builder: (BuildContext context) => page),
    );
  }

  // Replace with custom route
  static Future<dynamic> pushReplacementRoute(Widget page) {
    return navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute(builder: (BuildContext context) => page),
    );
  }

  // Show dialog
  static Future<T?> showDialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    return navigatorKey.currentState!.push<T>(
      DialogRoute<T>(
        context: navigatorKey.currentContext!,
        builder: builder,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
      ),
    );
  }

  // Show bottom sheet
  static Future<T?> showBottomSheet<T>({
    required WidgetBuilder builder,
    bool isScrollControlled = false,
  }) {
    return showModalBottomSheet<T>(
      context: navigatorKey.currentContext!,
      builder: builder,
      isScrollControlled: isScrollControlled,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}

// Extension for easy navigation from context
extension NavigationExtension on BuildContext {
  Future<dynamic> pushNamed(String routeName, {dynamic arguments}) {
    return Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushReplacementNamed(String routeName, {dynamic arguments}) {
    return Navigator.of(this).pushReplacementNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushNamedAndRemoveUntil(String routeName, {dynamic arguments}) {
    return Navigator.of(this).pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  void pop([dynamic result]) {
    if (Navigator.canPop(this)) {
      Navigator.of(this).pop(result);
    }
  }

  bool get canPop => Navigator.canPop(this);

  void popUntil(String routeName) {
    Navigator.of(this).popUntil(ModalRoute.withName(routeName));
  }
}