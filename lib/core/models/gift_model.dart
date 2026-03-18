// lib/core/models/gift_model.dart

class GiftModel {
  final String id;
  final String name;
  final int price;
  final String category;
  final String animationPath;
  final String soundPath;
  final String previewImage;
  final bool isVip;
  final bool isSvip;
  final int tier;
  final Map<String, dynamic> effects;

  GiftModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.animationPath,
    required this.soundPath,
    required this.previewImage,
    this.isVip = false,
    this.isSvip = false,
    this.tier = 0,
    this.effects = const {},
  });

  // fromJson factory constructor
  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      category: json['category'] ?? '',
      animationPath: json['animationPath'] ?? '',
      soundPath: json['soundPath'] ?? '',
      previewImage: json['previewImage'] ?? '',
      isVip: json['isVip'] ?? false,
      isSvip: json['isSvip'] ?? false,
      tier: json['tier'] ?? 0,
      effects: json['effects'] ?? {},
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'animationPath': animationPath,
      'soundPath': soundPath,
      'previewImage': previewImage,
      'isVip': isVip,
      'isSvip': isSvip,
      'tier': tier,
      'effects': effects,
    };
  }

  // getMockGifts method (for testing/fallback)
  static List<GiftModel> getMockGifts() {
    return [
      GiftModel(
        id: 'g1',
        name: 'Rose',
        price: 100,
        category: 'Cute',
        animationPath: 'assets/gifts/rose.json',
        soundPath: 'assets/sounds/gifts/rose.mp3',
        previewImage: 'assets/gifts/preview/rose.png',
      ),
      GiftModel(
        id: 'g2',
        name: 'Chocolate',
        price: 200,
        category: 'Cute',
        animationPath: 'assets/gifts/chocolate.json',
        soundPath: 'assets/sounds/gifts/chocolate.mp3',
        previewImage: 'assets/gifts/preview/chocolate.png',
      ),
      GiftModel(
        id: 'vip1',
        name: 'VIP Car',
        price: 5000,
        category: 'VIP',
        animationPath: 'assets/gifts/vip_car.json',
        soundPath: 'assets/sounds/gifts/vip_car.mp3',
        previewImage: 'assets/gifts/preview/vip_car.png',
        isVip: true,
        tier: 1,
        effects: {'fullscreen': true, 'duration': 5},
      ),
      GiftModel(
        id: 'svip1',
        name: 'SVIP Yacht',
        price: 50000,
        category: 'SVIP',
        animationPath: 'assets/gifts/svip_yacht.json',
        soundPath: 'assets/sounds/gifts/svip_yacht.mp3',
        previewImage: 'assets/gifts/preview/svip_yacht.png',
        isSvip: true,
        tier: 1,
        effects: {'fullscreen': true, 'duration': 10, 'confetti': true},
      ),
    ];
  }

  // 🟢 ADD: getGifts method (alias for getMockGifts)
  static List<GiftModel> getGifts() {
    return getMockGifts();
  }

  // copyWith method (optional but useful)
  GiftModel copyWith({
    String? id,
    String? name,
    int? price,
    String? category,
    String? animationPath,
    String? soundPath,
    String? previewImage,
    bool? isVip,
    bool? isSvip,
    int? tier,
    Map<String, dynamic>? effects,
  }) {
    return GiftModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      animationPath: animationPath ?? this.animationPath,
      soundPath: soundPath ?? this.soundPath,
      previewImage: previewImage ?? this.previewImage,
      isVip: isVip ?? this.isVip,
      isSvip: isSvip ?? this.isSvip,
      tier: tier ?? this.tier,
      effects: effects ?? this.effects,
    );
  }
}