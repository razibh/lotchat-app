import 'package:flutter/foundation.dart';
import '../di/service_locator.dart';
import 'logger_service.dart';

// Frame Model Class
class Frame {
  final String id;
  final String name;
  final String description;
  final String type; // profile, badge, gift, special
  final String category;
  final int price;
  final String? previewUrl;
  final bool isLimited;
  final int? duration; // in days, for limited frames

  Frame({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.category,
    required this.price,
    this.previewUrl,
    this.isLimited = false,
    this.duration,
  });

  // CopyWith method
  Frame copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    String? category,
    int? price,
    String? previewUrl,
    bool? isLimited,
    int? duration,
  }) {
    return Frame(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      price: price ?? this.price,
      previewUrl: previewUrl ?? this.previewUrl,
      isLimited: isLimited ?? this.isLimited,
      duration: duration ?? this.duration,
    );
  }

  // FromJson factory
  factory Frame.fromJson(Map<String, dynamic> json) {
    return Frame(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'profile',
      category: json['category'] ?? 'all',
      price: json['price'] ?? 0,
      previewUrl: json['previewUrl'],
      isLimited: json['isLimited'] ?? false,
      duration: json['duration'],
    );
  }

  // ToJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'category': category,
      'price': price,
      'previewUrl': previewUrl,
      'isLimited': isLimited,
      'duration': duration,
    };
  }
}

class FrameService {
  final LoggerService _logger;

  FrameService({
    LoggerService? logger,
  }) : _logger = logger ?? ServiceLocator.instance.get<LoggerService>();

  // Get frames by category
  Future<List<Frame>> getFrames({
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _logger.debug('Fetching frames, category: $category, page: $page');

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      return List.generate(limit, (index) {
        final actualIndex = (page - 1) * limit + index;
        final types = ['profile', 'badge', 'gift', 'special'];
        final type = types[actualIndex % types.length];

        return Frame(
          id: 'frame_$actualIndex',
          name: '${_capitalize(type)} Frame ${actualIndex + 1}',
          description: 'A beautiful $type frame for your profile',
          type: type,
          category: category ?? 'all',
          price: 500 + (actualIndex * 100),
          previewUrl: null,
          isLimited: actualIndex % 5 == 0,
          duration: actualIndex % 5 == 0 ? 30 : null,
        );
      });

    } catch (e, stackTrace) {
      _logger.error('Failed to fetch frames', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // Get user owned frames
  Future<List<Frame>> getUserFrames(String userId) async {
    try {
      _logger.debug('Fetching frames for user: $userId');

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      return [
        Frame(
          id: 'frame_1',
          name: 'Basic Profile Frame',
          description: 'A simple frame for your profile',
          type: 'profile',
          category: 'profile',
          price: 500,
          previewUrl: null,
        ),
        Frame(
          id: 'frame_2',
          name: 'Gold Badge Frame',
          description: 'Show off your gold badge',
          type: 'badge',
          category: 'badge',
          price: 1000,
          previewUrl: null,
          isLimited: true,
          duration: 30,
        ),
        Frame(
          id: 'frame_3',
          name: 'Gift Box Frame',
          description: 'A special gift frame',
          type: 'gift',
          category: 'gift',
          price: 750,
          previewUrl: null,
        ),
        Frame(
          id: 'frame_4',
          name: 'Diamond Elite Frame',
          description: 'For elite members only',
          type: 'special',
          category: 'special',
          price: 2000,
          previewUrl: null,
          isLimited: true,
          duration: 60,
        ),
      ];

    } catch (e, stackTrace) {
      _logger.error('Failed to fetch user frames', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // Get equipped frames
  Future<List<Frame>> getEquippedFrames(String userId) async {
    try {
      _logger.debug('Fetching equipped frames for user: $userId');

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      return [
        Frame(
          id: 'frame_1',
          name: 'Basic Profile Frame',
          description: 'A simple frame for your profile',
          type: 'profile',
          category: 'profile',
          price: 500,
          previewUrl: null,
        ),
      ];

    } catch (e, stackTrace) {
      _logger.error('Failed to fetch equipped frames', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // Purchase frame
  Future<bool> purchaseFrame(String userId, String frameId, int price) async {
    try {
      _logger.debug('User $userId purchasing frame $frameId for $price coins');

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      return true;

    } catch (e, stackTrace) {
      _logger.error('Failed to purchase frame', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Equip frame
  Future<bool> equipFrame(String userId, String frameId) async {
    try {
      _logger.debug('User $userId equipping frame $frameId');

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      return true;

    } catch (e, stackTrace) {
      _logger.error('Failed to equip frame', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Unequip frame
  Future<bool> unequipFrame(String userId, String frameId) async {
    try {
      _logger.debug('User $userId unequipping frame $frameId');

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      return true;

    } catch (e, stackTrace) {
      _logger.error('Failed to unequip frame', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Helper method to capitalize string
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}