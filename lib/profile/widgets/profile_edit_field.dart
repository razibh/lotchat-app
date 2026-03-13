import 'package:flutter/material.dart';

class ProfileEditField extends StatelessWidget {

  const ProfileEditField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
  }) : super(key: key);
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        counterText: '',
      ),
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
    );
  }
}