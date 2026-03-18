import 'package:flutter/material.dart';

mixin ValidationMixin {
  // Required field validation
  String? validateRequired(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Email validation (built-in, no package needed)
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return null;

    // Simple but effective email regex
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Phone number validation
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return null;

    // Remove all non-digits
    final String digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 10) {
      return 'Phone number must have at least 10 digits';
    }

    if (digits.length > 15) {
      return 'Phone number cannot exceed 15 digits';
    }

    return null;
  }

  // Password validation
  String? validatePassword(String? value, {
    int minLength = 6,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireNumber = true,
    bool requireSpecial = false,
  }) {
    if (value == null || value.isEmpty) return null;

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    if (requireUppercase && !value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (requireLowercase && !value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (requireNumber && !value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (requireSpecial && !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  // Confirm password validation
  String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return null;
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Username validation
  String? validateUsername(String? value, {
    int minLength = 3,
    int maxLength = 20,
    bool allowUnderscore = true,
    bool allowNumbers = true,
  }) {
    if (value == null || value.isEmpty) return null;

    if (value.length < minLength) {
      return 'Username must be at least $minLength characters';
    }

    if (value.length > maxLength) {
      return 'Username cannot exceed $maxLength characters';
    }

    var pattern = '^[a-zA-Z';
    if (allowNumbers) pattern += '0-9';
    if (allowUnderscore) pattern += '_';
    pattern += r']+$';

    if (!RegExp(pattern).hasMatch(value)) {
      return 'Username can only contain letters${allowNumbers ? ', numbers' : ''}${allowUnderscore ? ' and underscore' : ''}';
    }

    return null;
  }

  // URL validation
  String? validateUrl(String? value) {
    if (value == null || value.isEmpty) return null;

    final RegExp urlRegExp = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );

    if (!urlRegExp.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  // Number validation
  String? validateNumber(String? value, {
    int? min,
    int? max,
    bool isInteger = true,
    String fieldName = 'Value',
  }) {
    if (value == null || value.isEmpty) return null;

    if (isInteger) {
      final int? number = int.tryParse(value);
      if (number == null) {
        return 'Please enter a valid whole number';
      }
      if (min != null && number < min) {
        return '$fieldName must be at least $min';
      }
      if (max != null && number > max) {
        return '$fieldName cannot exceed $max';
      }
    } else {
      final double? number = double.tryParse(value);
      if (number == null) {
        return 'Please enter a valid number';
      }
      if (min != null && number < min) {
        return '$fieldName must be at least $min';
      }
      if (max != null && number > max) {
        return '$fieldName cannot exceed $max';
      }
    }

    return null;
  }

  // Date validation
  String? validateDate(String? value, {
    DateTime? minDate,
    DateTime? maxDate,
    String format = 'dd/MM/yyyy',
  }) {
    if (value == null || value.isEmpty) return null;

    try {
      final DateTime date = DateTime.parse(value);

      if (minDate != null && date.isBefore(minDate)) {
        return 'Date must be after ${_formatDate(minDate)}';
      }

      if (maxDate != null && date.isAfter(maxDate)) {
        return 'Date must be before ${_formatDate(maxDate)}';
      }
    } catch (e) {
      return 'Please enter a valid date';
    }

    return null;
  }

  // Time validation
  String? validateTime(String? value) {
    if (value == null || value.isEmpty) return null;

    final RegExp timeRegExp = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegExp.hasMatch(value)) {
      return 'Please enter a valid time (HH:MM)';
    }

    return null;
  }

  // Credit card validation
  String? validateCreditCard(String? value) {
    if (value == null || value.isEmpty) return null;

    // Remove spaces and dashes
    final String cardNumber = value.replaceAll(RegExp(r'[\s-]'), '');

    if (cardNumber.length < 13 || cardNumber.length > 19) {
      return 'Invalid card number length';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(cardNumber)) {
      return 'Card number can only contain digits';
    }

    // Luhn algorithm
    if (!_luhnCheck(cardNumber)) {
      return 'Invalid card number';
    }

    return null;
  }

  bool _luhnCheck(String cardNumber) {
    int sum = 0;
    bool alternate = false;

    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int n = int.parse(cardNumber[i]);

      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }

      sum += n;
      alternate = !alternate;
    }

    return (sum % 10 == 0);
  }

  // CVV validation
  String? validateCVV(String? value) {
    if (value == null || value.isEmpty) return null;

    if (!RegExp(r'^[0-9]{3,4}$').hasMatch(value)) {
      return 'CVV must be 3 or 4 digits';
    }

    return null;
  }

  // Expiry date validation (MM/YY)
  String? validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) return null;

    final RegExp expiryRegExp = RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$');
    if (!expiryRegExp.hasMatch(value)) {
      return 'Please enter a valid expiry date (MM/YY)';
    }

    final List<String> parts = value.split('/');
    final int month = int.parse(parts[0]);
    final int year = int.parse('20${parts[1]}');

    final DateTime now = DateTime.now();
    final DateTime expiry = DateTime(year, month + 1, 0);

    if (expiry.isBefore(now)) {
      return 'Card has expired';
    }

    return null;
  }

  // IP address validation
  String? validateIPAddress(String? value) {
    if (value == null || value.isEmpty) return null;

    final RegExp ipRegExp = RegExp(
      r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );

    if (!ipRegExp.hasMatch(value)) {
      return 'Please enter a valid IP address';
    }

    return null;
  }

  // Hex color validation
  String? validateHexColor(String? value) {
    if (value == null || value.isEmpty) return null;

    final RegExp hexRegExp = RegExp(r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$');
    if (!hexRegExp.hasMatch(value)) {
      return 'Please enter a valid hex color (e.g., #FF0000)';
    }

    return null;
  }

  // Min length validation
  String? validateMinLength(String? value, int minLength, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) return null;
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  // Max length validation
  String? validateMaxLength(String? value, int maxLength, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) return null;
    if (value.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }
    return null;
  }

  // Exact length validation
  String? validateExactLength(String? value, int length, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) return null;
    if (value.length != length) {
      return '$fieldName must be exactly $length characters';
    }
    return null;
  }

  // Range validation
  String? validateRange(num? value, num min, num max, {String fieldName = 'Value'}) {
    if (value == null) return null;
    if (value < min || value > max) {
      return '$fieldName must be between $min and $max';
    }
    return null;
  }

  // Pattern validation
  String? validatePattern(String? value, RegExp pattern, {String message = 'Invalid format'}) {
    if (value == null || value.isEmpty) return null;
    if (!pattern.hasMatch(value)) {
      return message;
    }
    return null;
  }

  // Not equal validation
  String? validateNotEqual(String? value, String compare, {String fieldName = 'This field'}) {
    if (value == null) return null;
    if (value == compare) {
      return '$fieldName cannot be the same';
    }
    return null;
  }

  // Equal validation
  String? validateEqual(String? value, String compare, {String fieldName = 'This field'}) {
    if (value == null) return null;
    if (value != compare) {
      return '$fieldName must match';
    }
    return null;
  }

  // Contains validation
  String? validateContains(String? value, String substring, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) return null;
    if (!value.contains(substring)) {
      return '$fieldName must contain "$substring"';
    }
    return null;
  }

  // Starts with validation
  String? validateStartsWith(String? value, String prefix, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) return null;
    if (!value.startsWith(prefix)) {
      return '$fieldName must start with "$prefix"';
    }
    return null;
  }

  // Ends with validation
  String? validateEndsWith(String? value, String suffix, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) return null;
    if (!value.endsWith(suffix)) {
      return '$fieldName must end with "$suffix"';
    }
    return null;
  }

  // List validation
  String? validateList<T>(List<T>? value, {int? minItems, int? maxItems, String fieldName = 'List'}) {
    if (value == null) return null;

    if (minItems != null && value.length < minItems) {
      return '$fieldName must have at least $minItems items';
    }

    if (maxItems != null && value.length > maxItems) {
      return '$fieldName cannot have more than $maxItems items';
    }

    return null;
  }

  // File validation
  String? validateFileSize(int? bytes, int maxBytes, {String fieldName = 'File'}) {
    if (bytes == null) return null;
    if (bytes > maxBytes) {
      return '$fieldName size must be less than ${_formatBytes(maxBytes)}';
    }
    return null;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Combine multiple validators
  String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final String? result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }

  // Conditional validation
  String? Function(String?) conditional(
      bool condition,
      String? Function(String?) validator,
      ) {
    return (String? value) {
      if (condition) {
        return validator(value);
      }
      return null;
    };
  }

  // Async validation (for API calls)
  Future<String?> validateAsync(
      String? value,
      Future<String?> Function(String?) validator,
      ) async {
    return validator(value);
  }

  // Validation result
  ValidationResult validateAll(Map<String, String?> values, Map<String, String? Function(String?)> validators) {
    final errors = <String, String?>{};
    bool isValid = true;

    for (final entry in validators.entries) {
      final String? value = values[entry.key];
      final String? error = entry.value(value);
      if (error != null) {
        errors[entry.key] = error;
        isValid = false;
      }
    }

    return ValidationResult(isValid: isValid, errors: errors);
  }
}

class ValidationResult {
  final bool isValid;
  final Map<String, String?> errors;

  ValidationResult({required this.isValid, required this.errors});

  String? getFirstError() {
    return errors.values.firstWhere((String? e) => e != null, orElse: () => null);
  }

  bool hasError(String field) {
    return errors.containsKey(field) && errors[field] != null;
  }
}