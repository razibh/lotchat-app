import 'package:flutter/material.dart';
import '../models/message_model.dart';

class MessageReactions extends StatelessWidget {

  const MessageReactions({
    required this.reactions, super.key,
    this.onReaction,
  });
  final List<MessageReaction> reactions;
  final Function(String)? onReaction;

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    // Group reactions
    final Map<String, int> grouped = <String, int>{};
    for (MessageReaction reaction in reactions) {
      grouped[reaction.reaction] = (grouped[reaction.reaction] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <>[
          ...grouped.entries.map((MapEntry<String, int> entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <>[
                  Text(entry.key),
                  if (entry.value > 1)
                    Text(
                      ' ${entry.value}',
                      style: const TextStyle(fontSize: 10),
                    ),
                ],
              ),
            );
          }),
          if (onReaction != null)
            InkWell(
              onTap: () => _showReactionPicker(context),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.add, size: 12),
              ),
            ),
        ],
      ),
    );
  }

  void _showReactionPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Add Reaction'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <String>[
            '👍', '❤️', '😂', '😮', '😢', '😡',
          ].map((String emoji) {
            return InkWell(
              onTap: () {
                Navigator.pop(context);
                onReaction?.call(emoji);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<MessageReaction>('reactions', reactions));
    properties.add(ObjectFlagProperty<Function(String)?>.has('onReaction', onReaction));
  }
}