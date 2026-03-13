import 'package:flutter/material.dart';
import '../models/chat_model.dart';

class ChatHeader extends StatelessWidget {

  const ChatHeader({
    Key? key,
    required this.chat,
    required this.onBack,
    required this.onCall,
    required this.onVideoCall,
    required this.onInfo,
  }) : super(key: key);
  final ChatModel chat;
  final VoidCallback onBack;
  final VoidCallback onCall;
  final VoidCallback onVideoCall;
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: <>[
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
            ),
            const SizedBox(width: 8),
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <>[
                  Text(
                    chat.type == 'private'
                        ? chat.participants.first
                        : chat.groupName ?? 'Group',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _buildStatus(),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.call),
              onPressed: onCall,
            ),
            IconButton(
              icon: const Icon(Icons.videocam),
              onPressed: onVideoCall,
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: onInfo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (chat.type == 'private') {
      return Stack(
        children: <>[
          CircleAvatar(
            radius: 20,
            backgroundImage: chat.groupAvatar != null
                ? NetworkImage(chat.groupAvatar!)
                : null,
            child: chat.groupAvatar == null
                ? Text(chat.participants.first[0].toUpperCase())
                : null,
          ),
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
      );
    } else {
      return CircleAvatar(
        radius: 20,
        backgroundImage: chat.groupAvatar != null
            ? NetworkImage(chat.groupAvatar!)
            : null,
        child: chat.groupAvatar == null
            ? const Icon(Icons.group, size: 20)
            : null,
      );
    }
  }

  Widget _buildStatus() {
    if (chat.type == 'private') {
      return const Text(
        'Online',
        style: TextStyle(
          fontSize: 12,
          color: Colors.green,
        ),
      );
    } else {
      return Text(
        '${chat.participants.length} members',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      );
    }
  }
}