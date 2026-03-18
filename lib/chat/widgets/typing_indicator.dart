import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 🟢 DiagnosticPropertiesBuilder এর জন্য

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({
    super.key,
    required this.typingUsers,
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
        children: [
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
          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    // 🟢 IterableProperty সরিয়ে DiagnosticsProperty ব্যবহার করুন
    properties.add(DiagnosticsProperty<List<String>>('typingUsers', typingUsers));
  }
}