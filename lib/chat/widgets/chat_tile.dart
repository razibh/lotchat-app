import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/chat_model.dart';
import '../../core/utils/date_formatters.dart';


class ChatTile extends StatelessWidget {
  const ChatTile({
    super.key,
    required this.chat,
    required this.onTap,
    this.onLongPress,
    this.onMute,
    this.onPin,
    this.onArchive,
    this.onDelete,
  });

  final ChatModel chat;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onMute;
  final VoidCallback? onPin;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildAvatar(),
      title: Row(
        children: [
          Expanded(
            child: Text(
              chat.type == 'private'
                  ? (chat.participants.isNotEmpty ? chat.participants.first : 'User')
                  : (chat.groupName ?? 'Group'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 4),
          // 🟢 lastMessageTime ব্যবহার করুন
          Text(
            _formatTime(chat.lastMessageTime),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              chat.lastMessage ?? 'No messages yet',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          // 🟢 Mute/Pin/Archive features সরিয়ে দেওয়া হয়েছে কারণ ChatModel এ fields নেই
        ],
      ),
      onTap: onTap,
      onLongPress: () => _showOptions(context),
    );
  }

  Widget _buildAvatar() {
    if (chat.type == 'private') {
      return CircleAvatar(
        backgroundImage: chat.groupAvatar != null
            ? NetworkImage(chat.groupAvatar!)
            : null,
        child: chat.groupAvatar == null
            ? Text(chat.participants.isNotEmpty
            ? chat.participants.first[0].toUpperCase()
            : '?')
            : null,
      );
    } else {
      return CircleAvatar(
        backgroundImage: chat.groupAvatar != null
            ? NetworkImage(chat.groupAvatar!)
            : null,
        child: chat.groupAvatar == null
            ? const Icon(Icons.group, size: 20)
            : null,
      );
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    } else {
      return 'now';
    }
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.push_pin),
              title: const Text('Pin Chat'),
              onTap: () {
                Navigator.pop(context);
                onPin?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.volume_off),
              title: const Text('Mute Notifications'),
              onTap: () {
                Navigator.pop(context);
                onMute?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archive Chat'),
              onTap: () {
                Navigator.pop(context);
                onArchive?.call();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Chat', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                onDelete?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ChatModel>('chat', chat));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onTap', onTap));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onLongPress', onLongPress));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onMute', onMute));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onPin', onPin));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onArchive', onArchive));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onDelete', onDelete));
  }
}