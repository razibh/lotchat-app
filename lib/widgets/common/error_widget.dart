import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? title;
  final IconData? icon;
  final Color? color;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.title,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated error icon with gradient background
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (color ?? Colors.red).withValues(alpha: 0.2),
                    (color ?? Colors.red).withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: (color ?? Colors.red).withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (color ?? Colors.red).withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                color: color ?? Colors.red,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),

            // Error title
            if (title != null) ...[
              Text(
                title!,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],

            // Error message
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Retry button with gradient
            if (onRetry != null)
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ).copyWith(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    return Colors.transparent;
                  }),
                  shadowColor: WidgetStateProperty.all(Colors.transparent),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color ?? Colors.pink,
                        (color ?? Colors.pink).withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: (color ?? Colors.pink).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.refresh, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Try Again',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('message', message));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onRetry', onRetry));
    properties.add(StringProperty('title', title));
    properties.add(DiagnosticsProperty<IconData?>('icon', icon));
  }
}

// Network error widget
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const NetworkErrorWidget({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'Network Error',
      message: 'Unable to connect to the internet.\nPlease check your connection and try again.',
      icon: Icons.wifi_off,
      color: Colors.orange,
      onRetry: onRetry,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<VoidCallback>.has('onRetry', onRetry));
  }
}

// Server error widget
class ServerErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const ServerErrorWidget({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'Server Error',
      message: 'Something went wrong on our end.\nPlease try again later.',
      icon: Icons.cloud_off,
      color: Colors.red,
      onRetry: onRetry,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<VoidCallback>.has('onRetry', onRetry));
  }
}

// Authentication error widget
class AuthErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback? onLogin;

  const AuthErrorWidget({
    super.key,
    required this.onRetry,
    this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'Authentication Failed',
      message: 'Please sign in again to continue.',
      icon: Icons.lock_outline,
      color: Colors.purple,
      onRetry: onRetry,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<VoidCallback>.has('onRetry', onRetry));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onLogin', onLogin));
  }
}

// Empty state widget
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  final Color? color;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.subtitle,
    required this.icon,
    this.onAction,
    this.actionLabel,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state icon with animation
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (color ?? Colors.grey).withValues(alpha: 0.1),
                    (color ?? Colors.grey).withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: color ?? Colors.white70,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),

            // Message
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ).copyWith(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    return Colors.transparent;
                  }),
                  shadowColor: WidgetStateProperty.all(Colors.transparent),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color ?? Colors.pink,
                        (color ?? Colors.pink).withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    child: Text(
                      actionLabel!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
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
    properties.add(StringProperty('message', message));
    properties.add(StringProperty('subtitle', subtitle));
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onAction', onAction));
    properties.add(StringProperty('actionLabel', actionLabel));
  }
}

// Loading error widget (for partial loading failures)
class LoadingErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const LoadingErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.2),
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('message', message));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onRetry', onRetry));
  }
}