import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../widgets/chat_tile.dart';
import 'chat_detail_screen.dart';

class ChatSearchScreen extends StatefulWidget {
  const ChatSearchScreen({Key? key}) : super(key: key);

  @override
  State<ChatSearchScreen> createState() => _ChatSearchScreenState();
}

class _ChatSearchScreenState extends State<ChatSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<ChatModel> _filteredChats = <>[];
  List<MessageModel> _filteredMessages = <>[];

  // Mock data
  final List<ChatModel> _chats = List.generate(10, (int index) {
    return ChatModel(
      id: 'chat_$index',
      type: index % 3 == 0 ? 'group' : 'private',
      participants: <String>['User ${index + 1}'],
      groupName: index % 3 == 0 ? 'Group ${index + 1}' : null,
      lastMessage: MessageModel(
        id: 'msg_$index',
        chatId: 'chat_$index',
        senderId: 'user_$index',
        senderName: 'User ${index + 1}',
        type: MessageType.text,
        status: MessageStatus.read,
        content: 'Last message ${index + 1}',
        timestamp: DateTime.now().subtract(Duration(hours: index)),
        readBy: <dynamic>[],
        reactions: <dynamic>[],
      ),
      unreadCount: index % 5,
      createdAt: DateTime.now().subtract(Duration(days: index)),
      updatedAt: DateTime.now().subtract(Duration(hours: index)),
    );
  });

  final List<MessageModel> _messages = List.generate(50, (int index) {
    return MessageModel(
      id: 'msg_$index',
      chatId: 'chat_${index % 10}',
      senderId: 'user_${index % 5}',
      senderName: 'User ${index % 5}',
      type: index % 4 == 0 ? MessageType.image : MessageType.text,
      status: MessageStatus.read,
      content: 'Searchable message content ${index + 1}',
      timestamp: DateTime.now().subtract(Duration(minutes: index * 30)),
      readBy: <dynamic>[],
      reactions: <dynamic>[],
    );
  });

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _performSearch();
    });
  }

  void _performSearch() {
    if (_searchQuery.isEmpty) {
      _filteredChats.clear();
      _filteredMessages.clear();
      return;
    }

    final String query = _searchQuery.toLowerCase();

    // Search chats
    _filteredChats = _chats.where((Object? chat) {
      final name = chat.type == 'private'
          ? chat.participants.first.toLowerCase()
          : chat.groupName?.toLowerCase() ?? '';
      return name.contains(query);
    }).toList();

    // Search messages
    _filteredMessages = _messages.where((Object? msg) {
      return msg.content.toLowerCase().contains(query);
    }).toList();
  }

  void _clearSearch() {
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.blue,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search messages or chats...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _searchQuery.isEmpty
          ? _buildEmptySearch()
          : _buildSearchResults(),
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <>[
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Search Messages',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Find messages, photos, and more',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_filteredChats.isEmpty && _filteredMessages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <>[
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Results Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No matches for "$_searchQuery"',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: <>[
        if (_filteredChats.isNotEmpty) ...<>[
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'CHATS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ..._filteredChats.map((Object? chat) => ChatTile(
            chat: chat,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(chat: chat),
                ),
              );
            },
          )),
          const Divider(),
        ],

        if (_filteredMessages.isNotEmpty) ...<>[
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'MESSAGES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ..._filteredMessages.map(_buildMessageResult),
        ],
      ],
    );
  }

  Widget _buildMessageResult(MessageModel message) {
    final chat = _chats.firstWhere(
      (Object? c) => c.id == message.chatId,
      orElse: () => _chats.first,
    );

    return ListTile(
      leading: CircleAvatar(
        child: Icon(
          message.type == MessageType.text ? Icons.message : Icons.image,
          size: 20,
        ),
      ),
      title: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black),
          children: _highlightText(message.content),
        ),
      ),
      subtitle: Text(
        'in ${chat.type == 'private' ? chat.participants.first : chat.groupName} • ${_formatTime(message.timestamp)}',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(chat: chat),
          ),
        );
      },
    );
  }

  List<TextSpan> _highlightText(String text) {
    if (_searchQuery.isEmpty) return <>[TextSpan(text: text)];

    final spans = <TextSpan>[];
    final String lowerText = text.toLowerCase();
    final String lowerQuery = _searchQuery.toLowerCase();
    int start = 0;

    while (true) {
      final int index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + _searchQuery.length),
        style: const TextStyle(
          backgroundColor: Colors.yellow,
          fontWeight: FontWeight.bold,
        ),
      ));

      start = index + _searchQuery.length;
    }

    return spans;
  }

  String _formatTime(DateTime time) {
    final DateTime now = DateTime.now();
    final Duration diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}