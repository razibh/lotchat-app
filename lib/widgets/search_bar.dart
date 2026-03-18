import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async'; // Timer এর জন্য

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final bool autofocus;
  final VoidCallback? onSubmitted;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final EdgeInsets? margin;

  const CustomSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.controller,
    this.autofocus = false,
    this.onSubmitted,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[200],
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
          hintStyle: TextStyle(
            color: (textColor ?? Colors.grey).withOpacity(0.7),
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            color: iconColor ?? Colors.grey,
          ),
          suffixIcon: controller != null && controller!.text.isNotEmpty
              ? IconButton(
            icon: Icon(
              Icons.clear,
              color: iconColor ?? Colors.grey,
              size: 18,
            ),
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
        style: TextStyle(
          fontSize: 16,
          color: textColor ?? Colors.black87,
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('hintText', hintText));
    properties.add(DiagnosticsProperty<TextEditingController?>('controller', controller));
    properties.add(DiagnosticsProperty<bool>('autofocus', autofocus));
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties.add(ColorProperty('iconColor', iconColor));
    properties.add(ColorProperty('textColor', textColor));
  }
}

// Debounced search bar with automatic delay
class DebouncedSearchBar extends StatefulWidget {
  final String hintText;
  final Function(String) onSearch;
  final Duration debounceDuration;
  final TextEditingController? controller;
  final bool autofocus;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;

  const DebouncedSearchBar({
    super.key,
    required this.hintText,
    required this.onSearch,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.controller,
    this.autofocus = false,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
  });

  @override
  State<DebouncedSearchBar> createState() => _DebouncedSearchBarState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('hintText', hintText));
    properties.add(DiagnosticsProperty<Duration>('debounceDuration', debounceDuration));
  }
}

class _DebouncedSearchBarState extends State<DebouncedSearchBar> {
  Timer? _debounceTimer;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onSearch(query);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomSearchBar(
      hintText: widget.hintText,
      onChanged: _onSearchChanged,
      controller: _controller,
      autofocus: widget.autofocus,
      backgroundColor: widget.backgroundColor,
      iconColor: widget.iconColor,
      textColor: widget.textColor,
    );
  }
}

// Search bar with filter chips
class FilterSearchBar extends StatelessWidget {
  final String hintText;
  final Function(String) onSearch;
  final List<FilterChipData> filters;
  final Function(int)? onFilterSelected;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;

  const FilterSearchBar({
    super.key,
    required this.hintText,
    required this.onSearch,
    required this.filters,
    this.onFilterSelected,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomSearchBar(
          hintText: hintText,
          onChanged: onSearch,
          backgroundColor: backgroundColor,
          iconColor: iconColor,
          textColor: textColor,
        ),
        if (filters.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter.label),
                    selected: filter.selected,
                    onSelected: (selected) {
                      onFilterSelected?.call(index);
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: filter.selectedColor ?? Theme.of(context).primaryColor,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: filter.selected ? Colors.white : Colors.black87,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('hintText', hintText));
    properties.add(IterableProperty<FilterChipData>('filters', filters));
  }
}

class FilterChipData {
  final String label;
  final bool selected;
  final Color? selectedColor;

  FilterChipData({
    required this.label,
    required this.selected,
    this.selectedColor,
  });
}