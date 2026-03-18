import 'package:flutter/material.dart';
import 'dart:async'; // Timer এর জন্য

typedef SearchPredicate<T> = bool Function(T item, String query);
typedef SearchFilter<T> = List<T> Function(List<T> items, String query);

mixin SearchMixin<T> on State {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  List<T> _allItems = [];
  List<T> _searchResults = [];
  String _searchQuery = '';
  bool _isSearching = false;
  bool _hasSearchResults = false;
  Duration _debounceDuration = const Duration(milliseconds: 300);
  Timer? _debounceTimer;

  List<T> get allItems => _allItems;
  List<T> get searchResults => _searchResults;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;
  bool get hasSearchResults => _hasSearchResults;
  bool get hasSearchQuery => _searchQuery.isNotEmpty;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      if (mounted) {
        setState(() {
          _searchQuery = searchController.text;
          _performSearch();
        });
      }
    });
  }

  void _performSearch() {
    if (_searchQuery.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      _hasSearchResults = false;
      return;
    }

    _isSearching = true;
    _searchResults = filterItems(_allItems, _searchQuery);
    _isSearching = false;
    _hasSearchResults = _searchResults.isNotEmpty;
  }

  // Override this method for custom filtering
  List<T> filterItems(List<T> items, String query) {
    return items.where((item) => defaultSearchPredicate(item, query)).toList();
  }

  // Default search predicate (override if needed)
  bool defaultSearchPredicate(T item, String query) {
    return item.toString().toLowerCase().contains(query.toLowerCase());
  }

  // Set custom search predicate
  void setSearchPredicate(SearchPredicate<T> predicate) {
    _performSearch(); // This will use the overridden method
  }

  // Set custom search filter
  void setSearchFilter(SearchFilter<T> filter) {
    // This can be used with a custom implementation
  }

  // Update items list
  void updateItems(List<T> newItems) {
    setState(() {
      _allItems = newItems;
      if (_searchQuery.isNotEmpty) {
        _performSearch();
      }
    });
  }

  // Clear search
  void clearSearch() {
    searchController.clear();
    setState(() {
      _searchQuery = '';
      _searchResults = [];
      _isSearching = false;
      _hasSearchResults = false;
    });
  }

  // Start searching (focus)
  void startSearch() {
    searchFocusNode.requestFocus();
  }

  // Stop searching (unfocus)
  void stopSearch() {
    searchFocusNode.unfocus();
    if (_searchQuery.isEmpty) {
      setState(() {
        _isSearching = false;
      });
    }
  }

  // Set debounce duration
  void setDebounceDuration(Duration duration) {
    _debounceDuration = duration;
  }

  // Get search suggestions
  List<String> getSuggestions({int limit = 5}) {
    if (_searchQuery.isEmpty) return [];

    final Set<String> suggestions = {};
    for (final item in _allItems) {
      final String itemStr = item.toString();
      if (itemStr.toLowerCase().contains(_searchQuery.toLowerCase())) {
        // Extract relevant part
        final int index = itemStr.toLowerCase().indexOf(_searchQuery.toLowerCase());
        if (index != -1) {
          final int start = index > 15 ? index - 15 : 0;
          final int end = index + _searchQuery.length + 15;
          final String suggestion = itemStr.substring(
            start,
            end > itemStr.length ? itemStr.length : end,
          );
          suggestions.add(suggestion);
        }
      }
      if (suggestions.length >= limit) break;
    }
    return suggestions.toList();
  }

  // Build search bar
  Widget buildSearchBar({
    String hintText = 'Search...',
    List<Widget>? actions,
    Color? backgroundColor,
    bool autofocus = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: backgroundColor ?? Theme.of(context).primaryColor,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              focusNode: searchFocusNode,
              autofocus: autofocus,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: clearSearch,
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          if (actions != null) ...actions,
        ],
      ),
    );
  }

  // Build search results count
  Widget buildResultsCount() {
    if (!hasSearchQuery) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        _hasSearchResults
            ? 'Found ${_searchResults.length} results for "$_searchQuery"'
            : 'No results found for "$_searchQuery"',
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  // Build search suggestions
  Widget buildSuggestions({
    required Function(String) onSuggestionTap,
    int limit = 5,
  }) {
    final List<String> suggestions = getSuggestions(limit: limit);

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: suggestions.map((String suggestion) {
          return ListTile(
            leading: const Icon(Icons.search, size: 20),
            title: RichText(
              text: _highlightText(suggestion),
            ),
            onTap: () {
              onSuggestionTap(suggestion);
              searchController.text = suggestion;
              searchController.selection = TextSelection(
                baseOffset: suggestion.length,
                extentOffset: suggestion.length,
              );
            },
          );
        }).toList(),
      ),
    );
  }

  TextSpan _highlightText(String text) {
    final String lowerText = text.toLowerCase();
    final String lowerQuery = _searchQuery.toLowerCase();
    final List<TextSpan> matches = [];
    int start = 0;

    while (true) {
      final int index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        if (start < text.length) {
          matches.add(TextSpan(text: text.substring(start)));
        }
        break;
      }

      if (index > start) {
        matches.add(TextSpan(text: text.substring(start, index)));
      }

      matches.add(TextSpan(
        text: text.substring(index, index + _searchQuery.length),
        style: const TextStyle(
          backgroundColor: Colors.yellow,
          fontWeight: FontWeight.bold,
        ),
      ));

      start = index + _searchQuery.length;
    }

    return TextSpan(children: matches);
  }

  // Build search history
  Widget buildSearchHistory({
    required List<String> history,
    required Function(String) onTap,
    required VoidCallback onClear,
  }) {
    if (history.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: onClear,
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
        ...history.map((String query) {
          return ListTile(
            leading: const Icon(Icons.history, size: 20),
            title: Text(query),
            trailing: const Icon(Icons.arrow_upward, size: 16),
            onTap: () => onTap(query),
          );
        }),
      ],
    );
  }

  // Build popular searches
  Widget buildPopularSearches({
    required List<String> popular,
    required Function(String) onTap,
  }) {
    if (popular.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Popular Searches',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: popular.map((String query) {
              return ActionChip(
                label: Text(query),
                onPressed: () => onTap(query),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Highlight search term in text
  Text highlightText(String text) {
    if (_searchQuery.isEmpty) return Text(text);

    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final String lowerQuery = _searchQuery.toLowerCase();
    int start = 0;

    while (true) {
      final int index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start)));
        }
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + _searchQuery.length),
        style: const TextStyle(
          backgroundColor: Colors.yellow,
          fontWeight: FontWeight.bold,
        ),
      ));

      start = index + _searchQuery.length;
    }

    return Text.rich(TextSpan(children: spans));
  }
}