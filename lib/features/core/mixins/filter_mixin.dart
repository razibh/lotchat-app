import 'package:flutter/material.dart';

typedef FilterPredicate<T> = bool Function(T item, Map<String, dynamic> filters);
typedef FilterOptionsBuilder = Map<String, List<dynamic>> Function();

mixin FilterMixin<T> on State {
  Map<String, dynamic> _filters = <String, dynamic>{};
  List<T> _filteredItems = <Object?>[];
  bool _isFiltering = false;

  Map<String, dynamic> get filters => _filters;
  List<T> get filteredItems => _filteredItems;
  bool get isFiltering => _isFiltering;

  // Initialize filters
  void initFilters(Map<String, dynamic> initialFilters) {
    _filters = Map.from(initialFilters);
  }

  // Apply filters
  void applyFilters(List<T> items, FilterPredicate<T> predicate) {
    setState(() {
      _isFiltering = true;
      _filteredItems = items.where((item) => predicate(item, _filters)).toList();
      _isFiltering = false;
    });
  }

  // Update single filter
  void updateFilter(String key, dynamic value) {
    setState(() {
      _filters[key] = value;
    });
  }

  // Update multiple filters
  void updateFilters(Map<String, dynamic> newFilters) {
    setState(() {
      _filters.addAll(newFilters);
    });
  }

  // Remove filter
  void removeFilter(String key) {
    setState(() {
      _filters.remove(key);
    });
  }

  // Clear all filters
  void clearFilters() {
    setState(() {
      _filters.clear();
    });
  }

  // Check if filter exists
  bool hasFilter(String key) {
    return _filters.containsKey(key);
  }

  // Get filter value
  dynamic getFilter(String key, {dynamic defaultValue}) {
    return _filters[key] ?? defaultValue;
  }

  // Get filter as type
  T? getFilterAs<T>(String key) {
    final value = _filters[key];
    if (value is T) return value;
    return null;
  }

  // Get filter count
  int get filterCount => _filters.length;

  // Check if any filter active
  bool get hasActiveFilters => _filters.isNotEmpty;

  // Build filter chip
  Widget buildFilterChip({
    required String label,
    required String filterKey,
    required dynamic filterValue,
    Color? selectedColor,
    VoidCallback? onTap,
  }) {
    final bool isSelected = _filters[filterKey] == filterValue;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          updateFilter(filterKey, filterValue);
        } else {
          removeFilter(filterKey);
        }
        onTap?.call();
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: selectedColor ?? Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
      ),
    );
  }

  // Build filter slider
  Widget buildFilterSlider({
    required String label,
    required String filterKey,
    required double min,
    required double max,
    int divisions = 100,
    String? valueSuffix,
  }) {
    final double currentValue = getFilterAs<double>(filterKey) ?? min;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <>[
            Text(label),
            Text('${currentValue.toStringAsFixed(1)}$valueSuffix'),
          ],
        ),
        Slider(
          value: currentValue,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: (double value) => updateFilter(filterKey, value),
        ),
      ],
    );
  }

  // Build filter range slider
  Widget buildFilterRangeSlider({
    required String label,
    required String minKey,
    required String maxKey,
    required double min,
    required double max,
    int divisions = 100,
  }) {
    final double currentMin = getFilterAs<double>(minKey) ?? min;
    final double currentMax = getFilterAs<double>(maxKey) ?? max;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <>[
        Text(label),
        RangeSlider(
          values: RangeValues(currentMin, currentMax),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: (RangeValues values) {
            updateFilters(<String, dynamic>{
              minKey: values.start,
              maxKey: values.end,
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <>[
            Text('Min: ${currentMin.toStringAsFixed(0)}'),
            Text('Max: ${currentMax.toStringAsFixed(0)}'),
          ],
        ),
      ],
    );
  }

  // Build filter checkbox
  Widget buildFilterCheckbox({
    required String label,
    required String filterKey,
  }) {
    return CheckboxListTile(
      title: Text(label),
      value: getFilter(filterKey, defaultValue: false),
      onChanged: (bool? value) => updateFilter(filterKey, value),
    );
  }

  // Build filter radio
  Widget buildFilterRadio<T>({
    required String label,
    required String filterKey,
    required T value,
    required T groupValue,
  }) {
    return RadioListTile<T>(
      title: Text(label),
      value: value,
      groupValue: groupValue,
      onChanged: (selected) => updateFilter(filterKey, selected),
    );
  }

  // Build filter dropdown
  Widget buildFilterDropdown({
    required String label,
    required String filterKey,
    required List<DropdownMenuItem> items,
    dynamic value,
  }) {
    return DropdownButtonFormField(
      decoration: InputDecoration(labelText: label),
      initialValue: getFilter(filterKey, defaultValue: value),
      items: items,
      onChanged: (value) => updateFilter(filterKey, value),
    );
  }

  // Build filter date picker
  Future<void> buildFilterDatePicker({
    required String label,
    required String filterKey,
  }) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      updateFilter(filterKey, date);
    }
  }

  // Build filter bottom sheet
  void showFilterSheet({
    required Widget child,
    String title = 'Filters',
    VoidCallback? onApply,
    VoidCallback? onClear,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <>[
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <>[
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                
                // Filter content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: child,
                  ),
                ),
                const Divider(),
                
                // Footer buttons
                Row(
                  children: <>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          clearFilters();
                          onClear?.call();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear All'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          onApply?.call();
                          Navigator.pop(context);
                        },
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}