enum EffectType {
  entry,        // Room entry effect
  exit,         // Room exit effect
  gift,         // Gift effect
  achievement,  // Achievement effect
  levelUp,      // Level up effect
  celebration,  // Celebration effect
  special       // Special event effect
}

enum EffectRarity {
  common,
  rare,
  epic,
  legendary,
  mythic
}

class EffectModel {

  EffectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.rarity,
    required this.animationPath,
    this.thumbnailPath,
    this.soundPath,
    required this.duration,
    required this.price,
    this.isVip = false,
    this.isSvip = false,
    this.requiredLevel = 1,
    this.tags = const [],
    this.properties = const {},
    this.availableFrom,
    this.availableTo,
    this.isActive = true,
  });

  factory EffectModel.fromJson(Map<String, dynamic> json) {
    return EffectModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: EffectType.values[json['type']],
      rarity: EffectRarity.values[json['rarity']],
      animationPath: json['animationPath'],
      thumbnailPath: json['thumbnailPath'],
      soundPath: json['soundPath'],
      duration: json['duration'],
      price: json['price'],
      isVip: json['isVip'] ?? false,
      isSvip: json['isSvip'] ?? false,
      requiredLevel: json['requiredLevel'] ?? 1,
      tags: List<String>.from(json['tags'] ?? []),
      properties: json['properties'] ?? {},
      availableFrom: json['availableFrom'] != null 
          ? DateTime.parse(json['availableFrom']) 
          : null,
      availableTo: json['availableTo'] != null 
          ? DateTime.parse(json['availableTo']) 
          : null,
      isActive: json['isActive'] ?? true,
    );
  }
  final String id;
  final String name;
  final String description;
  final EffectType type;
  final EffectRarity rarity;
  final String animationPath; // Lottie JSON path
  final String? thumbnailPath;
  final String? soundPath;
  final int duration; // in milliseconds
  final int price; // in coins
  final bool isVip;
  final bool isSvip;
  final int requiredLevel;
  final List<String> tags;
  final Map<String, dynamic> properties; // size, color, etc.
  final DateTime? availableFrom;
  final DateTime? availableTo;
  final bool isActive;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'description': description,
    'type': type.index,
    'rarity': rarity.index,
    'animationPath': animationPath,
    'thumbnailPath': thumbnailPath,
    'soundPath': soundPath,
    'duration': duration,
    'price': price,
    'isVip': isVip,
    'isSvip': isSvip,
    'requiredLevel': requiredLevel,
    'tags': tags,
    'properties': properties,
    'availableFrom': availableFrom?.toIso8601String(),
    'availableTo': availableTo?.toIso8601String(),
    'isActive': isActive,
  };

  bool get isAvailable {
    if (!isActive) return false;
    if (availableFrom != null && DateTime.now().isBefore(availableFrom!)) {
      return false;
    }
    if (availableTo != null && DateTime.now().isAfter(availableTo!)) {
      return false;
    }
    return true;
  }

  String get rarityColor {
    switch (rarity) {
      case EffectRarity.common:
        return '#6B7280'; // Gray
      case EffectRarity.rare:
        return '#3B82F6'; // Blue
      case EffectRarity.epic:
        return '#8B5CF6'; // Purple
      case EffectRarity.legendary:
        return '#F59E0B'; // Orange
      case EffectRarity.mythic:
        return '#EC4899'; // Pink
    }
  }

  static List<EffectModel> getEntryEffects() {
    return <EffectModel>[
      EffectModel(
        id: 'entry_1',
        name: 'Basic Entry',
        description: 'Simple entry effect',
        type: EffectType.entry,
        rarity: EffectRarity.common,
        animationPath: 'assets/effects/entry/basic.json',
        duration: 2000,
        price: 1000,
      ),
      EffectModel(
        id: 'entry_2',
        name: 'VIP Entry',
        description: 'Premium VIP entry effect',
        type: EffectType.entry,
        rarity: EffectRarity.epic,
        animationPath: 'assets/effects/entry/vip.json',
        duration: 3000,
        price: 5000,
        isVip: true,
      ),
      EffectModel(
        id: 'entry_3',
        name: 'SVIP Entry',
        description: 'Ultimate SVIP entry effect',
        type: EffectType.entry,
        rarity: EffectRarity.legendary,
        animationPath: 'assets/effects/entry/svip.json',
        duration: 4000,
        price: 10000,
        isSvip: true,
      ),
      EffectModel(
        id: 'entry_4',
        name: 'Diamond Entry',
        description: 'Diamond-studded entry',
        type: EffectType.entry,
        rarity: EffectRarity.epic,
        animationPath: 'assets/effects/entry/diamond.json',
        duration: 3500,
        price: 7500,
      ),
      EffectModel(
        id: 'entry_5',
        name: 'Royal Entry',
        description: 'Royal crown entry',
        type: EffectType.entry,
        rarity: EffectRarity.legendary,
        animationPath: 'assets/effects/entry/royal.json',
        duration: 4000,
        price: 12000,
      ),
    ];
  }

  static List<EffectModel> getGiftEffects() {
    return <EffectModel>[
      EffectModel(
        id: 'gift_1',
        name: 'Sparkle',
        description: 'Simple sparkle effect',
        type: EffectType.gift,
        rarity: EffectRarity.common,
        animationPath: 'assets/effects/gift/sparkle.json',
        duration: 1500,
        price: 500,
      ),
      EffectModel(
        id: 'gift_2',
        name: 'Fireworks',
        description: 'Colorful fireworks',
        type: EffectType.gift,
        rarity: EffectRarity.rare,
        animationPath: 'assets/effects/gift/fireworks.json',
        duration: 2500,
        price: 1500,
      ),
      EffectModel(
        id: 'gift_3',
        name: 'Rainbow',
        description: 'Rainbow explosion',
        type: EffectType.gift,
        rarity: EffectRarity.epic,
        animationPath: 'assets/effects/gift/rainbow.json',
        duration: 3000,
        price: 3000,
      ),
      EffectModel(
        id: 'gift_4',
        name: 'Galaxy',
        description: 'Galactic gift effect',
        type: EffectType.gift,
        rarity: EffectRarity.legendary,
        animationPath: 'assets/effects/gift/galaxy.json',
        duration: 4000,
        price: 8000,
      ),
    ];
  }
}

class UserEffect {

  UserEffect({
    required this.userId,
    required this.effectId,
    required this.acquiredAt,
    this.expiresAt,
    this.isEquipped = false,
  });

  factory UserEffect.fromJson(Map<String, dynamic> json) {
    return UserEffect(
      userId: json['userId'],
      effectId: json['effectId'],
      acquiredAt: DateTime.parse(json['acquiredAt']),
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt']) 
          : null,
      isEquipped: json['isEquipped'] ?? false,
    );
  }
  final String userId;
  final String effectId;
  final DateTime acquiredAt;
  final DateTime? expiresAt;
  final bool isEquipped;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'userId': userId,
    'effectId': effectId,
    'acquiredAt': acquiredAt.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
    'isEquipped': isEquipped,
  };

  bool get isValid {
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }
}