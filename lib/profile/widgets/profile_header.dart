import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import 'profile_avatar.dart';
import '../../../core/utils/date_formatter.dart';

class ProfileHeader extends StatelessWidget {

  const ProfileHeader({
    Key? key,
    required this.profile,
    required this.isCurrentUser,
    this.onEditPressed,
    this.onMessagePressed,
    this.onFollowPressed,
    this.onSharePressed,
  }) : super(key: key);
  final ProfileModel profile;
  final bool isCurrentUser;
  final VoidCallback? onEditPressed;
  final VoidCallback? onMessagePressed;
  final VoidCallback? onFollowPressed;
  final VoidCallback? onSharePressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <>[
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
                      colors: <>[Colors.blue.shade300, Colors.purple.shade300],
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
                colors: <>[
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
              children: <>[
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
                    children: <>[
                      Text(
                        profile.displayNameOrUsername,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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
                      if (profile.location != null)
                        Row(
                          children: <>[
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
                      Text(
                        'Joined ${DateFormatter.formatDate(profile.joinedAt)}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <>[
                    if (isCurrentUser)
                      _buildActionButton(
                        icon: Icons.edit,
                        label: 'Edit',
                        onPressed: onEditPressed,
                      )
                    else ...<>[
                      _buildActionButton(
                        icon: Icons.message,
                        label: 'Message',
                        onPressed: onMessagePressed,
                      ),
                      const SizedBox(height: 8),
                      _buildActionButton(
                        icon: Icons.person_add,
                        label: 'Follow',
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
      ],
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
          children: <>[
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}