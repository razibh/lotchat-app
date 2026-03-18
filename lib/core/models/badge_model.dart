import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

enum BadgeType {
  vip,
  svip,
  fan,
  event,
  official,
  agency,
  host,
  moderator,
  streamer,
}

// 🟢 দ্বিতীয় ফাইল থেকে যোগ করা হয়েছে
enum BadgeRarity { common, rare, epic, legendary, limited }

class BadgeModel {
  final String id;
  final String name;
  final String description; // 🟢 দ্বিতীয় ফাইল থেকে
  final BadgeType type;
  final int tier; // 1-10 for VIP, 1-8 for SVIP
  final String svgPath; // assets/badges/vip1.svg
  final String? animationPath; // assets/badges/vip1.json (optional)
  final Map<String, dynamic> requirements; // coins spent, gifts sent etc.
  final int expiryDays; // 0 = permanent
  final BadgeRarity rarity; // 🟢 দ্বিতীয় ফাইল থেকে
  final int? level; // 🟢 দ্বিতীয় ফাইল থেকে
  final bool isHidden; // 🟢 দ্বিতীয় ফাইল থেকে
  final DateTime? acquiredAt; // 🟢 দ্বিতীয় ফাইল থেকে
  final bool isEquipped; // 🟢 দ্বিতীয় ফাইল থেকে

  // Additional fields
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final Map<String, dynamic>? metadata;

  BadgeModel({
    required this.id,
    required this.name,
    required this.description, // 🟢 required করা হয়েছে
    required this.type,
    required this.tier,
    required this.svgPath,
    this.animationPath,
    this.requirements = const {},
    this.expiryDays = 0,
    this.rarity = BadgeRarity.common, // 🟢 ডিফল্ট ভ্যালু
    this.level,
    this.isHidden = false,
    this.acquiredAt,
    this.isEquipped = false,
    this.isActive = true,
    this.createdAt,
    this.expiresAt,
    this.metadata,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '', // 🟢 যোগ করা হয়েছে
      type: _parseBadgeType(json['type']),
      tier: json['tier'] ?? 1,
      svgPath: json['svgPath'] ?? '',
      animationPath: json['animationPath'],
      requirements: json['requirements'] ?? {},
      expiryDays: json['expiryDays'] ?? 0,
      rarity: _parseBadgeRarity(json['rarity']), // 🟢 যোগ করা হয়েছে
      level: json['level'],
      isHidden: json['isHidden'] ?? false,
      acquiredAt: json['acquiredAt'] != null
          ? DateTime.parse(json['acquiredAt'])
          : null,
      isEquipped: json['isEquipped'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
      metadata: json['metadata'],
    );
  }

  static BadgeType _parseBadgeType(String? type) {
    if (type == null) return BadgeType.fan;
    switch (type.toLowerCase()) {
      case 'vip':
        return BadgeType.vip;
      case 'svip':
        return BadgeType.svip;
      case 'fan':
        return BadgeType.fan;
      case 'event':
        return BadgeType.event;
      case 'official':
        return BadgeType.official;
      case 'agency':
        return BadgeType.agency;
      case 'host':
        return BadgeType.host;
      case 'moderator':
        return BadgeType.moderator;
      case 'streamer':
        return BadgeType.streamer;
      default:
        return BadgeType.fan;
    }
  }

  // 🟢 দ্বিতীয় ফাইল থেকে যোগ করা হয়েছে
  static BadgeRarity _parseBadgeRarity(dynamic rarity) {
    if (rarity == null) return BadgeRarity.common;
    if (rarity is int) {
      return BadgeRarity.values[rarity];
    }
    if (rarity is String) {
      switch (rarity.toLowerCase()) {
        case 'common':
          return BadgeRarity.common;
        case 'rare':
          return BadgeRarity.rare;
        case 'epic':
          return BadgeRarity.epic;
        case 'legendary':
          return BadgeRarity.legendary;
        case 'limited':
          return BadgeRarity.limited;
        default:
          return BadgeRarity.common;
      }
    }
    return BadgeRarity.common;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description, // 🟢 যোগ করা হয়েছে
      'type': type.toString().split('.').last,
      'tier': tier,
      'svgPath': svgPath,
      'animationPath': animationPath,
      'requirements': requirements,
      'expiryDays': expiryDays,
      'rarity': rarity.index, // 🟢 যোগ করা হয়েছে
      'level': level,
      'isHidden': isHidden,
      'acquiredAt': acquiredAt?.toIso8601String(),
      'isEquipped': isEquipped,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  BadgeModel copyWith({
    String? id,
    String? name,
    String? description, // 🟢 যোগ করা হয়েছে
    BadgeType? type,
    int? tier,
    String? svgPath,
    String? animationPath,
    Map<String, dynamic>? requirements,
    int? expiryDays,
    BadgeRarity? rarity, // 🟢 যোগ করা হয়েছে
    int? level,
    bool? isHidden,
    DateTime? acquiredAt,
    bool? isEquipped,
    bool? isActive,
    DateTime? createdAt,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) {
    return BadgeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description, // 🟢 যোগ করা হয়েছে
      type: type ?? this.type,
      tier: tier ?? this.tier,
      svgPath: svgPath ?? this.svgPath,
      animationPath: animationPath ?? this.animationPath,
      requirements: requirements ?? this.requirements,
      expiryDays: expiryDays ?? this.expiryDays,
      rarity: rarity ?? this.rarity, // 🟢 যোগ করা হয়েছে
      level: level ?? this.level,
      isHidden: isHidden ?? this.isHidden,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      isEquipped: isEquipped ?? this.isEquipped,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper getters
  bool get isPermanent => expiryDays == 0;

  bool get isExpired {
    if (isPermanent) return false;
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isAcquired => acquiredAt != null; // 🟢 দ্বিতীয় ফাইল থেকে

  String get tierName {
    switch (type) {
      case BadgeType.vip:
        return 'VIP $tier';
      case BadgeType.svip:
        return 'SVIP $tier';
      case BadgeType.fan:
        return 'Fan $tier';
      case BadgeType.event:
        return 'Event $tier';
      case BadgeType.official:
        return 'Official';
      case BadgeType.agency:
        return 'Agency';
      case BadgeType.host:
        return 'Host';
      case BadgeType.moderator:
        return 'Moderator';
      case BadgeType.streamer:
        return 'Streamer';
    }
  }

  // 🟢 দ্বিতীয় ফাইল থেকে যোগ করা হয়েছে
  Color get rarityColor {
    switch (rarity) {
      case BadgeRarity.common:
        return const Color(0xFF6B7280);
      case BadgeRarity.rare:
        return const Color(0xFF3B82F6);
      case BadgeRarity.epic:
        return const Color(0xFF8B5CF6);
      case BadgeRarity.legendary:
        return const Color(0xFFF59E0B);
      case BadgeRarity.limited:
        return const Color(0xFFEF4444);
    }
  }

  // Check if badge meets requirements
  bool meetsRequirements(Map<String, dynamic> userStats) {
    for (var entry in requirements.entries) {
      if (!userStats.containsKey(entry.key)) return false;
      if (userStats[entry.key] < entry.value) return false;
    }
    return true;
  }

  // Get badge color based on type
  Color? get badgeColor {
    switch (type) {
      case BadgeType.vip:
        return const Color(0xFFFBBF24); // Gold
      case BadgeType.svip:
        return const Color(0xFF8B5CF6); // Purple
      case BadgeType.fan:
        return const Color(0xFFEC4899); // Pink
      case BadgeType.event:
        return const Color(0xFFF59E0B); // Orange
      case BadgeType.official:
        return const Color(0xFF3B82F6); // Blue
      case BadgeType.agency:
        return const Color(0xFF9C27B0); // Purple
      case BadgeType.host:
        return const Color(0xFFE91E63); // Pink
      case BadgeType.moderator:
        return const Color(0xFF4CAF50); // Green
      case BadgeType.streamer:
        return const Color(0xFF673AB7); // Deep Purple
    }
  }

  @override
  String toString() {
    return 'BadgeModel(id: $id, name: $name, type: $type, tier: $tier, rarity: $rarity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BadgeModel &&
        other.id == id &&
        other.type == type &&
        other.tier == tier;
  }

  @override
  int get hashCode => Object.hash(id, type, tier);
}

// 🟢 UserBadge ক্লাস দ্বিতীয় ফাইল থেকে নেওয়া হয়েছে
class UserBadge {
  final String badgeId;
  final DateTime acquiredAt;
  final bool isEquipped;

  UserBadge({
    required this.badgeId,
    required this.acquiredAt,
    this.isEquipped = false,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      badgeId: json['badgeId'] ?? '',
      acquiredAt: DateTime.parse(json['acquiredAt'] ?? DateTime.now().toIso8601String()),
      isEquipped: json['isEquipped'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'badgeId': badgeId,
      'acquiredAt': acquiredAt.toIso8601String(),
      'isEquipped': isEquipped,
    };
  }

  UserBadge copyWith({
    String? badgeId,
    DateTime? acquiredAt,
    bool? isEquipped,
  }) {
    return UserBadge(
      badgeId: badgeId ?? this.badgeId,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      isEquipped: isEquipped ?? this.isEquipped,
    );
  }
}