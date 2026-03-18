import 'package:flutter/material.dart';

mixin PaginationMixin<T> {
  // এই mixin টি State কে extends করে না
  // শুধু মেথড এবং প্রপার্টি ডিফাইন করে
  // State কে আলাদাভাবে হ্যান্ডেল করতে হবে

  List<T> _items = [];
  int _currentPage = 0;
  int _totalPages = 1;
  int _totalItems = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  late ScrollController scrollController;

  // Getters
  List<T> get items => List.unmodifiable(_items);
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;

  // Methods that need to be called from State
  void initPagination() {
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
  }

  void disposePagination() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoading) return;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;

    if (currentScroll >= maxScroll * 0.8) {
      // This needs to be implemented in the State class
      // because it needs setState
    }
  }

  // These methods need to be called with a state setter
  Future<void> loadFirstPage(Function(void Function()) setState) async {
    setState(() {
      _currentPage = 0;
      _items.clear();
      _hasMore = true;
      _error = null;
    });

    await _loadPage(0, setState);
  }

  Future<void> refreshData(Function(void Function()) setState) async {
    setState(() {
      _isRefreshing = true;
      _currentPage = 0;
      _items.clear();
      _hasMore = true;
      _error = null;
    });

    try {
      await _loadPage(0, setState);
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> loadMore(Function(void Function()) setState) async {
    if (!_hasMore || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _loadPage(_currentPage + 1, setState);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPage(int page, Function(void Function()) setState) async {
    try {
      final result = await fetchPage(page);

      setState(() {
        if (result.items.isEmpty) {
          _hasMore = false;
        } else {
          _items.addAll(result.items);
          _currentPage = page;
          _totalPages = result.totalPages;
          _totalItems = result.totalItems;
          _hasMore = page < result.totalPages - 1;
        }
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<PaginationResult<T>> fetchPage(int page);

  Future<void> retry(Function(void Function()) setState) async {
    await refreshData(setState);
  }

  void addItem(T item, Function(void Function()) setState) {
    _items.insert(0, item);
    _totalItems++;
    setState(() {});
  }

  void updateItem(String id, T updatedItem,
      Function(void Function()) setState, {
        String Function(T)? idExtractor,
      }) {
    final index = _items.indexWhere((item) {
      if (idExtractor != null) {
        return idExtractor(item) == id;
      }
      return false;
    });

    if (index != -1) {
      _items[index] = updatedItem;
      setState(() {});
    }
  }

  void removeItem(String id, Function(void Function()) setState, {
    String Function(T)? idExtractor,
  }) {
    final index = _items.indexWhere((item) {
      if (idExtractor != null) {
        return idExtractor(item) == id;
      }
      return false;
    });

    if (index != -1) {
      _items.removeAt(index);
      _totalItems--;
      setState(() {});
    }
  }

  void clearItems(Function(void Function()) setState) {
    _items.clear();
    _currentPage = 0;
    _totalPages = 1;
    _totalItems = 0;
    _hasMore = true;
    setState(() {});
  }

  bool get isEmpty => _items.isEmpty && !_isLoading && !_isRefreshing;
}

class PaginationResult<T> {
  final List<T> items;
  final int totalPages;
  final int totalItems;
  final int currentPage;

  PaginationResult({
    required this.items,
    required this.totalPages,
    required this.totalItems,
    required this.currentPage,
  });

  bool get hasMore => currentPage < totalPages - 1;
}