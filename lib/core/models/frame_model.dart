import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'user_models.dart'; // UserTier এর জন্য

enum FrameRarity { common, rare, epic, legendary, limited }
enum FrameType { basic, vip, svip, event, animated }

class FrameModel {
  final String id;
  final String name;
  final String description;
  final FrameRarity rarity;
  final FrameType type;
  final String imageUrl;
  final String? thumbnailUrl;
  final String? animationUrl;
  final int price;
  final bool isPurchased;
  final bool isEquipped;
  final DateTime? availableUntil;
  final Map<String, dynamic> requirements;
  final UserTier? requiredTier;
  final bool isAnimated;
  final Color? borderColor;
  final double borderWidth;
  final bool isLimited;
  final int maxQuantity;
  final int currentQuantity;
  final List<String>? tags;
  final DateTime? createdAt;
  final bool isActive;

  FrameModel({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.type,
    required this.imageUrl,
    required this.price,
    this.thumbnailUrl,
    this.animationUrl,
    this.isPurchased = false,
    this.isEquipped = false,
    this.availableUntil,
    this.requirements = const {},
    this.requiredTier,
    this.isAnimated = false,
    this.borderColor,
    this.borderWidth = 2.0,
    this.isLimited = false,
    this.maxQuantity = 0,
    this.currentQuantity = 0,
    this.tags,
    this.createdAt,
    this.isActive = true,
  });

  factory FrameModel.fromJson(Map<String, dynamic> json) {
    return FrameModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      rarity: _parseFrameRarity(json['rarity']),
      type: _parseFrameType(json['type']),
      imageUrl: json['imageUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      animationUrl: json['animationUrl'],
      price: json['price'] ?? 0,
      isPurchased: json['isPurchased'] ?? false,
      isEquipped: json['isEquipped'] ?? false,
      availableUntil: json['availableUntil'] != null
          ? DateTime.parse(json['availableUntil'])
          : null,
      requirements: json['requirements'] ?? {},
      requiredTier: json['requiredTier'] != null
          ? _parseUserTier(json['requiredTier'])
          : null,
      isAnimated: json['isAnimated'] ?? false,
      borderColor: json['borderColor'] != null
          ? Color(json['borderColor'])
          : null,
      borderWidth: (json['borderWidth'] ?? 2.0).toDouble(),
      isLimited: json['isLimited'] ?? false,
      maxQuantity: json['maxQuantity'] ?? 0,
      currentQuantity: json['currentQuantity'] ?? 0,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  static FrameRarity _parseFrameRarity(dynamic rarity) {
    if (rarity == null) return FrameRarity.common;
    if (rarity is int) {
      return FrameRarity.values[rarity];
    }
    if (rarity is String) {
      switch (rarity.toLowerCase()) {
        case 'common':
          return FrameRarity.common;
        case 'rare':
          return FrameRarity.rare;
        case 'epic':
          return FrameRarity.epic;
        case 'legendary':
          return FrameRarity.legendary;
        case 'limited':
          return FrameRarity.limited;
        default:
          return FrameRarity.common;
      }
    }
    return FrameRarity.common;
  }

  static FrameType _parseFrameType(dynamic type) {
    if (type == null) return FrameType.basic;
    if (type is int) {
      return FrameType.values[type];
    }
    if (type is String) {
      switch (type.toLowerCase()) {
        case 'basic':
          return FrameType.basic;
        case 'vip':
          return FrameType.vip;
        case 'svip':
          return FrameType.svip;
        case 'event':
          return FrameType.event;
        case 'animated':
          return FrameType.animated;
        default:
          return FrameType.basic;
      }
    }
    return FrameType.basic;
  }

  static UserTier? _parseUserTier(dynamic tier) {
    if (tier == null) return null;
    if (tier is int) {
      return UserTier.values[tier];
    }
    if (tier is String) {
      switch (tier.toLowerCase()) {
        case 'vip':
          return UserTier.vip;
        case 'svip':
          return UserTier.svip;
        case 'normal':
          return UserTier.normal;
        default:
          return UserTier.normal;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'rarity': rarity.index,
      'type': type.index,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'animationUrl': animationUrl,
      'price': price,
      'isPurchased': isPurchased,
      'isEquipped': isEquipped,
      'availableUntil': availableUntil?.toIso8601String(),
      'requirements': requirements,
      'requiredTier': requiredTier?.index,
      'isAnimated': isAnimated,
      'borderColor': borderColor?.value,
      'borderWidth': borderWidth,
      'isLimited': isLimited,
      'maxQuantity': maxQuantity,
      'currentQuantity': currentQuantity,
      'tags': tags,
      'createdAt': createdAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  FrameModel copyWith({
    String? id,
    String? name,
    String? description,
    FrameRarity? rarity,
    FrameType? type,
    String? imageUrl,
    String? thumbnailUrl,
    String? animationUrl,
    int? price,
    bool? isPurchased,
    bool? isEquipped,
    DateTime? availableUntil,
    Map<String, dynamic>? requirements,
    UserTier? requiredTier,
    bool? isAnimated,
    Color? borderColor,
    double? borderWidth,
    bool? isLimited,
    int? maxQuantity,
    int? currentQuantity,
    List<String>? tags,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return FrameModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      rarity: rarity ?? this.rarity,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      animationUrl: animationUrl ?? this.animationUrl,
      price: price ?? this.price,
      isPurchased: isPurchased ?? this.isPurchased,
      isEquipped: isEquipped ?? this.isEquipped,
      availableUntil: availableUntil ?? this.availableUntil,
      requirements: requirements ?? this.requirements,
      requiredTier: requiredTier ?? this.requiredTier,
      isAnimated: isAnimated ?? this.isAnimated,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      isLimited: isLimited ?? this.isLimited,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Color getters
  Color get rarityColor {
    switch (rarity) {
      case FrameRarity.common:
        return const Color(0xFF6B7280);
      case FrameRarity.rare:
        return const Color(0xFF3B82F6);
      case FrameRarity.epic:
        return const Color(0xFF8B5CF6);
      case FrameRarity.legendary:
        return const Color(0xFFF59E0B);
      case FrameRarity.limited:
        return const Color(0xFFEF4444);
    }
  }

  // Boolean getters
  bool get isAvailable {
    if (!isActive) return false;
    if (availableUntil != null && DateTime.now().isAfter(availableUntil!)) {
      return false;
    }
    if (isLimited && currentQuantity >= maxQuantity) {
      return false;
    }
    return true;
  }

  bool get isExpired {
    if (availableUntil == null) return false;
    return DateTime.now().isAfter(availableUntil!);
  }

  bool get isLimitedTime => availableUntil != null;

  bool get isPurchasable => price > 0 && !isPurchased;

  bool get isTaskReward => requirements.isNotEmpty;

  // Price display
  String get priceDisplay {
    if (isPurchased) return 'Owned';
    if (price > 0) return '$price coins';
    return 'Free';
  }

  // Check if user meets tier requirement
  bool meetsTierRequirement(UserTier? userTier) {
    if (requiredTier == null) return true;
    if (userTier == null) return false;

    // Tier comparison logic
    return userTier.index >= requiredTier!.index;
  }

  // Check if user meets all requirements
  bool meetsAllRequirements(UserTier? userTier, Map<String, dynamic> userStats) {
    if (!meetsTierRequirement(userTier)) return false;

    for (var entry in requirements.entries) {
      if (!userStats.containsKey(entry.key)) return false;
      if (userStats[entry.key] < entry.value) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'FrameModel(id: $id, name: $name, rarity: $rarity, type: $type, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FrameModel &&
        other.id == id &&
        other.name == name &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(id, name, type);
}

class UserFrame {
  final String frameId;
  final DateTime acquiredAt;
  final bool isEquipped;

  UserFrame({
    required this.frameId,
    required this.acquiredAt,
    this.isEquipped = false,
  });

  factory UserFrame.fromJson(Map<String, dynamic> json) {
    return UserFrame(
      frameId: json['frameId'] ?? '',
      acquiredAt: DateTime.parse(json['acquiredAt'] ?? DateTime.now().toIso8601String()),
      isEquipped: json['isEquipped'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frameId': frameId,
      'acquiredAt': acquiredAt.toIso8601String(),
      'isEquipped': isEquipped,
    };
  }

  UserFrame copyWith({
    String? frameId,
    DateTime? acquiredAt,
    bool? isEquipped,
  }) {
    return UserFrame(
      frameId: frameId ?? this.frameId,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      isEquipped: isEquipped ?? this.isEquipped,
    );
  }
}