import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../di/service_locator.dart';

class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final SupabaseClient _supabase = getService<SupabaseClient>();

  Future<void> initialize() async {
    try {
      // Request permissions
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ Push notification permission granted');
      } else {
        debugPrint('⚠️ Push notification permission denied');
      }

      // Get FCM token
      final String? token = await _fcm.getToken();
      debugPrint('📱 FCM Token: $token');

      // Save token to Supabase
      await _saveTokenToSupabase(token);

      // Initialize local notifications
      AndroidInitializationSettings initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');

      DarwinInitializationSettings initializationSettingsIOS =
      const DarwinInitializationSettings();

      InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleMessage);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

      // Handle when app opened from terminated state
      final RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationClick(initialMessage);
      }

      // Handle when app opened from background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);

      debugPrint('✅ NotificationService initialized');
    } catch (e) {
      debugPrint('❌ Error initializing NotificationService: $e');
    }
  }

  // Save FCM token to Supabase
  Future<void> _saveTokenToSupabase(String? token) async {
    if (token == null) return;

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase
          .from('user_devices')
          .upsert({
        'user_id': user.id,
        'fcm_token': token,
        'device_type': kIsWeb ? 'web' : (defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android'),
        'last_active': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ FCM token saved to Supabase');
    } catch (e) {
      debugPrint('❌ Error saving FCM token to Supabase: $e');
    }
  }

  void _handleMessage(RemoteMessage message) {
    try {
      debugPrint('📨 Foreground message: ${message.messageId}');
      _showLocalNotification(message);
      _saveNotificationToSupabase(message);
    } catch (e) {
      debugPrint('Error handling message: $e');
    }
  }

  static Future<void> _backgroundHandler(RemoteMessage message) async {
    debugPrint('📱 Background message: ${message.messageId}');

  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      if (notification == null) return;

      AndroidNotificationDetails androidDetails = const AndroidNotificationDetails(
        'default_channel',
        'Default Channel',
        channelDescription: 'Default notifications for LotChat',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
      );

      DarwinNotificationDetails iosDetails = const DarwinNotificationDetails();

      NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        details,
        payload: message.data.toString(),
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }

  void _handleNotificationClick(RemoteMessage message) {
    debugPrint('📱 App opened from notification: ${message.messageId}');
    // Handle navigation based on message.data
    _saveNotificationToSupabase(message);
  }

  // Save notification to Supabase for history
  Future<void> _saveNotificationToSupabase(RemoteMessage message) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('notifications').insert({
        'user_id': user.id,
        'title': message.notification?.title,
        'body': message.notification?.body,
        'data': message.data,
        'type': message.data['type'] ?? 'unknown',
        'read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error saving notification to Supabase: $e');
    }
  }

  // Get user's notifications from Supabase
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

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'read': true})
          .eq('id', notificationId);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase
          .from('notifications')
          .update({'read': true})
          .eq('user_id', user.id)
          .eq('read', false);
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  // Delete notification
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

  // Clear all notifications
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

  // Toggle notifications
  Future<void> toggleNotifications(bool enabled) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', enabled);
      debugPrint('Notifications toggled: $enabled');
    } catch (e) {
      debugPrint('Error toggling notifications: $e');
    }
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool('notifications_enabled') ?? true;
    } catch (e) {
      return true;
    }
  }

  // Cancel all notifications
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
  system
}