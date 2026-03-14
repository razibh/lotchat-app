import 'package:flutter/material.dart';

mixin PaginationMixin<T> {
  final List<T> _items = <Object?>[];
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  final ScrollController scrollController = ScrollController();

  List<T> get items => List.unmodifiable(_items);
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  void initPagination() {
    scrollController.addListener(_onScroll);
  }

  void disposePagination() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= 
        scrollController.position.maxScrollExtent * 0.8) {
      loadMore();
    }
  }

  void resetPagination() {
    _items.clear();
    _currentPage = 0;
    _hasMore = true;
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    try {
      final List<Object?> newItems = await fetchPage(_currentPage);
      
      if (newItems.isEmpty) {
        _hasMore = false;
      } else {
        _items.addAll(newItems);
        _currentPage++;
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  // Override this method
  Future<List<T>> fetchPage(int page);

  // Add single item
  void addItem(T item) {
    _items.insert(0, item);
  }

  // Remove item
  void removeItem(T item) {
    _items.remove(item);
  }

  // Update item
  void updateItem(T oldItem, T newItem) {
    final int index = _items.indexOf(oldItem);
    if (index != -1) {
      _items[index] = newItem;
    }
  }

  // Loading indicator at bottom
  Widget buildPaginationLoadingIndicator() {
    if (!_isLoadingMore) return const SizedBox.shrink();
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}