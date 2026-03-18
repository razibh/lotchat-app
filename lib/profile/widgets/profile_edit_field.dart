import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ProfileEditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final String? hintText;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Color? fillColor;
  final bool filled;

  const ProfileEditField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.hintText,
    this.suffixIcon,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.fillColor,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        counterText: maxLength != null ? null : '',
        fillColor: fillColor ?? (filled ? Colors.grey.shade50 : null),
        filled: filled,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      onChanged: onChanged,
      focusNode: focusNode,
      textInputAction: textInputAction,
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
    properties.add(DiagnosticsProperty<TextInputType>('keyboardType', keyboardType));
    properties.add(DiagnosticsProperty<bool>('obscureText', obscureText));
    properties.add(DiagnosticsProperty<bool>('enabled', enabled));
    properties.add(StringProperty('hintText', hintText));
  }
}

// Bio field with character counter
class ProfileBioField extends StatelessWidget {
  final TextEditingController controller;
  final int maxLength;
  final void Function(String)? onChanged;

  const ProfileBioField({
    super.key,
    required this.controller,
    this.maxLength = 500,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ProfileEditField(
          controller: controller,
          label: 'Bio',
          icon: Icons.info_outline,
          maxLines: 5,
          maxLength: maxLength,
          onChanged: onChanged,
          hintText: 'Tell us about yourself...',
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, right: 8),
          child: Text(
            '${controller.text.length}/$maxLength',
            style: TextStyle(
              fontSize: 12,
              color: controller.text.length > maxLength * 0.9
                  ? Colors.orange
                  : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('maxLength', maxLength));
  }
}

// Location field
class ProfileLocationField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onTap;
  final bool enabled;

  const ProfileLocationField({
    super.key,
    required this.controller,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileEditField(
      controller: controller,
      label: 'Location',
      icon: Icons.location_on_outlined,
      enabled: enabled,
      onChanged: (_) {},
      hintText: 'City, Country',
    );
  }
}

// Website field
class ProfileWebsiteField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const ProfileWebsiteField({
    super.key,
    required this.controller,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileEditField(
      controller: controller,
      label: 'Website',
      icon: Icons.link,
      keyboardType: TextInputType.url,
      enabled: enabled,
      hintText: 'https://example.com',
      validator: (value) {
        if (value == null || value.isEmpty) return null;
        if (!value.startsWith('http://') && !value.startsWith('https://')) {
          return 'Please enter a valid URL starting with http:// or https://';
        }
        return null;
      },
    );
  }
}

// Phone field
class ProfilePhoneField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const ProfilePhoneField({
    super.key,
    required this.controller,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileEditField(
      controller: controller,
      label: 'Phone Number',
      icon: Icons.phone,
      keyboardType: TextInputType.phone,
      enabled: enabled,
      hintText: '+8801XXXXXXXXX',
    );
  }
}

// Birthday field
class ProfileBirthdayField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onTap;
  final bool enabled;

  const ProfileBirthdayField({
    super.key,
    required this.controller,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileEditField(
      controller: controller,
      label: 'Birthday',
      icon: Icons.cake,
      enabled: enabled,
      onChanged: (_) {},
      hintText: 'DD/MM/YYYY',
      suffixIcon: IconButton(
        icon: const Icon(Icons.calendar_today),
        onPressed: enabled ? onTap : null,
      ),
    );
  }
}

// Gender selection field
class ProfileGenderField extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  final List<String> options;
  final bool enabled;

  const ProfileGenderField({
    super.key,
    required this.value,
    required this.onChanged,
    this.options = const ['Male', 'Female', 'Other', 'Prefer not to say'],
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabled: enabled,
      ),
      items: options.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('value', value));
    properties.add(IterableProperty<String>('options', options));
    properties.add(DiagnosticsProperty<bool>('enabled', enabled));
  }
}

// Interests field with chips
class ProfileInterestsField extends StatelessWidget {
  final List<String> selectedInterests;
  final List<String> availableInterests;
  final Function(String) onToggle;
  final bool enabled;

  const ProfileInterestsField({
    super.key,
    required this.selectedInterests,
    required this.availableInterests,
    required this.onToggle,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Interests',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableInterests.map((interest) {
            final isSelected = selectedInterests.contains(interest);
            return FilterChip(
              label: Text(interest),
              selected: isSelected,
              onSelected: enabled ? (_) => onToggle(interest) : null,
              backgroundColor: Colors.grey.shade100,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<String>('selectedInterests', selectedInterests));
    properties.add(IterableProperty<String>('availableInterests', availableInterests));
    properties.add(DiagnosticsProperty<bool>('enabled', enabled));
  }
}