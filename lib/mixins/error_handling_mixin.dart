import 'package:flutter/material.dart';
import '../core/services/logger_service.dart';
import '../core/di/service_locator.dart';

mixin ErrorHandlingMixin {
  final LoggerService _logger = ServiceLocator().get<LoggerService>();

  void handleError(dynamic error, {StackTrace? stackTrace, String? message}) {
    _logger.error(
      message ?? 'An error occurred',
      error: error,
      stackTrace: stackTrace,
    );
  }

  String getUserFriendlyErrorMessage(dynamic error) {
    if (error.toString().contains('SocketException') ||
        error.toString().contains('Network')) {
      return 'Network error. Please check your connection.';
    }
    
    if (error.toString().contains('PERMISSION_DENIED')) {
      return 'You don\'t have permission to do this.';
    }
    
    if (error.toString().contains('NOT_FOUND')) {
      return 'Item not found.';
    }
    
    if (error.toString().contains('ALREADY_EXISTS')) {
      return 'This item already exists.';
    }
    
    return 'Something went wrong. Please try again.';
  }

  void showErrorDialog(BuildContext context, dynamic error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
      if (showError && context != null) {
        showErrorDialog(context, e);
      }
      return null;
    }
  }
}