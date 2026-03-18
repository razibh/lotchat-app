import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Color? fillColor;
  final Color? textColor;
  final EdgeInsets? contentPadding;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.fillColor,
    this.textColor,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      focusNode: focusNode,
      textInputAction: textInputAction,
      style: TextStyle(
        color: textColor ?? (enabled ? Colors.black87 : Colors.grey),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: TextStyle(
          color: enabled ? Colors.grey.shade700 : Colors.grey.shade400,
        ),
        hintStyle: TextStyle(
          color: enabled ? Colors.grey.shade500 : Colors.grey.shade300,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
          prefixIcon,
          color: enabled ? Colors.grey.shade700 : Colors.grey.shade400,
        )
            : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        filled: true,
        fillColor: fillColor ?? (enabled ? Colors.white : Colors.grey.shade100),
        contentPadding: contentPadding ?? const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        counterText: maxLength != null ? null : '',
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TextEditingController>('controller', controller));
    properties.add(StringProperty('label', label));
    properties.add(StringProperty('hintText', hintText));
    properties.add(DiagnosticsProperty<IconData?>('prefixIcon', prefixIcon));
    properties.add(DiagnosticsProperty<bool>('obscureText', obscureText));
    properties.add(DiagnosticsProperty<TextInputType>('keyboardType', keyboardType));
    properties.add(ObjectFlagProperty<String? Function(String?)?>.has('validator', validator));
    properties.add(ObjectFlagProperty<void Function(String)?>.has('onChanged', onChanged));
    properties.add(ObjectFlagProperty<void Function(String)?>.has('onSubmitted', onSubmitted));
    properties.add(IntProperty('maxLines', maxLines));
    properties.add(IntProperty('maxLength', maxLength));
    properties.add(DiagnosticsProperty<bool>('enabled', enabled));
    properties.add(DiagnosticsProperty<FocusNode?>('focusNode', focusNode));
    properties.add(DiagnosticsProperty<TextInputAction?>('textInputAction', textInputAction));
    properties.add(ColorProperty('fillColor', fillColor));
    properties.add(ColorProperty('textColor', textColor));
  }
}

// Password field with show/hide toggle
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final FocusNode? focusNode;

  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.focusNode,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TextEditingController>('controller', controller));
    properties.add(StringProperty('label', label));
    properties.add(StringProperty('hintText', hintText));
    properties.add(ObjectFlagProperty<String? Function(String?)?>.has('validator', validator));
  }
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      label: widget.label,
      hintText: widget.hintText,
      obscureText: _obscureText,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey.shade600,
        ),
        onPressed: widget.enabled
            ? () {
          setState(() {
            _obscureText = !_obscureText;
          });
        }
            : null,
      ),
    );
  }
}

// Email field with validation
class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final FocusNode? focusNode;

  const EmailField({
    super.key,
    required this.controller,
    this.label = 'Email',
    this.hintText = 'Enter your email',
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      hintText: hintText,
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      focusNode: focusNode,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email is required';
        }
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value)) {
          return 'Enter a valid email';
        }
        return null;
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TextEditingController>('controller', controller));
    properties.add(StringProperty('label', label));
    properties.add(StringProperty('hintText', hintText));
  }
}

// Phone field with formatting
class PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final FocusNode? focusNode;

  const PhoneField({
    super.key,
    required this.controller,
    this.label = 'Phone Number',
    this.hintText = 'Enter phone number',
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      hintText: hintText,
      prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      focusNode: focusNode,
      maxLength: 15,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Phone number is required';
        }
        final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
        if (!phoneRegex.hasMatch(value)) {
          return 'Enter a valid phone number';
        }
        return null;
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TextEditingController>('controller', controller));
    properties.add(StringProperty('label', label));
    properties.add(StringProperty('hintText', hintText));
  }
}

// Search field
class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final FocusNode? focusNode;

  const SearchField({
    super.key,
    required this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: '',
      hintText: hintText,
      prefixIcon: Icons.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      focusNode: focusNode,
      maxLines: 1,
      suffixIcon: controller.text.isNotEmpty
          ? IconButton(
        icon: const Icon(Icons.clear, size: 18),
        onPressed: () {
          controller.clear();
          onClear?.call();
          onChanged?.call('');
        },
      )
          : null,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TextEditingController>('controller', controller));
    properties.add(StringProperty('hintText', hintText));
  }
}