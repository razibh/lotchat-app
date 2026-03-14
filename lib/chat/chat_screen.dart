import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/chat_model.dart';
import 'providers/chat_provider.dart';
import 'widgets/chat_tile.dart';
import 'chat_detail_screen.dart';
import 'chat_search_screen.dart';
import 'group_chat_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const ChatSearchScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const GroupChatScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (BuildContext context, ChatProvider provider, Widget? child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.chats.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            itemCount: provider.chats.length,
            itemBuilder: (BuildContext context, int index) {
              final ChatModel chat = provider.chats[index];
              return ChatTile(
                chat: chat,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => ChatDetailScreen(chat: chat),
                    ),
                  );
                },
                onMute: () => provider.toggleMute(chat.id),
                onPin: () => provider.togglePin(chat.id),
                onArchive: () => provider.toggleArchive(chat.id),
                onDelete: () => _deleteChat(chat.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: New chat
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New chat coming soon!')),
          );
        },
        child: const Icon(Icons.chat),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Messages Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start a conversation with someone',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: Start new chat
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Start new chat coming soon!')),
              );
            },
            child: const Text('Start Chatting'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteChat(String chatId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text('Are you sure you want to delete this chat?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      context.read<ChatProvider>().deleteChat(chatId);
    }
  }
}