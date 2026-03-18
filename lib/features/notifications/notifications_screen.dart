import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with PaginationMixin {
  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  Future<PaginationResult> fetchPage(int page) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));

    final items = List.generate(20, (index) => NotificationModel(
      id: 'notif_$index',
      title: 'Notification $index',
      message: 'This is notification number $index',
      type: 'info',
      isRead: false,
      createdAt: DateTime.now(),
    ));

    return PaginationResult(
      items: items,
      hasMore: page < 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist),
            onPressed: () {
              setState(() {
                for (var item in items) {
                  (item as NotificationModel).isRead = true;
                }
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: items.isEmpty && !isLoading
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No notifications yet',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        )
            : ListView.builder(
          controller: scrollController,
          itemCount: items.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == items.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final notification = items[index] as NotificationModel;
            return _buildNotificationItem(notification);
          },
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getNotificationColor(notification.type),
        child: Icon(
          _getNotificationIcon(notification.type),
          color: Colors.white,
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Text(notification.message),
      trailing: Text(
        _formatTime(notification.createdAt),
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      onTap: () {
        setState(() {
          notification.isRead = true;
        });
        // Handle notification tap
      },
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'info':
      default:
        return Colors.blue;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'info':
      default:
        return Icons.info;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });
}

mixin PaginationMixin<T extends StatefulWidget> on State<T> {
  final List<dynamic> items = [];
  final ScrollController scrollController = ScrollController();
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  bool isRefreshing = false;

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

  void initPagination() {
    items.clear();
    currentPage = 1;
    hasMore = true;
  }

  void _onScroll() {
    if (!isLoading &&
        hasMore &&
        scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  Future<void> loadMore() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    try {
      final result = await fetchPage(currentPage);

      setState(() {
        items.addAll(result.items);
        hasMore = result.hasMore;
        currentPage++;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> refresh() async {
    setState(() {
      isRefreshing = true;
      currentPage = 1;
      hasMore = true;
    });

    try {
      final result = await fetchPage(1);

      setState(() {
        items.clear();
        items.addAll(result.items);
        hasMore = result.hasMore;
        currentPage = 2;
        isRefreshing = false;
      });
    } catch (e) {
      setState(() {
        isRefreshing = false;
      });
    }
  }

  Future<PaginationResult> fetchPage(int page);
}

class PaginationResult {
  final List<dynamic> items;
  final bool hasMore;

  PaginationResult({
    required this.items,
    required this.hasMore,
  });
}