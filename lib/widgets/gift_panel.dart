import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../core/models/gift_model.dart';

class GiftPanel extends StatefulWidget {
  final Function(GiftModel) onSendGift;
  final VoidCallback onClose;
  
  const GiftPanel({
    super.key,
    required this.onSendGift,
    required this.onClose,
  });

  @override
  State<GiftPanel> createState() => _GiftPanelState();
}

class _GiftPanelState extends State<GiftPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int multiplier = 1;
  String selectedCategory = 'Cute';
  GiftModel? selectedGift;
  int userCoins = 5000; // Get from user provider
  
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
      height: 400,
      decoration: BoxDecoration(
        color: Color(0xFF1a1a2e),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Send Gift',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                // Recent Gifters Strip
                Container(
                  height: 30,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 30,
                        margin: EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'U${index + 1}',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
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
            tabs: categories.map((cat) => Tab(text: cat)).toList(),
          ),
          
          // Gifts Grid
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: categories.map((category) {
                return _buildGiftGrid(category);
              }).toList(),
            ),
          ),
          
          // Bottom Controls
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: [
                // Multiplier
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [1, 5, 10, 99].map((m) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            multiplier = m;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                Spacer(),
                
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
    final gifts = GiftModel.getGifts()
        .where((g) => g.category == category)
        .toList();
    
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
          onTap: () {
            setState(() {
              selectedGift = gift;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.purple.withOpacity(0.3)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? Colors.purple
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Lottie.asset(
                      gift.animationPath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Text(
                  gift.name,
                  style: TextStyle(
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
}