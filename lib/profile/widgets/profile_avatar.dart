import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {

  const ProfileAvatar({
    required this.username, super.key,
    this.avatarUrl,
    this.size = 60,
    this.isOnline = false,
    this.frameUrl,
    this.isAnimated = false,
  });
  final String? avatarUrl;
  final String username;
  final double size;
  final bool isOnline;
  final String? frameUrl;
  final bool isAnimated;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <>[
        // Avatar with optional frame
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: frameUrl != null
                ? DecorationImage(
                    image: NetworkImage(frameUrl!),
                    fit: BoxFit.contain,
                  )
                : null,
          ),
          child: Padding(
            padding: frameUrl != null ? EdgeInsets.all(size * 0.1) : EdgeInsets.zero,
            child: CircleAvatar(
              radius: size * 0.4,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl!)
                  : null,
              backgroundColor: Colors.grey.shade300,
              child: avatarUrl == null
                  ? Text(
                      username[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: size * 0.4,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
        ),

        // Online Indicator
        if (isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size * 0.2,
              height: size * 0.2,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),

        // Animated Indicator
        if (isAnimated)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.animation,
                color: Colors.white,
                size: 10,
              ),
            ),
          ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('avatarUrl', avatarUrl));
    properties.add(StringProperty('username', username));
    properties.add(DoubleProperty('size', size));
    properties.add(DiagnosticsProperty<bool>('isOnline', isOnline));
    properties.add(StringProperty('frameUrl', frameUrl));
    properties.add(DiagnosticsProperty<bool>('isAnimated', isAnimated));
  }
}