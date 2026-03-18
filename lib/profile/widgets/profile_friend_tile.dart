import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/models/user_models.dart';
import 'profile_avatar.dart';

class ProfileFriendTile extends StatelessWidget {
  final User user; // UserModel এর পরিবর্তে User
  final VoidCallback? onTap;
  final VoidCallback? onMessage;
  final VoidCallback? onFollow;
  final VoidCallback? onUnfollow;
  final bool showActions;
  final bool isFollowing;

  const ProfileFriendTile({
    super.key,
    required this.user,
    this.onTap,
    this.onMessage,
    this.onFollow,
    this.onUnfollow,
    this.showActions = true,
    this.isFollowing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: ProfileAvatar(
          avatarUrl: user.avatar ?? user.photoURL,
          username: user.username,
          size: 40,
          isOnline: user.isOnline,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.displayName ?? user.username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (user.isVerified)
              const Icon(
                Icons.verified,
                color: Colors.blue,
                size: 16,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '@${user.username}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 2),
            _buildStatusText(),
          ],
        ),
        trailing: showActions ? _buildActions() : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatusText() {
    if (user.isOnline) {
      return const Text(
        'Online',
        style: TextStyle(
          color: Colors.green,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (user.lastLoginAt != null) {
      return Text(
        'Last seen ${_formatLastSeen(user.lastLoginAt!)}',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 11,
        ),
      );
    }

    return const Text(
      'Offline',
      style: TextStyle(
        color: Colors.grey,
        fontSize: 11,
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Message Button
        IconButton(
          icon: const Icon(Icons.message, color: Colors.blue),
          onPressed: onMessage,
          tooltip: 'Send Message',
          splashRadius: 20,
        ),

        // Follow/Unfollow Button
        if (onFollow != null || onUnfollow != null)
          IconButton(
            icon: Icon(
              isFollowing ? Icons.person_remove : Icons.person_add,
              color: isFollowing ? Colors.red : Colors.green,
            ),
            onPressed: isFollowing ? onUnfollow : onFollow,
            tooltip: isFollowing ? 'Unfollow' : 'Follow',
            splashRadius: 20,
          ),
      ],
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<User>('user', user));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onMessage', onMessage));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onFollow', onFollow));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onUnfollow', onUnfollow));
    properties.add(DiagnosticsProperty<bool>('showActions', showActions));
    properties.add(DiagnosticsProperty<bool>('isFollowing', isFollowing));
  }
}

// Friend list with section header
class ProfileFriendSection extends StatelessWidget {
  final String title;
  final List<User> friends;
  final VoidCallback? onViewAll;
  final Function(User)? onFriendTap;
  final Function(User)? onMessageTap;
  final Function(User)? onFollowTap;
  final Function(User)? onUnfollowTap;

  const ProfileFriendSection({
    super.key,
    required this.title,
    required this.friends,
    this.onViewAll,
    this.onFriendTap,
    this.onMessageTap,
    this.onFollowTap,
    this.onUnfollowTap,
  });

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onViewAll != null && friends.length > 5)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('View All'),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: friends.length > 5 ? 5 : friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 8),
                child: Column(
                  children: [
                    ProfileAvatar(
                      avatarUrl: friend.avatar ?? friend.photoURL,
                      username: friend.username,
                      size: 50,
                      isOnline: friend.isOnline,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      friend.displayName ?? friend.username,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(IterableProperty<User>('friends', friends));
  }
}

// Friend request tile
class ProfileFriendRequestTile extends StatelessWidget {
  final User user;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onTap;

  const ProfileFriendRequestTile({
    super.key,
    required this.user,
    this.onAccept,
    this.onReject,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: ProfileAvatar(
          avatarUrl: user.avatar ?? user.photoURL,
          username: user.username,
          size: 40,
        ),
        title: Text(user.displayName ?? user.username),
        subtitle: Text('@${user.username}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: onAccept,
              tooltip: 'Accept',
              splashRadius: 20,
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: onReject,
              tooltip: 'Reject',
              splashRadius: 20,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<User>('user', user));
  }
}

// Friend suggestion tile
class ProfileFriendSuggestionTile extends StatelessWidget {
  final User user;
  final int? mutualFriends;
  final VoidCallback? onAdd;
  final VoidCallback? onTap;

  const ProfileFriendSuggestionTile({
    super.key,
    required this.user,
    this.mutualFriends,
    this.onAdd,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: ProfileAvatar(
          avatarUrl: user.avatar ?? user.photoURL,
          username: user.username,
          size: 40,
        ),
        title: Text(user.displayName ?? user.username),
        subtitle: mutualFriends != null && mutualFriends! > 0
            ? Text('$mutualFriends mutual friends')
            : Text('@${user.username}'),
        trailing: IconButton(
          icon: const Icon(Icons.person_add, color: Colors.green),
          onPressed: onAdd,
          tooltip: 'Add Friend',
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<User>('user', user));
    properties.add(IntProperty('mutualFriends', mutualFriends));
  }
}