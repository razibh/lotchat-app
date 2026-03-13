import 'package:flutter/material.dart';
import '../models/chat_model.dart';

class MessageForwardDialog extends StatelessWidget {

  const MessageForwardDialog({
    Key? key,
    required this.chats,
    required this.onForward,
  }) : super(key: key);
  final List<ChatModel> chats;
  final Function(ChatModel) onForward;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Forward Message'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: chat.groupAvatar != null
                    ? NetworkImage(chat.groupAvatar!)
                    : null,
                child: chat.groupAvatar == null
                    ? Text(
                        chat.type == 'private'
                            ? chat.participants.first[0].toUpperCase()
                            : 'G',
                      )
                    : null,
              ),
              title: Text(
                chat.type == 'private'
                    ? chat.participants.first
                    : chat.groupName ?? 'Group',
              ),
              onTap: () {
                Navigator.pop(context);
                onForward(chat);
              },
            );
          },
        ),
      ),
      actions: <>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}