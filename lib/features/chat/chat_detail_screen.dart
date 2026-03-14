import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/socket_service.dart';
import '../../mixins/pagination_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/room/gift_panel.dart';
import '../call/widgets/call_screen.dart';

class ChatDetailScreen extends StatefulWidget {

  const ChatDetailScreen({
    required this.userId, required this.userName, super.key,
    this.userAvatar,
  });
  final String userId;
  final String userName;
  final String? userAvatar;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('userId', userId));
    properties.add(StringProperty('userName', userName));
    properties.add(StringProperty('userAvatar', userAvatar));
  }
}

class _ChatDetailScreenState extends State<ChatDetailScreen> 
    with PaginationMixin<Map<String, dynamic>>, ToastMixin {
  
  final SocketService _socketService = ServiceLocator().get<SocketService>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isTyping = false;
  bool _showGiftPanel = false;

  @override
  void initState() {
    super.initState();
    initPagination();
    loadMore();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socketService.onNewMessage((data) {
      if (data['senderId'] == widget.userId) {
        setState(() {
          addItem(data);
        });
        _scrollToBottom();
      }
    });

    _socketService.on('typing', (data) {
      if (data['userId'] == widget.userId) {
        setState(() {
          _isTyping = data['isTyping'];
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPage(int page) async {
    // Fetch messages from database
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data
    return List.generate(20, (int index) {
      final bool isMe = index % 3 != 0;
      return <String, >{
        'id': 'msg_$index',
        'senderId': isMe ? 'current_user' : widget.userId,
        'senderName': isMe ? 'You' : widget.userName,
        'message': 'This is message ${index + 1}',
        'timestamp': DateTime.now().subtract(Duration(minutes: index * 5)),
        'type': 'text',
      };
    }).reversed.toList();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
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
    if (_messageController.text.trim().isEmpty) return;

    final message = <String, >{
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'senderId': 'current_user',
      'senderName': 'You',
      'message': _messageController.text,
      'timestamp': DateTime.now(),
      'type': 'text',
    };

    // Send via socket
    _socketService.sendMessage(
      roomId: widget.userId,
      message: _messageController.text,
      senderId: 'current_user',
      senderName: 'You',
    );

    setState(() {
      addItem(message);
      _messageController.clear();
    });

    _scrollToBottom();
  }

  void _sendGift(dynamic gift) {
    final Map<String, dynamic> message = <String, dynamic>{
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'senderId': 'current_user',
      'senderName': 'You',
      'gift': gift,
      'timestamp': DateTime.now(),
      'type': 'gift',
    };

    setState(() {
      addItem(message);
      _showGiftPanel = false;
    });

    showSuccess('Gift sent!');
    _scrollToBottom();
  }

  void _startCall(bool isVideo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => CallScreen(
          user: null, // Pass user model
          isVideoCall: isVideo,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <>[
            CircleAvatar(
              backgroundImage: widget.userAvatar != null
                  ? NetworkImage(widget.userAvatar!)
                  : null,
              child: widget.userAvatar == null
                  ? Text(widget.userName[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <>[
                  Text(widget.userName),
                  if (_isTyping)
                    const Text(
                      'Typing...',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: <>[
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => _startCall(false),
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () => _startCall(true),
          ),
        ],
      ),
      body: Column(
        children: <>[
          // Messages List
          Expanded(
            child: items.isEmpty && isLoadingMore
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount: items.length + (hasMore ? 1 : 0),
                    itemBuilder: (BuildContext context, int index) {
                      if (index == items.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      
                      final Map<String, dynamic> message = items[items.length - 1 - index];
                      final bool isMe = message['senderId'] == 'current_user';
                      
                      return _buildMessageBubble(message, isMe);
                    },
                  ),
          ),

          // Gift Panel
          if (_showGiftPanel)
            GiftPanel(
              onSendGift: _sendGift,
              onClose: () {
                setState(() {
                  _showGiftPanel = false;
                });
              },
            ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: <>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: <>[
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {
                    // Attach file
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.emoji_emotions),
                  onPressed: () {
                    // Show emoji picker
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (String value) {
                      // Send typing indicator
                    },
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.card_giftcard, color: Colors.purple),
                  onPressed: () {
                    setState(() {
                      _showGiftPanel = !_showGiftPanel;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe) {
    final bool isGift = message['type'] == 'gift';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <>[
          if (!isMe)
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.userAvatar != null
                  ? NetworkImage(widget.userAvatar!)
                  : null,
              child: widget.userAvatar == null
                  ? Text(widget.userName[0].toUpperCase(), style: const TextStyle(fontSize: 12))
                  : null,
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isGift
                    ? Colors.purple.withValues(alpha: 0.1)
                    : (isMe ? Colors.blue : Colors.grey.shade200),
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <>[
                  if (isGift) ...<>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <>[
                        const Icon(Icons.card_giftcard, color: Colors.purple),
                        const SizedBox(width: 8),
                        Text(
                          'Sent a gift',
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    // Gift animation would go here
                  ] else
                    Text(
                      message['message'],
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message['timestamp']),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}