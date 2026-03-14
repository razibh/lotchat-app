enum FrameRarity { common, rare, epic, legendary, limited }
enum FrameType { basic, vip, svip, event, animated }

class FrameModel {

  FrameModel({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.type,
    required this.imageUrl,
    required this.price, this.thumbnailUrl,
    this.animationUrl,
    this.isPurchased = false,
    this.isEquipped = false,
    this.availableUntil,
    this.requirements = const <String, dynamic>{},
  });

  factory FrameModel.fromJson(Map<String, dynamic> json) {
    return FrameModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      rarity: FrameRarity.values[json['rarity']],
      type: FrameType.values[json['type']],
      imageUrl: json['imageUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      animationUrl: json['animationUrl'],
      price: json['price'],
      isPurchased: json['isPurchased'] ?? false,
      isEquipped: json['isEquipped'] ?? false,
      availableUntil: json['availableUntil'] != null 
          ? DateTime.parse(json['availableUntil']) 
          : null,
      requirements: json['requirements'] ?? <String, dynamic>{},
    );
  }
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

  Map<String, dynamic> toJson() => <String, dynamic>{
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
  };

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

  bool get isAvailable {
    if (availableUntil == null) return true;
    return DateTime.now().isBefore(availableUntil!);
  }

  bool get isAnimated => type == FrameType.animated;
  bool get isVip => type == FrameType.vip;
  bool get isSvip => type == FrameType.svip;
}

class UserFrame {

  UserFrame({
    required this.frameId,
    required this.acquiredAt,
    this.isEquipped = false,
  });

  factory UserFrame.fromJson(Map<String, dynamic> json) {
    return UserFrame(
      frameId: json['frameId'],
      acquiredAt: DateTime.parse(json['acquiredAt']),
      isEquipped: json['isEquipped'] ?? false,
    );
  }
  final String frameId;
  final DateTime acquiredAt;
  final bool isEquipped;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'frameId': frameId,
    'acquiredAt': acquiredAt.toIso8601String(),
    'isEquipped': isEquipped,
  };
}