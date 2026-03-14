import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {

  const TypingIndicator({
    required this.typingUsers, super.key,
  });
  final List<String> typingUsers;

  @override
  Widget build(BuildContext context) {
    if (typingUsers.isEmpty) return const SizedBox.shrink();

    String text;
    if (typingUsers.length == 1) {
      text = '${typingUsers.first} is typing';
    } else if (typingUsers.length == 2) {
      text = '${typingUsers[0]} and ${typingUsers[1]} are typing';
    } else {
      text = 'Several people are typing';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: <>[
          _buildTypingAnimation(),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingAnimation() {
    return SizedBox(
      width: 40,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (int index) {
          return Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
            child: AnimatedOpacity(
              opacity: 0.5,
              duration: const Duration(milliseconds: 500),
              child: Container(),
            ),
          );
        }),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<String>('typingUsers', typingUsers));
  }
}