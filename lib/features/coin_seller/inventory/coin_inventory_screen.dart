import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/neumorphic_button.dart';
import '../../../core/widgets/neumorphic_text_field.dart';
import '../models/seller_models.dart';

class CoinInventoryScreen extends StatefulWidget {

  const CoinInventoryScreen({Key? key, required this.sellerId}) : super(key: key);
  final String sellerId;

  @override
  State<CoinInventoryScreen> createState() => _CoinInventoryScreenState();
}

class _CoinInventoryScreenState extends State<CoinInventoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  
  List<CoinPackage> _packages = <>[];
  List<BulkCoinPurchase> _purchases = <>[];
  final List<CoinTransfer> _recentTransfers = <>[];
  
  final double _totalCoins = 25000;
  final double _lockedCoins = 5000;
  final double _availableCoins = 20000;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInventoryData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInventoryData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _packages = <>[
        CoinPackage(
          id: 'pkg_001',
          name: 'Starter Pack',
          coins: 100,
          regularPrice: 100,
          sellerPrice: 85,
          discountRate: 15,
          isPopular: true,
        ),
        CoinPackage(
          id: 'pkg_002',
          name: 'Popular Pack',
          coins: 500,
          regularPrice: 500,
          sellerPrice: 425,
          discountRate: 15,
          isPopular: true,
        ),
        CoinPackage(
          id: 'pkg_003',
          name: 'Pro Pack',
          coins: 1000,
          regularPrice: 1000,
          sellerPrice: 850,
          discountRate: 15,
        ),
        CoinPackage(
          id: 'pkg_004',
          name: 'Master Pack',
          coins: 5000,
          regularPrice: 5000,
          sellerPrice: 4250,
          discountRate: 15,
        ),
      ];

      _purchases = <>[
        BulkCoinPurchase(
          id: 'buy_001',
          sellerId: widget.sellerId,
          coins: 10000,
          costPrice: 7500,
          pricePerCoin: 0.75,
          supplier: 'Official Recharge Panel',
          purchaseDate: DateTime.now().subtract(const Duration(days: 2)),
          status: PurchaseStatus.completed,
        ),
        BulkCoinPurchase(
          id: 'buy_002',
          sellerId: widget.sellerId,
          coins: 5000,
          costPrice: 4000,
          pricePerCoin: 0.80,
          supplier: 'Wholesale Agent',
          purchaseDate: DateTime.now().subtract(const Duration(days: 5)),
          status: PurchaseStatus.completed,
        ),
      ];

      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: <>[
              _buildHeader(),
              _buildBalanceCard(),
              _buildTabBar(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        controller: _tabController,
                        children: <>[
                          _buildPackagesTab(),
                          _buildPurchasesTab(),
                          _buildTransfersTab(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <>[
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Coin Inventory',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showAddPackageDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <>[
            Colors.green.withOpacity(0.3),
            Colors.blue.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: <>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <>[
              _buildBalanceItem('Total', _totalCoins.toString(), Icons.account_balance),
              _buildBalanceItem('Locked', _lockedCoins.toString(), Icons.lock),
              _buildBalanceItem('Available', _availableCoins.toString(), Icons.check_circle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(String label, String value, IconData icon) {
    return Column(
      children: <>[
        Icon(icon, color: Colors.white),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.orange,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const <>[
          Tab(text: 'Packages'),
          Tab(text: 'Purchases'),
          Tab(text: 'Transfers'),
        ],
      ),
    );
  }

  Widget _buildPackagesTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _packages.length,
      itemBuilder: (context, index) {
        final pkg = _packages[index];
        return _buildPackageCard(pkg);
      },
    );
  }

  Widget _buildPackageCard(CoinPackage pkg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: pkg.isPopular
            ? Border.all(color: Colors.orange, width: 2)
            : null,
      ),
      child: Column(
        children: <>[
          Row(
            children: <>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.inventory, color: Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <>[
                    Row(
                      children: <>[
                        Text(
                          pkg.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        if (pkg.isPopular) ...<>[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Popular', style: TextStyle(color: Colors.white, fontSize: 8)),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${pkg.coins} Coins',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <>[
                  Text(
                    '৳${pkg.currentPrice}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '৳${pkg.regularPrice}',
                    style: const TextStyle(
                      color: Colors.white38,
                      decoration: TextDecoration.lineThrough,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <>[
              _buildActionButton('Edit', Icons.edit, () {}),
              _buildActionButton('Disable', Icons.visibility_off, () {}),
              _buildActionButton('Share', Icons.share, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: <>[
            Icon(icon, color: Colors.white70, size: 14),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchasesTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _purchases.length,
      itemBuilder: (context, index) {
        final purchase = _purchases[index];
        return _buildPurchaseCard(purchase);
      },
    );
  }

  Widget _buildPurchaseCard(BulkCoinPurchase purchase) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_cart, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  '${purchase.coins} Coins',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Cost: ৳${purchase.costPrice}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  'Price/Coin: ৳${purchase.pricePerCoin}',
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  purchase.status.toString().split('.').last,
                  style: const TextStyle(color: Colors.green, fontSize: 10),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(purchase.purchaseDate),
                style: const TextStyle(color: Colors.white38, fontSize: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransfersTab() {
    if (_recentTransfers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <>[
            Icon(Icons.history, size: 60, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No transfers yet',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _recentTransfers.length,
      itemBuilder: (context, index) {
        final transfer = _recentTransfers[index];
        return _buildTransferCard(transfer);
      },
    );
  }

  Widget _buildTransferCard(CoinTransfer transfer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.send, color: Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  'To: ${transfer.receiverName}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${transfer.coins} Coins',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <>[
              Text(
                '৳${transfer.amount}',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              Text(
                'Profit: ৳${transfer.sellerProfit}',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddPackageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Add New Package', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            NeumorphicTextField(
              controller: TextEditingController(),
              hintText: 'Package Name',
            ),
            const SizedBox(height: 12),
            NeumorphicTextField(
              controller: TextEditingController(),
              hintText: 'Coins',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            NeumorphicTextField(
              controller: TextEditingController(),
              hintText: 'Price (৳)',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: <>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Package added successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}