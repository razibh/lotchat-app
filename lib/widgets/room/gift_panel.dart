import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/gift_service.dart';
import '../../core/services/payment_service.dart';
import '../../core/models/gift_model.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import 'gift_item.dart';
import 'gift_category_tab.dart';
import 'gift_combo_selector.dart';
import 'recent_gifters.dart';

class GiftPanel extends StatefulWidget {

  const GiftPanel({
    Key? key,
    required this.receiverId,
    this.roomId,
    this.onGiftSent,
  }) : super(key: key);
  final String receiverId;
  final String? roomId;
  final Function(GiftModel, int)? onGiftSent;

  @override
  State<GiftPanel> createState() => _GiftPanelState();
}

class _GiftPanelState extends State<GiftPanel> with LoadingMixin, ToastMixin {
  final GiftService _giftService = ServiceLocator().get<GiftService>();
  final PaymentService _paymentService = ServiceLocator().get<PaymentService>();
  
  late Future<List<GiftModel>> _giftsFuture;
  List<GiftModel> _gifts = <GiftModel>[];
  List<GiftModel> _filteredGifts = <GiftModel>[];
  String _selectedCategory = 'All';
  GiftModel? _selectedGift;
  int _comboMultiplier = 1;
  int _userCoins = 0;
  bool _showPreview = false;

  final List<String> _categories = <String>[
    'All', 'Cute', 'Luxury', 'VIP', 'SVIP', 'Special', 'Limited'
  ];

  @override
  void initState() {
    super.initState();
    _giftsFuture = _loadGifts();
    _loadUserCoins();
  }

  Future<List<GiftModel>> _loadGifts() async {
    final List<GiftModel> gifts = await _giftService.getAvailableGifts();
    setState(() {
      _gifts = gifts;
      _filteredGifts = gifts;
    });
    return gifts;
  }

  Future<void> _loadUserCoins() async {
    final coins = await _paymentService.getUserCoins();
    setState(() {
      _userCoins = coins;
    });
  }

  void _filterGifts(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All') {
        _filteredGifts = _gifts;
      } else {
        _filteredGifts = _gifts.where((GiftModel g) => g.category == category).toList();
      }
    });
  }

  Future<void> _sendGift() async {
    if (_selectedGift == null) {
      showError('Please select a gift');
      return;
    }

    final int totalPrice = _selectedGift!.price * _comboMultiplier;
    
    if (_userCoins < totalPrice) {
      showError('Not enough coins');
      return;
    }

    await runWithLoading(() async {
      try {
        await _giftService.sendGift(
          receiverId: widget.receiverId,
          giftId: _selectedGift!.id,
          amount: totalPrice,
          roomId: widget.roomId,
        );
        
        widget.onGiftSent?.call(_selectedGift!, _comboMultiplier);
        showSuccess('Gift sent successfully!');
        Navigator.pop(context);
      } catch (e) {
        showError('Failed to send gift: $e');
      }
    });
  }

  void _showGiftPreview(GiftModel gift) {
    setState(() {
      _selectedGift = gift;
      _showPreview = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: <>[
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: <>[
          // Header
          _buildHeader(),
          
          // Recent Gifters
          RecentGifters(receiverId: widget.receiverId),
          
          // Category Tabs
          GiftCategoryTab(
            categories: _categories,
            selectedCategory: _selectedCategory,
            onCategorySelected: _filterGifts,
          ),
          
          // Combo Multiplier
          GiftComboSelector(
            multiplier: _comboMultiplier,
            onChanged: (int value) {
              setState(() {
                _comboMultiplier = value;
              });
            },
          ),
          
          // Gifts Grid
          Expanded(
            child: FutureBuilder<List<GiftModel>>(
              future: _giftsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: _filteredGifts.length,
                  itemBuilder: (context, index) {
                    final GiftModel gift = _filteredGifts[index];
                    return GiftItem(
                      gift: gift,
                      isSelected: _selectedGift?.id == gift.id,
                      onTap: () => _showGiftPreview(gift),
                    );
                  },
                );
              },
            ),
          ),
          
          // Bottom Bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <>[
          const Text(
            'Send Gift',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: <>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: <>[
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$_userCoins',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: <>[
          // Selected gift preview
          if (_selectedGift != null)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _selectedGift!.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _selectedGift!.icon,
                color: _selectedGift!.color,
              ),
            ),
          
          if (_selectedGift != null) ...<>[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <>[
                  Text(
                    _selectedGift!.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_selectedGift!.price * _comboMultiplier} coins',
                    style: TextStyle(
                      color: _userCoins >= _selectedGift!.price * _comboMultiplier
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Send button
          ElevatedButton(
            onPressed: _selectedGift != null ? _sendGift : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              minimumSize: const Size(100, 45),
            ),
            child: Text(
              _selectedGift != null
                  ? 'Send ${_comboMultiplier}x'
                  : 'Select Gift',
            ),
          ),
        ],
      ),
    );
  }
}