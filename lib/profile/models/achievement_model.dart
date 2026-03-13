enum AchievementRarity { common, rare, epic, legendary, secret }
enum AchievementCategory { social, games, gifts, activity, special }

class AchievementModel {

  AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.category,
    required this.iconUrl,
    required this.xpReward,
    required this.coinReward,
    this.badgeReward,
    required this.requirements,
    required this.progress,
    required this.target,
    this.unlockedAt,
    this.isSecret = false,
    this.isUnlocked = false,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      rarity: AchievementRarity.values[json['rarity']],
      category: AchievementCategory.values[json['category']],
      iconUrl: json['iconUrl'],
      xpReward: json['xpReward'],
      coinReward: json['coinReward'],
      badgeReward: json['badgeReward'],
      requirements: json['requirements'] ?? {},
      progress: json['progress'] ?? 0,
      target: json['target'],
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt']) 
          : null,
      isSecret: json['isSecret'] ?? false,
      isUnlocked: json['isUnlocked'] ?? false,
    );
  }
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

  Map<String, dynamic> toJson() => <String, dynamic>{
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

  double get progressPercentage => progress / target;
  
  bool get isCompleted => progress >= target;

  Color get rarityColor {
    switch (rarity) {
      case AchievementRarity.common:
        return const Color(0xFF6B7280);
      case AchievementRarity.rare:
        return const Color(0xFF3B82F6);
      case AchievementRarity.epic:
        return const Color(0xFF8B5CF6);
      case AchievementRarity.legendary:
        return const Color(0xFFF59E0B);
      case AchievementRarity.secret:
        return const Color(0xFFEF4444);
    }
  }

  String get progressText {
    if (isUnlocked) return 'Completed';
    return '$progress/$target';
  }
}