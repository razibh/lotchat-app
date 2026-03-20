import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../di/service_locator.dart';

class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();

  // Supabase client
  final SupabaseClient _supabase = getService<SupabaseClient>();

  // Local notifications
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      // Initialize local notifications only
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      debugPrint('✅ NotificationService initialized');
    } catch (e) {
      debugPrint('❌ Error initializing NotificationService: $e');
    }
  }

  // ==================== SHOW NOTIFICATION ====================

  /// Show local notification (used by friend_service)
  Future<void> showNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'default_channel',
        'Default Channel',
        channelDescription: 'Default notifications for LotChat',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
      );

      const iosDetails = DarwinNotificationDetails();

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique id
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: data != null ? json.encode(data) : null,
      );

      debugPrint('✅ Local notification shown: $title');

      // Save to database
      await _saveNotificationToDatabase(title, body, data);
    } catch (e) {
      debugPrint('❌ Error showing notification: $e');
    }
  }

  // ==================== DATABASE OPERATIONS ====================

  /// Save notification to database
  Future<void> _saveNotificationToDatabase(
      String title,
      String body,
      Map<String, dynamic>? data,
      ) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('notifications').insert({
        'user_id': user.id,
        'title': title,
        'body': body,
        'data': data ?? {},
        'type': data?['type'] ?? 'local',
        'read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error saving notification to database: $e');
    }
  }

  /// Get user's notifications
  Future<List<Map<String, dynamic>>> getUserNotifications() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(50);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting user notifications: $e');
      return [];
    }
  }

  /// Stream user's notifications (without Realtime)
  Stream<List<Map<String, dynamic>>> streamUserNotifications() {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return Stream.value([]);

      // Simple polling every 30 seconds (instead of realtime)
      return Stream.periodic(
        const Duration(seconds: 30),
            (_) => null,
      ).asyncMap((_) async {
        return await getUserNotifications();
      });
    } catch (e) {
      debugPrint('Error streaming notifications: $e');
      return Stream.value([]);
    }
  }

  /// Get unread count
  Future<int> getUnreadCount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return 0;

      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', user.id)
          .eq('read', false);

      return response.length;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({
        'read': true,
        'read_at': DateTime.now().toIso8601String()
      })
          .eq('id', notificationId);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase
          .from('notifications')
          .update({
        'read': true,
        'read_at': DateTime.now().toIso8601String()
      })
          .eq('user_id', user.id)
          .eq('read', false);
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase
          .from('notifications')
          .delete()
          .eq('user_id', user.id);
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }

  // ==================== NOTIFICATION TAP HANDLER ====================

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');

    if (response.payload != null) {
      try {
        final data = json.decode(response.payload!);
        _handleNavigation(data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  void _handleNavigation(Map<String, dynamic> data) {
    final type = data['type'];
    final targetId = data['targetId'];
    debugPrint('Navigate to: $type - $targetId');
    // Implement navigation logic here
  }

  // ==================== SETTINGS ====================

  /// Toggle notifications
  Future<void> toggleNotifications(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', enabled);
      debugPrint('Notifications toggled: $enabled');
    } catch (e) {
      debugPrint('Error toggling notifications: $e');
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('notifications_enabled') ?? true;
    } catch (e) {
      return true;
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }
}

// Notification types
enum NotificationType {
  gift,
  message,
  friendRequest,
  call,
  game,
  pk,
  system,
  promotion
}