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
  final int? sentCount;  // 🔴 NEW: sentCount property যোগ করা হল

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
    this.sentCount,  // 🔴 NEW: কন্সট্রাক্টরে যোগ করা হল
    this.effects = const {},
  });

  // fromJson factory constructor - UPDATED
  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      category: json['category'] ?? '',
      animationPath: json['animation_path'] ?? json['animationPath'] ?? '',
      soundPath: json['sound_path'] ?? json['soundPath'] ?? '',
      previewImage: json['preview_image'] ?? json['previewImage'] ?? '',
      isVip: json['is_vip'] ?? json['isVip'] ?? false,
      isSvip: json['is_svip'] ?? json['isSvip'] ?? false,
      tier: json['tier'] ?? 0,
      sentCount: json['sent_count'] ?? json['sentCount'] ?? 0,  // 🔴 NEW: sent_count parse করা হল
      effects: json['effects'] ?? {},
    );
  }

  // toJson method - UPDATED
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'animation_path': animationPath,
      'sound_path': soundPath,
      'preview_image': previewImage,
      'is_vip': isVip,
      'is_svip': isSvip,
      'tier': tier,
      'sent_count': sentCount,  // 🔴 NEW: sent_count যোগ করা হল
      'effects': effects,
    };
  }

  // getMockGifts method (for testing/fallback) - UPDATED with sentCount
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
        sentCount: 0,  // 🔴 NEW: sentCount যোগ করা হল
      ),
      GiftModel(
        id: 'g2',
        name: 'Chocolate',
        price: 200,
        category: 'Cute',
        animationPath: 'assets/gifts/chocolate.json',
        soundPath: 'assets/sounds/gifts/chocolate.mp3',
        previewImage: 'assets/gifts/preview/chocolate.png',
        sentCount: 0,  // 🔴 NEW: sentCount যোগ করা হল
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
        sentCount: 0,  // 🔴 NEW: sentCount যোগ করা হল
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
        sentCount: 0,  // 🔴 NEW: sentCount যোগ করা হল
        effects: {'fullscreen': true, 'duration': 10, 'confetti': true},
      ),
    ];
  }

  // getGifts method (alias for getMockGifts)
  static List<GiftModel> getGifts() {
    return getMockGifts();
  }

  // copyWith method - UPDATED with sentCount
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
    int? sentCount,  // 🔴 NEW: sentCount প্যারামিটার যোগ করা হল
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
      sentCount: sentCount ?? this.sentCount,  // 🔴 NEW: sentCount যোগ করা হল
      effects: effects ?? this.effects,
    );
  }

  // 🟢 Utility method to check if gift is popular (optional)
  bool get isPopular => (sentCount ?? 0) > 100;

  // 🟢 Utility method to get tier name (optional)
  String get tierName {
    if (isSvip) return 'SVIP';
    if (isVip) return 'VIP';
    return 'Normal';
  }
}