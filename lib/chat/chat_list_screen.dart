import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    // Add any properties if needed
  }
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _chats = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Sample data
    _chats = List.generate(15, (index) {
      final isRead = index % 3 != 0;
      final isOnline = index % 4 == 0;
      final hasUnread = !isRead && index % 2 == 0;

      return {
        'id': 'chat_${index + 1}',
        'name': index % 2 == 0 ? 'User ${index + 1}' : 'Group ${index + 1}',
        'lastMessage': index % 3 == 0
            ? 'Hey, how are you?'
            : index % 3 == 1
            ? 'See you tomorrow!'
            : 'This is a very long message that might get truncated in the chat list preview',
        'timestamp': DateTime.now().subtract(Duration(hours: index * 2)),
        'avatar': null,
        'isGroup': index % 2 != 0,
        'isOnline': isOnline,
        'hasUnread': hasUnread,
        'unreadCount': hasUnread ? (index % 5) + 1 : 0,
        'lastMessageSender': index % 2 != 0 ? 'John' : null,
        'members': index % 2 != 0 ? 5 : null,
      };
    });

    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filteredChats {
    if (_searchQuery.isEmpty) return _chats;
    return _chats.where((chat) {
      return chat['name'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ChatSearchDelegate(_chats),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredChats.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _filteredChats.length,
              itemBuilder: (context, index) {
                final chat = _filteredChats[index];
                return _buildChatTile(chat);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to new chat screen
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          showSearch(
            context: context,
            delegate: ChatSearchDelegate(_chats),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Search messages...',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chat) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: chat['isGroup']
                ? Colors.orange.shade100
                : Colors.deepPurple.shade100,
            child: chat['avatar'] == null
                ? Text(
              chat['name'][0].toUpperCase(),
              style: TextStyle(
                color: chat['isGroup'] ? Colors.orange : Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            )
                : null,
          ),
          if (!chat['isGroup'] && chat['isOnline'])
            const Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 6,
                backgroundColor: Colors.green,
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              chat['name'],
              style: TextStyle(
                fontWeight: chat['hasUnread'] ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            _formatTimestamp(chat['timestamp']),
            style: TextStyle(
              fontSize: 12,
              color: chat['hasUnread'] ? Colors.deepPurple : Colors.grey,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              chat['isGroup'] && chat['lastMessageSender'] != null
                  ? '${chat['lastMessageSender']}: ${chat['lastMessage']}'
                  : chat['lastMessage'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: chat['hasUnread'] ? Colors.black : Colors.grey,
              ),
            ),
          ),
          if (chat['hasUnread'])
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${chat['unreadCount']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/chat/detail',
          arguments: {
            'chatId': chat['id'],
            'userName': chat['name'],
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with your friends',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to find friends
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
            child: const Text('Find Friends'),
          ),
        ],
      ),
    );
  }
}

// Search Delegate for Chat Search
class ChatSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> chats;

  ChatSearchDelegate(this.chats);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = chats.where((chat) {
      return chat['name'].toLowerCase().contains(query.toLowerCase()) ||
          (chat['lastMessage']?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final chat = results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: chat['isGroup'] ? Colors.orange.shade100 : Colors.deepPurple.shade100,
            child: Text(
              chat['name'][0].toUpperCase(),
              style: TextStyle(
                color: chat['isGroup'] ? Colors.orange : Colors.deepPurple,
              ),
            ),
          ),
          title: Text(chat['name']),
          subtitle: Text(chat['lastMessage']),
          onTap: () {
            close(context, chat['id']);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = chats.where((chat) {
      return chat['name'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final chat = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.chat),
          title: Text(chat['name']),
          onTap: () {
            query = chat['name'];
          },
        );
      },
    );
  }
}