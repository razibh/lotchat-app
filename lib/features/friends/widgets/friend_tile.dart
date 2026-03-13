import 'package:flutter/material.dart';
import '../models/friend_model.dart';
import 'online_status_badge.dart';

class FriendTile extends StatelessWidget {

  const FriendTile({
    Key? key,
    required this.friend,
    required this.onTap,
    required this.onMoreTap,
  }) : super(key: key);
  final FriendModel friend;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <>[
              // Avatar with online status
              OnlineStatusBadge(
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: friend.avatar != null
                      ? NetworkImage(friend.avatar!)
                      : null,
                  child: friend.avatar == null
                      ? Text(friend.username[0].toUpperCase())
                      : null,
                ),
                isOnline: friend.isOnline,
              ),
              const SizedBox(width: 12),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <>[
                    Row(
                      children: <>[
                        Expanded(
                          child: Text(
                            friend.displayNameOrUsername,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (friend.isFavorite)
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (friend.note != null) ...<>[
                      Text(
                        friend.note!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    Row(
                      children: <>[
                        Icon(Icons.people, size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 2),
                        Text(
                          '${friend.mutualFriends} mutual',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (friend.lastActive != null)
                          Text(
                            _formatLastActive(friend.lastActive!),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Button
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: onMoreTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatLastActive(DateTime lastActive) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(lastActive);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}