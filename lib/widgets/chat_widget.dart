import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../core/utils/date_formatters.dart';

enum MessageType { text, image, gift, system }

class ChatWidget extends StatefulWidget {
  final String roomId;
  final String? currentUserId;

  const ChatWidget({
    super.key,
    required this.roomId,
    this.currentUserId,
  });

  @override
  State<ChatWidget> createState() => _ChatWidgetState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('roomId', roomId));
    properties.add(StringProperty('currentUserId', currentUserId));
  }
}

class _ChatWidgetState extends State<ChatWidget> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    setState(() {
      _isLoading = true;
    });

    // Mock messages
    _messages.addAll([
      ChatMessage(
        id: '1',
        userId: 'user1',
        username: 'Alice',
        userAvatar: null,
        message: 'Hello everyone! Welcome to the room!',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChatMessage(
        id: '2',
        userId: 'user2',
        username: 'Bob',
        userAvatar: null,
        message: 'Hi Alice! Thanks for having us.',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
      ChatMessage(
        id: '3',
        userId: 'user3',
        username: 'Charlie',
        userAvatar: null,
        message: 'This is great!',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      ChatMessage(
        id: '4',
        userId: 'user1',
        username: 'Alice',
        userAvatar: null,
        message: 'Check out this gift!',
        type: MessageType.gift,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        giftData: {
          'name': 'Rose',
          'icon': Icons.local_florist,
          'color': Colors.red,
        },
      ),
    ]);

    setState(() {
      _isLoading = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _isSending = true;
    });

    // Simulate sending
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: widget.currentUserId ?? 'local',
            username: 'You',
            userAvatar: null,
            message: message,
            type: MessageType.text,
            timestamp: DateTime.now(),
          ));
          _isSending = false;
        });
        _scrollToBottom();
      }
    });
  }

  void addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Chat Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                Icon(Icons.chat, color: Colors.white70, size: 16),
                SizedBox(width: 8),
                Text(
                  'Room Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                final ChatMessage message = _messages[index];
                final bool isMe = message.userId == widget.currentUserId;

                return _buildMessageBubble(message, isMe);
              },
            ),
          ),

          // Input Area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to say hello!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: message.userAvatar != null
                  ? NetworkImage(message.userAvatar!)
                  : null,
              child: message.userAvatar == null
                  ? Text(message.username[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getBubbleColor(message, isMe),
                borderRadius: BorderRadius.circular(12).copyWith(
                  bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.username,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (message.type == MessageType.gift)
                    _buildGiftMessage(message)
                  else
                    Text(
                      message.message,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormatter.formatChatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundImage: message.userAvatar != null
                  ? NetworkImage(message.userAvatar!)
                  : null,
              child: message.userAvatar == null
                  ? Text(message.username[0].toUpperCase())
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Color _getBubbleColor(ChatMessage message, bool isMe) {
    if (message.type == MessageType.system) {
      return Colors.grey.shade200;
    } else if (message.type == MessageType.gift) {
      return Colors.purple.shade100;
    } else {
      return isMe ? Colors.blue : Colors.grey.shade200;
    }
  }

  Widget _buildGiftMessage(ChatMessage message) {
    final Map<String, dynamic> giftData = message.giftData ?? {};
    final Color giftColor = giftData['color'] is Color
        ? giftData['color'] as Color
        : Colors.purple;
    final IconData giftIcon = giftData['icon'] is IconData
        ? giftData['icon'] as IconData
        : Icons.card_giftcard;
    final String giftName = giftData['name']?.toString() ?? 'Gift';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: giftColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            giftIcon,
            color: giftColor,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sent a gift: $giftName',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                message.message,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.emoji_emotions, color: Colors.white70),
            onPressed: () {
              // Show emoji picker
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(color: Colors.white54),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: _isSending
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Icon(Icons.send, color: Colors.blue),
            onPressed: _isSending ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String id;
  final String userId;
  final String username;
  final String? userAvatar;
  final String message;
  final MessageType type;
  final DateTime timestamp;
  final Map<String, dynamic>? giftData;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.username,
    this.userAvatar,
    required this.message,
    required this.type,
    required this.timestamp,
    this.giftData,
  });
}