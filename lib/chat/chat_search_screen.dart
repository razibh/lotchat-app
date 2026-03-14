import 'package:flutter/material.dart';
import 'models/chat_model.dart';
import 'models/message_model.dart';
import 'widgets/chat_tile.dart';
import 'chat_detail_screen.dart';

class ChatSearchScreen extends StatefulWidget {
  const ChatSearchScreen({super.key});

  @override
  State<ChatSearchScreen> createState() => _ChatSearchScreenState();
}

class _ChatSearchScreenState extends State<ChatSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<ChatModel> _filteredChats = <ChatModel>[];
  List<MessageModel> _filteredMessages = <MessageModel>[];

  // Mock data
  late final List<ChatModel> _chats;
  late final List<MessageModel> _messages;

  @override
  void initState() {
    super.initState();
    _initializeMockData();
    _searchController.addListener(_onSearchChanged);
  }

  void _initializeMockData() {
    _chats = List.generate(10, (int index) {
      return ChatModel(
        id: 'chat_$index',
        type: index % 3 == 0 ? 'group' : 'private',
        participants: <String>['User ${index + 1}'],
        groupName: index % 3 == 0 ? 'Group ${index + 1}' : null,
        lastMessage: 'Last message ${index + 1}',
        lastMessageTime: DateTime.now().subtract(Duration(hours: index)),
      );
    });

    _messages = List.generate(50, (int index) {
      // Determine message type based on index
      MessageType messageType;
      if (index % 7 == 0) {
        messageType = MessageType.image;
      } else if (index % 7 == 1) {
        messageType = MessageType.video;
      } else if (index % 7 == 2) {
        messageType = MessageType.audio;
      } else if (index % 7 == 3) {
        messageType = MessageType.file;
      } else if (index % 7 == 4) {
        messageType = MessageType.location;
      } else {
        messageType = MessageType.text;
      }

      // Determine message status
      MessageStatus messageStatus;
      if (index % 4 == 0) {
        messageStatus = MessageStatus.read;
      } else if (index % 4 == 1) {
        messageStatus = MessageStatus.delivered;
      } else if (index % 4 == 2) {
        messageStatus = MessageStatus.sent;
      } else {
        messageStatus = MessageStatus.sending;
      }

      return MessageModel(
        id: 'msg_$index',
        chatId: 'chat_${index % 10}',
        senderId: 'user_${index % 5}',
        senderName: 'User ${index % 5}',
        content: 'Searchable message content ${index + 1}',
        timestamp: DateTime.now().subtract(Duration(minutes: index * 30)),
        type: messageType,
        status: messageStatus,
      );
    });
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
      _filteredChats = <ChatModel>[];
      _filteredMessages = <MessageModel>[];
      return;
    }

    final String query = _searchQuery.toLowerCase();

    // Search chats
    _filteredChats = _chats.where((ChatModel chat) {
      final String name = chat.type == 'private'
          ? (chat.participants.isNotEmpty ? chat.participants.first : '')
          : (chat.groupName ?? '');
      return name.toLowerCase().contains(query);
    }).toList();

    // Search messages
    _filteredMessages = _messages.where((MessageModel msg) {
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
        children: <Widget>[
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
          children: <Widget>[
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
      children: <Widget>[
        if (_filteredChats.isNotEmpty) ...<Widget>[
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
          ..._filteredChats.map((ChatModel chat) => ChatTile(
            chat: chat,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => ChatDetailScreen(chat: chat),
                ),
              );
            },
          ),),
          const Divider(),
        ],

        if (_filteredMessages.isNotEmpty) ...<Widget>[
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
    final ChatModel chat = _chats.firstWhere(
          (ChatModel c) => c.id == message.chatId,
      orElse: () => _chats.first,
    );

    // Get appropriate icon based on message type
    IconData getMessageIcon() {
      switch (message.type) {
        case MessageType.image:
          return Icons.image;
        case MessageType.video:
          return Icons.video_library;
        case MessageType.audio:
          return Icons.audio_file;
        case MessageType.file:
          return Icons.insert_drive_file;
        case MessageType.location:
          return Icons.location_on;
        case MessageType.contact:
          return Icons.contact_phone;
        case MessageType.sticker:
          return Icons.emoji_emotions;
        case MessageType.gift:
          return Icons.card_giftcard;
        case MessageType.call:
          return Icons.call;
        case MessageType.system:
          return Icons.info;
        default:
          return Icons.message;
      }
    }

    return ListTile(
      leading: CircleAvatar(
        child: Icon(
          getMessageIcon(),
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
            builder: (BuildContext context) => ChatDetailScreen(chat: chat),
          ),
        );
      },
    );
  }

  List<TextSpan> _highlightText(String text) {
    if (_searchQuery.isEmpty) return <TextSpan>[TextSpan(text: text)];

    final List<TextSpan> spans = <TextSpan>[];
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
      ),);

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