import 'package:flutter/material.dart';

mixin PaginationMixin<T> on State {
  final List<T> _items = <Object?>[];
  int _currentPage = 0;
  int _totalPages = 1;
  int _totalItems = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _isRefreshing = false;
  String? _error;
  final ScrollController scrollController = ScrollController();

  List<T> get items => List.unmodifiable(_items);
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore) return;
    
    final double maxScroll = scrollController.position.maxScrollExtent;
    final double currentScroll = scrollController.position.pixels;
    
    if (currentScroll >= maxScroll * 0.8) {
      _loadMore();
    }
  }

  // Load first page
  Future<void> loadFirstPage() async {
    setState(() {
      _currentPage = 0;
      _items.clear();
      _hasMore = true;
      _error = null;
    });
    
    await _loadPage(0);
  }

  // Refresh (pull to refresh)
  Future<void> refreshData() async {
    setState(() {
      _isRefreshing = true;
      _currentPage = 0;
      _items.clear();
      _hasMore = true;
      _error = null;
    });

    try {
      await _loadPage(0);
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  // Load more (infinite scroll)
  Future<void> _loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    try {
      await _loadPage(_currentPage + 1);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  // Load specific page
  Future<void> _loadPage(int page) async {
    try {
      final PaginationResult<Object?> result = await fetchPage(page);
      
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

  // Abstract method to be implemented by the widget
  Future<PaginationResult<T>> fetchPage(int page);

  // Retry after error
  Future<void> retry() async {
    await refreshData();
  }

  // Add item to list (for real-time updates)
  void addItem(T item) {
    setState(() {
      _items.insert(0, item);
      _totalItems++;
    });
  }

  // Update item in list
  void updateItem(String id, T updatedItem, {String Function(T)? idExtractor}) {
    final int index = _items.indexWhere((item) {
      if (idExtractor != null) {
        return idExtractor(item) == id;
      }
      return false;
    });
    
    if (index != -1) {
      setState(() {
        _items[index] = updatedItem;
      });
    }
  }

  // Remove item from list
  void removeItem(String id, {String Function(T)? idExtractor}) {
    final int index = _items.indexWhere((item) {
      if (idExtractor != null) {
        return idExtractor(item) == id;
      }
      return false;
    });
    
    if (index != -1) {
      setState(() {
        _items.removeAt(index);
        _totalItems--;
      });
    }
  }

  // Clear all items
  void clearItems() {
    setState(() {
      _items.clear();
      _currentPage = 0;
      _totalPages = 1;
      _totalItems = 0;
      _hasMore = true;
    });
  }

  // Check if list is empty
  bool get isEmpty => _items.isEmpty && !_isLoadingMore && !_isRefreshing;

  // Build loading indicator for list footer
  Widget buildLoadingIndicator() {
    if (!_isLoadingMore) return const SizedBox.shrink();
    
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // Build error widget
  Widget buildErrorWidget({VoidCallback? onRetry}) {
    if (_error == null) return const SizedBox.shrink();
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <>[
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error loading data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry ?? retry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Build empty state
  Widget buildEmptyState({
    String title = 'No items found',
    String message = 'There are no items to display',
    IconData icon = Icons.inbox,
    Widget? customWidget,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    if (customWidget != null) return customWidget;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <>[
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            if (onAction != null && actionLabel != null) ...<>[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Get shimmer loading count
  int get shimmerCount => 5;
}

class PaginationResult<T> {

  PaginationResult({
    required this.items,
    required this.totalPages,
    required this.totalItems,
    required this.currentPage,
  });

  factory PaginationResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return PaginationResult(
      items: (json['items'] as List).map((e) => fromJson(e)).toList(),
      totalPages: json['totalPages'],
      totalItems: json['totalItems'],
      currentPage: json['currentPage'],
    );
  }
  final List<T> items;
  final int totalPages;
  final int totalItems;
  final int currentPage;
}

// Shimmer Loading Widget (can be used with the mixin)
class ShimmerLoading extends StatelessWidget {

  const ShimmerLoading({
    required this.itemCount, required this.itemBuilder, super.key,
  });
  final int itemCount;
  final Widget Function(int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) => itemBuilder(index),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('itemCount', itemCount));
    properties.add(ObjectFlagProperty<Widget Function(int index)>.has('itemBuilder', itemBuilder));
  }
}