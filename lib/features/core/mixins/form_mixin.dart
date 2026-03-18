import 'package:flutter/material.dart';

mixin FormMixin<T extends StatefulWidget> on State<T> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _isSubmitting = false;
  Map<String, List<String>> _fieldErrors = {};

  GlobalKey<FormState> get formKey => _formKey;
  AutovalidateMode get autovalidateMode => _autovalidateMode;
  bool get isSubmitting => _isSubmitting;
  Map<String, List<String>> get fieldErrors => _fieldErrors;

  // Controller management
  TextEditingController getController(String field) {
    if (!_controllers.containsKey(field)) {
      _controllers[field] = TextEditingController();
    }
    return _controllers[field]!;
  }

  FocusNode getFocusNode(String field) {
    if (!_focusNodes.containsKey(field)) {
      _focusNodes[field] = FocusNode();
    }
    return _focusNodes[field]!;
  }

  void setControllerValue(String field, String value) {
    getController(field).text = value;
  }

  String getControllerValue(String field) {
    return getController(field).text;
  }

  void clearController(String field) {
    getController(field).clear();
  }

  void clearAllControllers() {
    for (final TextEditingController controller in _controllers.values) {
      controller.clear();
    }
  }

  // Form validation
  bool validateForm() {
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
    });
    return _formKey.currentState?.validate() ?? false;
  }

  void saveForm() {
    _formKey.currentState?.save();
  }

  void resetForm() {
    _formKey.currentState?.reset();
    clearAllControllers();
    _fieldErrors.clear();
  }

  void enableAutoValidate() {
    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });
  }

  void disableAutoValidate() {
    setState(() {
      _autovalidateMode = AutovalidateMode.disabled;
    });
  }

  // Field focus management
  void nextFocus(String currentField, String nextField) {
    getFocusNode(currentField).unfocus();
    FocusScope.of(context).requestFocus(getFocusNode(nextField));
  }

  void previousFocus(String currentField, String previousField) {
    getFocusNode(currentField).unfocus();
    FocusScope.of(context).requestFocus(getFocusNode(previousField));
  }

  void unfocusAll() {
    FocusScope.of(context).unfocus();
  }

  // Form submission
  Future<void> submitForm({
    required Future<void> Function() onSubmit,
    VoidCallback? onSuccess,
    Function(Object)? onError,
  }) async {
    if (!validateForm()) return;

    setState(() {
      _isSubmitting = true;
      _fieldErrors.clear();
    });

    try {
      await onSubmit();
      onSuccess?.call();
    } catch (e) {
      setState(() {
        _fieldErrors = _parseErrors(e);
      });
      onError?.call(e);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Map<String, List<String>> _parseErrors(Object error) {
    // Override this to parse API errors
    return {};
  }

  // Field validation helpers
  String? requiredValidator(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) return null;
    final RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? phoneValidator(String? value) {
    if (value == null || value.isEmpty) return null;
    final RegExp phoneRegExp = RegExp(r'^\+?[\d\s-]{10,}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? minLengthValidator(String? value, int minLength, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) return null;
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  String? maxLengthValidator(String? value, int maxLength, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) return null;
    if (value.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  String? confirmPasswordValidator(String? value, String password, {String fieldName = 'Confirm password'}) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  String? urlValidator(String? value) {
    if (value == null || value.isEmpty) return null;
    final RegExp urlRegExp = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );
    if (!urlRegExp.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  String? numericValidator(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) return null;
    if (double.tryParse(value) == null) {
      return '$fieldName must be a number';
    }
    return null;
  }

  String? positiveNumberValidator(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) return null;
    final num? number = num.tryParse(value);
    if (number == null) {
      return '$fieldName must be a number';
    }
    if (number <= 0) {
      return '$fieldName must be a positive number';
    }
    return null;
  }

  String? minValueValidator(String? value, num min, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) return null;
    final num? number = num.tryParse(value);
    if (number == null) return '$fieldName must be a number';
    if (number < min) {
      return '$fieldName must be at least $min';
    }
    return null;
  }

  String? maxValueValidator(String? value, num max, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) return null;
    final num? number = num.tryParse(value);
    if (number == null) return '$fieldName must be a number';
    if (number > max) {
      return '$fieldName cannot exceed $max';
    }
    return null;
  }

  String? rangeValidator(String? value, num min, num max, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) return null;
    final num? number = num.tryParse(value);
    if (number == null) return '$fieldName must be a number';
    if (number < min || number > max) {
      return '$fieldName must be between $min and $max';
    }
    return null;
  }

  String? alphaValidator(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
      return '$fieldName must contain only letters';
    }
    return null;
  }

  String? alphanumericValidator(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return '$fieldName must contain only letters and numbers';
    }
    return null;
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }
}