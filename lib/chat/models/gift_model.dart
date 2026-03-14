// lib/chat/models/gift_model.dart

class GiftModel {

  GiftModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.isAvailable = true,
    this.category,
    this.description,
    this.animationId,
  });

  // 🟢 fromJson factory constructor
  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      isAvailable: json['isAvailable'] as bool? ?? true,
      category: json['category'] as String?,
      description: json['description'] as String?,
      animationId: json['animationId'] as int?,
    );
  }
  final String id;
  final String name;
  final String imageUrl;
  final int price;
  final bool isAvailable;
  final String? category;
  final String? description;
  final int? animationId;

  // 🟢 toJson method
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'isAvailable': isAvailable,
      'category': category,
      'description': description,
      'animationId': animationId,
    };
  }
}