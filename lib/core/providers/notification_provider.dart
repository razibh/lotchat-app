import 'dart:async';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  bool _isInitialized = false;
  bool _hasUnread = false;
  int _unreadCount = 0;
  String? _lastNotification;
  List<Map<String, dynamic>> _notifications = [];

  // Getters
  bool get isInitialized => _isInitialized;
  bool get hasUnread => _hasUnread;
  int get unreadCount => _unreadCount;
  String? get lastNotification => _lastNotification;
  List<Map<String, dynamic>> get notifications => _notifications;

  Future<void> initialize() async {
    try {
      await _notificationService.initialize();

      // Load existing notifications from Supabase
      await loadNotifications();

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      _isInitialized = false;
    }
  }

  // Load notifications from Supabase
  Future<void> loadNotifications() async {
    try {
      _notifications = await _notificationService.getUserNotifications();
      _updateUnreadCount();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  // Handle new notification (called from NotificationService)
  void handleNewNotification(Map<String, dynamic> notification) {
    _notifications.insert(0, notification);
    _updateUnreadCount();
    _lastNotification = notification['title'];
    notifyListeners();
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => n['read'] == false).length;
    _hasUnread = _unreadCount > 0;
  }

  // Mark single notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);

      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['read'] = true;
      }

      _updateUnreadCount();
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();

      for (var notification in _notifications) {
        notification['read'] = true;
      }

      _unreadCount = 0;
      _hasUnread = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);

      _notifications.removeWhere((n) => n['id'] == notificationId);
      _updateUnreadCount();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      await _notificationService.clearAllNotifications();

      _notifications.clear();
      _unreadCount = 0;
      _hasUnread = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }

  void clearLastNotification() {
    _lastNotification = null;
    notifyListeners();
  }

  // Refresh notifications
  Future<void> refresh() async {
    await loadNotifications();
  }

  @override
  void dispose() {
    super.dispose();
  }
}