import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 🟢 DiagnosticPropertiesBuilder এর জন্য

class MessageDeleteDialog extends StatelessWidget {
  const MessageDeleteDialog({
    super.key,
    required this.onDeleteForMe,
    required this.onDeleteForEveryone,
  });

  final VoidCallback onDeleteForMe;
  final VoidCallback onDeleteForEveryone;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Message'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
            title: const Text(
                'Delete for everyone',
                style: TextStyle(color: Colors.red)
            ),
            onTap: () {
              Navigator.pop(context);
              onDeleteForEveryone();
            },
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<VoidCallback>.has('onDeleteForMe', onDeleteForMe));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onDeleteForEveryone', onDeleteForEveryone));
  }
}