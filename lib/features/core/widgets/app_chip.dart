import 'package:flutter/material.dart';

class AppChip extends StatelessWidget {

  const AppChip({
    required this.label, super.key,
    this.icon,
    this.color,
    this.textColor,
    this.isSelected = false,
    this.isRemovable = false,
    this.onTap,
    this.onDeleted,
    this.height = 32,
    this.fontSize = 14,
  });
  final String label;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final bool isSelected;
  final bool isRemovable;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color chipColor = color ?? (isSelected ? theme.primaryColor : Colors.grey.shade200);
    final Color labelColor = textColor ?? (isSelected ? Colors.white : Colors.black87);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: chipColor.withValues(alpha: isSelected ? 1 : 0.1),
          borderRadius: BorderRadius.circular(height / 2),
          border: Border.all(
            color: isSelected ? Colors.transparent : chipColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            if (icon != null) ...<>[
              Icon(
                icon,
                size: fontSize * 1.2,
                color: labelColor,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: fontSize,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isRemovable) ...<>[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDeleted,
                child: Icon(
                  Icons.close,
                  size: fontSize * 1.2,
                  color: labelColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('label', label));
    properties.add(DiagnosticsProperty<IconData?>('icon', icon));
    properties.add(ColorProperty('color', color));
    properties.add(ColorProperty('textColor', textColor));
    properties.add(DiagnosticsProperty<bool>('isSelected', isSelected));
    properties.add(DiagnosticsProperty<bool>('isRemovable', isRemovable));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onDeleted', onDeleted));
    properties.add(DoubleProperty('height', height));
    properties.add(DoubleProperty('fontSize', fontSize));
  }
}

class FilterChipWidget extends StatefulWidget {

  const FilterChipWidget({
    required this.label, required this.initialSelected, required this.onSelected, super.key,
    this.selectedColor,
  });
  final String label;
  final bool initialSelected;
  final ValueChanged<bool> onSelected;
  final Color? selectedColor;

  @override
  State<FilterChipWidget> createState() => _FilterChipWidgetState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('label', label));
    properties.add(DiagnosticsProperty<bool>('initialSelected', initialSelected));
    properties.add(ObjectFlagProperty<ValueChanged<bool>>.has('onSelected', onSelected));
    properties.add(ColorProperty('selectedColor', selectedColor));
  }
}

class _FilterChipWidgetState extends State<FilterChipWidget> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.initialSelected;
  }

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(widget.label),
      selected: _isSelected,
      onSelected: (bool selected) {
        setState(() {
          _isSelected = selected;
        });
        widget.onSelected(selected);
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: widget.selectedColor ?? Theme.of(context).primaryColor,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: _isSelected ? Colors.white : Colors.black87,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}

class ChoiceChipWidget extends StatelessWidget {

  const ChoiceChipWidget({
    required this.label, required this.isSelected, required this.onSelected, super.key,
    this.selectedColor,
  });
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.grey.shade100,
      selectedColor: selectedColor ?? Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('label', label));
    properties.add(DiagnosticsProperty<bool>('isSelected', isSelected));
    properties.add(ObjectFlagProperty<ValueChanged<bool>>.has('onSelected', onSelected));
    properties.add(ColorProperty('selectedColor', selectedColor));
  }
}