import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class NeumorphicTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;  // ← IconData? থেকে Widget? পরিবর্তন
  final VoidCallback? onSuffixIconPressed;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final bool readOnly;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? hintColor;

  const NeumorphicTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,  // ← টাইপ পরিবর্তন
    this.onSuffixIconPressed,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.readOnly = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.focusNode,
    this.contentPadding,
    this.borderRadius = 12,
    this.backgroundColor,
    this.textColor,
    this.hintColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = enabled && !readOnly;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? (isEnabled
            ? AppColors.surfaceLight
            : AppColors.surfaceLight.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        boxShadow: isEnabled ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            offset: const Offset(-2, -2),
            blurRadius: 4,
          ),
        ] : null,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        minLines: minLines,
        enabled: enabled,
        readOnly: readOnly,
        validator: validator,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        textInputAction: textInputAction,
        focusNode: focusNode,
        style: TextStyle(
          color: textColor ?? (enabled ? Colors.white : Colors.white54),
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          hintStyle: TextStyle(
            color: hintColor ?? (enabled ? Colors.white54 : Colors.white38),
            fontSize: 14,
          ),
          labelStyle: TextStyle(
            color: hintColor ?? (enabled ? Colors.white70 : Colors.white38),
            fontSize: 14,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(
            prefixIcon,
            color: enabled ? AppColors.accentPurple : Colors.white38,
            size: 20,
          )
              : null,
          suffixIcon: suffixIcon,  // ← সরাসরি Widget ব্যবহার করুন
          border: InputBorder.none,
          contentPadding: contentPadding ?? const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}