import 'package:flutter/material.dart';

mixin LoadingMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;
  bool _isButtonLoading = false;
  String? _loadingMessage;
  OverlayEntry? _loadingOverlay;

  bool get isLoading => _isLoading;
  bool get isButtonLoading => _isButtonLoading;
  String? get loadingMessage => _loadingMessage;

  @override
  void dispose() {
    _removeLoadingOverlay();
    super.dispose();
  }

  // Show full screen loading with overlay
  void showLoading([String? message]) {
    _loadingMessage = message;
    _removeLoadingOverlay();

    _loadingOverlay = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_loadingOverlay!);
    setState(() => _isLoading = true);
  }

  // Hide full screen loading
  void hideLoading() {
    _removeLoadingOverlay();
    setState(() {
      _isLoading = false;
      _loadingMessage = null;
    });
  }

  void _removeLoadingOverlay() {
    _loadingOverlay?.remove();
    _loadingOverlay = null;
  }

  // Show/hide button loading
  void showButtonLoading() => setState(() => _isButtonLoading = true);
  void hideButtonLoading() => setState(() => _isButtonLoading = false);

  // Full screen loading widget (simple version)
  Widget buildLoadingIndicator() {
    if (!_isLoading) return const SizedBox.shrink();
    return const ColoredBox(
      color: Colors.black54,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // Full screen loading with message
  Widget buildLoadingWithMessage() {
    if (!_isLoading) return const SizedBox.shrink();
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (_loadingMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _loadingMessage!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
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
  Future<T?> runWithLoading<T>(Future<T?> Function() task, [String? message]) async {
    showLoading(message);
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