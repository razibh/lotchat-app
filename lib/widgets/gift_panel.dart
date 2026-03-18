import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:lottie/lottie.dart';
import '../core/models/gift_model.dart';

class GiftPanel extends StatefulWidget {
  final Function(GiftModel) onSendGift;
  final VoidCallback onClose;
  final String? receiverId;

  const GiftPanel({
    required this.onSendGift,
    required this.onClose,
    this.receiverId,
    super.key,
  });

  @override
  State<GiftPanel> createState() => _GiftPanelState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<Function(GiftModel)>.has('onSendGift', onSendGift));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onClose', onClose));
    properties.add(StringProperty('receiverId', receiverId));
  }
}

class _GiftPanelState extends State<GiftPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int multiplier = 1;
  String selectedCategory = 'Cute';
  GiftModel? selectedGift;
  int userCoins = 5000;

  final List<String> categories = ['Cute', 'Luxury', 'VIP', 'SVIP', 'Special'];

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
      height: 500,
      decoration: const BoxDecoration(
        color: Color(0xFF1a1a2e),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: [
                if (widget.receiverId != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Colors.purple, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'To: ${widget.receiverId!.substring(0, 6)}...',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                const Text(
                  'Send Gift',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
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
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: categories.map((cat) => Tab(text: cat)).toList(),
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
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: [
                // Multiplier
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [1, 5, 10, 99].map((int m) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            multiplier = m;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: multiplier == m ? Colors.purple : Colors.transparent,
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

                // User coins
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Your Coins',
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                      Text(
                        '$userCoins',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Send Button
                ElevatedButton(
                  onPressed: selectedGift != null
                      ? () {
                    if (userCoins >= selectedGift!.price * multiplier) {
                      final giftToSend = selectedGift!.copyWith(
                        price: selectedGift!.price * multiplier,
                      );
                      widget.onSendGift(giftToSend);
                      setState(() {
                        userCoins -= selectedGift!.price * multiplier;
                        selectedGift = null;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Insufficient coins!'),
                          backgroundColor: Colors.red,
                        ),
                      );
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
        .where((g) => g.category == category)
        .toList();

    if (gifts.isEmpty) {
      return const Center(
        child: Text(
          'No gifts in this category',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: gifts.length,
      itemBuilder: (context, index) {
        final gift = gifts[index];
        final isSelected = selectedGift?.id == gift.id;
        final canAfford = userCoins >= gift.price * multiplier;

        return GestureDetector(
          onTap: canAfford
              ? () {
            setState(() {
              selectedGift = gift;
            });
          }
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.purple.withOpacity(0.3)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Colors.purple : Colors.transparent,
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Lottie.asset(
                          gift.animationPath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.card_giftcard,
                              color: Colors.white.withOpacity(0.7),
                              size: 40,
                            );
                          },
                        ),
                      ),
                    ),
                    Text(
                      gift.name,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
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
                if (!canAfford)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: Icon(Icons.lock, color: Colors.white70, size: 30),
                      ),
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