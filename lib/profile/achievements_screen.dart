import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement_model.dart';
import '../providers/profile_provider.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/notification_service.dart';
import '../../../widgets/common/empty_state_widget.dart';
import '../../../widgets/animation/fade_animation.dart';

class AchievementsScreen extends StatefulWidget {

  const AchievementsScreen({Key? key, required this.userId}) : super(key: key);
  final String userId;

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final NotificationService _notificationService = ServiceLocator().get<NotificationService>();
  String _selectedCategory = 'All';

  final List<String> _categories = <String>['All', 'Social', 'Games', 'Gifts', 'Activity', 'Special'];

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingAchievements) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final achievements = _filterAchievements(provider.achievements);
        final unlockedCount = provider.achievements.where((a) => a.isUnlocked).length;
        final totalCount = provider.achievements.length;
        final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Achievements'),
            backgroundColor: Colors.green,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Column(
                children: <>[
                  // Progress Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: <>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <>[
                            Text(
                              'Progress',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              '$unlockedCount/$totalCount',
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
                            value: progress,
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
                            onSelected: (selected) {
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
          body: achievements.isEmpty
              ? const EmptyStateWidget(
                  title: 'No Achievements',
                  message: 'No achievements available',
                  icon: Icons.emoji_events,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = achievements[index];
                    return FadeAnimation(
                      delay: Duration(milliseconds: index * 50),
                      child: _buildAchievementCard(achievement),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildAchievementCard(AchievementModel achievement) {
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
            children: <>[
              // Achievement Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: achievement.rarityColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Image.network(
                  achievement.iconUrl,
                  width: 30,
                  height: 30,
                  errorBuilder: (context, error, stack) {
                    return Icon(
                      Icons.emoji_events,
                      size: 30,
                      color: achievement.rarityColor,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Achievement Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <>[
                    Row(
                      children: <>[
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
                            achievement.rarity.toString().split('.').last,
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
                    if (!isUnlocked) ...<>[
                      Row(
                        children: <>[
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
                    ] else ...<>[
                      Row(
                        children: <>[
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
                          if (achievement.coinReward > 0) ...<>[
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

  void _showAchievementDetails(AchievementModel achievement) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            // Achievement Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: achievement.rarityColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Image.network(
                achievement.iconUrl,
                width: 50,
                height: 50,
                errorBuilder: (context, error, stack) {
                  return Icon(
                    Icons.emoji_events,
                    size: 50,
                    color: achievement.rarityColor,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Achievement Name
            Text(
              achievement.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Achievement Description
            Text(
              achievement.description,
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
                children: <>[
                  _buildDetailRow('Rarity', achievement.rarity.toString().split('.').last),
                  _buildDetailRow('Category', achievement.category.toString().split('.').last),
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
            else ...<>[
              const Text(
                'How to unlock:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...achievement.requirements.entries.map((entry) {
                return Text('• ${entry.key}: ${entry.value}');
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <>[
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  List<AchievementModel> _filterAchievements(List<AchievementModel> achievements) {
    if (_selectedCategory == 'All') return achievements;
    
    final String category = _selectedCategory.toLowerCase();
    return achievements.where((Object? a) {
      return a.category.toString().split('.').last == category;
    }).toList();
  }
}