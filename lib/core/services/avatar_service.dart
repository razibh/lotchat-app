import 'dart:convert';
import 'dart:math' as dart_math;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AvatarService {
  final String _baseUrl = 'https://api.example.com/avatars';

  // Cache for avatar items
  final Map<String, List<AvatarItem>> _cache = {};

  // Get all avatar items by category
  Future<List<AvatarItem>> getItemsByCategory(String category) async {
    // Check cache first
    if (_cache.containsKey(category)) {
      return _cache[category]!;
    }

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data
      final items = _generateMockItems(category);

      // Cache the result
      _cache[category] = items;

      return items;
    } catch (e) {
      debugPrint('Error fetching avatar items: $e');
      return [];
    }
  }

  // Get user's owned avatar items
  Future<List<String>> getOwnedItems(String userId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock data - return some owned items
      return [
        'face1', 'face2', 'face3',
        'eyes1', 'eyes2',
        'hair1', 'hair2', 'hair3',
        'outfit1', 'outfit2',
      ];
    } catch (e) {
      debugPrint('Error fetching owned items: $e');
      return [];
    }
  }

  // Purchase avatar item
  Future<bool> purchaseItem(String userId, String itemId, int price) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Simulate successful purchase
      debugPrint('User $userId purchased item $itemId for $price coins');
      return true;
    } catch (e) {
      debugPrint('Error purchasing item: $e');
      return false;
    }
  }

  // Save avatar configuration
  Future<bool> saveAvatar(String userId, Map<String, dynamic> avatarConfig) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      debugPrint('Avatar saved for user $userId');
      return true;
    } catch (e) {
      debugPrint('Error saving avatar: $e');
      return false;
    }
  }

  // Get avatar configuration
  Future<Map<String, dynamic>?> getAvatar(String userId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data
      return {
        'face': 'face1',
        'eyes': 'eyes1',
        'nose': 'nose1',
        'mouth': 'mouth1',
        'hair': 'hair1',
        'outfit': 'outfit1',
        'accessory': 'none',
        'background': 'bg1',
      };
    } catch (e) {
      debugPrint('Error fetching avatar: $e');
      return null;
    }
  }

  // Generate random avatar
  Map<String, dynamic> generateRandomAvatar() {
    final random = dart_math.Random();
    return {
      'face': 'face${random.nextInt(10) + 1}',
      'eyes': 'eyes${random.nextInt(10) + 1}',
      'nose': 'nose${random.nextInt(5) + 1}',
      'mouth': 'mouth${random.nextInt(8) + 1}',
      'hair': 'hair${random.nextInt(15) + 1}',
      'outfit': 'outfit${random.nextInt(20) + 1}',
      'accessory': random.nextBool() ? 'accessory${random.nextInt(5) + 1}' : 'none',
      'background': 'bg${random.nextInt(6) + 1}',
    };
  }

  // Generate mock items for a category
  List<AvatarItem> _generateMockItems(String category) {
    switch (category) {
      case 'Face':
        return List.generate(10, (index) => AvatarItem(
          id: 'face${index + 1}',
          name: 'Face ${index + 1}',
          category: category,
          price: index < 3 ? 0 : 500 * (index + 1),
          imageUrl: 'assets/avatars/face_$index.png',
          thumbnailUrl: 'assets/avatars/thumb/face_$index.png',
          isLocked: index > 5,
          isOwned: index < 3,
        ));
      case 'Eyes':
        return List.generate(10, (index) => AvatarItem(
          id: 'eyes${index + 1}',
          name: 'Eyes ${index + 1}',
          category: category,
          price: index < 3 ? 0 : 300 * (index + 1),
          imageUrl: 'assets/avatars/eyes_$index.png',
          thumbnailUrl: 'assets/avatars/thumb/eyes_$index.png',
          isLocked: index > 5,
          isOwned: index < 3,
        ));
      case 'Hair':
        return List.generate(15, (index) => AvatarItem(
          id: 'hair${index + 1}',
          name: 'Hairstyle ${index + 1}',
          category: category,
          price: index < 5 ? 0 : 800 * (index + 1),
          imageUrl: 'assets/avatars/hair_$index.png',
          thumbnailUrl: 'assets/avatars/thumb/hair_$index.png',
          isLocked: index > 8,
          isOwned: index < 5,
        ));
      case 'Outfit':
        return List.generate(20, (index) => AvatarItem(
          id: 'outfit${index + 1}',
          name: 'Outfit ${index + 1}',
          category: category,
          price: index < 5 ? 0 : 1000 * (index + 1),
          imageUrl: 'assets/avatars/outfit_$index.png',
          thumbnailUrl: 'assets/avatars/thumb/outfit_$index.png',
          isLocked: index > 10,
          isOwned: index < 5,
        ));
      default:
        return [];
    }
  }
}

// Avatar Item Model
class AvatarItem {
  final String id;
  final String name;
  final String category;
  final int price;
  final String imageUrl;
  final String thumbnailUrl;
  final bool isLocked;
  final bool isOwned;

  AvatarItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.isLocked,
    required this.isOwned,
  });

  factory AvatarItem.fromJson(Map<String, dynamic> json) {
    return AvatarItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: json['price'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      isLocked: json['isLocked'] ?? false,
      isOwned: json['isOwned'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'isLocked': isLocked,
      'isOwned': isOwned,
    };
  }
}
