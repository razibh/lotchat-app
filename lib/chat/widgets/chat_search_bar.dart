import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 🟢 DiagnosticPropertiesBuilder এর জন্য

class ChatSearchBar extends StatelessWidget {
  const ChatSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TextEditingController>('controller', controller));
    properties.add(ObjectFlagProperty<Function(String)>.has('onChanged', onChanged));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onClear', onClear));
  }
}