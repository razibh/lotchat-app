import 'package:flutter/material.dart';

mixin LoadingMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;
  bool _isButtonLoading = false;
  
  bool get isLoading => _isLoading;
  bool get isButtonLoading => _isButtonLoading;

  // Show/hide full screen loading
  void showLoading() => setState(() => _isLoading = true);
  void hideLoading() => setState(() => _isLoading = false);

  // Show/hide button loading
  void showButtonLoading() => setState(() => _isButtonLoading = true);
  void hideButtonLoading() => setState(() => _isButtonLoading = false);

  // Full screen loading widget
  Widget buildLoadingIndicator() {
    if (!_isLoading) return const SizedBox.shrink();
    return Container(
      color: Colors.black54,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // Button loading widget
  Widget buildButtonLoading() {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  // Run async task with loading
  Future<T?> runWithLoading<T>(Future<T?> Function() task) async {
    showLoading();
    try {
      return await task();
    } finally {
      hideLoading();
    }
  }

  // Run async task with button loading
  Future<T?> runWithButtonLoading<T>(Future<T?> Function() task) async {
    showButtonLoading();
    try {
      return await task();
    } finally {
      hideButtonLoading();
    }
  }
}