import 'package:flutter/material.dart';
import 'logger_service.dart';

class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  factory ErrorService() => _instance;
  ErrorService._internal();

  final LoggerService _logger = LoggerService();

  // ==================== ERROR HANDLING ====================

  void handleError({
    required dynamic error,
    StackTrace? stackTrace,
    String? message,
    bool showToUser = false,
    BuildContext? context,
  }) {
    // Log the error
    _logger.error(
      message ?? 'An error occurred',
      error: error,
      stackTrace: stackTrace,
    );

    // Show to user if needed
    if (showToUser && context != null) {
      _showErrorDialog(context, _getUserFriendlyMessage(error));
    }
  }

  String _getUserFriendlyMessage(dynamic error) {
    if (error is Exception) {
      if (error is FormatException) {
        return 'Invalid data format';
      } else if (error is TimeoutException) {
        return 'Connection timeout. Please check your internet.';
      }
    }
    
    // Firebase errors
    if (error.toString().contains('PERMISSION_DENIED')) {
      return "You don't have permission to perform this action";
    } else if (error.toString().contains('NOT_FOUND')) {
      return 'The requested item was not found';
    } else if (error.toString().contains('ALREADY_EXISTS')) {
      return 'This item already exists';
    }
    
    // Network errors
    if (error.toString().contains('SocketException') ||
        error.toString().contains('Network')) {
      return 'Network error. Please check your connection.';
    }
    
    return 'Something went wrong. Please try again.';
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
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

  // ==================== SPECIFIC ERROR HANDLERS ====================

  void handleAuthError(dynamic error, BuildContext context) {
    String message = 'Authentication failed';
    
    if (error.toString().contains('user-not-found')) {
      message = 'No user found with this email';
    } else if (error.toString().contains('wrong-password')) {
      message = 'Wrong password';
    } else if (error.toString().contains('email-already-in-use')) {
      message = 'Email already in use';
    } else if (error.toString().contains('weak-password')) {
      message = 'Password is too weak';
    } else if (error.toString().contains('invalid-email')) {
      message = 'Invalid email address';
    } else if (error.toString().contains('network-request-failed')) {
      message = 'Network error. Please check your connection.';
    }

    handleError(
      error: error,
      message: message,
      showToUser: true,
      context: context,
    );
  }

  void handlePaymentError(dynamic error, BuildContext context) {
    String message = 'Payment failed';
    
    if (error.toString().contains('insufficient-funds')) {
      message = 'Insufficient funds';
    } else if (error.toString().contains('payment-cancelled')) {
      message = 'Payment was cancelled';
    } else if (error.toString().contains('payment-failed')) {
      message = 'Payment processing failed';
    }

    handleError(
      error: error,
      message: message,
      showToUser: true,
      context: context,
    );
  }

  // ==================== TRY-CATCH WRAPPER ====================

  Future<T?> tryCatch<T>(
    Future<T> Function() action, {
    String? errorMessage,
    bool showToUser = false,
    BuildContext? context,
  }) async {
    try {
      return await action();
    } catch (e, s) {
      handleError(
        error: e,
        stackTrace: s,
        message: errorMessage,
        showToUser: showToUser,
        context: context,
      );
      return null;
    }
  }

  // ==================== VALIDATION ERRORS ====================

  ValidationResult validateInput({
    required String value,
    String? fieldName,
    bool required = false,
    int? minLength,
    int? maxLength,
    RegExp? pattern,
    String? patternMessage,
  }) {
    final errors = <String>[];

    if (required && value.isEmpty) {
      errors.add('${fieldName ?? 'Field'} is required');
    }

    if (minLength != null && value.length < minLength) {
      errors.add('${fieldName ?? 'Field'} must be at least $minLength characters');
    }

    if (maxLength != null && value.length > maxLength) {
      errors.add('${fieldName ?? 'Field'} must be at most $maxLength characters');
    }

    if (pattern != null && !pattern.hasMatch(value)) {
      errors.add(patternMessage ?? 'Invalid format');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  // ==================== NETWORK ERRORS ====================

  bool isNetworkError(dynamic error) {
    return error.toString().contains('SocketException') ||
           error.toString().contains('Network') ||
           error.toString().contains('Timeout') ||
           error.toString().contains('Failed host lookup');
  }

  bool isServerError(dynamic error) {
    return error.toString().contains('500') ||
           error.toString().contains('502') ||
           error.toString().contains('503');
  }

  bool isClientError(dynamic error) {
    return error.toString().contains('400') ||
           error.toString().contains('401') ||
           error.toString().contains('403') ||
           error.toString().contains('404');
  }

  // ==================== ERROR RECOVERY ====================

  Future<bool> retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        await operation();
        return true;
      } catch (e) {
        if (i == maxRetries - 1) {
          _logger.error('Operation failed after $maxRetries retries', error: e);
          return false;
        }
        await Future.delayed(delay * (i + 1));
      }
    }
    return false;
  }
}

// ==================== MODEL CLASSES ====================

class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({
    required this.isValid,
    required this.errors,
  });

  String? get firstError => errors.isNotEmpty ? errors.first : null;
}