import 'package:flutter/material.dart';

class AppChip extends StatelessWidget {

  const AppChip({
    Key? key,
    required this.label,
    this.icon,
    this.color,
    this.textColor,
    this.isSelected = false,
    this.isRemovable = false,
    this.onTap,
    this.onDeleted,
    this.height = 32,
    this.fontSize = 14,
  }) : super(key: key);
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
    final theme = Theme.of(context);
    final chipColor = color ?? (isSelected ? theme.primaryColor : Colors.grey.shade200);
    final labelColor = textColor ?? (isSelected ? Colors.white : Colors.black87);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: chipColor.withOpacity(isSelected ? 1 : 0.1),
          borderRadius: BorderRadius.circular(height / 2),
          border: Border.all(
            color: isSelected ? Colors.transparent : chipColor.withOpacity(0.3),
            width: 1,
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
}

class FilterChipWidget extends StatefulWidget {

  const FilterChipWidget({
    Key? key,
    required this.label,
    required this.initialSelected,
    required this.onSelected,
    this.selectedColor,
  }) : super(key: key);
  final String label;
  final bool initialSelected;
  final ValueChanged<bool> onSelected;
  final Color? selectedColor;

  @override
  State<FilterChipWidget> createState() => _FilterChipWidgetState();
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
      onSelected: (selected) {
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
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.selectedColor,
  }) : super(key: key);
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
}