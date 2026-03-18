// lib/core/models/user_roles.dart

import 'package:flutter/material.dart'; // 🟢 Color এবং Colors এর জন্য

enum UserRole {
  user,
  host,
  agency,
  countryManager,
  coinSeller,
  admin,
}

enum BadgeType {
  none,
  agency,
  coinSeller,
  official,
  vip,
  svip,
  moderator,
  streamer,
  event,
  special,
}

class UserBadge {
  final BadgeType type;
  final String? agencyId;
  final String? sellerId;
  final DateTime? assignedAt;
  final bool isVerified;
  final String? description;
  final String? imageUrl;
  final int? tier;
  final DateTime? expiresAt;
  final Map<String, dynamic>? metadata;

  UserBadge({
    required this.type,
    this.agencyId,
    this.sellerId,
    this.assignedAt,
    this.isVerified = false,
    this.description,
    this.imageUrl,
    this.tier,
    this.expiresAt,
    this.metadata,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      type: _parseBadgeType(json['type']),
      agencyId: json['agencyId'],
      sellerId: json['sellerId'],
      assignedAt: json['assignedAt'] != null
          ? DateTime.parse(json['assignedAt'])
          : null,
      isVerified: json['isVerified'] ?? false,
      description: json['description'],
      imageUrl: json['imageUrl'],
      tier: json['tier'],
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
      metadata: json['metadata'],
    );
  }

  static BadgeType _parseBadgeType(String? type) {
    if (type == null) return BadgeType.none;
    switch (type.toLowerCase()) {
      case 'agency':
        return BadgeType.agency;
      case 'coinseller':
      case 'coin_seller':
        return BadgeType.coinSeller;
      case 'official':
        return BadgeType.official;
      case 'vip':
        return BadgeType.vip;
      case 'svip':
        return BadgeType.svip;
      case 'moderator':
        return BadgeType.moderator;
      case 'streamer':
        return BadgeType.streamer;
      case 'event':
        return BadgeType.event;
      case 'special':
        return BadgeType.special;
      default:
        return BadgeType.none;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'agencyId': agencyId,
      'sellerId': sellerId,
      'assignedAt': assignedAt?.toIso8601String(),
      'isVerified': isVerified,
      'description': description,
      'imageUrl': imageUrl,
      'tier': tier,
      'expiresAt': expiresAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  UserBadge copyWith({
    BadgeType? type,
    String? agencyId,
    String? sellerId,
    DateTime? assignedAt,
    bool? isVerified,
    String? description,
    String? imageUrl,
    int? tier,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserBadge(
      type: type ?? this.type,
      agencyId: agencyId ?? this.agencyId,
      sellerId: sellerId ?? this.sellerId,
      assignedAt: assignedAt ?? this.assignedAt,
      isVerified: isVerified ?? this.isVerified,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      tier: tier ?? this.tier,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get hasBadge => type != BadgeType.none;

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  String get badgeName {
    switch (type) {
      case BadgeType.agency:
        return 'Official Agency';
      case BadgeType.coinSeller:
        return 'Coin Seller';
      case BadgeType.official:
        return 'Official';
      case BadgeType.vip:
        return 'VIP';
      case BadgeType.svip:
        return 'SVIP';
      case BadgeType.moderator:
        return 'Moderator';
      case BadgeType.streamer:
        return 'Streamer';
      case BadgeType.event:
        return 'Event';
      case BadgeType.special:
        return 'Special';
      default:
        return '';
    }
  }

  Color get badgeColor {
    switch (type) {
      case BadgeType.agency:
        return const Color(0xFF9C27B0); // Purple
      case BadgeType.coinSeller:
        return const Color(0xFFFF9800); // Orange
      case BadgeType.official:
        return const Color(0xFF2196F3); // Blue
      case BadgeType.vip:
        return const Color(0xFFF44336); // Red
      case BadgeType.svip:
        return const Color(0xFF8B5CF6); // Light Purple
      case BadgeType.moderator:
        return const Color(0xFF4CAF50); // Green
      case BadgeType.streamer:
        return const Color(0xFFE91E63); // Pink
      case BadgeType.event:
        return const Color(0xFFFFC107); // Amber
      case BadgeType.special:
        return const Color(0xFF673AB7); // Deep Purple
      default:
        return Colors.grey;
    }
  }

  IconData? get badgeIcon {
    switch (type) {
      case BadgeType.agency:
        return Icons.business;
      case BadgeType.coinSeller:
        return Icons.monetization_on;
      case BadgeType.official:
        return Icons.verified;
      case BadgeType.vip:
        return Icons.star;
      case BadgeType.svip:
        return Icons.star_half;
      case BadgeType.moderator:
        return Icons.shield;
      case BadgeType.streamer:
        return Icons.videocam;
      case BadgeType.event:
        return Icons.event;
      case BadgeType.special:
        return Icons.emoji_events;
      default:
        return null;
    }
  }

  String get badgeDescription {
    if (description != null) return description!;

    switch (type) {
      case BadgeType.agency:
        return 'Official agency badge';
      case BadgeType.coinSeller:
        return 'Verified coin seller';
      case BadgeType.official:
        return 'Official verified account';
      case BadgeType.vip:
        return 'Very Important Person';
      case BadgeType.svip:
        return 'Super VIP member';
      case BadgeType.moderator:
        return 'Room moderator';
      case BadgeType.streamer:
        return 'Live streamer';
      case BadgeType.event:
        return 'Event participant';
      case BadgeType.special:
        return 'Special achievement';
      default:
        return '';
    }
  }
}

class UserPermissions {
  static const Map<UserRole, List<String>> rolePermissions = {
    UserRole.admin: [
      'manage_users',
      'manage_rooms',
      'manage_gifts',
      'manage_games',
      'manage_reports',
      'manage_agencies',
      'manage_sellers',
      'manage_system',
      'view_analytics',
      'manage_settings',
    ],
    UserRole.countryManager: [
      'manage_agencies',
      'manage_hosts',
      'view_reports',
      'manage_country',
      'view_analytics',
    ],
    UserRole.agency: [
      'manage_hosts',
      'view_earnings',
      'manage_commission',
      'recruit_hosts',
    ],
    UserRole.coinSeller: [
      'manage_packages',
      'view_sales',
      'manage_inventory',
      'view_earnings',
    ],
    UserRole.host: [
      'manage_rooms',
      'view_earnings',
      'manage_schedule',
      'view_analytics',
    ],
    UserRole.user: [
      'view_rooms',
      'send_messages',
      'send_gifts',
      'play_games',
      'join_clans',
    ],
  };

  static bool hasPermission(UserRole role, String permission) {
    final permissions = rolePermissions[role];
    return permissions?.contains(permission) ?? false;
  }

  static List<String> getPermissions(UserRole role) {
    return rolePermissions[role] ?? [];
  }
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.user:
        return 'User';
      case UserRole.host:
        return 'Host';
      case UserRole.agency:
        return 'Agency';
      case UserRole.countryManager:
        return 'Country Manager';
      case UserRole.coinSeller:
        return 'Coin Seller';
      case UserRole.admin:
        return 'Admin';
    }
  }

  Color get roleColor {
    switch (this) {
      case UserRole.user:
        return Colors.grey;
      case UserRole.host:
        return Colors.blue;
      case UserRole.agency:
        return Colors.purple;
      case UserRole.countryManager:
        return Colors.orange;
      case UserRole.coinSeller:
        return Colors.green;
      case UserRole.admin:
        return Colors.red;
    }
  }

  int get priority {
    switch (this) {
      case UserRole.user:
        return 1;
      case UserRole.host:
        return 2;
      case UserRole.agency:
        return 3;
      case UserRole.coinSeller:
        return 3;
      case UserRole.countryManager:
        return 4;
      case UserRole.admin:
        return 5;
    }
  }

  bool canManage(UserRole other) {
    return priority > other.priority;
  }
}