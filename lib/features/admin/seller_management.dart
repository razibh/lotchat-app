import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/admin_service.dart';
import '../../core/services/payment_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/dialog_mixin.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class SellerManagement extends StatefulWidget {
  const SellerManagement({super.key});

  @override
  State<SellerManagement> createState() => _SellerManagementState();
}

class _SellerManagementState extends State<SellerManagement> 
    with LoadingMixin, ToastMixin, DialogMixin {
  
  final AdminService _adminService = ServiceLocator().get<AdminService>();
  final PaymentService _paymentService = ServiceLocator().get<PaymentService>();
  
  List<Map<String, dynamic>> _sellers = <Map<String, dynamic>>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSellers();
  }

  Future<void> _loadSellers() async {
    await runWithLoading(() async {
      try {
        // Mock data
        _sellers = List.generate(5, (int index) => <String, dynamic>{
          'id': 'seller_$index',
          'name': 'Seller ${index + 1}',
          'email': 'seller$index@example.com',
          'coinBalance': 100000 * (index + 1),
          'totalCoinsSold': 50000 * (index + 1),
          'commissionRate': 0.1 + (index * 0.02),
          'isActive': index % 2 == 0,
          'createdAt': DateTime.now().subtract(Duration(days: index * 30)),
        },);
      } catch (e) {
        showError('Failed to load sellers: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _createSeller() async {
    final String? userId = await showInputDialog(
      context,
      title: 'User ID',
      hintText: 'Enter user ID',
    );

    if (userId != null && userId.isNotEmpty) {
      final String? commission = await showInputDialog(
        context,
        title: 'Commission Rate',
        hintText: 'Enter commission rate (0.1 = 10%)',
      );

      if (commission != null && commission.isNotEmpty) {
        final double? rate = double.tryParse(commission);
        if (rate != null) {
          final String? coins = await showInputDialog(
            context,
            title: 'Initial Coins',
            hintText: 'Enter initial coin balance',
          );

          if (coins != null && coins.isNotEmpty) {
            final int? initialCoins = int.tryParse(coins);
            if (initialCoins != null) {
              await runWithLoading(() async {
                try {
                  await _adminService.createSeller(
                    userId: userId,
                    commissionRate: rate,
                    initialCoins: initialCoins,
                  );
                  showSuccess('Seller created successfully');
                  _loadSellers();
                } catch (e) {
                  showError('Failed to create seller: $e');
                }
              });
            }
          }
        }
      }
    }
  }

  Future<void> _addCoins(Map<String, dynamic> seller) async {
    final String? amount = await showInputDialog(
      context,
      title: 'Add Coins',
      hintText: 'Enter coin amount',
    );

    if (amount != null && amount.isNotEmpty) {
      final int? coins = int.tryParse(amount);
      if (coins != null && coins > 0) {
        await runWithLoading(() async {
          try {
            await _adminService.addCoinsToSeller(
              sellerId: seller['id'],
              amount: coins,
            );
            showSuccess('$coins coins added to ${seller['name']}');
            _loadSellers();
          } catch (e) {
            showError('Failed to add coins: $e');
          }
        });
      }
    }
  }

  Future<void> _toggleStatus(Map<String, dynamic> seller) async {
    await runWithLoading(() async {
      try {
        final bool newStatus = !seller['isActive'];
        // Update seller status
        showSuccess('Seller ${newStatus ? 'activated' : 'deactivated'}');
        _loadSellers();
      } catch (e) {
        showError('Failed to update status: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Management'),
        backgroundColor: Colors.green,
        actions: <>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createSeller,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _sellers.length,
              itemBuilder: (BuildContext context, int index) {
                final Map<String, dynamic> seller = _sellers[index];
                return _buildSellerCard(seller);
              },
            ),
    );
  }

  Widget _buildSellerCard(Map<String, dynamic> seller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <>[
            // Header
            Row(
              children: <>[
                CircleAvatar(
                  backgroundColor: seller['isActive'] ? Colors.green : Colors.grey,
                  child: Text(
                    seller['name'][0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <>[
                      Text(
                        seller['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        seller['email'],
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: seller['isActive'] ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    seller['isActive'] ? 'Active' : 'Inactive',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stats
            Row(
              children: <>[
                Expanded(
                  child: _buildStatItem(
                    'Coin Balance',
                    '${seller['coinBalance']}',
                    Icons.account_balance_wallet,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total Sold',
                    '${seller['totalCoinsSold']}',
                    Icons.trending_up,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: <>[
                Expanded(
                  child: _buildStatItem(
                    'Commission',
                    '${(seller['commissionRate'] * 100).toInt()}%',
                    Icons.percent,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Joined',
                    _formatDate(seller['createdAt']),
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Actions
            Row(
              children: <>[
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.add_card,
                    label: 'Add Coins',
                    color: Colors.green,
                    onTap: () => _addCoins(seller),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    icon: seller['isActive'] ? Icons.pause : Icons.play_arrow,
                    label: seller['isActive'] ? 'Deactivate' : 'Activate',
                    color: seller['isActive'] ? Colors.orange : Colors.green,
                    onTap: () => _toggleStatus(seller),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.history,
                    label: 'History',
                    color: Colors.blue,
                    onTap: () => _viewHistory(seller),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: <>[
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <>[
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: <>[
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewHistory(Map<String, dynamic> seller) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Sales History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 5,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                leading: const Icon(Icons.sell, color: Colors.green),
                title: Text('Sale #${index + 1}'),
                subtitle: Text('${(index + 1) * 1000} coins'),
                trailing: Text('\$${(index + 1) * 10}'),
              );
            },
          ),
        ),
        actions: <>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}