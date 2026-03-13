import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/badge_model.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_badge.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/notification_service.dart';
import '../../../widgets/common/empty_state_widget.dart';

class BadgesScreen extends StatefulWidget {

  const BadgesScreen({Key? key, required this.userId}) : super(key: key);
  final String userId;

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  final NotificationService _notificationService = ServiceLocator().get<NotificationService>();
  String _selectedCategory = 'All';
  String _selectedRarity = 'All';

  final List<String> _categories = <String>['All', 'Achievement', 'Event', 'VIP', 'SVIP'];
  final List<String> _rarities = <String>['All', 'Common', 'Rare', 'Epic', 'Legendary', 'Limited'];

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingBadges) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final badges = _filterBadges(provider.badges);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Badges'),
            backgroundColor: Colors.amber,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Column(
                children: <>[
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
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(rarity),
                            selected: _selectedRarity == rarity,
                            onSelected: (selected) {
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
          body: badges.isEmpty
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
                  itemCount: badges.length,
                  itemBuilder: (context, index) {
                    final badge = badges[index];
                    return ProfileBadge(
                      badge: badge,
                      onTap: () => _showBadgeDetails(badge),
                      onEquip: badge.isAcquired && !badge.isEquipped
                          ? () => _equipBadge(badge.id)
                          : null,
                    );
                  },
                ),
        );
      },
    );
  }

  List<BadgeModel> _filterBadges(List<BadgeModel> badges) {
    return badges.where((Object? badge) {
      // Filter by category
      if (_selectedCategory != 'All') {
        final String category = _selectedCategory.toLowerCase();
        if (badge.category.toString().split('.').last != category) {
          return false;
        }
      }

      // Filter by rarity
      if (_selectedRarity != 'All') {
        final String rarity = _selectedRarity.toLowerCase();
        if (badge.rarity.toString().split('.').last != rarity) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _showBadgeDetails(BadgeModel badge) {
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
            // Badge Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: badge.rarityColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Image.network(
                badge.iconUrl,
                width: 60,
                height: 60,
                errorBuilder: (context, error, stack) {
                  return Icon(
                    Icons.emoji_events,
                    size: 50,
                    color: badge.rarityColor,
                  );
                },
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
                children: <>[
                  _buildDetailRow('Rarity', badge.rarity.toString().split('.').last),
                  _buildDetailRow('Category', badge.category.toString().split('.').last),
                  if (badge.level != null)
                    _buildDetailRow('Level', '${badge.level}'),
                  if (badge.acquiredAt != null)
                    _buildDetailRow('Acquired', _formatDate(badge.acquiredAt!)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action Button
            if (badge.isAcquired && !badge.isEquipped)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _equipBadge(badge.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Equip Badge'),
              )
            else if (badge.isEquipped)
              const Text(
                'Currently Equipped',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              )
            else
              Column(
                children: <>[
                  const Text(
                    'How to unlock:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...badge.requirements.entries.map((entry) {
                    return Text('• ${entry.key}: ${entry.value}');
                  }),
                ],
              ),
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

  Future<void> _equipBadge(String badgeId) async {
    try {
      await context.read<ProfileProvider>().equipBadge(badgeId);
      _notificationService.showSuccess('Badge equipped');
    } catch (e) {
      _notificationService.showError('Failed to equip badge');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}