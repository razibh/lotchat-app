import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/notification_service.dart';
import '../../mixins/pagination_mixin.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/animation/fade_animation.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> 
    with PaginationMixin<Map<String, dynamic>> {
  
  final _notificationService = ServiceLocator().get<NotificationService>();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    initPagination();
    loadMore();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPage(int page) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return List.generate(20, (index) {
      final type = index % 5;
      return {
        'id': 'notif_$index',
        'type': _getNotificationType(type),
        'icon': _getNotificationIcon(type),
        'color': _getNotificationColor(type),
        'title': _getNotificationTitle(type, index),
        'body': _getNotificationBody(type, index),
        'time': DateTime.now().subtract(Duration(minutes: index * 30)),
        'isRead': index % 3 == 0,
        'data': {},
      };
    });
  }

  String _getNotificationType(int type) {
    switch (type) {
      case 0: return 'gift';
      case 1: return 'like';
      case 2: return 'comment';
      case 3: return 'friend';
      case 4: return 'system';
      default: return 'other';
    }
  }

  IconData _getNotificationIcon(int type) {
    switch (type) {
      case 0: return Icons.card_giftcard;
      case 1: return Icons.favorite;
      case 2: return Icons.comment;
      case 3: return Icons.person_add;
      case 4: return Icons.info;
      default: return Icons.notifications;
    }
  }

  Color _getNotificationColor(int type) {
    switch (type) {
      case 0: return Colors.purple;
      case 1: return Colors.red;
      case 2: return Colors.blue;
      case 3: return Colors.green;
      case 4: return Colors.orange;
      default: return Colors.grey;
    }
  }

  String _getNotificationTitle(int type, int index) {
    switch (type) {
      case 0: return 'Gift Received';
      case 1: return 'New Like';
      case 2: return 'New Comment';
      case 3: return 'Friend Request';
      case 4: return 'System Update';
      default: return 'Notification';
    }
  }

  String _getNotificationBody(int type, int index) {
    switch (type) {
      case 0: return 'User${index + 1} sent you a gift';
      case 1: return 'User${index + 1} liked your post';
      case 2: return 'User${index + 1} commented on your post';
      case 3: return 'User${index + 1} sent you a friend request';
      case 4: return 'App update available';
      default: return 'You have a new notification';
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

  void _markAsRead(String id) {
    setState(() {
      final index = items.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        items[index]['isRead'] = true;
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notif in items) {
        notif['isRead'] = true;
      }
    });
  }

  void _clearAll() {
    setState(() {
      items.clear();
    });
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilter == 'All') return items;
    return items.where((n) => n['type'] == _selectedFilter.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: _markAllAsRead,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearAll,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['All', 'Gift', 'Like', 'Comment', 'Friend', 'System']
                  .map((filter) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: _selectedFilter == filter,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          backgroundColor: Colors.white.withOpacity(0.2),
                          selectedColor: Colors.white,
                          labelStyle: TextStyle(
                            color: _selectedFilter == filter ? Colors.purple : Colors.white,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
      body: _filteredNotifications.isEmpty
          ? const EmptyStateWidget(
              title: 'No Notifications',
              message: 'You\'re all caught up!',
              icon: Icons.notifications_off,
            )
          : ListView.builder(
              controller: scrollController,
              itemCount: _filteredNotifications.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _filteredNotifications.length) {
                  return buildPaginationLoadingIndicator();
                }
                
                final notif = _filteredNotifications[index];
                return FadeAnimation(
                  child: Dismissible(
                    key: Key(notif['id']),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      setState(() {
                        items.removeWhere((n) => n['id'] == notif['id']);
                      });
                    },
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: notif['color'].withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          notif['icon'],
                          color: notif['color'],
                          size: 20,
                        ),
                      ),
                      title: Text(
                        notif['title'],
                        style: TextStyle(
                          fontWeight: notif['isRead'] ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(notif['body']),
                      trailing: Text(
                        _formatTime(notif['time']),
                        style: TextStyle(
                          color: notif['isRead'] ? Colors.grey : notif['color'],
                          fontSize: 12,
                        ),
                      ),
                      onTap: () {
                        _markAsRead(notif['id']);
                        _handleNotificationTap(notif);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notif) {
    switch (notif['type']) {
      case 'gift':
        // Navigate to gift receipt
        break;
      case 'friend':
        // Navigate to friend request
        break;
      case 'like':
      case 'comment':
        // Navigate to post
        break;
      case 'system':
        // Show system message
        break;
    }
  }
}