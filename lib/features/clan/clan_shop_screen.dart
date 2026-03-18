import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // DiagnosticPropertiesBuilder এর জন্য
import '../../core/di/service_locator.dart';
import '../clan/services/clan_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/dialog_mixin.dart';
import '../../widgets/animation/fade_animation.dart';

class ClanShopScreen extends StatefulWidget {
  final String clanId;

  const ClanShopScreen({required this.clanId, super.key});

  @override
  State<ClanShopScreen> createState() => _ClanShopScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('clanId', clanId));
  }
}

class _ClanShopScreenState extends State<ClanShopScreen>
    with LoadingMixin, ToastMixin, DialogMixin {

  final ClanService _clanService = ServiceLocator().get<ClanService>();

  int _clanCoins = 1250;
  String _selectedCategory = 'All';
  List<ClanShopItem> _items = [];

  final List<String> _categories = ['All', 'Badges', 'Frames', 'Effects', 'Gifts'];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    await runWithLoading(() async {
      await Future.delayed(const Duration(seconds: 1));

      _items = [
        ClanShopItem(
          id: '1',
          name: 'Clan Warrior Badge',
          description: 'Show off your clan warrior status',
          price: 500,
          category: 'Badges',
          icon: Icons.military_tech,
          color: Colors.red,
          level: 1,
        ),
        ClanShopItem(
          id: '2',
          name: 'Golden Clan Frame',
          description: 'Premium frame for your profile',
          price: 1000,
          category: 'Frames',
          icon: Icons.military_tech,
          color: Colors.amber,
          level: 3,
        ),
        ClanShopItem(
          id: '3',
          name: 'Clan Entry Effect',
          description: 'Special effect when entering rooms',
          price: 800,
          category: 'Effects',
          icon: Icons.auto_awesome,
          color: Colors.purple,
          level: 2,
        ),
        ClanShopItem(
          id: '4',
          name: 'Clan Gift Box',
          description: 'Special gift for clan members',
          price: 300,
          category: 'Gifts',
          icon: Icons.card_giftcard,
          color: Colors.pink,
          level: 1,
        ),
        ClanShopItem(
          id: '5',
          name: 'Dragon Badge',
          description: 'Legendary dragon clan badge',
          price: 2000,
          category: 'Badges',
          icon: Icons.whatshot,
          color: Colors.orange,
          level: 5,
        ),
        ClanShopItem(
          id: '6',
          name: 'Animated Clan Frame',
          description: 'Animated frame with clan logo',
          price: 1500,
          category: 'Frames',
          icon: Icons.animation,
          color: Colors.blue,
          level: 4,
        ),
        ClanShopItem(
          id: '7',
          name: 'Phoenix Entry Effect',
          description: 'Spectacular phoenix entrance',
          price: 2500,
          category: 'Effects',
          icon: Icons.auto_fix_high,
          color: Colors.deepPurple,
          level: 5,
        ),
        ClanShopItem(
          id: '8',
          name: 'Clan Celebration Pack',
          description: 'Pack of 5 exclusive gifts',
          price: 1200,
          category: 'Gifts',
          icon: Icons.cake,
          color: Colors.teal,
          level: 3,
        ),
      ];
    });
  }

  List<ClanShopItem> get _filteredItems {
    if (_selectedCategory == 'All') {
      return _items;
    }
    return _items.where((ClanShopItem item) => item.category == _selectedCategory).toList();
  }

  Future<void> _purchaseItem(ClanShopItem item) async {
    if (_clanCoins < item.price) {
      showError('Not enough clan coins');
      return;
    }

    final bool? confirmed = await showConfirmDialog(
      context,
      title: 'Purchase Item',
      message: 'Buy ${item.name} for ${item.price} clan coins?',
    );

    if (confirmed ?? false) {
      await runWithLoading(() async {
        await Future.delayed(const Duration(seconds: 1));

        setState(() {
          _clanCoins -= item.price;
        });

        showSuccess('Item purchased successfully!');
      });
    }
  }

  Widget _buildBuyButton(ClanShopItem item) {
    final bool canAfford = _clanCoins >= item.price;

    return SizedBox(
      width: double.infinity,
      height: 28,
      child: ElevatedButton(
        onPressed: canAfford ? () => _purchaseItem(item) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: item.color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Buy',
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clan Shop'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$_clanCoins',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
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
                      color: _selectedCategory == category ? Colors.deepPurple : Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _filteredItems.length,
        itemBuilder: (BuildContext context, int index) {
          final ClanShopItem item = _filteredItems[index];

          return FadeAnimation(
            delay: Duration(milliseconds: index * 100),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Item Image
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.2),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          item.icon,
                          size: 50,
                          color: item.color,
                        ),
                      ),
                    ),
                  ),

                  // Item Info
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.description,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.monetization_on,
                                      size: 10,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${item.price}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Lvl ${item.level}',
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          _buildBuyButton(item),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ClanShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final String category;
  final IconData icon;
  final Color color;
  final int level;

  ClanShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.icon,
    required this.color,
    required this.level,
  });
}