enum BadgeRarity { common, rare, epic, legendary, limited }
enum BadgeCategory { achievement, event, special, vip, svip }

class BadgeModel {

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.category,
    required this.iconUrl,
    this.animationUrl,
    this.acquiredAt,
    this.isEquipped = false,
    this.requirements = const {},
    this.level,
    this.isHidden = false,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      rarity: BadgeRarity.values[json['rarity']],
      category: BadgeCategory.values[json['category']],
      iconUrl: json['iconUrl'],
      animationUrl: json['animationUrl'],
      acquiredAt: json['acquiredAt'] != null 
          ? DateTime.parse(json['acquiredAt']) 
          : null,
      isEquipped: json['isEquipped'] ?? false,
      requirements: json['requirements'] ?? {},
      level: json['level'],
      isHidden: json['isHidden'] ?? false,
    );
  }
  final String id;
  final String name;
  final String description;
  final BadgeRarity rarity;
  final BadgeCategory category;
  final String iconUrl;
  final String? animationUrl;
  final DateTime? acquiredAt;
  final bool isEquipped;
  final Map<String, dynamic> requirements;
  final int? level;
  final bool isHidden;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'description': description,
    'rarity': rarity.index,
    'category': category.index,
    'iconUrl': iconUrl,
    'animationUrl': animationUrl,
    'acquiredAt': acquiredAt?.toIso8601String(),
    'isEquipped': isEquipped,
    'requirements': requirements,
    'level': level,
    'isHidden': isHidden,
  };

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

  bool get isAcquired => acquiredAt != null;
}

class UserBadge {

  UserBadge({
    required this.badgeId,
    required this.acquiredAt,
    this.isEquipped = false,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      badgeId: json['badgeId'],
      acquiredAt: DateTime.parse(json['acquiredAt']),
      isEquipped: json['isEquipped'] ?? false,
    );
  }
  final String badgeId;
  final DateTime acquiredAt;
  final bool isEquipped;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'badgeId': badgeId,
    'acquiredAt': acquiredAt.toIso8601String(),
    'isEquipped': isEquipped,
  };
}