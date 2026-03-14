import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../core/models/gift_model.dart';

class GiftPanel extends StatefulWidget {
  
  const GiftPanel({
    required this.onSendGift, required this.onClose, super.key,
  });
  final Function(GiftModel) onSendGift;
  final VoidCallback onClose;

  @override
  State<GiftPanel> createState() => _GiftPanelState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<Function(GiftModel)>.has('onSendGift', onSendGift));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onClose', onClose));
  }
}

class _GiftPanelState extends State<GiftPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int multiplier = 1;
  String selectedCategory = 'Cute';
  GiftModel? selectedGift;
  int userCoins = 5000; // Get from user provider
  
  final List<String> categories = <String>['Cute', 'Luxury', 'VIP', 'SVIP', 'Special'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectedCategory = categories[_tabController.index];
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: const BoxDecoration(
        color: Color(0xFF1a1a2e),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: <>[
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            child: Row(
              children: <>[
                const Text(
                  'Send Gift',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Recent Gifters Strip
                SizedBox(
                  height: 30,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: 3,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        width: 30,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: const BoxDecoration(
                          color: Colors.purple,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'U${index + 1}',
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
          
          // Categories Tab
          TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.purple,
            tabs: categories.map((String cat) => Tab(text: cat)).toList(),
          ),
          
          // Gifts Grid
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: categories.map(_buildGiftGrid).toList(),
            ),
          ),
          
          // Bottom Controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            child: Row(
              children: <>[
                // Multiplier
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: <int>[1, 5, 10, 99].map((int m) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            multiplier = m;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: multiplier == m
                                ? Colors.purple
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '×$m',
                            style: TextStyle(
                              color: multiplier == m ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Spacer(),
                
                // Send Button
                ElevatedButton(
                  onPressed: selectedGift != null
                      ? () {
                          if (userCoins >= selectedGift!.price * multiplier) {
                            widget.onSendGift(selectedGift!);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedGift != null &&
                        userCoins >= selectedGift!.price * multiplier
                        ? Colors.purple
                        : Colors.grey,
                  ),
                  child: Text(
                    selectedGift != null
                        ? 'Send ${selectedGift!.price * multiplier}'
                        : 'Select Gift',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGiftGrid(String category) {
    final List<GiftModel> gifts = GiftModel.getGifts()
        .where((GiftModel g) => g.category == category)
        .toList();
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: gifts.length,
      itemBuilder: (BuildContext context, int index) {
        final GiftModel gift = gifts[index];
        final bool isSelected = selectedGift?.id == gift.id;
        final bool canAfford = userCoins >= gift.price * multiplier;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedGift = gift;
            });
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.purple.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? Colors.purple
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              children: <>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Lottie.asset(
                      gift.animationPath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Text(
                  gift.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${gift.price}',
                  style: TextStyle(
                    color: canAfford ? Colors.green : Colors.red,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('multiplier', multiplier));
    properties.add(StringProperty('selectedCategory', selectedCategory));
    properties.add(DiagnosticsProperty<GiftModel?>('selectedGift', selectedGift));
    properties.add(IntProperty('userCoins', userCoins));
    properties.add(IterableProperty<String>('categories', categories));
  }
}