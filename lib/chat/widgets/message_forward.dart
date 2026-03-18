import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 🟢 DiagnosticPropertiesBuilder এর জন্য
import '../models/chat_model.dart';

class MessageForwardDialog extends StatelessWidget {
  const MessageForwardDialog({
    super.key,
    required this.chats,
    required this.onForward,
  });

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
          itemBuilder: (BuildContext context, int index) {
            final ChatModel chat = chats[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: chat.groupAvatar != null
                    ? NetworkImage(chat.groupAvatar!)
                    : null,
                child: chat.groupAvatar == null
                    ? Text(
                  chat.type == 'private'
                      ? (chat.participants.isNotEmpty
                      ? chat.participants.first[0].toUpperCase()
                      : '?')
                      : 'G',
                )
                    : null,
              ),
              title: Text(
                chat.type == 'private'
                    ? (chat.participants.isNotEmpty
                    ? chat.participants.first
                    : 'User')
                    : (chat.groupName ?? 'Group'),
              ),
              onTap: () {
                Navigator.pop(context);
                onForward(chat);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(DiagnosticsProperty<List<ChatModel>>('chats', chats));
    properties.add(ObjectFlagProperty<Function(ChatModel)>.has('onForward', onForward));
  }
}