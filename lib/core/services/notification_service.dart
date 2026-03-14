import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      // Request permissions
      await _fcm.requestPermission(
        badge: true,
      );

      // Get FCM token
      final String? token = await _fcm.getToken();
      debugPrint('FCM Token: $token');

      // Initialize local notifications - সঠিক syntax
      AndroidInitializationSettings initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');

      DarwinInitializationSettings initializationSettingsIOS =
      const DarwinInitializationSettings();

      InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(initializationSettings);

      // Handle messages
      FirebaseMessaging.onMessage.listen(_handleMessage);
      FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

      debugPrint('✅ NotificationService initialized');
    } catch (e) {
      debugPrint('❌ Error initializing NotificationService: $e');
    }
  }

  void _handleMessage(RemoteMessage message) {
    try {
      final RemoteNotification? notification = message.notification;
      if (notification != null) {
        _showLocalNotification(
          title: notification.title ?? '',
          body: notification.body ?? '',
        );
      }
    } catch (e) {
      debugPrint('Error handling message: $e');
    }
  }

  static Future<void> _backgroundHandler(RemoteMessage message) async {
    debugPrint('Background message: ${message.messageId}');
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    try {
      // Android notification details - সঠিক syntax
      AndroidNotificationDetails androidDetails = const AndroidNotificationDetails(
        'default_channel',
        'Default Channel',
        importance: Importance.high,
        priority: Priority.high,
      );

      DarwinNotificationDetails iosDetails = const DarwinNotificationDetails();

      NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        0,  // id
        title,
        body,
        details,
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  // sendNotification method - PK Service এর জন্য
  Future<void> sendNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      await _showLocalNotification(
        title: title,
        body: body,
      );
      debugPrint('📱 Notification sent to $userId: $title');
    } catch (e) {
      debugPrint('Error sending notification: $e');
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