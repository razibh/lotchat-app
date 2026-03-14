import 'package:flutter/material.dart';

mixin FormMixin<T extends StatefulWidget> on State<T> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = <String, >{};
  final Map<String, FocusNode> _focusNodes = <String, >{};
  
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _isSubmitting = false;
  Map<String, List<String>> _fieldErrors = <String, List<String>>{};

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
    return <String, List<String>>{};
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
    if (!value.contains(RegExp('[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(Reg
     <Null>{
      return null,;
    return null;
    }
    return null;