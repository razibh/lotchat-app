import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/neumorphic_button.dart';
import '../badge/seller_badge_widget.dart';
import '../transfer/coin_transfer_screen.dart';
import '../inventory/coin_inventory_screen.dart';

class CoinSellerDashboard extends StatefulWidget {

  const CoinSellerDashboard({required this.sellerId, super.key});
  final String sellerId;

  @override
  State<CoinSellerDashboard> createState() => _CoinSellerDashboardState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('sellerId', sellerId));
  }
}

class _CoinSellerDashboardState extends State<CoinSellerDashboard> {
  bool _isLoading = true;
  Map<String, dynamic> _sellerData = <String, dynamic>{};
  List<CoinTransfer> _recentTransfers = <>[];

  @override
  void initState() {
    super.initState();
    _loadSellerData();
  }

  Future<void> _loadSellerData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _sellerData = <String, dynamic>{
        'id': 'seller_001',
        'businessName': 'Fast Coin BD',
        'ownerName': 'Shahid Khan',
        'email': 'shahid@fastcoin.com',
        'phone': '01712345678',
        'countryId': 'bd',
        'coinBalance': 25000,
        'lockedCoins': 5000,
        'totalSold': 150000,
        'totalRevenue': 75000,
        'discountRate': 15, // 15% discount
        'totalCustomers': 450,
        'rating': 4.8,
        'badge': CoinSellerBadge(
          sellerId: 'seller_001',
          businessName: 'Fast Coin BD',
          discountRate: 15,
          totalSold: 150000,
          rating: 4.8,
          isVerified: true,
        ),
      };

      _recentTransfers = _generateSampleTransfers();
      _isLoading = false;
    });
  }

  List<CoinTransfer> _generateSampleTransfers() {
    return <>[
      CoinTransfer(
        id: 'tr_001',
        sellerId: 'seller_001',
        receiverId: 'user_001',
        coins: 1000,
        amount: 850, // after 15% discount, original price 1000
        sellerProfit: 100, // bought at 750, sold at 850
        transferDate: DateTime.now().subtract(const Duration(hours: 2)),
        status: TransferStatus.completed,
      ),
      CoinTransfer(
        id: 'tr_002',
        sellerId: 'seller_001',
        receiverId: 'user_002',
        coins: 500,
        amount: 425,
        sellerProfit: 50,
        transferDate: DateTime.now().subtract(const Duration(hours: 5)),
        status: TransferStatus.completed,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildDashboard(),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return Column(
      children: <>[
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <>[
                _buildSellerBadgeSection(),
                const SizedBox(height: 20),
                _buildBalanceCard(),
                const SizedBox(height: 20),
                _buildQuickActions(),
                const SizedBox(height: 20),
                _buildStatsGrid(),
                const SizedBox(height: 20),
                _buildRecentTransfers(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <>[
          const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.orange,
            child: Icon(Icons.store, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  _sellerData['businessName'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _sellerData['ownerName'],
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSellerBadgeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <>[
            Colors.orange.withValues(alpha: 0.3),
            Colors.red.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: <>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_offer, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                const Row(
                  children: <>[
                    Text(
                      'Verified Coin Seller',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.verified, color: Colors.blue, size: 16),
                  ],
                ),
                Text(
                  '${_sellerData['discountRate']}% Discount on all coins',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <>[
            Colors.green.withValues(alpha: 0.3),
            Colors.blue.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: <>[
          const Text(
            'Available Coins',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Text(
            '${_sellerData['coinBalance']}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Locked: ${_sellerData['lockedCoins']}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: <>[
        Expanded(
          child: NeumorphicButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CoinTransferScreen(sellerId: widget.sellerId),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Column(
                children: <>[
                  Icon(Icons.send, color: Colors.white),
                  SizedBox(height: 4),
                  Text(
                    'Send Coins',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: NeumorphicButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CoinInventoryScreen(sellerId: widget.sellerId),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Column(
                children: <>[
                  Icon(Icons.inventory, color: Colors.white),
                  SizedBox(height: 4),
                  Text(
                    'Inventory',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: NeumorphicButton(
            onPressed: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Column(
                children: <>[
                  Icon(Icons.show_chart, color: Colors.white),
                  SizedBox(height: 4),
                  Text(
                    'Analytics',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: <>[
        _buildStatCard('Total Sold', '${_sellerData['totalSold']} Coins', Icons.money),
        _buildStatCard('Revenue', '৳${_sellerData['totalRevenue']}', Icons.trending_up),
        _buildStatCard('Customers', '${_sellerData['totalCustomers']}', Icons.people),
        _buildStatCard('Rating', '${_sellerData['rating']} ⭐', Icons.star),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <>[
          Icon(icon, color: Colors.orange),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransfers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <>[
        const Text(
          'Recent Transfers',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ..._recentTransfers.map(_buildTransferTile),
      ],
    );
  }

  Widget _buildTransferTile(CoinTransfer transfer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.currency_exchange, color: Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  '${transfer.coins} Coins',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Amount: ৳${transfer.amount}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <>[
              Text(
                'Profit: ৳${transfer.sellerProfit}',
                style: const TextStyle(color: Colors.green, fontSize: 12),
              ),
              Text(
                _formatDate(transfer.transferDate),
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.hour}:${date.minute}';
  }
}