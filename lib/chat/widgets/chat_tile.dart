import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../../../core/utils/date_formatter.dart';

class ChatTile extends StatelessWidget {

  const ChatTile({
    required this.chat, required this.onTap, super.key,
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
        children: <>[
          Expanded(
            child: Text(
              chat.type == 'private' 
                  ? chat.participants.first 
                  : chat.groupName ?? 'Group',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (chat.isPinned)
            const Icon(Icons.push_pin, size: 16, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            DateFormatter.formatChatTime(chat.updatedAt),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      subtitle: Row(
        children: <>[
          if (chat.lastMessage != null) ...<>[
            Expanded(
              child: Text(
                chat.lastMessage!.content,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: chat.unreadCount > 0 
                      ? Colors.black 
                      : Colors.grey,
                  fontWeight: chat.unreadCount > 0 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
              ),
            ),
          ],
          if (chat.isMuted)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.volume_off, size: 16, color: Colors.grey),
            ),
          if (chat.unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${chat.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
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
            ? Text(chat.participants.first[0].toUpperCase())
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

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Wrap(
          children: <>[
            if (!chat.isPinned)
              ListTile(
                leading: const Icon(Icons.push_pin),
                title: const Text('Pin Chat'),
                onTap: () {
                  Navigator.pop(context);
                  onPin?.call();
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.push_pin_outlined),
                title: const Text('Unpin Chat'),
                onTap: () {
                  Navigator.pop(context);
                  onPin?.call();
                },
              ),
            if (!chat.isMuted)
              ListTile(
                leading: const Icon(Icons.volume_off),
                title: const Text('Mute Notifications'),
                onTap: () {
                  Navigator.pop(context);
                  onMute?.call();
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.volume_up),
                title: const Text('Unmute Notifications'),
                onTap: () {
                  Navigator.pop(context);
                  onMute?.call();
                },
              ),
            if (!chat.isArchived)
              ListTile(
                leading: const Icon(Icons.archive),
                title: const Text('Archive Chat'),
                onTap: () {
                  Navigator.pop(context);
                  onArchive?.call();
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.unarchive),
                title: const Text('Unarchive Chat'),
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