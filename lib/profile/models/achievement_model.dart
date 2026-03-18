import 'package:flutter/material.dart'; // 🟢 Color এর জন্য
import 'package:flutter/foundation.dart';

enum AchievementRarity { common, rare, epic, legendary, secret }
enum AchievementCategory { social, games, gifts, activity, special }

class AchievementModel {
  final String id;
  final String name;
  final String description;
  final AchievementRarity rarity;
  final AchievementCategory category;
  final String iconUrl;
  final int xpReward;
  final int coinReward;
  final String? badgeReward;
  final Map<String, dynamic> requirements;
  final int progress;
  final int target;
  final DateTime? unlockedAt;
  final bool isSecret;
  final bool isUnlocked;

  AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.category,
    required this.iconUrl,
    required this.xpReward,
    required this.coinReward,
    required this.requirements,
    required this.progress,
    required this.target,
    this.badgeReward,
    this.unlockedAt,
    this.isSecret = false,
    this.isUnlocked = false,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      rarity: _parseAchievementRarity(json['rarity']),
      category: _parseAchievementCategory(json['category']),
      iconUrl: json['iconUrl'] ?? '',
      xpReward: json['xpReward'] ?? 0,
      coinReward: json['coinReward'] ?? 0,
      badgeReward: json['badgeReward'],
      requirements: json['requirements'] ?? {},
      progress: json['progress'] ?? 0,
      target: json['target'] ?? 1,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
      isSecret: json['isSecret'] ?? false,
      isUnlocked: json['isUnlocked'] ?? false,
    );
  }

  static AchievementRarity _parseAchievementRarity(dynamic rarity) {
    if (rarity == null) return AchievementRarity.common;
    if (rarity is int) {
      return AchievementRarity.values[rarity];
    }
    if (rarity is String) {
      switch (rarity.toLowerCase()) {
        case 'common':
          return AchievementRarity.common;
        case 'rare':
          return AchievementRarity.rare;
        case 'epic':
          return AchievementRarity.epic;
        case 'legendary':
          return AchievementRarity.legendary;
        case 'secret':
          return AchievementRarity.secret;
        default:
          return AchievementRarity.common;
      }
    }
    return AchievementRarity.common;
  }

  static AchievementCategory _parseAchievementCategory(dynamic category) {
    if (category == null) return AchievementCategory.activity;
    if (category is int) {
      return AchievementCategory.values[category];
    }
    if (category is String) {
      switch (category.toLowerCase()) {
        case 'social':
          return AchievementCategory.social;
        case 'games':
          return AchievementCategory.games;
        case 'gifts':
          return AchievementCategory.gifts;
        case 'activity':
          return AchievementCategory.activity;
        case 'special':
          return AchievementCategory.special;
        default:
          return AchievementCategory.activity;
      }
    }
    return AchievementCategory.activity;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'rarity': rarity.index,
      'category': category.index,
      'iconUrl': iconUrl,
      'xpReward': xpReward,
      'coinReward': coinReward,
      'badgeReward': badgeReward,
      'requirements': requirements,
      'progress': progress,
      'target': target,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'isSecret': isSecret,
      'isUnlocked': isUnlocked,
    };
  }

  AchievementModel copyWith({
    String? id,
    String? name,
    String? description,
    AchievementRarity? rarity,
    AchievementCategory? category,
    String? iconUrl,
    int? xpReward,
    int? coinReward,
    String? badgeReward,
    Map<String, dynamic>? requirements,
    int? progress,
    int? target,
    DateTime? unlockedAt,
    bool? isSecret,
    bool? isUnlocked,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      rarity: rarity ?? this.rarity,
      category: category ?? this.category,
      iconUrl: iconUrl ?? this.iconUrl,
      xpReward: xpReward ?? this.xpReward,
      coinReward: coinReward ?? this.coinReward,
      badgeReward: badgeReward ?? this.badgeReward,
      requirements: requirements ?? this.requirements,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isSecret: isSecret ?? this.isSecret,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  // Getters
  double get progressPercentage {
    if (target == 0) return 0.0;
    return progress / target;
  }

  bool get isCompleted => progress >= target;

  Color get rarityColor {
    switch (rarity) {
      case AchievementRarity.common:
        return const Color(0xFF6B7280); // Grey
      case AchievementRarity.rare:
        return const Color(0xFF3B82F6); // Blue
      case AchievementRarity.epic:
        return const Color(0xFF8B5CF6); // Purple
      case AchievementRarity.legendary:
        return const Color(0xFFF59E0B); // Orange
      case AchievementRarity.secret:
        return const Color(0xFFEF4444); // Red
    }
  }

  String get progressText {
    if (isUnlocked) return 'Completed';
    return '$progress/$target';
  }

  String get rarityName {
    switch (rarity) {
      case AchievementRarity.common:
        return 'Common';
      case AchievementRarity.rare:
        return 'Rare';
      case AchievementRarity.epic:
        return 'Epic';
      case AchievementRarity.legendary:
        return 'Legendary';
      case AchievementRarity.secret:
        return 'Secret';
    }
  }

  String get categoryName {
    switch (category) {
      case AchievementCategory.social:
        return 'Social';
      case AchievementCategory.games:
        return 'Games';
      case AchievementCategory.gifts:
        return 'Gifts';
      case AchievementCategory.activity:
        return 'Activity';
      case AchievementCategory.special:
        return 'Special';
    }
  }

  // Check if requirement is met
  bool meetsRequirement(String key, dynamic value) {
    if (!requirements.containsKey(key)) return true;
    final required = requirements[key];
    if (value is num && required is num) {
      return value >= required;
    }
    return value == required;
  }

  // Update progress
  AchievementModel updateProgress(int newProgress) {
    return copyWith(
      progress: newProgress,
      isUnlocked: newProgress >= target,
      unlockedAt: newProgress >= target ? DateTime.now() : unlockedAt,
    );
  }

  // Increment progress
  AchievementModel incrementProgress([int amount = 1]) {
    final newProgress = progress + amount;
    return updateProgress(newProgress);
  }

  @override
  String toString() {
    return 'AchievementModel(id: $id, name: $name, rarity: $rarity, progress: $progress/$target)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AchievementModel &&
        other.id == id &&
        other.name == name &&
        other.rarity == rarity;
  }

  @override
  int get hashCode => Object.hash(id, name, rarity);
}

// User Achievement class
class UserAchievement {
  final String achievementId;
  final DateTime unlockedAt;
  final bool isNew;

  UserAchievement({
    required this.achievementId,
    required this.unlockedAt,
    this.isNew = false,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      achievementId: json['achievementId'] ?? '',
      unlockedAt: DateTime.parse(json['unlockedAt'] ?? DateTime.now().toIso8601String()),
      isNew: json['isNew'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'achievementId': achievementId,
      'unlockedAt': unlockedAt.toIso8601String(),
      'isNew': isNew,
    };
  }

  UserAchievement copyWith({
    String? achievementId,
    DateTime? unlockedAt,
    bool? isNew,
  }) {
    return UserAchievement(
      achievementId: achievementId ?? this.achievementId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isNew: isNew ?? this.isNew,
    );
  }
}

// Achievement progress tracker
class AchievementProgress {
  final String achievementId;
  final int progress;
  final int target;
  final DateTime? lastUpdated;

  AchievementProgress({
    required this.achievementId,
    required this.progress,
    required this.target,
    this.lastUpdated,
  });

  factory AchievementProgress.fromJson(Map<String, dynamic> json) {
    return AchievementProgress(
      achievementId: json['achievementId'] ?? '',
      progress: json['progress'] ?? 0,
      target: json['target'] ?? 1,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'achievementId': achievementId,
      'progress': progress,
      'target': target,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  double get percentage {
    if (target == 0) return 0.0;
    return progress / target;
  }

  bool get isCompleted => progress >= target;

  AchievementProgress copyWith({
    String? achievementId,
    int? progress,
    int? target,
    DateTime? lastUpdated,
  }) {
    return AchievementProgress(
      achievementId: achievementId ?? this.achievementId,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}