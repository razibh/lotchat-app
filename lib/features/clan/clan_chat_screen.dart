import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/clan_service.dart';
import '../../core/services/socket_service.dart';
import '../../core/services/auth_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/pagination_mixin.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/room/gift_panel.dart';
import 'widgets/clan_chat_bubble.dart';

class ClanChatScreen extends StatefulWidget {
  final String clanId;
  final String clanName;

  const ClanChatScreen({
    Key? key,
    required this.clanId,
    required this.clanName,
  }) : super(key: key);

  @override
  State<ClanChatScreen> createState() => _ClanChatScreenState();
}

class _ClanChatScreenState extends State<ClanChatScreen> 
    with LoadingMixin, ToastMixin, PaginationMixin<Map<String, dynamic>> {
  
  final _clanService = ServiceLocator().get<ClanService>();
  final _socketService = ServiceLocator().get<SocketService>();
  final _authService = ServiceLocator().get<AuthService>();
  
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isTyping = false;
  bool _showGiftPanel = false;
  String? _currentUserId;
  Map<String, dynamic>? _clanInfo;

  @override
  void initState() {
    super.initState();
    initPagination();
    loadMore();
    _getCurrentUser();
    _loadClanInfo();
    _setupSocketListeners();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _socketService.emit('leave-clan-chat', {'clanId': widget.clanId});
    super.dispose();
  }

  Future<void> _getCurrentUser() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      _currentUserId = user?.uid;
    });
  }

  Future<void> _loadClanInfo() async {
    final clan = await _clanService.getClan(widget.clanId);
    if (clan != null) {
      setState(() {
        _clanInfo = {
          'name': clan.name,
          'emblem': clan.emblem,
          'memberCount': clan.memberCount,
        };
      });
    }
  }

  void _setupSocketListeners() {
    // Join clan chat room
    _socketService.emit('join-clan-chat', {'clanId': widget.clanId});

    _socketService.on('clan-message', (data) {
      if (mounted) {
        setState(() {
          addItem(data);
        });
        _scrollToBottom();
      }
    });

    _socketService.on('clan-typing', (data) {
      if (data['userId'] != _currentUserId) {
        setState(() {
          _isTyping = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isTyping = false;
            });
          }
        });
      }
    });

    _socketService.on('clan-user-online', (data) {
      // Update online status
      setState(() {});
    });

    _socketService.on('clan-user-offline', (data) {
      // Update online status
      setState(() {});
    });
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPage(int page) async {
    // Fetch messages from database
    await Future.delayed(const Duration(seconds: 1));
    
    return List.generate(20, (index) {
      final isMe = index % 2 == 0;
      return {
        'id': 'msg_$index',
        'userId': isMe ? _currentUserId : 'user_$index',
        'username': isMe ? 'You' : 'User ${index + 1}',
        'avatar': null,
        'message': 'This is message ${index + 1} in clan chat',
        'timestamp': DateTime.now().subtract(Duration(minutes: index * 5)),
        'type': 'text',
        'reactions': {},
        'isPinned': index == 0,
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

    final message = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'userId': _currentUserId,
      'username': 'You',
      'message': _messageController.text,
      'timestamp': DateTime.now(),
      'type': 'text',
      'reactions': {},
    };

    _socketService.emit('clan-message', {
      'clanId': widget.clanId,
      'message': _messageController.text,
      'userId': _currentUserId,
      'username': 'You',
    });

    setState(() {
      addItem(message);
      _messageController.clear();
    });

    _scrollToBottom();
  }

  void _sendGift(dynamic gift) {
    final message = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'userId': _currentUserId,
      'username': 'You',
      'gift': gift,
      'timestamp': DateTime.now(),
      'type': 'gift',
    };

    _socketService.emit('clan-gift', {
      'clanId': widget.clanId,
      'gift': gift,
      'userId': _currentUserId,
    });

    setState(() {
      addItem(message);
      _showGiftPanel = false;
    });

    showSuccess('Gift sent to clan!');
    _scrollToBottom();
  }

  void _addReaction(String messageId, String reaction) {
    _socketService.emit('clan-reaction', {
      'clanId': widget.clanId,
      'messageId': messageId,
      'userId': _currentUserId,
      'reaction': reaction,
    });
  }

  void _pinMessage(String messageId) {
    _socketService.emit('clan-pin-message', {
      'clanId': widget.clanId,
      'messageId': messageId,
    });
    showSuccess('Message pinned');
  }

  void _reportMessage(String messageId) {
    showConfirmDialog(
      context,
      title: 'Report Message',
      message: 'Are you sure you want to report this message?',
    ).then((confirmed) {
      if (confirmed == true) {
        showSuccess('Message reported');
      }
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Clan Emblem
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                shape: BoxShape.circle,
                image: _clanInfo?['emblem'] != null
                    ? DecorationImage(
                        image: NetworkImage(_clanInfo!['emblem']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _clanInfo?['emblem'] == null
                  ? const Icon(Icons.groups, color: Colors.deepPurple)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _clanInfo?['name'] ?? widget.clanName,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    '${_clanInfo?['memberCount'] ?? 0} members',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              _showClanInfo();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Pinned Message
          if (items.any((m) => m['isPinned'] == true))
            Container(
              color: Colors.amber.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.push_pin, color: Colors.amber, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      items.firstWhere((m) => m['isPinned'] == true)['message'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      // Unpin message
                    },
                  ),
                ],
              ),
            ),

          // Typing Indicator
          if (_isTyping)
            Container(
              padding: const EdgeInsets.all(8),
              child: const Row(
                children: [
                  CircleAvatar(radius: 4, child: Text('')),
                  SizedBox(width: 4),
                  CircleAvatar(radius: 4, child: Text('')),
                  SizedBox(width: 4),
                  CircleAvatar(radius: 4, child: Text('')),
                  SizedBox(width: 8),
                  Text('Someone is typing...'),
                ],
              ),
            ),

          // Messages
          Expanded(
            child: items.isEmpty && isLoadingMore
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount: items.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == items.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      
                      final message = items[items.length - 1 - index];
                      final isMe = message['userId'] == _currentUserId;
                      
                      return ClanChatBubble(
                        message: message,
                        isMe: isMe,
                        onReaction: (reaction) => _addReaction(message['id'], reaction),
                        onPin: () => _pinMessage(message['id']),
                        onReport: () => _reportMessage(message['id']),
                      );
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
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
                    onChanged: (value) {
                      _socketService.emit('clan-typing', {
                        'clanId': widget.clanId,
                        'userId': _currentUserId,
                      });
                    },
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.card_giftcard, color: Colors.deepPurple),
                  onPressed: () {
                    setState(() {
                      _showGiftPanel = !_showGiftPanel;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClanInfo() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Clan Info',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Members'),
              trailing: Text('${_clanInfo?['memberCount'] ?? 0}'),
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Total Messages'),
              trailing: Text('${items.length}'),
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Active Now'),
              trailing: const Text('12'),
            ),
          ],
        ),
      ),
    );
  }
}