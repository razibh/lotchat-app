import 'package:flutter/material.dart';

class CallPermissionDialog extends StatelessWidget {
  const CallPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Permissions Required'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber,
            color: Colors.orange,
            size: 50,
          ),
          SizedBox(height: 16),
          Text(
            'This app needs camera and microphone permissions to make calls.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Grant Permissions'),
        ),
      ],
    );
  }
}