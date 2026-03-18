import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/logger_service.dart';
import '../../core/services/notification_service.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/animation/fade_animation.dart';

// Achievement Model Class
class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final int points;
  final String category; // gifts, rooms, social, special
  final bool isUnlocked;
  final double progress;
  final DateTime? unlockedAt;
  final Map<String, dynamic> requirements;
  final Color rarityColor;
  final int xpReward;
  final int coinReward;
  final bool isSecret;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.points,
    required this.category,
    required this.isUnlocked,
    required this.progress,
    this.unlockedAt,
    required this.requirements,
    this.rarityColor = Colors.grey,
    this.xpReward = 0,
    this.coinReward = 0,
    this.isSecret = false,
  });

  // CopyWith method
  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    int? points,
    String? category,
    bool? isUnlocked,
    double? progress,
    DateTime? unlockedAt,
    Map<String, dynamic>? requirements,
    Color? rarityColor,
    int? xpReward,
    int? coinReward,
    bool? isSecret,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      points: points ?? this.points,
      category: category ?? this.category,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      progress: progress ?? this.progress,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      requirements: requirements ?? this.requirements,
      rarityColor: rarityColor ?? this.rarityColor,
      xpReward: xpReward ?? this.xpReward,
      coinReward: coinReward ?? this.coinReward,
      isSecret: isSecret ?? this.isSecret,
    );
  }

  // FromJson factory
  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: _getIconFromString(json['icon'] ?? 'emoji_events'),
      points: json['points'] ?? 0,
      category: json['category'] ?? 'special',
      isUnlocked: json['isUnlocked'] ?? false,
      progress: (json['progress'] ?? 0).toDouble(),
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
      requirements: json['requirements'] ?? {},
      rarityColor: _getRarityColor(json['rarity'] ?? 'common'),
      xpReward: json['xpReward'] ?? 0,
      coinReward: json['coinReward'] ?? 0,
      isSecret: json['isSecret'] ?? false,
    );
  }

  // Helper method to get IconData from string
  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'emoji_events':
        return Icons.emoji_events;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'videocam':
        return Icons.videocam;
      case 'people':
        return Icons.people;
      case 'star':
        return Icons.star;
      case 'favorite':
        return Icons.favorite;
      case 'whatshot':
        return Icons.whatshot;
      case 'military_tech':
        return Icons.military_tech;
      case 'sports_kabaddi':
        return Icons.sports_kabaddi;
      case 'music_note':
        return Icons.music_note;
      default:
        return Icons.emoji_events;
    }
  }

  // Helper method to get color from rarity
  static Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return const Color(0xFF6B7280);
      case 'rare':
        return const Color(0xFF3B82F6);
      case 'epic':
        return const Color(0xFF8B5CF6);
      case 'legendary':
        return const Color(0xFFF59E0B);
      case 'secret':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  // ToJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon.toString(),
      'points': points,
      'category': category,
      'isUnlocked': isUnlocked,
      'progress': progress,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'requirements': requirements,
      'xpReward': xpReward,
      'coinReward': coinReward,
      'isSecret': isSecret,
    };
  }

  // Getters
  double get progressPercentage => progress / (requirements['target'] ?? 1);

  String get progressText {
    if (isUnlocked) return 'Completed';
    final current = requirements['current'] ?? 0;
    final target = requirements['target'] ?? 100;
    return '$current/$target';
  }

  bool get isCompleted => progress >= (requirements['target'] ?? 1);
}

class AchievementService {
  final LoggerService _logger;

  AchievementService({
    LoggerService? logger,
  }) : _logger = logger ?? ServiceLocator.instance.get<LoggerService>();

  // Get user achievements
  Future<List<Achievement>> getUserAchievements(String userId) async {
    try {
      _logger.debug('Fetching achievements for user: $userId');

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      return [
        Achievement(
          id: '1',
          name: 'Gift Master',
          description: 'Send 100 gifts to other users',
          icon: Icons.card_giftcard,
          points: 100,
          category: 'gifts',
          isUnlocked: true,
          progress: 1.0,
          unlockedAt: DateTime.now().subtract(const Duration(days: 5)),
          requirements: {'gifts_sent': 100, 'target': 100, 'current': 100},
          rarityColor: const Color(0xFF8B5CF6),
          xpReward: 100,
          coinReward: 500,
        ),
        Achievement(
          id: '2',
          name: 'Social Butterfly',
          description: 'Make 50 new friends',
          icon: Icons.people,
          points: 150,
          category: 'social',
          isUnlocked: false,
          progress: 0.6,
          requirements: {'friends': 30, 'target': 50, 'current': 30},
          rarityColor: const Color(0xFF3B82F6),
          xpReward: 150,
          coinReward: 750,
        ),
        Achievement(
          id: '3',
          name: 'Room Host',
          description: 'Host 30 live rooms',
          icon: Icons.videocam,
          points: 200,
          category: 'rooms',
          isUnlocked: true,
          progress: 1.0,
          unlockedAt: DateTime.now().subtract(const Duration(days: 10)),
          requirements: {'rooms_hosted': 30, 'target': 30, 'current': 30},
          rarityColor: const Color(0xFFF59E0B),
          xpReward: 200,
          coinReward: 1000,
        ),
        Achievement(
          id: '4',
          name: 'Streak Master',
          description: 'Maintain a 30-day streak',
          icon: Icons.whatshot,
          points: 300,
          category: 'special',
          isUnlocked: false,
          progress: 0.5,
          requirements: {'current_streak': 15, 'target': 30, 'current': 15},
          rarityColor: const Color(0xFFEF4444),
          xpReward: 300,
          coinReward: 1500,
          isSecret: true,
        ),
      ];

    } catch (e, stackTrace) {
      _logger.error('Failed to fetch achievements', error: e, stackTrace: stackTrace);
      throw Exception('Failed to load achievements: $e');
    }
  }

  // Get recent achievements
  Future<List<Achievement>> getRecentAchievements(String userId) async {
    try {
      final all = await getUserAchievements(userId);
      return all.where((a) => a.isUnlocked).take(3).toList();
    } catch (e) {
      return [];
    }
  }

  // Get achievement stats
  Future<Map<String, dynamic>> getAchievementStats(String userId) async {
    try {
      final achievements = await getUserAchievements(userId);

      final total = achievements.length;
      final unlocked = achievements.where((a) => a.isUnlocked).length;
      final totalPoints = achievements.fold<int>(
        0,
            (sum, a) => sum + (a.isUnlocked ? a.points : 0),
      );

      return {
        'total_points': totalPoints,
        'unlocked_count': unlocked,
        'total_count': total,
        'completion_rate': total > 0 ? unlocked / total : 0.0,
      };

    } catch (e) {
      return {
        'total_points': 0,
        'unlocked_count': 0,
        'total_count': 0,
        'completion_rate': 0.0,
      };
    }
  }

  // Unlock achievement
  Future<bool> unlockAchievement(String userId, String achievementId) async {
    try {
      _logger.debug('Unlocking achievement $achievementId for user $userId');

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      return true;

    } catch (e, stackTrace) {
      _logger.error('Failed to unlock achievement', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Check achievement progress
  Future<Map<String, dynamic>> checkProgress(String userId) async {
    try {
      // TODO: Implement progress checking logic
      return {};

    } catch (e, stackTrace) {
      _logger.error('Failed to check progress', error: e, stackTrace: stackTrace);
      return {};
    }
  }
}

class AchievementsScreen extends StatefulWidget {
  final String userId;

  const AchievementsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('userId', userId));
  }
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final AchievementService _achievementService = ServiceLocator.instance.get<AchievementService>();
  final NotificationService _notificationService = ServiceLocator.instance.get<NotificationService>();

  List<Achievement> _achievements = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Gifts', 'Social', 'Rooms', 'Special'];

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final achievements = await _achievementService.getUserAchievements(widget.userId);

      setState(() {
        _achievements = achievements;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Achievement> get _filteredAchievements {
    if (_selectedCategory == 'All') return _achievements;

    final category = _selectedCategory.toLowerCase();
    return _achievements.where((a) => a.category == category).toList();
  }

  int get _unlockedCount => _achievements.where((a) => a.isUnlocked).length;
  int get _totalCount => _achievements.length;
  double get _progress => _totalCount > 0 ? _unlockedCount / _totalCount : 0.0;

  void _showAchievementDetails(Achievement achievement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Achievement Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: achievement.rarityColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                achievement.icon,
                size: 50,
                color: achievement.rarityColor,
              ),
            ),
            const SizedBox(height: 16),

            // Achievement Name
            Text(
              achievement.isSecret && !achievement.isUnlocked ? '???' : achievement.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Achievement Description
            Text(
              achievement.isSecret && !achievement.isUnlocked ? '???' : achievement.description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Achievement Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Rarity', achievement.rarityColor),
                  _buildDetailRow('Category', achievement.category),
                  if (!achievement.isUnlocked)
                    _buildDetailRow('Progress', achievement.progressText),
                  _buildDetailRow('XP Reward', '+${achievement.xpReward}'),
                  if (achievement.coinReward > 0)
                    _buildDetailRow('Coin Reward', '+${achievement.coinReward}'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Unlock Status
            if (achievement.isUnlocked)
              const Text(
                '✓ Unlocked',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              )
            else ...[
              const Text(
                'How to unlock:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...achievement.requirements.entries.map((entry) {
                if (entry.key == 'target' || entry.key == 'current') return const SizedBox();
                return Text('• ${entry.key}: ${entry.value}');
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    Color? color;
    if (value is Color) {
      color = value;
      value = label == 'Rarity' ? _getRarityName(value) : value;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          if (color != null)
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            )
          else
            Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getRarityName(Color color) {
    if (color == const Color(0xFF6B7280)) return 'Common';
    if (color == const Color(0xFF3B82F6)) return 'Rare';
    if (color == const Color(0xFF8B5CF6)) return 'Epic';
    if (color == const Color(0xFFF59E0B)) return 'Legendary';
    if (color == const Color(0xFFEF4444)) return 'Secret';
    return 'Common';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAchievements,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: Colors.green,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Progress',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          '$_unlockedCount/$_totalCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),

              // Category Filter
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: _categories.map((String category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        backgroundColor: Colors.white.withOpacity(0.2),
                        selectedColor: Colors.white,
                        labelStyle: TextStyle(
                          color: _selectedCategory == category ? Colors.green : Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _filteredAchievements.isEmpty
          ? const EmptyStateWidget(
        title: 'No Achievements',
        message: 'No achievements available',
        icon: Icons.emoji_events,
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredAchievements.length,
        itemBuilder: (BuildContext context, int index) {
          final achievement = _filteredAchievements[index];
          return FadeAnimation(
            delay: Duration(milliseconds: index * 50),
            child: _buildAchievementCard(achievement),
          );
        },
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;
    final progress = achievement.progressPercentage;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showAchievementDetails(achievement),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Achievement Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: achievement.rarityColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  achievement.icon,
                  size: 30,
                  color: achievement.rarityColor,
                ),
              ),
              const SizedBox(width: 12),

              // Achievement Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            achievement.isSecret && !isUnlocked
                                ? '???'
                                : achievement.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isUnlocked ? achievement.rarityColor : null,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: achievement.rarityColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getRarityName(achievement.rarityColor),
                            style: TextStyle(
                              fontSize: 10,
                              color: achievement.rarityColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.isSecret && !isUnlocked
                          ? '???'
                          : achievement.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Progress Bar
                    if (!isUnlocked) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  achievement.rarityColor,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            achievement.progressText,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Unlocked',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '+${achievement.xpReward} XP',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (achievement.coinReward > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              '+${achievement.coinReward} 🪙',
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}