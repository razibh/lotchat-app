import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../models/friend_model.dart';
import 'online_status_badge.dart';

class FriendTile extends StatelessWidget {
  final FriendModel friend;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  const FriendTile({
    required this.friend,
    required this.onTap,
    required this.onMoreTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar with online status
              OnlineStatusBadge(
                isOnline: friend.isOnline,
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: friend.avatar != null
                      ? NetworkImage(friend.avatar!)
                      : null,
                  backgroundColor: Colors.grey.shade200,
                  child: friend.avatar == null
                      ? Text(
                    friend.username.isNotEmpty ? friend.username[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : null,
                ),
              ),
              const SizedBox(width: 12),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            friend.displayNameOrUsername,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (friend.isFavorite)
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (friend.note != null && friend.note!.isNotEmpty) ...[
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
                      children: [
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
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatLastActive(DateTime lastActive) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${lastActive.day}/${lastActive.month}';
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<FriendModel>('friend', friend));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onTap', onTap));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onMoreTap', onMoreTap));
  }
}