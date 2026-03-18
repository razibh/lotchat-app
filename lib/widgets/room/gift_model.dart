// lib/core/models/gift_model.dart
import 'package:flutter/material.dart';
class GiftModel {
  final String id;
  final String name;
  final int price;
  final String category;
  final String animationPath;
  final String? previewImage;
  final String? soundPath;

  // 🟢 নতুন ফিল্ড যোগ করা হয়েছে
  final bool isLimited;
  final int? stock;

  GiftModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.animationPath,
    this.previewImage,
    this.soundPath,
    this.isLimited = false,  // 🟢 ডিফল্ট false
    this.stock,              // 🟢 অপশনাল
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      category: json['category'] ?? '',
      animationPath: json['animationPath'] ?? 'assets/animations/gift.json',
      previewImage: json['previewImage'],
      soundPath: json['soundPath'],
      // 🟢 নতুন ফিল্ড JSON থেকে পড়া
      isLimited: json['isLimited'] ?? false,
      stock: json['stock'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'animationPath': animationPath,
      'previewImage': previewImage,
      'soundPath': soundPath,
      // 🟢 নতুন ফিল্ড JSON এ লেখা
      'isLimited': isLimited,
      'stock': stock,
    };
  }

  GiftModel copyWith({
    String? id,
    String? name,
    int? price,
    String? category,
    String? animationPath,
    String? previewImage,
    String? soundPath,
    bool? isLimited,    // 🟢 নতুন প্যারামিটার
    int? stock,         // 🟢 নতুন প্যারামিটার
  }) {
    return GiftModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      animationPath: animationPath ?? this.animationPath,
      previewImage: previewImage ?? this.previewImage,
      soundPath: soundPath ?? this.soundPath,
      isLimited: isLimited ?? this.isLimited,    // 🟢 যোগ করা হয়েছে
      stock: stock ?? this.stock,                // 🟢 যোগ করা হয়েছে
    );
  }

  // 🟢 নতুন গেটার - স্টক আছে কিনা চেক করার জন্য
  bool get hasStock => stock == null || stock! > 0;

  // 🟢 নতুন গেটার - লিমিটেড এডিশন কিনা চেক করার জন্য
  bool get isAvailable => !isLimited || (stock != null && stock! > 0);

  // ডেমো ডাটা তৈরির জন্য স্ট্যাটিক মেথড
  static List<GiftModel> getGifts() {
    return [
      GiftModel(
        id: 'gift1',
        name: 'Rose',
        price: 10,
        category: 'Cute',
        animationPath: 'assets/animations/rose.json',
        isLimited: false,
        stock: null,
      ),
      GiftModel(
        id: 'gift2',
        name: 'Chocolate',
        price: 20,
        category: 'Cute',
        animationPath: 'assets/animations/chocolate.json',
        isLimited: false,
        stock: null,
      ),
      GiftModel(
        id: 'gift3',
        name: 'Teddy Bear',
        price: 30,
        category: 'Cute',
        animationPath: 'assets/animations/teddy.json',
        isLimited: true,
        stock: 10,
      ),
      GiftModel(
        id: 'gift4',
        name: 'Ring',
        price: 50,
        category: 'Luxury',
        animationPath: 'assets/animations/ring.json',
        isLimited: true,
        stock: 5,
      ),
      GiftModel(
        id: 'gift5',
        name: 'Crown',
        price: 100,
        category: 'VIP',
        animationPath: 'assets/animations/crown.json',
        isLimited: true,
        stock: 2,
      ),
    ];
  }

  // 🟢 ক্যাটাগরি অনুযায়ী গিফট ফিল্টার করার জন্য
  static List<GiftModel> getGiftsByCategory(String category) {
    return getGifts().where((gift) => gift.category == category).toList();
  }

  // 🟢 লিমিটেড গিফট পাওয়ার জন্য
  static List<GiftModel> getLimitedGifts() {
    return getGifts().where((gift) => gift.isLimited).toList();
  }

  // 🟢 স্টক আছে এমন গিফট পাওয়ার জন্য
  static List<GiftModel> getAvailableGifts() {
    return getGifts().where((gift) => gift.isAvailable).toList();
  }
}

// 🟢 গিফট ক্যাটাগরির জন্য এনাম (যদি প্রয়োজন হয়)
enum GiftCategory {
  cute,
  luxury,
  vip,
  svip,
  special,
  limited,
  flowers,
  jewelry,
  cars,
  pets,
  food,
  drinks,
  travel,
  fashion,
  tech,
  sports,
}

// 🟢 গিফট ক্যাটাগরির জন্য এক্সটেনশন
extension GiftCategoryExtension on GiftCategory {
  String get displayName {
    switch (this) {
      case GiftCategory.cute:
        return 'Cute';
      case GiftCategory.luxury:
        return 'Luxury';
      case GiftCategory.vip:
        return 'VIP';
      case GiftCategory.svip:
        return 'SVIP';
      case GiftCategory.special:
        return 'Special';
      case GiftCategory.limited:
        return 'Limited';
      case GiftCategory.flowers:
        return 'Flowers';
      case GiftCategory.jewelry:
        return 'Jewelry';
      case GiftCategory.cars:
        return 'Cars';
      case GiftCategory.pets:
        return 'Pets';
      case GiftCategory.food:
        return 'Food';
      case GiftCategory.drinks:
        return 'Drinks';
      case GiftCategory.travel:
        return 'Travel';
      case GiftCategory.fashion:
        return 'Fashion';
      case GiftCategory.tech:
        return 'Tech';
      case GiftCategory.sports:
        return 'Sports';
    }
  }

  Color get color {
    switch (this) {
      case GiftCategory.cute:
        return Colors.pink;
      case GiftCategory.luxury:
        return Colors.amber;
      case GiftCategory.vip:
        return Colors.purple;
      case GiftCategory.svip:
        return Colors.deepPurple;
      case GiftCategory.special:
        return Colors.red;
      case GiftCategory.limited:
        return Colors.orange;
      case GiftCategory.flowers:
        return Colors.pink.shade300;
      case GiftCategory.jewelry:
        return Colors.amber.shade700;
      case GiftCategory.cars:
        return Colors.blue;
      case GiftCategory.pets:
        return Colors.brown;
      case GiftCategory.food:
        return Colors.green;
      case GiftCategory.drinks:
        return Colors.teal;
      case GiftCategory.travel:
        return Colors.indigo;
      case GiftCategory.fashion:
        return Colors.purple.shade400;
      case GiftCategory.tech:
        return Colors.cyan;
      case GiftCategory.sports:
        return Colors.lime;
    }
  }

  IconData get icon {
    switch (this) {
      case GiftCategory.cute:
        return Icons.favorite;
      case GiftCategory.luxury:
        return Icons.diamond;
      case GiftCategory.vip:
        return Icons.star;
      case GiftCategory.svip:
        return Icons.auto_awesome;
      case GiftCategory.special:
        return Icons.card_giftcard;
      case GiftCategory.limited:
        return Icons.timer;
      case GiftCategory.flowers:
        return Icons.local_florist;
      case GiftCategory.jewelry:
        return Icons.ring_volume;
      case GiftCategory.cars:
        return Icons.directions_car;
      case GiftCategory.pets:
        return Icons.pets;
      case GiftCategory.food:
        return Icons.fastfood;
      case GiftCategory.drinks:
        return Icons.local_drink;
      case GiftCategory.travel:
        return Icons.flight;
      case GiftCategory.fashion:
        return Icons.checkroom;
      case GiftCategory.tech:
        return Icons.computer;
      case GiftCategory.sports:
        return Icons.sports_esports;
    }
  }
}

