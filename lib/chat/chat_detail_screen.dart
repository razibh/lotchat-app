import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/services/socket_service.dart';
import 'models/chat_model.dart';
import 'models/chat_model.dart';
import 'models/message_model.dart';
import 'providers/message_provider.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_input.dart';
import 'widgets/typing_indicator.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({
    required this.chat, super.key,
  });

  final ChatModel chat;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ChatModel>('chat', chat));
  }
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late final ScrollController _scrollController;
  late final SocketService _socketService;
  final List<String> _typingUsers = <String>[];
  final String _currentUserId = 'current_user_id'; // TODO: Get from AuthProvider

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _socketService = ServiceLocator.instance.get<SocketService>();
    _loadMessages();
    _setupSocketListeners();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    try {
      context.read<MessageProvider>().loadMessages(widget.chat.id);
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  void _setupSocketListeners() {
    try {
      _socketService.on('typing', (dynamic data) {
        if (data is Map<String, dynamic> && data['chatId'] == widget.chat.id) {
          final userId = data['userId'] as String? ?? '';
          if (userId.isNotEmpty && !_typingUsers.contains(userId)) {
            setState(() {
              _typingUsers.add(userId);
            });

            // Remove after 2 seconds
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _typingUsers.remove(userId);
                });
              }
            });
          }
        }
      });

      _socketService.on('new-message', (dynamic data) {
        if (data is Map<String, dynamic> && data['chatId'] == widget.chat.id) {
          try {
            context.read<MessageProvider>().addMessage(data);
            _scrollToBottom();
          } catch (e) {
            debugPrint('Error adding message: $e');
          }
        }
      });
    } catch (e) {
      debugPrint('Socket setup error: $e');
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0, // ListView reverse: true, so 0 is bottom
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    try {
      context.read<MessageProvider>().sendMessage(
        chatId: widget.chat.id,
        content: text,
      );
      _scrollToBottom();
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  void _sendTyping() {
    try {
      _socketService.emit('typing', <String, dynamic>{
        'chatId': widget.chat.id,
        'userId': _currentUserId,
      });
    } catch (e) {
      debugPrint('Error sending typing: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              backgroundImage: widget.chat.groupAvatar != null
                  ? NetworkImage(widget.chat.groupAvatar!)
                  : null,
              child: widget.chat.groupAvatar == null
                  ? Text(
                widget.chat.displayTitle[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.chat.displayTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_typingUsers.isNotEmpty)
                    const Text(
                      'Typing...',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              // TODO: Implement voice call
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Voice call coming soon!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              // TODO: Implement video call
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video call coming soon!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // TODO: Show chat info
              Navigator.pushNamed(context, '/chat-info', arguments: widget.chat);
            },
          ),
        ],
      ),
      body: Consumer<MessageProvider>(
        builder: (BuildContext context, MessageProvider provider, Widget? child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.messages.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Send a message to start the conversation',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: provider.messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final MessageModel message = provider.messages[index];
                    final bool isMe = message.senderId == _currentUserId;

                    // Check if we should show avatar
                    final bool showAvatar;
                    if (index == provider.messages.length - 1) {
                      showAvatar = true;
                    } else {
                      showAvatar = provider.messages[index + 1].senderId != message.senderId;
                    }

                    return MessageBubble(
                      message: message,
                      isMe: isMe,
                      showAvatar: showAvatar,
                      showName: !isMe && showAvatar,
                      onReply: () {
                        // TODO: Implement reply
                      },
                      onForward: () {
                        // TODO: Implement forward
                      },
                      onDelete: () => provider.deleteMessage(message.id),
                      onReport: () {
                        // TODO: Implement report
                      },
                      onReaction: (reaction) =>
                          provider.addReaction(message.id, reaction),
                    );
                  },
                ),
              ),
              if (_typingUsers.isNotEmpty)
                TypingIndicator(typingUsers: _typingUsers),
              MessageInput(
                onSend: _sendMessage,
                onTyping: _sendTyping,
              ),
            ],
          );
        },
      ),
    );
  }
}o