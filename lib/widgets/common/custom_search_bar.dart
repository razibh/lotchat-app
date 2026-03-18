import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final Function(String) onChanged;
  final TextEditingController? controller;
  final bool autofocus;
  final VoidCallback? onSubmitted;

  const CustomSearchBar({
    Key? key,
    required this.hintText,
    required this.onChanged,
    this.controller,
    this.autofocus = false,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: (_) => onSubmitted?.call(),
        autofocus: autofocus,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: controller != null && controller!.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              controller!.clear();
              onChanged('');
            },
          )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}