import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  bool _isInitialized = false;
  bool _hasUnread = false;
  int _unreadCount = 0;
  String? _lastNotification;
  StreamSubscription? _messageSubscription;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get hasUnread => _hasUnread;
  int get unreadCount => _unreadCount;
  String? get lastNotification => _lastNotification;

  Future<void> initialize() async {
    try {
      await _notificationService.initialize();

      // Listen to foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleMessage(message);
      });

      // Listen to when app is opened from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleMessage(message);
      });

      // Get initial message if app was opened from terminated state
      final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleMessage(initialMessage);
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      _isInitialized = false;
    }
  }

  void _handleMessage(RemoteMessage message) {
    _lastNotification = message.notification?.title;
    _unreadCount++;
    _hasUnread = true;
    notifyListeners();
  }

  void markAllAsRead() {
    _unreadCount = 0;
    _hasUnread = false;
    notifyListeners();
  }

  void clearLastNotification() {
    _lastNotification = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}