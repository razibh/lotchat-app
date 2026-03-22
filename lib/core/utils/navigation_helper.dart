import 'package:flutter/material.dart';
import '../services/navigation_service.dart';

/// Global Navigation Helper
/// Use this class for all navigation operations throughout the app
class NavigationHelper {
  NavigationHelper._();

  // ==================== NAVIGATION METHODS ====================

  /// Navigate to a new screen
  static Future<dynamic> navigateTo(
      String routeName, {
        dynamic arguments,
        BuildContext? fallbackContext,
      }) async {
    try {
      // Try to use NavigationService if available
      if (NavigationService.navigatorKey.currentContext != null) {
        return NavigationService.navigateTo(routeName, arguments: arguments);
      }

      // Fallback to direct Navigator if context provided
      if (fallbackContext != null) {
        debugPrint('⚠️ Using fallback context for navigation to $routeName');
        return await Navigator.pushNamed(
          fallbackContext,
          routeName,
          arguments: arguments,
        );
      }

      debugPrint('❌ Cannot navigate to $routeName - no context available');
      return null;
    } catch (e) {
      debugPrint('❌ Navigation error to $routeName: $e');
      return null;
    }
  }

  /// Replace current screen with new screen
  static Future<dynamic> navigateToReplacement(
      String routeName, {
        dynamic arguments,
        BuildContext? fallbackContext,
      }) async {
    try {
      // Try to use NavigationService if available
      if (NavigationService.navigatorKey.currentContext != null) {
        return NavigationService.navigateToReplacement(routeName, arguments: arguments);
      }

      if (fallbackContext != null) {
        debugPrint('⚠️ Using fallback context for replacement to $routeName');
        return await Navigator.pushReplacementNamed(
          fallbackContext,
          routeName,
          arguments: arguments,
        );
      }

      debugPrint('❌ Cannot replace to $routeName - no context available');
      return null;
    } catch (e) {
      debugPrint('❌ Navigation replacement error to $routeName: $e');
      return null;
    }
  }

  /// Navigate and remove all previous screens
  static Future<dynamic> navigateToAndRemoveUntil(
      String routeName, {
        dynamic arguments,
        BuildContext? fallbackContext,
      }) async {
    try {
      // Try to use NavigationService if available
      if (NavigationService.navigatorKey.currentContext != null) {
        return NavigationService.navigateToAndRemoveUntil(routeName, arguments: arguments);
      }

      if (fallbackContext != null) {
        debugPrint('⚠️ Using fallback context for removeUntil to $routeName');
        return await Navigator.pushNamedAndRemoveUntil(
          fallbackContext,
          routeName,
              (route) => false,
          arguments: arguments,
        );
      }

      debugPrint('❌ Cannot removeUntil to $routeName - no context available');
      return null;
    } catch (e) {
      debugPrint('❌ Navigation removeUntil error to $routeName: $e');
      return null;
    }
  }

  /// Go back to previous screen
  static void goBack({dynamic result, BuildContext? fallbackContext}) {
    try {
      // Try to use NavigationService if available
      if (NavigationService.navigatorKey.currentContext != null && NavigationService.canGoBack()) {
        if (result != null) {
          NavigationService.goBackWithResult(result);
        } else {
          NavigationService.goBack();
        }
        return;
      }

      if (fallbackContext != null && Navigator.canPop(fallbackContext)) {
        debugPrint('⚠️ Using fallback context for goBack');
        if (result != null) {
          Navigator.pop(fallbackContext, result);
        } else {
          Navigator.pop(fallbackContext);
        }
        return;
      }

      debugPrint('❌ Cannot go back - no context available');
    } catch (e) {
      debugPrint('❌ Go back error: $e');
    }
  }

  /// Pop until a specific route
  static void popUntil(String routeName, {BuildContext? fallbackContext}) {
    try {
      // Try to use NavigationService if available
      if (NavigationService.navigatorKey.currentContext != null) {
        // Use Navigator directly
        final navigator = NavigationService.navigatorKey.currentState;
        if (navigator != null) {
          navigator.popUntil((route) => route.settings.name == routeName);
        }
        return;
      }

      if (fallbackContext != null) {
        debugPrint('⚠️ Using fallback context for popUntil to $routeName');
        Navigator.popUntil(fallbackContext, (route) => route.settings.name == routeName);
        return;
      }

      debugPrint('❌ Cannot popUntil to $routeName - no context available');
    } catch (e) {
      debugPrint('❌ PopUntil error: $e');
    }
  }

  // ==================== DIALOG METHODS ====================

  /// Show a dialog safely
  static Future<T?> showDialogSafe<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    BuildContext? fallbackContext,
  }) async {
    final context = _getContext(fallbackContext);
    if (context == null) {
      debugPrint('❌ Cannot show dialog - no context available');
      return null;
    }

    try {
      return await showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        builder: builder,
      );
    } catch (e) {
      debugPrint('❌ Dialog error: $e');
      return null;
    }
  }

  /// Show a snackbar safely
  static void showSnackBar(
      String message, {
        Color? backgroundColor,
        Duration duration = const Duration(seconds: 3),
        SnackBarBehavior behavior = SnackBarBehavior.floating,
        BuildContext? fallbackContext,
      }) {
    final context = _getContext(fallbackContext);
    if (context == null) {
      debugPrint('❌ Cannot show snackbar - no context available');
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor ?? Colors.red,
          duration: duration,
          behavior: behavior,
        ),
      );
    } catch (e) {
      debugPrint('❌ Snackbar error: $e');
    }
  }

  /// Show a success snackbar
  static void showSuccessSnackBar(String message, {BuildContext? fallbackContext}) {
    showSnackBar(
      message,
      backgroundColor: Colors.green,
      fallbackContext: fallbackContext,
    );
  }

  /// Show an error snackbar
  static void showErrorSnackBar(String message, {BuildContext? fallbackContext}) {
    showSnackBar(
      message,
      backgroundColor: Colors.red,
      fallbackContext: fallbackContext,
    );
  }

  /// Show an info snackbar
  static void showInfoSnackBar(String message, {BuildContext? fallbackContext}) {
    showSnackBar(
      message,
      backgroundColor: Colors.blue,
      fallbackContext: fallbackContext,
    );
  }

  // ==================== BOTTOM SHEET METHODS ====================

  /// Show a bottom sheet safely
  static Future<T?> showBottomSheetSafe<T>({
    required WidgetBuilder builder,
    bool isScrollControlled = false,
    bool isDismissible = true,
    Color? backgroundColor,
    ShapeBorder? shape,
    BuildContext? fallbackContext,
  }) async {
    final context = _getContext(fallbackContext);
    if (context == null) {
      debugPrint('❌ Cannot show bottom sheet - no context available');
      return null;
    }

    try {
      return await showModalBottomSheet<T>(
        context: context,
        isScrollControlled: isScrollControlled,
        isDismissible: isDismissible,
        backgroundColor: backgroundColor,
        shape: shape,
        builder: builder,
      );
    } catch (e) {
      debugPrint('❌ Bottom sheet error: $e');
      return null;
    }
  }

  // ==================== ALERT DIALOG METHODS ====================

  /// Show a confirmation dialog
  static Future<bool?> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    BuildContext? fallbackContext,
  }) async {
    final result = await showDialogSafe<bool>(
      fallbackContext: fallbackContext,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: confirmColor != null
                ? ElevatedButton.styleFrom(backgroundColor: confirmColor)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result;
  }

  /// Show a success dialog
  static Future<void> showSuccessDialog({
    required String title,
    required String message,
    BuildContext? fallbackContext,
  }) async {
    await showDialogSafe(
      fallbackContext: fallbackContext,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show an error dialog
  static Future<void> showErrorDialog({
    required String title,
    required String message,
    BuildContext? fallbackContext,
  }) async {
    await showDialogSafe(
      fallbackContext: fallbackContext,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show a loading dialog
  static Future<void> showLoadingDialog({
    String message = 'Loading...',
    BuildContext? fallbackContext,
  }) async {
    await showDialogSafe(
      barrierDismissible: false,
      fallbackContext: fallbackContext,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  // ==================== UTILITY METHODS ====================

  /// Get current context safely
  static BuildContext? getCurrentContext() {
    return NavigationService.navigatorKey.currentContext;
  }

  /// Check if navigation is ready
  static bool get isReady {
    return NavigationService.navigatorKey.currentContext != null &&
        NavigationService.navigatorKey.currentState != null;
  }

  /// Wait for navigation to be ready
  static Future<void> waitForReady({Duration timeout = const Duration(seconds: 5)}) async {
    final startTime = DateTime.now();
    while (!isReady) {
      if (DateTime.now().difference(startTime) > timeout) {
        debugPrint('⚠️ NavigationHelper: Timeout waiting for navigation to be ready');
        return;
      }
      await Future.delayed(const Duration(milliseconds: 50));
    }
    debugPrint('✅ NavigationHelper: Navigation is ready');
  }

  /// Get current route name
  static String? getCurrentRouteName() {
    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) return null;
    final route = ModalRoute.of(context);
    return route?.settings.name;
  }

  /// Get current route name safely
  static String? getCurrentRouteNameSafe() {
    try {
      final context = NavigationService.navigatorKey.currentContext;
      if (context == null) return null;
      final route = ModalRoute.of(context);
      return route?.settings.name;
    } catch (e) {
      debugPrint('Error getting current route name: $e');
      return null;
    }
  }

  /// Check if can go back
  static bool canGoBack() {
    final navigator = NavigationService.navigatorKey.currentState;
    if (navigator == null) return false;
    return navigator.canPop();
  }

  // ==================== PRIVATE HELPER ====================

  /// Get context from multiple sources
  static BuildContext? _getContext(BuildContext? fallbackContext) {
    // Try NavigationService first
    if (NavigationService.navigatorKey.currentContext != null) {
      return NavigationService.navigatorKey.currentContext;
    }

    // Use fallback context if provided
    if (fallbackContext != null) {
      return fallbackContext;
    }

    return null;
  }
}

// ==================== EXTENSIONS ====================

/// Extension for BuildContext to use NavigationHelper easily
extension NavigationHelperExtension on BuildContext {
  /// Navigate to a route
  Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    return NavigationHelper.navigateTo(routeName, arguments: arguments, fallbackContext: this);
  }

  /// Replace current route
  Future<dynamic> navigateToReplacement(String routeName, {dynamic arguments}) {
    return NavigationHelper.navigateToReplacement(
      routeName,
      arguments: arguments,
      fallbackContext: this,
    );
  }

  /// Navigate and remove all previous routes
  Future<dynamic> navigateToAndRemoveUntil(String routeName, {dynamic arguments}) {
    return NavigationHelper.navigateToAndRemoveUntil(
      routeName,
      arguments: arguments,
      fallbackContext: this,
    );
  }

  /// Go back
  void goBack({dynamic result}) {
    NavigationHelper.goBack(result: result, fallbackContext: this);
  }

  /// Show snackbar
  void showSnackBar(String message, {Color? backgroundColor}) {
    NavigationHelper.showSnackBar(message, backgroundColor: backgroundColor, fallbackContext: this);
  }

  /// Show success snackbar
  void showSuccessSnackBar(String message) {
    NavigationHelper.showSuccessSnackBar(message, fallbackContext: this);
  }

  /// Show error snackbar
  void showErrorSnackBar(String message) {
    NavigationHelper.showErrorSnackBar(message, fallbackContext: this);
  }

  /// Show info snackbar
  void showInfoSnackBar(String message) {
    NavigationHelper.showInfoSnackBar(message, fallbackContext: this);
  }

  /// Show dialog
  Future<T?> showDialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return NavigationHelper.showDialogSafe<T>(
      builder: builder,
      barrierDismissible: barrierDismissible,
      fallbackContext: this,
    );
  }

  /// Show confirmation dialog
  Future<bool?> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    return NavigationHelper.showConfirmationDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      fallbackContext: this,
    );
  }

  /// Show loading dialog
  Future<void> showLoadingDialog({String message = 'Loading...'}) {
    return NavigationHelper.showLoadingDialog(
      message: message,
      fallbackContext: this,
    );
  }
}