import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // DiagnosticPropertiesBuilder এর জন্য

class ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String username;
  final double size;
  final bool isOnline;
  final String? frameUrl;
  final bool isAnimated;

  const ProfileAvatar({
    super.key,
    required this.username,
    this.avatarUrl,
    this.size = 60,
    this.isOnline = false,
    this.frameUrl,
    this.isAnimated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
            padding: frameUrl != null
                ? EdgeInsets.all(size * 0.1)
                : EdgeInsets.zero,
            child: CircleAvatar(
              radius: frameUrl != null ? size * 0.4 : size * 0.5,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl!)
                  : null,
              backgroundColor: Colors.grey.shade300,
              child: avatarUrl == null
                  ? Text(
                username.isNotEmpty ? username[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 2,
                    spreadRadius: 1,
                  ),
                ],
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
              decoration: BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
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

// ProfileAvatarGroup widget for displaying multiple avatars
class ProfileAvatarGroup extends StatelessWidget {
  final List<ProfileAvatarData> avatars;
  final double size;
  final int maxDisplay;
  final bool showCount;

  const ProfileAvatarGroup({
    super.key,
    required this.avatars,
    this.size = 40,
    this.maxDisplay = 3,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    final displayAvatars = avatars.take(maxDisplay).toList();
    final remaining = avatars.length - maxDisplay;

    return SizedBox(
      height: size,
      child: Stack(
        children: [
          ...displayAvatars.asMap().entries.map((entry) {
            final index = entry.key;
            final avatar = entry.value;
            final leftOffset = index * (size * 0.6);

            return Positioned(
              left: leftOffset,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ProfileAvatar(
                  username: avatar.username,
                  avatarUrl: avatar.avatarUrl,
                  size: size,
                  isOnline: avatar.isOnline,
                  frameUrl: avatar.frameUrl,
                ),
              ),
            );
          }).toList(),
          if (showCount && remaining > 0)
            Positioned(
              left: maxDisplay * (size * 0.6),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+$remaining',
                    style: TextStyle(
                      fontSize: size * 0.3,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<ProfileAvatarData>('avatars', avatars));
    properties.add(DoubleProperty('size', size));
    properties.add(IntProperty('maxDisplay', maxDisplay));
    properties.add(DiagnosticsProperty<bool>('showCount', showCount));
  }
}

// Data class for ProfileAvatarGroup
class ProfileAvatarData {
  final String username;
  final String? avatarUrl;
  final bool isOnline;
  final String? frameUrl;

  ProfileAvatarData({
    required this.username,
    this.avatarUrl,
    this.isOnline = false,
    this.frameUrl,
  });
}

// ProfileAvatarWithStatus widget
class ProfileAvatarWithStatus extends StatelessWidget {
  final ProfileAvatar avatar;
  final String? statusText;
  final Color? statusColor;
  final VoidCallback? onTap;

  const ProfileAvatarWithStatus({
    super.key,
    required this.avatar,
    this.statusText,
    this.statusColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          avatar,
          if (statusText != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: statusColor ?? Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText!,
                style: TextStyle(
                  fontSize: 10,
                  color: statusColor ?? Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ProfileAvatar>('avatar', avatar));
    properties.add(StringProperty('statusText', statusText));
    properties.add(ColorProperty('statusColor', statusColor));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
  }
}