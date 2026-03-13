import 'package:flutter/material.dart';

class MessageDeleteDialog extends StatelessWidget {

  const MessageDeleteDialog({
    Key? key,
    required this.onDeleteForMe,
    required this.onDeleteForEveryone,
  }) : super(key: key);
  final VoidCallback onDeleteForMe;
  final VoidCallback onDeleteForEveryone;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Message'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <>[
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Delete for me'),
            onTap: () {
              Navigator.pop(context);
              onDeleteForMe();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete for everyone', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              onDeleteForEveryone();
            },
          ),
        ],
      ),
    );
  }
}