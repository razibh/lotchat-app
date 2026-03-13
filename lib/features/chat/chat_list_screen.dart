import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/database_service.dart';
import '../../core/services/socket_service.dart';
import '../../mixins/pagination_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../profile/profile_screen.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> 
    with PaginationMixin<Map<String, dynamic>>, ToastMixin {
  
  final DatabaseService _databaseService = ServiceLocator().get<DatabaseService>();
  final SocketService _socketService = ServiceLocator().get<SocketService>();
  final String _currentUserId = 'current_user_id'; // Get from auth

  @override
  void initState() {
    super.initState();
    initPagination();
    loadMore();
  }

  @override
  void dispose() {
    disposePagination();
    super.dispose();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPage(int page) async {
    // Fetch chat list from database
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data
    return List.generate(10, (int index) => <String, dynamic>{
      'id': 'chat_$index',
      'userId': 'user_$index',
      'name': 'User ${index + 1}',
      'avatar': null,
      'lastMessage': 'Hello! How are you?',
      'lastMessageTime': DateTime.now().subtract(Duration(hours: index)),
      'unreadCount': index % 3,
      'isOnline': index % 2 == 0,
      'isTyping': false,
    });
  }

  String _formatTime(DateTime time) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
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
        title: const Text('Messages'),
        actions: <>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Navigate to search
            },
          ),
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () {
              // Create group chat
            },
          ),
        ],
      ),
      body: items.isEmpty && isLoadingMore
          ? const LoadingWidget(message: 'Loading chats...')
          : items.isEmpty
              ? const EmptyStateWidget(
                  title: 'No Messages',
                  message: 'Start a conversation with someone!',
                  icon: Icons.chat,
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    resetPagination();
                    await loadMore();
                  },
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: items.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == items.length) {
                        return buildPaginationLoadingIndicator();
                      }
                      
                      final Map<String, dynamic> chat = items[index];
                      return _buildChatTile(chat);
                    },
                  ),
                ),
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chat) {
    return ListTile(
      leading: Stack(
        children: <>[
          CircleAvatar(
            backgroundImage: chat['avatar'] != null
                ? NetworkImage(chat['avatar'])
                : null,
            child: chat['avatar'] == null
                ? Text(chat['name'][0].toUpperCase())
                : null,
          ),
          if (chat['isOnline'])
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: <>[
          Expanded(
            child: Text(
              chat['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            _formatTime(chat['lastMessageTime']),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: <>[
          if (chat['isTyping'])
            const Expanded(
              child: Text(
                'Typing...',
                style: TextStyle(
                  color: Colors.blue,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            Expanded(
              child: Text(
                chat['lastMessage'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          if (chat['unreadCount'] > 0)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${chat['unreadCount']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              userId: chat['userId'],
              userName: chat['name'],
              userAvatar: chat['avatar'],
            ),
          ),
        );
      },
      onLongPress: () {
        _showChatOptions(chat);
      },
    );
  }

  void _showChatOptions(Map<String, dynamic> chat) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <>[
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userId: chat['userId']),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.call),
              title: const Text('Voice Call'),
              onTap: () {
                Navigator.pop(context);
                // Start voice call
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Video Call'),
              onTap: () {
                Navigator.pop(context);
                // Start video call
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Chat', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteChat(chat['id']);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteChat(String chatId) {
    // Delete chat logic
    showSuccess('Chat deleted');
  }
}