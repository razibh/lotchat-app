import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {

  const EmptyStateWidget({
    required this.title, required this.message, super.key,
    this.icon = Icons.inbox,
    this.buttonText,
    this.onButtonPressed,
  });
  final String title;
  final String message;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <>[
            Icon(
              icon,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...<>[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onButtonPressed,
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(StringProperty('message', message));
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
    properties.add(StringProperty('buttonText', buttonText));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onButtonPressed', onButtonPressed));
  }
}