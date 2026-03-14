import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/chat_model.dart';
import 'models/message_model.dart';
import 'providers/chat_provider.dart';
import 'widgets/chat_info_tile.dart';
import '../core/utils/date_formatters.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/notification_service.dart';

class ChatInfoScreen extends StatefulWidget {
  const ChatInfoScreen({
    required this.chat, super.key,
  });

  final ChatModel chat;

  @override
  State<ChatInfoScreen> createState() => _ChatInfoScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ChatModel>('chat', chat));
  }
}

class _ChatInfoScreenState extends State<ChatInfoScreen> {
  late final NotificationService _notificationService;
  bool _isMuted = false;
  bool _isPinned = false;
  bool _isArchived = false;

  @override
  void initState() {
    super.initState();
    _notificationService = ServiceLocator.instance.get<NotificationService>();
    _isMuted = widget.chat.isMuted ?? false;
    _isPinned = widget.chat.isPinned ?? false;
    _isArchived = widget.chat.isArchived ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Info'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: <Widget>[
          // Chat Header
          _buildChatHeader(),
          const SizedBox(height: 16),

          // Media & Files
          _buildSectionTitle('Media & Files'),
          _buildMediaGrid(),
          const SizedBox(height: 8),
          ChatInfoTile(
            icon: Icons.photo_library,
            title: 'All Media',
            subtitle: 'View all photos and videos',
            onTap: _viewAllMedia,
          ),
          ChatInfoTile(
            icon: Icons.insert_drive_file,
            title: 'Files',
            subtitle: 'View all shared files',
            onTap: _viewAllFiles,
          ),
          const Divider(),

          // Options
          _buildSectionTitle('Options'),
          ChatInfoTile(
            icon: Icons.notifications,
            title: 'Mute Notifications',
            trailing: Switch(
              value: _isMuted,
              onChanged: _toggleMute,
            ),
            onTap: () => _toggleMute(!_isMuted),
          ),
          ChatInfoTile(
            icon: Icons.push_pin,
            title: 'Pin Chat',
            trailing: Switch(
              value: _isPinned,
              onChanged: _togglePin,
            ),
            onTap: () => _togglePin(!_isPinned),
          ),
          ChatInfoTile(
            icon: Icons.archive,
            title: 'Archive Chat',
            trailing: Switch(
              value: _isArchived,
              onChanged: _toggleArchive,
            ),
            onTap: () => _toggleArchive(!_isArchived),
          ),
          const Divider(),

          // Members (for group chat)
          if (widget.chat.type == 'group') ...<Widget>[
            _buildSectionTitle('Members'),
            ...List.generate(5, (int index) {
              return ListTile(
                leading: CircleAvatar(
                  child: Text('U${index + 1}'),
                ),
                title: Text('User ${index + 1}'),
                subtitle: Text(index == 0 ? 'Admin' : 'Member'),
                trailing: index != 0
                    ? PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'make_admin') {
                      // Make admin logic
                    } else if (value == 'remove') {
                      // Remove member logic
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'make_admin',
                      child: Text('Make Admin'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'remove',
                      child: Text('Remove'),
                    ),
                  ],
                )
                    : null,
              );
            }),
            ChatInfoTile(
              icon: Icons.person_add,
              title: 'Add Members',
              onTap: _addMembers,
            ),
            const Divider(),
          ],

          // Privacy & Support
          _buildSectionTitle('Privacy & Support'),
          ChatInfoTile(
            icon: Icons.block,
            title: 'Block User',
            subtitle: 'Block this user',
            color: Colors.red,
            onTap: _blockUser,
          ),
          ChatInfoTile(
            icon: Icons.flag,
            title: 'Report',
            subtitle: 'Report this chat',
            color: Colors.orange,
            onTap: _reportChat,
          ),
          ChatInfoTile(
            icon: Icons.delete_forever,
            title: 'Delete Chat',
            subtitle: 'Delete this conversation',
            color: Colors.red,
            onTap: _deleteChat,
          ),
          const SizedBox(height: 20),

          // Chat Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Chat Details',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Created: ${DateFormatter.formatDate(widget.chat.createdAt)}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'Chat ID: ${widget.chat.id.substring(0, 8)}...',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.blue.withValues(alpha: 0.1), // Fixed deprecated withOpacity
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 40,
            backgroundImage: widget.chat.groupAvatar != null
                ? NetworkImage(widget.chat.groupAvatar!)
                : null,
            child: widget.chat.groupAvatar == null
                ? Icon(
              widget.chat.type == 'private' ? Icons.person : Icons.group,
              size: 40,
            )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.chat.type == 'private'
                      ? widget.chat.participants.first
                      : widget.chat.groupName ?? 'Group',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.chat.type == 'private'
                      ? 'Last seen recently'
                      : '${widget.chat.participants.length} members',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildMediaGrid() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 10,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              image: index % 3 == 0
                  ? DecorationImage(
                image: NetworkImage('https://picsum.photos/80/80?random=$index'),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: index % 3 != 0
                ? const Center(
              child: Icon(Icons.insert_drive_file, color: Colors.grey),
            )
                : null,
          );
        },
      ),
    );
  }

  void _toggleMute(bool? value) {
    if (value == null) return;
    setState(() => _isMuted = value);
    context.read<ChatProvider>().toggleMute(widget.chat.id);

    if (value) {
      _notificationService.showToast('Chat muted');
    } else {
      _notificationService.showToast('Chat unmuted');
    }
  }

  void _togglePin(bool? value) {
    if (value == null) return;
    setState(() => _isPinned = value);
    context.read<ChatProvider>().togglePin(widget.chat.id);

    if (value) {
      _notificationService.showToast('Chat pinned');
    } else {
      _notificationService.showToast('Chat unpinned');
    }
  }

  void _toggleArchive(bool? value) {
    if (value == null) return;
    setState(() => _isArchived = value);
    context.read<ChatProvider>().toggleArchive(widget.chat.id);

    if (value) {
      _notificationService.showToast('Chat archived');
      Navigator.pop(context);
      Navigator.pop(context); // Go back to chat list
    } else {
      _notificationService.showToast('Chat unarchived');
    }
  }

  void _viewAllMedia() {
    // Navigate to all media
  }

  void _viewAllFiles() {
    // Navigate to all files
  }

  void _addMembers() {
    // Add members to group
  }

  Future<void> _blockUser() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Block User'),
        content: const Text('Are you sure you want to block this user?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Block'),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      _notificationService.showToast('User blocked');
      Navigator.pop(context);
    }
  }

  Future<void> _reportChat() async {
    final String? reason = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Report Chat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Why are you reporting this chat?'),
            const SizedBox(height: 16),
            ...<String>['Spam', 'Harassment', 'Inappropriate', 'Other'].map((String r) {
              return ListTile(
                title: Text(r),
                onTap: () => Navigator.pop(context, r),
              );
            }),
          ],
        ),
      ),
    );

    if (reason != null) {
      _notificationService.showToast('Chat reported');
    }
  }

  Future<void> _deleteChat() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text('Are you sure you want to delete this chat?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      context.read<ChatProvider>().deleteChat(widget.chat.id);
      _notificationService.showToast('Chat deleted');
      Navigator.pop(context);
      Navigator.pop(context); // Go back to chat list
    }
  }
}