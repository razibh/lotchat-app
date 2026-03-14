import 'package:flutter/material.dart';
import '../models/message_model.dart';
import 'message_reaction.dart';

class MessageBubble extends StatelessWidget {

  const MessageBubble({
    required this.message, required this.isMe, super.key,
    this.showAvatar = true,
    this.showName = true,
    this.onTap,
    this.onLongPress,
    this.onReply,
    this.onForward,
    this.onDelete,
    this.onReport,
    this.onReaction,
  });
  final MessageModel message;
  final bool isMe;
  final bool showAvatar;
  final bool showName;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onReply;
  final VoidCallback? onForward;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;
  final Function(String)? onReaction;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showOptions(context),
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 64 : 16,
          right: isMe ? 16 : 64,
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
                        message.senderName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <>[
                        if (message.replyTo != null)
                          _buildReplyPreview(),
                        if (message.type == MessageType.text)
                          Text(
                            message.content,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        if (message.type == MessageType.image)
                          _buildImage(),
                        if (message.type == MessageType.video)
                          _buildVideo(),
                        if (message.type == MessageType.audio)
                          _buildAudio(),
                        if (message.type == MessageType.file)
                          _buildFile(),
                        if (message.type == MessageType.location)
                          _buildLocation(),
                        if (message.type == MessageType.contact)
                          _buildContact(),
                        if (message.type == MessageType.gift)
                          _buildGift(),
                        if (message.type == MessageType.call)
                          _buildCall(),
                        _buildFooter(),
                      ],
                    ),
                  ),
                  if (message.reactions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: MessageReactions(
                        reactions: message.reactions,
                        onReaction: onReaction,
                      ),
                    ),
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
      child: CircleAvatar(
        radius: 16,
        backgroundImage: message.senderAvatar != null
            ? NetworkImage(message.senderAvatar!)
            : null,
        child: message.senderAvatar == null
            ? Text(message.senderName[0].toUpperCase())
            : null,
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: <>[
          const Icon(Icons.reply, size: 12),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  message.replyTo!.senderName,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  message.replyTo!.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Column(
      children: <>[
        if (message.thumbnailUrl != null)
          Image.network(
            message.thumbnailUrl!,
            height: 150,
            width: 150,
            fit: BoxFit.cover,
          ),
        if (message.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(message.content),
          ),
      ],
    );
  }

  Widget _buildVideo() {
    return Container(
      height: 100,
      width: 150,
      color: Colors.black12,
      child: const Center(
        child: Icon(Icons.play_circle_fill, size: 40),
      ),
    );
  }

  Widget _buildAudio() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <>[
          const Icon(Icons.audio_file),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  message.fileName ?? 'Audio',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  _formatDuration(message.duration ?? 0),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFile() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <>[
          const Icon(Icons.insert_drive_file),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  message.fileName ?? 'File',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  _formatFileSize(message.fileSize ?? 0),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocation() {
    return Container(
      height: 100,
      width: 150,
      color: Colors.black12,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <>[
            const Icon(Icons.location_on),
            Text(message.placeName ?? 'Location'),
          ],
        ),
      ),
    );
  }

  Widget _buildContact() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: <>[
          const CircleAvatar(
            child: Icon(Icons.person, size: 20),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <>[
              Text(message.contactName ?? 'Contact'),
              Text(
                message.contactPhone ?? '',
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGift() {
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
          const Icon(Icons.card_giftcard, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  message.giftName ?? 'Gift',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${message.giftPrice} coins',
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCall() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: <>[
          Icon(
            message.callType == 'video' ? Icons.videocam : Icons.call,
            color: message.callType == 'video' ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  message.callType == 'video' ? 'Video Call' : 'Voice Call',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatDuration(message.callDuration ?? 0),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
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
          if (message.isForwarded)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.reply, size: 10, color: Colors.grey),
            ),
          if (message.editedAt != null)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Text(
                'edited',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          Text(
            _formatTime(message.timestamp),
            style: TextStyle(
              fontSize: 10,
              color: isMe ? Colors.white70 : Colors.grey,
            ),
          ),
          if (isMe) ...<>[
            const SizedBox(width: 4),
            Icon(
              message.status == MessageStatus.read
                  ? Icons.done_all
                  : message.status == MessageStatus.delivered
                      ? Icons.done_all
                      : message.status == MessageStatus.sent
                          ? Icons.done
                          : message.status == MessageStatus.sending
                              ? Icons.schedule
                              : Icons.error,
              size: 12,
              color: message.status == MessageStatus.read
                  ? Colors.blue
                  : Colors.white70,
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final DateTime now = DateTime.now();
    final Duration diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${time.hour}:${time.minute}';
  }

  String _formatDuration(int seconds) {
    final int mins = seconds ~/ 60;
    final int secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Wrap(
          children: <>[
            if (!isMe)
              ListTile(
                leading: const Icon(Icons.reply),
                title: const Text('Reply'),
                onTap: () {
                  Navigator.pop(context);
                  onReply?.call();
                },
              ),
            ListTile(
              leading: const Icon(Icons.forward),
              title: const Text('Forward'),
              onTap: () {
                Navigator.pop(context);
                onForward?.call();
              },
            ),
            if (!isMe)
              ListTile(
                leading: const Icon(Icons.flag, color: Colors.orange),
                title: const Text('Report'),
                onTap: () {
                  Navigator.pop(context);
                  onReport?.call();
                },
              ),
            if (isMe)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
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
    properties.add(DiagnosticsProperty<MessageModel>('message', message));
    properties.add(DiagnosticsProperty<bool>('isMe', isMe));
    properties.add(DiagnosticsProperty<bool>('showAvatar', showAvatar));
    properties.add(DiagnosticsProperty<bool>('showName', showName));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onLongPress', onLongPress));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onReply', onReply));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onForward', onForward));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onDelete', onDelete));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onReport', onReport));
    properties.add(ObjectFlagProperty<Function(String)?>.has('onReaction', onReaction));
  }
}