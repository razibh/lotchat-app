import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/logger_service.dart';
import '../../core/services/notification_service.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../mixins/toast_mixin.dart'; // ToastMixin যোগ করা হয়েছে

// UserBadge Model Class
class UserBadge {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int points;
  final String category; // achievement, event, vip, svip, limited
  final bool isEarned;
  final DateTime? earnedAt;
  final String requirement;
  final bool isLimited;
  final int? expiresIn;
  final String rarity; // common, rare, epic, legendary, limited
  final Color rarityColor;
  final int? level;

  UserBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.points,
    required this.category,
    required this.isEarned,
    this.earnedAt,
    required this.requirement,
    this.isLimited = false,
    this.expiresIn,
    this.rarity = 'common',
    required this.rarityColor,
    this.level,
  });

  // CopyWith method
  UserBadge copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    Color? color,
    int? points,
    String? category,
    bool? isEarned,
    DateTime? earnedAt,
    String? requirement,
    bool? isLimited,
    int? expiresIn,
    String? rarity,
    Color? rarityColor,
    int? level,
  }) {
    return UserBadge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      points: points ?? this.points,
      category: category ?? this.category,
      isEarned: isEarned ?? this.isEarned,
      earnedAt: earnedAt ?? this.earnedAt,
      requirement: requirement ?? this.requirement,
      isLimited: isLimited ?? this.isLimited,
      expiresIn: expiresIn ?? this.expiresIn,
      rarity: rarity ?? this.rarity,
      rarityColor: rarityColor ?? this.rarityColor,
      level: level ?? this.level,
    );
  }

  // FromJson factory
  factory UserBadge.fromJson(Map<String, dynamic> json) {
    final rarity = json['rarity'] ?? 'common';
    return UserBadge(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: _getIconFromString(json['icon'] ?? 'military_tech'),
      color: _getColorFromString(json['color'] ?? 'amber'),
      points: json['points'] ?? 0,
      category: json['category'] ?? 'achievement',
      isEarned: json['isEarned'] ?? false,
      earnedAt: json['earnedAt'] != null
          ? DateTime.parse(json['earnedAt'])
          : null,
      requirement: json['requirement'] ?? '',
      isLimited: json['isLimited'] ?? false,
      expiresIn: json['expiresIn'],
      rarity: rarity,
      rarityColor: _getRarityColor(rarity),
      level: json['level'],
    );
  }

  // Helper method to get IconData from string
  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'military_tech':
        return Icons.military_tech;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'star':
        return Icons.star;
      case 'star_border':
        return Icons.star_border;
      case 'star_half':
        return Icons.star_half;
      case 'favorite':
        return Icons.favorite;
      case 'favorite_border':
        return Icons.favorite_border;
      case 'whatshot':
        return Icons.whatshot;
      case 'diamond':
        return Icons.diamond;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'workspace_premium_outlined':
        return Icons.workspace_premium_outlined;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'celebration':
        return Icons.celebration;
      default:
        return Icons.military_tech;
    }
  }

  // Helper method to get Color from string
  static Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'amber':
        return Colors.amber;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      case 'teal':
        return Colors.teal;
      case 'cyan':
        return Colors.cyan;
      case 'indigo':
        return Colors.indigo;
      case 'yellow':
        return Colors.yellow;
      default:
        return Colors.amber;
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
      case 'limited':
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
      'color': color.toString(),
      'points': points,
      'category': category,
      'isEarned': isEarned,
      'earnedAt': earnedAt?.toIso8601String(),
      'requirement': requirement,
      'isLimited': isLimited,
      'expiresIn': expiresIn,
      'rarity': rarity,
      'level': level,
    };
  }

  // Getters
  bool get isAcquired => isEarned;
  bool get isEquipped => false; // This would come from user data
  String get iconUrl => ''; // For network images if needed
}

class BadgeService {
  final LoggerService _logger;

  BadgeService({
    LoggerService? logger,
  }) : _logger = logger ?? ServiceLocator.instance.get<LoggerService>();

  // Get user badges
  Future<List<UserBadge>> getUserBadges(String userId) async {
    try {
      _logger.debug('Fetching badges for user: $userId');

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      return [
        UserBadge(
          id: '1',
          name: 'Rising Star',
          description: 'Reached 10,000 followers',
          icon: Icons.star,
          color: Colors.amber,
          points: 100,
          category: 'achievement',
          isEarned: true,
          earnedAt: DateTime.now().subtract(const Duration(days: 30)),
          requirement: '10K followers',
          rarity: 'legendary',
          rarityColor: const Color(0xFFF59E0B),
        ),
        UserBadge(
          id: '2',
          name: 'Gift Master',
          description: 'Received 1,000 gifts',
          icon: Icons.card_giftcard,
          color: Colors.purple,
          points: 150,
          category: 'achievement',
          isEarned: true,
          earnedAt: DateTime.now().subtract(const Duration(days: 15)),
          requirement: '1,000 gifts',
          rarity: 'epic',
          rarityColor: const Color(0xFF8B5CF6),
        ),
        UserBadge(
          id: '3',
          name: 'Valentine\'s Special',
          description: 'Participated in Valentine event',
          icon: Icons.favorite,
          color: Colors.red,
          points: 200,
          category: 'event',
          isEarned: true,
          earnedAt: DateTime.now().subtract(const Duration(days: 45)),
          requirement: 'Event participation',
          rarity: 'rare',
          rarityColor: const Color(0xFF3B82F6),
        ),
        UserBadge(
          id: '4',
          name: 'Diamond Elite',
          description: 'Top 1% of gift receivers',
          icon: Icons.diamond,
          color: Colors.blue,
          points: 500,
          category: 'special',
          isEarned: false,
          requirement: 'Be in top 1%',
          rarity: 'legendary',
          rarityColor: const Color(0xFFF59E0B),
        ),
        UserBadge(
          id: '5',
          name: 'New Year 2025',
          description: 'Limited edition New Year badge',
          icon: Icons.emoji_events,
          color: Colors.orange,
          points: 300,
          category: 'limited',
          isEarned: false,
          requirement: 'Login on New Year',
          isLimited: true,
          expiresIn: 30,
          rarity: 'limited',
          rarityColor: const Color(0xFFEF4444),
        ),
        UserBadge(
          id: '6',
          name: 'Crown of Legends',
          description: 'Achieve legendary status',
          icon: Icons.emoji_events,
          color: Colors.amber,
          points: 1000,
          category: 'special',
          isEarned: false,
          requirement: 'Reach level 100',
          rarity: 'legendary',
          rarityColor: const Color(0xFFF59E0B),
        ),
      ];

    } catch (e, stackTrace) {
      _logger.error('Failed to fetch badges', error: e, stackTrace: stackTrace);
      throw Exception('Failed to load badges: $e');
    }
  }

  // Get recent badges
  Future<List<UserBadge>> getRecentBadges(String userId) async {
    try {
      final all = await getUserBadges(userId);
      return all.where((b) => b.isEarned).take(3).toList();
    } catch (e) {
      return [];
    }
  }

  // Get badge stats
  Future<Map<String, dynamic>> getBadgeStats(String userId) async {
    try {
      final badges = await getUserBadges(userId);

      final earned = badges.where((b) => b.isEarned).length;
      final total = badges.length;
      final points = badges.fold<int>(
        0,
            (sum, b) => sum + (b.isEarned ? b.points : 0),
      );

      // Calculate level based on points
      int level = 1;
      if (points >= 1000) level = 5;
      else if (points >= 500) level = 4;
      else if (points >= 200) level = 3;
      else if (points >= 50) level = 2;

      return {
        'earned_count': earned,
        'total_count': total,
        'total_points': points,
        'level': level,
        'next_level_points': level == 5 ? null : level * 200,
      };

    } catch (e) {
      return {
        'earned_count': 0,
        'total_count': 0,
        'total_points': 0,
        'level': 1,
        'next_level_points': 200,
      };
    }
  }

  // Earn badge
  Future<bool> earnBadge(String userId, String badgeId) async {
    try {
      _logger.debug('Earning badge $badgeId for user $userId');

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      return true;

    } catch (e, stackTrace) {
      _logger.error('Failed to earn badge', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Check badge eligibility
  Future<List<UserBadge>> checkEligibleBadges(String userId) async {
    try {
      final all = await getUserBadges(userId);
      return all.where((b) => !b.isEarned).toList();
    } catch (e) {
      return [];
    }
  }

  // Get badge by ID
  Future<UserBadge?> getBadgeById(String badgeId) async {
    try {
      _logger.debug('Fetching badge by ID: $badgeId');

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data
      return UserBadge(
        id: badgeId,
        name: 'Sample Badge',
        description: 'Sample badge description',
        icon: Icons.military_tech,
        color: Colors.amber,
        points: 100,
        category: 'achievement',
        isEarned: true,
        earnedAt: DateTime.now(),
        requirement: 'Sample requirement',
        rarity: 'common',
        rarityColor: const Color(0xFF6B7280),
      );

    } catch (e, stackTrace) {
      _logger.error('Failed to fetch badge', error: e, stackTrace: stackTrace);
      return null;
    }
  }
}

// Profile Badge Widget (simplified version)
class ProfileBadge extends StatelessWidget {
  final UserBadge badge;
  final VoidCallback? onTap;
  final VoidCallback? onEquip;

  const ProfileBadge({
    super.key,
    required this.badge,
    this.onTap,
    this.onEquip,
  });

  @override
  Widget build(BuildContext context) {
    final isAcquired = badge.isAcquired;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isAcquired ? badge.rarityColor.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Badge Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isAcquired ? badge.rarityColor.withOpacity(0.2) : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    badge.icon,
                    size: 30,
                    color: isAcquired ? badge.rarityColor : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),

                // Badge Name
                Text(
                  badge.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isAcquired ? Colors.black87 : Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Badge Description
                Text(
                  badge.description,
                  style: TextStyle(
                    fontSize: 8,
                    color: isAcquired ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            // Locked Overlay
            if (!isAcquired)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),

            // Equip Button
            if (onEquip != null && isAcquired)
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onEquip,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: badge.rarityColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.stars,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Main Badges Screen - সাথে ToastMixin মিক্সিন
class BadgesScreen extends StatefulWidget {
  final String userId;

  const BadgesScreen({
    super.key,
    required this.userId,
  });

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('userId', userId));
  }
}

class _BadgesScreenState extends State<BadgesScreen> with ToastMixin { // ToastMixin যোগ করা হয়েছে
  final BadgeService _badgeService = ServiceLocator.instance.get<BadgeService>();
  final NotificationService _notificationService = ServiceLocator.instance.get<NotificationService>();

  List<UserBadge> _badges = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _selectedRarity = 'All';

  final List<String> _categories = ['All', 'achievement', 'event', 'vip', 'svip', 'limited'];
  final List<String> _rarities = ['All', 'common', 'rare', 'epic', 'legendary', 'limited'];

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final badges = await _badgeService.getUserBadges(widget.userId);

      setState(() {
        _badges = badges;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<UserBadge> get _filteredBadges {
    return _badges.where((badge) {
      // Filter by category
      if (_selectedCategory != 'All') {
        if (badge.category != _selectedCategory) {
          return false;
        }
      }

      // Filter by rarity
      if (_selectedRarity != 'All') {
        if (badge.rarity != _selectedRarity) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _showBadgeDetails(UserBadge badge) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: badge.rarityColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                badge.icon,
                size: 50,
                color: badge.rarityColor,
              ),
            ),
            const SizedBox(height: 16),

            // Badge Name
            Text(
              badge.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Badge Description
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Badge Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Rarity', badge.rarity, badge.rarityColor),
                  _buildDetailRow('Category', badge.category),
                  if (badge.level != null)
                    _buildDetailRow('Level', '${badge.level}'),
                  if (badge.earnedAt != null)
                    _buildDetailRow('Acquired', _formatDate(badge.earnedAt!)),
                  _buildDetailRow('Points', '${badge.points}'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action Button
            if (badge.isEarned)
              const Text(
                '✓ Earned',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              )
            else
              Column(
                children: [
                  const Text(
                    'How to unlock:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(badge.requirement),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, [Color? color]) {
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
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            )
          else
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _equipBadge(String badgeId) async {
    try {
      // TODO: Implement equip badge logic
      showSuccess('Badge equipped'); // ToastMixin এর showSuccess ব্যবহার
    } catch (e) {
      showError('Failed to equip badge'); // ToastMixin এর showError ব্যবহার
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
                onPressed: _loadBadges,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Badges'),
        backgroundColor: Colors.amber,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Category Filter
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: _categories.map((String category) {
                    final displayCategory = category == 'All' ? 'All' : category[0].toUpperCase() + category.substring(1);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(displayCategory),
                        selected: _selectedCategory == category,
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        backgroundColor: Colors.white.withOpacity(0.2),
                        selectedColor: Colors.white,
                        labelStyle: TextStyle(
                          color: _selectedCategory == category ? Colors.amber : Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Rarity Filter
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: _rarities.map((String rarity) {
                    final displayRarity = rarity == 'All' ? 'All' : rarity[0].toUpperCase() + rarity.substring(1);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(displayRarity),
                        selected: _selectedRarity == rarity,
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedRarity = rarity;
                          });
                        },
                        backgroundColor: Colors.white.withOpacity(0.2),
                        selectedColor: Colors.white,
                        labelStyle: TextStyle(
                          color: _selectedRarity == rarity ? Colors.amber : Colors.white,
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
      body: _filteredBadges.isEmpty
          ? const EmptyStateWidget(
        title: 'No Badges',
        message: "This user hasn't earned any badges yet",
        icon: Icons.emoji_events,
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.9,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _filteredBadges.length,
        itemBuilder: (BuildContext context, int index) {
          final badge = _filteredBadges[index];
          return ProfileBadge(
            badge: badge,
            onTap: () => _showBadgeDetails(badge),
            onEquip: badge.isEarned ? () => _equipBadge(badge.id) : null,
          );
        },
      ),
    );
  }
}