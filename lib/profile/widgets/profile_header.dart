import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/profile_model.dart';
import 'profile_avatar.dart';
import '../../core/utils/date_formatters.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileModel profile;
  final bool isCurrentUser;
  final VoidCallback? onEditPressed;
  final VoidCallback? onMessagePressed;
  final VoidCallback? onFollowPressed;
  final VoidCallback? onSharePressed;
  final bool isFollowing;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.isCurrentUser,
    this.onEditPressed,
    this.onMessagePressed,
    this.onFollowPressed,
    this.onSharePressed,
    this.isFollowing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Cover Image
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            image: profile.coverImage != null
                ? DecorationImage(
              image: NetworkImage(profile.coverImage!),
              fit: BoxFit.cover,
            )
                : null,
          ),
          child: profile.coverImage == null
              ? Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade300, Colors.purple.shade300],
              ),
            ),
          )
              : null,
        ),

        // Gradient Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
        ),

        // Content
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Avatar
                ProfileAvatar(
                  avatarUrl: profile.avatar,
                  username: profile.username,
                  size: 80,
                  isOnline: profile.isOnline,
                ),
                const SizedBox(width: 16),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              profile.displayNameOrUsername,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (profile.badges.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${profile.username}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (profile.location != null && profile.location!.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              profile.location!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white54,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Joined ${DateFormatter.formatDate(profile.joinedAt)}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isCurrentUser)
                      _buildActionButton(
                        icon: Icons.edit,
                        label: 'Edit',
                        onPressed: onEditPressed,
                      )
                    else ...[
                      _buildActionButton(
                        icon: Icons.message,
                        label: 'Message',
                        onPressed: onMessagePressed,
                      ),
                      const SizedBox(height: 8),
                      _buildActionButton(
                        icon: isFollowing ? Icons.person_remove : Icons.person_add,
                        label: isFollowing ? 'Unfollow' : 'Follow',
                        onPressed: onFollowPressed,
                      ),
                    ],
                    const SizedBox(height: 8),
                    _buildActionButton(
                      icon: Icons.share,
                      label: 'Share',
                      onPressed: onSharePressed,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Back Button
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),

        // Stats Overlay (optional)
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _buildStatItem('${profile.followersCount}', 'Followers'),
                _buildStatDivider(),
                _buildStatItem('${profile.followingCount}', 'Following'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 20,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ProfileModel>('profile', profile));
    properties.add(DiagnosticsProperty<bool>('isCurrentUser', isCurrentUser));
    properties.add(DiagnosticsProperty<bool>('isFollowing', isFollowing));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onEditPressed', onEditPressed));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onMessagePressed', onMessagePressed));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onFollowPressed', onFollowPressed));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onSharePressed', onSharePressed));
  }
}

// Simple header without cover image (for profile card)
class ProfileSimpleHeader extends StatelessWidget {
  final ProfileModel profile;
  final double size;

  const ProfileSimpleHeader({
    super.key,
    required this.profile,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProfileAvatar(
          avatarUrl: profile.avatar,
          username: profile.username,
          size: size,
          isOnline: profile.isOnline,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.displayNameOrUsername,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '@${profile.username}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ProfileModel>('profile', profile));
    properties.add(DoubleProperty('size', size));
  }
}

// Mini header for list tiles
class ProfileMiniHeader extends StatelessWidget {
  final ProfileModel profile;

  const ProfileMiniHeader({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProfileAvatar(
          avatarUrl: profile.avatar,
          username: profile.username,
          size: 40,
          isOnline: profile.isOnline,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.displayNameOrUsername,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '@${profile.username}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ProfileModel>('profile', profile));
  }
}