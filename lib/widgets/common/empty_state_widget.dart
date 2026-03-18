import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Color? iconColor;
  final double iconSize;
  final Widget? customIcon;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox,
    this.buttonText,
    this.onButtonPressed,
    this.iconColor,
    this.iconSize = 80,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon or Custom Icon
            if (customIcon != null)
              customIcon!
            else
              Icon(
                icon,
                size: iconSize,
                color: iconColor ?? Colors.grey.shade400,
              ),

            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),

            // Optional Button
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
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
    properties.add(ColorProperty('iconColor', iconColor));
    properties.add(DoubleProperty('iconSize', iconSize));
  }
}