import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../core/di/service_locator.dart';
import '../core/services/logger_service.dart';

mixin ErrorHandlingMixin {
  late final LoggerService _logger;

  void initErrorHandling() {
    try {
      _logger = ServiceLocator.instance.get<LoggerService>();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing LoggerService: $e');
      }
    }
  }

  void handleError(dynamic error, {StackTrace? stackTrace, String? message}) {
    // Ensure logger is initialized
    try {
      if (_logger == null) {
        _logger = ServiceLocator.instance.get<LoggerService>();
      }
      _logger.error(
        message ?? 'An error occurred',
        error: error,
        stackTrace: stackTrace,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error handling error: $e');
        print('Original error: $error');
      }
    }
  }

  String getUserFriendlyErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socketexception') ||
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Network error. Please check your connection.';
    }

    if (errorString.contains('permission_denied') ||
        errorString.contains('permission denied')) {
      return "You don't have permission to do this.";
    }

    if (errorString.contains('not_found') ||
        errorString.contains('not found')) {
      return 'Item not found.';
    }

    if (errorString.contains('already_exists') ||
        errorString.contains('already exists')) {
      return 'This item already exists.';
    }

    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (errorString.contains('unauthorized') ||
        errorString.contains('unauthenticated')) {
      return 'You need to login again.';
    }

    return 'Something went wrong. Please try again.';
  }

  void showErrorDialog(BuildContext context, dynamic error) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Error'),
        content: Text(getUserFriendlyErrorMessage(error)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<T?> tryCatch<T>(
      Future<T> Function() action, {
        BuildContext? context,
        bool showError = true,
      }) async {
    try {
      return await action();
    } catch (e, s) {
      handleError(e, stackTrace: s);
      if (showError && context != null && context.mounted) {
        showErrorDialog(context, e);
      }
      return null;
    }
  }
}