import 'package:flutter/material.dart';
import '../core/utils/date_formatter.dart';

enum MessageType { text, image, gift, system }

class ChatWidget extends StatefulWidget {

  const ChatWidget({
    required this.roomId, super.key,
    this.currentUserId,
  });
  final String roomId;
  final String? currentUserId;

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
  final List<ChatMessage> _messages = <ChatMessage>[];
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    // Mock messages
    _messages.addAll(<ChatMessage>[
      ChatMessage(
        id: '1',
        userId: 'user1',
        username: 'Alice',
        message: 'Hello everyone! Welcome to the room!',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChatMessage(
        id: '2',
        userId: 'user2',
        username: 'Bob',
        message: 'Hi Alice! Thanks for having us.',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
      ChatMessage(
        id: '3',
        userId: 'user3',
        username: 'Charlie',
        message: 'This is great!',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      ChatMessage(
        id: '4',
        userId: 'user1',
        username: 'Alice',
        message: 'Check out this gift!',
        type: MessageType.gift,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        giftData: <String, dynamic>{
          'name': 'Rose',
          'icon': Icons.local_florist,
          'color': Colors.red,
        },
      ),
    ]);

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

  void addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <>[
          // Chat Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: <>[
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

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <>[
          if (!isMe) ...<>[
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
                children: <>[
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
          if (isMe) ...<>[
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
    final Map<String, dynamic> giftData = message.giftData!;
    
    return Row(
      children: <>[
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: giftData['color'].withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            giftData['icon'],
            color: giftData['color'],
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <>[
              Text(
                'Sent a gift: ${giftData['name']}',
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
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        children: <>[
          IconButton(
            icon: const Icon(Icons.emoji_emotions, color: Colors.white70),
            onPressed: () {},
          ),
          const Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class ChatMessage {

  ChatMessage({
    required this.id,
    required this.userId,
    required this.username,
    required this.message, required this.type, required this.timestamp, this.userAvatar,
    this.giftData,
  });
  final String id;
  final String userId;
  final String username;
  final String? userAvatar;
  final String message;
  final MessageType type;
  final DateTime timestamp;
  final Map<String, dynamic>? giftData;
}