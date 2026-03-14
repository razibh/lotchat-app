import 'package:flutter/material.dart';

class ProfileEditField extends StatelessWidget {

  const ProfileEditField({
    required this.controller, required this.label, required this.icon, super.key,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
  });
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TextEditingController>('controller', controller));
    properties.add(StringProperty('label', label));
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
    properties.add(IntProperty('maxLines', maxLines));
    properties.add(IntProperty('maxLength', maxLength));
    properties.add(ObjectFlagProperty<String? Function(String?)?>.has('validator', validator));
  }
}