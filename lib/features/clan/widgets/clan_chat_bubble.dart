import 'package:flutter/material.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/clan_member_model.dart';

enum MessageType { text, image, gift, system, announcement }

class ClanChatBubble extends StatelessWidget {

  const ClanChatBubble({
    required this.sender, required this.message, required this.type, required this.timestamp, required this.isMe, super.key,
    this.showAvatar = true,
    this.showName = true,
    this.imageUrl,
    this.giftName,
    this.giftPrice,
    this.reactions,
    this.onTap,
    this.onLongPress,
    this.onReply,
    this.onReact,
    this.onPin,
    this.onReport,
  });
  final ClanMemberModel sender;
  final String message;
  final MessageType type;
  final DateTime timestamp;
  final bool isMe;
  final bool showAvatar;
  final bool showName;
  final String? imageUrl;
  final String? giftName;
  final int? giftPrice;
  final Map<String, dynamic>? reactions;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onReply;
  final VoidCallback? onReact;
  final VoidCallback? onPin;
  final VoidCallback? onReport;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: _showOptions,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 64 : 8,
          right: isMe ? 8 : 64,
          top: 4,
          bottom: 4,
        ),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <>[
            if (!isMe && showAvatar)
              _buildAvatar()
            else if (!isMe && !showAvatar)
              const SizedBox(width: 40),
            
            Expanded(
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: <>[
                  if (!isMe && showName)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 2),
                      child: Text(
                        sender.displayNameOrUsername,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: sender.roleColor,
                        ),
                      ),
                    ),
                  
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getBubbleColor(),
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomLeft: isMe 
                            ? const Radius.circular(16) 
                            : Radius.zero,
                        bottomRight: isMe 
                            ? Radius.zero 
                            : const Radius.circular(16),
                      ),
                      boxShadow: <>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <>[
                        if (type == MessageType.system)
                          _buildSystemMessage()
                        else if (type == MessageType.announcement)
                          _buildAnnouncement()
                        else if (type == MessageType.image)
                          _buildImageMessage()
                        else if (type == MessageType.gift)
                          _buildGiftMessage()
                        else
                          _buildTextMessage(),
                        
                        _buildFooter(),
                      ],
                    ),
                  ),

                  if (reactions != null && reactions!.isNotEmpty)
                    _buildReactions(),
                ],
              ),
            ),

            if (isMe && showAvatar)
              _buildAvatar()
            else if (isMe && !showAvatar)
              const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Stack(
        children: <>[
          CircleAvatar(
            radius: 16,
            backgroundImage: sender.avatar != null
                ? NetworkImage(sender.avatar!)
                : null,
            backgroundColor: Colors.grey.shade200,
            child: sender.avatar == null
                ? Text(
                    sender.username[0].toUpperCase(),
                    style: const TextStyle(fontSize: 12),
                  )
                : null,
          ),
          if (sender.isOnline)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextMessage() {
    return SelectableText(
      message,
      style: TextStyle(
        color: isMe ? Colors.white : Colors.black87,
        fontSize: 14,
      ),
    );
  }

  Widget _buildImageMessage() {
    return Column(
      children: <>[
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl!,
            height: 150,
            width: 150,
            fit: BoxFit.cover,
            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? progress) {
              if (progress == null) return child;
              return Container(
                height: 150,
                width: 150,
                color: Colors.grey.shade300,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ),
        if (message.isNotEmpty) ...<>[
          const SizedBox(height: 8),
          _buildTextMessage(),
        ],
      ],
    );
  }

  Widget _buildGiftMessage() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <>[Colors.purple, Colors.pink],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <>[
          const Icon(
            Icons.card_giftcard,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  giftName ?? 'Gift',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (giftPrice != null)
                  Text(
                    '$giftPrice coins',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMessage() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncement() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <>[
          const Icon(
            Icons.campaign,
            color: Colors.amber,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <>[
          Text(
            DateFormatter.formatChatTime(timestamp),
            style: TextStyle(
              fontSize: 10,
              color: isMe ? Colors.white70 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactions() {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Wrap(
        spacing: 2,
        children: reactions!.entries.map((MapEntry<String, dynamic> entry) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <>[
                Text(entry.key),
                const SizedBox(width: 2),
                Text(
                  '${entry.value}',
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getBubbleColor() {
    if (type == MessageType.system || type == MessageType.announcement) {
      return Colors.transparent;
    }
    if (type == MessageType.gift) {
      return Colors.transparent;
    }
    return isMe ? Colors.blue : Colors.grey.shade200;
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Wrap(
          children: <>[
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(context);
                onReply?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_emotions),
              title: const Text('React'),
              onTap: () {
                Navigator.pop(context);
                onReact?.call();
              },
            ),
            if (!isMe && sender.role != ClanRole.member) ...<>[
              ListTile(
                leading: const Icon(Icons.push_pin),
                title: const Text('Pin Message'),
                onTap: () {
                  Navigator.pop(context);
                  onPin?.call();
                },
              ),
            ],
            if (!isMe) ...<>[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.flag, color: Colors.orange),
                title: const Text('Report', style: TextStyle(color: Colors.orange)),
                onTap: () {
                  Navigator.pop(context);
                  onReport?.call();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ClanMemberModel>('sender', sender));
    properties.add(StringProperty('message', message));
    properties.add(EnumProperty<MessageType>('type', type));
    properties.add(DiagnosticsProperty<DateTime>('timestamp', timestamp));
    properties.add(DiagnosticsProperty<bool>('isMe', isMe));
    properties.add(DiagnosticsProperty<bool>('showAvatar', showAvatar));
    properties.add(DiagnosticsProperty<bool>('showName', showName));
    properties.add(StringProperty('imageUrl', imageUrl));
    properties.add(StringProperty('giftName', giftName));
    properties.add(IntProperty('giftPrice', giftPrice));
    properties.add(DiagnosticsProperty<Map<String, dynamic>?>('reactions', reactions));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onLongPress', onLongPress));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onReply', onReply));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onReact', onReact));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onPin', onPin));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onReport', onReport));
  }
}