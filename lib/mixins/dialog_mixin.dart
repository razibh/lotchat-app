import 'package:flutter/material.dart';

mixin DialogMixin {
  // Show loading dialog
  Future<void> showLoadingDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const PopScope(
        canPop: false,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  // Show confirmation dialog
  Future<bool?> showConfirmDialog(
      BuildContext context, {
        required String title,
        required String message,
        String confirmText = 'Confirm',
        String cancelText = 'Cancel',
        Color confirmColor = Colors.green,
      }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // Show info dialog
  void showInfoDialog(
      BuildContext context, {
        required String title,
        required String message,
        String buttonText = 'OK',
      }) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  // Show input dialog
  Future<String?> showInputDialog(
      BuildContext context, {
        required String title,
        String? initialValue,
        String hintText = 'Enter value',
        TextInputType keyboardType = TextInputType.text,
      }) {
    final TextEditingController controller = TextEditingController(text: initialValue);

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          keyboardType: keyboardType,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Show bottom sheet
  Future<T?> showBottomSheet<T>(
      BuildContext context, {
        required Widget child,
        bool isScrollControlled = false,
      }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: child,
      ),
    );
  }

  // Show menu
  Future<T?> showMenuDialog<T>({
    required BuildContext context,
    required List<PopupMenuEntry<T>> items,
    required Widget child,
  }) {
    return showMenu<T>(
      context: context,
      position: const RelativeRect.fromLTRB(0, 0, 0, 0),
      items: items,
    );
  }
}