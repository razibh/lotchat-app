import 'package:flutter/material.dart';

mixin FormMixin {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  void saveForm() {
    formKey.currentState?.save();
  }

  void resetForm() {
    formKey.currentState?.reset();
  }

  void enableAutoValidate() {
    autovalidateMode = AutovalidateMode.onUserInteraction;
  }

  // Clear all text fields
  void clearForm() {
    formKey.currentState?.reset();
  }

  // Focus management
  void nextFocus(FocusNode current, FocusNode next) {
    current.unfocus();
    next.requestFocus();
  }

  void unfocusAll() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}