import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/payment_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/animation/fade_animation.dart';
import 'recharge_screen.dart';
import 'withdraw_screen.dart';
import 'transaction_history_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with LoadingMixin, ToastMixin {

  final PaymentService _paymentService = ServiceLocator.instance.get<PaymentService>();

  final int _coins = 15000;
  final int _diamonds = 500;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const TransactionHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Balance Card
          FadeAnimation(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.pink],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.yellow, size: 30),
                      const SizedBox(width: 8),
                      Text(
                        '$_coins',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.diamond, color: Colors.cyan, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '$_diamonds Diamonds',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Quick Actions
          FadeAnimation(
            delay: const Duration(milliseconds: 100),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.add_circle,
                    label: 'Recharge',
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => const RechargeScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.remove_circle,
                    label: 'Withdraw',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => const WithdrawScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Coin Packages
          const FadeAnimation(
            delay: Duration(milliseconds: 200),
            child: Text(
              'Buy Coins',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),

          ...List.generate(4, (int index) {
            final List<int> coinsList = [10000, 50000, 100000, 500000];
            final List<double> priceList = [1, 5, 10, 50];
            final int coins = coinsList[index];
            final double price = priceList[index];
            final bool popular = index == 1;

            return FadeAnimation(
              delay: Duration(milliseconds: 300 + index * 100),
              child: _buildPackageCard(
                coins: coins,
                price: price,
                popular: popular,
              ),
            );
          }),
          const SizedBox(height: 20),

          // Diamond Exchange
          FadeAnimation(
            delay: const Duration(milliseconds: 600),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Exchange Diamonds',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '100 Diamonds = 50 Coins',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Exchange',
                      onPressed: () {},
                      color: Colors.cyan,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard({
    required int coins,
    required double price,
    bool popular = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: popular ? Colors.purple : Colors.grey.shade300,
          width: popular ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          if (popular)
            Positioned(
              top: 0,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: const BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  'POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.monetization_on, color: Colors.yellow, size: 40),
            title: Text(
              '$coins Coins',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('\$$price USD'),
            trailing: CustomButton(
              text: 'Buy',
              onPressed: () {
                _showPaymentDialog(coins, price);
              },
              color: Colors.purple,
              height: 36,
              isFullWidth: false,
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(int coins, double price) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildPaymentMethod(
              icon: Icons.credit_card,
              name: 'Credit Card',
              onTap: () {
                Navigator.pop(context);
                showSuccess('Payment successful!');
              },
            ),
            _buildPaymentMethod(
              icon: Icons.account_balance,
              name: 'Google Pay',
              onTap: () {
                Navigator.pop(context);
                showSuccess('Payment successful!');
              },
            ),
            _buildPaymentMethod(
              icon: Icons.phone_iphone,
              name: 'Apple Pay',
              onTap: () {
                Navigator.pop(context);
                showSuccess('Payment successful!');
              },
            ),
            _buildPaymentMethod(
              icon: Icons.payment,
              name: 'PayPal',
              onTap: () {
                Navigator.pop(context);
                showSuccess('Payment successful!');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod({
    required IconData icon,
    required String name,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple),
      title: Text(name),
      onTap: onTap,
    );
  }
}