import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/clan_member_model.dart';
import '../../../core/utils/date_formatters.dart';  // এই import টা আছে কি?

class ClanMemberTile extends StatelessWidget {
  final ClanMemberModel member;
  final bool isCurrentUser;
  final VoidCallback? onTap;
  final VoidCallback? onMessage;
  final VoidCallback? onPromote;
  final VoidCallback? onDemote;
  final VoidCallback? onKick;
  final bool showActions;

  const ClanMemberTile({
    required this.member,
    super.key,
    this.isCurrentUser = false,
    this.onTap,
    this.onMessage,
    this.onPromote,
    this.onDemote,
    this.onKick,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar with status
              _buildAvatar(),
              const SizedBox(width: 12),

              // Member Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            member.displayNameOrUsername,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isCurrentUser)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'You',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: member.roleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            member.roleIcon,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            member.roleDisplay,
                            style: TextStyle(
                              fontSize: 10,
                              color: member.roleColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Activity Stats
                    Row(
                      children: [
                        _buildStatItem(
                          icon: Icons.flash_on,
                          value: '${member.activityPoints}',
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 8),
                        _buildStatItem(
                          icon: Icons.card_giftcard,
                          value: '${member.giftsSent}',
                          color: Colors.purple,
                        ),
                        const SizedBox(width: 8),
                        _buildStatItem(
                          icon: Icons.emoji_events,
                          value: '${member.warPoints}',
                          color: Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Join Date
                    Text(
                      'Joined ${_formatDate(member.joinedAt)}',  // Formatters এর পরিবর্তে লোকাল মেথড ব্যবহার
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              if (showActions && !isCurrentUser)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) {
                    final items = <PopupMenuEntry<String>>[
                      const PopupMenuItem(
                        value: 'message',
                        child: Text('Message'),
                      ),
                    ];

                    if (member.role != MemberClanRole.leader) {
                      items.addAll([
                        const PopupMenuItem(
                          value: 'promote',
                          child: Text('Promote'),
                        ),
                        const PopupMenuItem(
                          value: 'demote',
                          child: Text('Demote'),
                        ),
                        const PopupMenuItem(
                          value: 'kick',
                          child: Text(
                            'Kick Member',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ]);
                    }

                    return items;
                  },
                  onSelected: (value) {
                    switch (value) {
                      case 'message':
                        onMessage?.call();
                        break;
                      case 'promote':
                        onPromote?.call();
                        break;
                      case 'demote':
                        onDemote?.call();
                        break;
                      case 'kick':
                        onKick?.call();
                        break;
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundImage: member.avatar != null
              ? NetworkImage(member.avatar!)
              : null,
          backgroundColor: Colors.grey.shade200,
          child: member.avatar == null
              ? Text(
            member.username[0].toUpperCase(),
            style: const TextStyle(fontSize: 20),
          )
              : null,
        ),
        if (member.isOnline)
          const Positioned(
            bottom: 2,
            right: 2,
            child: CircleAvatar(
              radius: 6,
              backgroundColor: Colors.green,
            ),
          ),
        if (member.status == MemberOnlineStatus.away ||
            member.status == MemberOnlineStatus.busy)
          Positioned(
            bottom: 2,
            right: 2,
            child: CircleAvatar(
              radius: 6,
              backgroundColor: member.status == MemberOnlineStatus.away
                  ? Colors.orange
                  : Colors.red,
            ),
          ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  // ✅ নতুন মেথড যোগ করা হয়েছে
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ClanMemberModel>('member', member));
    properties.add(DiagnosticsProperty<bool>('isCurrentUser', isCurrentUser));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onMessage', onMessage));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onPromote', onPromote));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onDemote', onDemote));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onKick', onKick));
    properties.add(DiagnosticsProperty<bool>('showActions', showActions));
  }
}

class CompactMemberTile extends StatelessWidget {
  final ClanMemberModel member;
  final VoidCallback? onTap;

  const CompactMemberTile({
    required this.member,
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: member.avatar != null
                ? NetworkImage(member.avatar!)
                : null,
            child: member.avatar == null
                ? Text(member.username[0].toUpperCase())
                : null,
          ),
          if (member.isOnline)
            const Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 5,
                backgroundColor: Colors.green,
              ),
            ),
        ],
      ),
      title: Text(member.displayNameOrUsername),
      subtitle: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: member.roleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              member.roleDisplay,
              style: TextStyle(
                fontSize: 10,
                color: member.roleColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${member.activityPoints} XP',
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
      trailing: Text(
        member.roleIcon,
        style: const TextStyle(fontSize: 16),
      ),
      onTap: onTap,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ClanMemberModel>('member', member));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
  }
}