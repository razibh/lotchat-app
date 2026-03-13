import 'package:flutter/material.dart';

class ChatSearchBar extends StatelessWidget {

  const ChatSearchBar({
    Key? key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  }) : super(key: key);
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search messages...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: onClear,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }
}