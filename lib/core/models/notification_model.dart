// lib/core/models/notification_model.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // 🟢 Icons, Colors, VoidCallback এর জন্য

enum NotificationType {
  gift,
  message,
  friendRequest,
  friendAccept,
  call,
  game,
  pk,
  clan,
  levelUp,
  achievement,
  event,
  system,
  promotion,
  reminder
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent
}

class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final NotificationPriority priority;
  final String title;
  final String body;
  final String? imageUrl;
  final String? deepLink; // navigation link
  final Map<String, dynamic> data; // additional data
  final bool isRead;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String? actionButton;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.priority,
    required this.title,
    required this.body,
    required this.createdAt,
    this.imageUrl,
    this.deepLink,
    this.data = const {},
    this.isRead = false,
    this.isArchived = false,
    this.expiresAt,
    this.actionButton,
    this.onAction,
    this.onDismiss,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: NotificationType.values[json['type'] ?? 0],
      priority: NotificationPriority.values[json['priority'] ?? 1],
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      imageUrl: json['imageUrl'],
      deepLink: json['deepLink'],
      data: json['data'] ?? {},
      isRead: json['isRead'] ?? false,
      isArchived: json['isArchived'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
      actionButton: json['actionButton'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.index,
      'priority': priority.index,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'deepLink': deepLink,
      'data': data,
      'isRead': isRead,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'actionButton': actionButton,
    };
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  IconData get icon {
    switch (type) {
      case NotificationType.gift:
        return Icons.card_giftcard;
      case NotificationType.message:
        return Icons.message;
      case NotificationType.friendRequest:
        return Icons.person_add;
      case NotificationType.friendAccept:
        return Icons.people;
      case NotificationType.call:
        return Icons.call;
      case NotificationType.game:
        return Icons.sports_esports;
      case NotificationType.pk:
        return Icons.emoji_events;
      case NotificationType.clan:
        return Icons.group;
      case NotificationType.levelUp:
        return Icons.trending_up;
      case NotificationType.achievement:
        return Icons.emoji_events;
      case NotificationType.event:
        return Icons.event;
      case NotificationType.system:
        return Icons.info;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.reminder:
        return Icons.alarm;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.gift:
        return Colors.purple;
      case NotificationType.message:
        return Colors.blue;
      case NotificationType.friendRequest:
        return Colors.green;
      case NotificationType.friendAccept:
        return Colors.teal;
      case NotificationType.call:
        return Colors.red;
      case NotificationType.game:
        return Colors.orange;
      case NotificationType.pk:
        return Colors.amber;
      case NotificationType.clan:
        return Colors.indigo;
      case NotificationType.levelUp:
        return Colors.cyan;
      case NotificationType.achievement:
        return Colors.pink;
      case NotificationType.event:
        return Colors.deepPurple;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.promotion:
        return Colors.lime;
      case NotificationType.reminder:
        return Colors.brown;
    }
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    NotificationPriority? priority,
    String? title,
    String? body,
    String? imageUrl,
    String? deepLink,
    Map<String, dynamic>? data,
    bool? isRead,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? actionButton,
    VoidCallback? onAction,
    VoidCallback? onDismiss,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      deepLink: deepLink ?? this.deepLink,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      actionButton: actionButton ?? this.actionButton,
      onAction: onAction ?? this.onAction,
      onDismiss: onDismiss ?? this.onDismiss,
    );
  }
}

class NotificationSettings {
  final bool enablePush;
  final bool enableEmail;
  final bool enableSound;
  final bool enableVibration;
  final bool enableLed;
  final String sound;
  final Map<NotificationType, bool> typeSettings;

  NotificationSettings({
    this.enablePush = true,
    this.enableEmail = false,
    this.enableSound = true,
    this.enableVibration = true,
    this.enableLed = true,
    this.sound = 'default',
    Map<NotificationType, bool>? typeSettings,
  }) : typeSettings = typeSettings ?? _defaultTypeSettings();

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    final typeSettings = <NotificationType, bool>{};
    if (json['typeSettings'] != null) {
      (json['typeSettings'] as Map).forEach((key, value) {
        typeSettings[NotificationType.values[int.parse(key)]] = value as bool;
      });
    }

    return NotificationSettings(
      enablePush: json['enablePush'] ?? true,
      enableEmail: json['enableEmail'] ?? false,
      enableSound: json['enableSound'] ?? true,
      enableVibration: json['enableVibration'] ?? true,
      enableLed: json['enableLed'] ?? true,
      sound: json['sound'] ?? 'default',
      typeSettings: typeSettings,
    );
  }

  static Map<NotificationType, bool> _defaultTypeSettings() {
    return {
      NotificationType.gift: true,
      NotificationType.message: true,
      NotificationType.friendRequest: true,
      NotificationType.friendAccept: true,
      NotificationType.call: true,
      NotificationType.game: true,
      NotificationType.pk: true,
      NotificationType.clan: true,
      NotificationType.levelUp: true,
      NotificationType.achievement: true,
      NotificationType.event: true,
      NotificationType.system: true,
      NotificationType.promotion: false,
      NotificationType.reminder: true,
    };
  }

  Map<String, dynamic> toJson() {
    final Map<String, bool> typeSettingsJson = {};
    typeSettings.forEach((NotificationType key, bool value) {
      typeSettingsJson[key.index.toString()] = value;
    });

    return {
      'enablePush': enablePush,
      'enableEmail': enableEmail,
      'enableSound': enableSound,
      'enableVibration': enableVibration,
      'enableLed': enableLed,
      'sound': sound,
      'typeSettings': typeSettingsJson,
    };
  }

  bool isEnabled(NotificationType type) {
    return typeSettings[type] ?? true;
  }

  NotificationSettings copyWith({
    bool? enablePush,
    bool? enableEmail,
    bool? enableSound,
    bool? enableVibration,
    bool? enableLed,
    String? sound,
    Map<NotificationType, bool>? typeSettings,
  }) {
    return NotificationSettings(
      enablePush: enablePush ?? this.enablePush,
      enableEmail: enableEmail ?? this.enableEmail,
      enableSound: enableSound ?? this.enableSound,
      enableVibration: enableVibration ?? this.enableVibration,
      enableLed: enableLed ?? this.enableLed,
      sound: sound ?? this.sound,
      typeSettings: typeSettings ?? this.typeSettings,
    );
  }
}

class NotificationBadge {
  final int count;
  final bool showDot;

  NotificationBadge({
    required this.count,
    this.showDot = false,
  });

  factory NotificationBadge.fromJson(Map<String, dynamic> json) {
    return NotificationBadge(
      count: json['count'] ?? 0,
      showDot: json['showDot'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'showDot': showDot,
    };
  }

  NotificationBadge copyWith({
    int? count,
    bool? showDot,
  }) {
    return NotificationBadge(
      count: count ?? this.count,
      showDot: showDot ?? this.showDot,
    );
  }
}