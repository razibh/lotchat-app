import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/neumorphic_button.dart';
import '../../core/widgets/neumorphic_text_field.dart';

class RechargeScreen extends StatefulWidget {
  const RechargeScreen({super.key});

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedPaymentMethod;
  final double _currentBalance = 250.50; // This would come from user data

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(name: 'bKash', icon: Icons.phone_android, color: Colors.pink),
    PaymentMethod(name: 'Nagad', icon: Icons.mobile_friendly, color: Colors.orange),
    PaymentMethod(name: 'Rocket', icon: Icons.rocket_launch, color: Colors.red),
    PaymentMethod(name: 'Credit Card', icon: Icons.credit_card, color: Colors.blue),
    PaymentMethod(name: 'PayPal', icon: Icons.paypal, color: Colors.blueAccent),
  ];

  final List<double> _presetAmounts = [100, 250, 500, 1000, 2500, 5000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _processRecharge() {
    final double amount = double.tryParse(_amountController.text) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Confirm Recharge', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Amount: ৳${amount.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Payment Method: $_selectedPaymentMethod',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessDialog(amount);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPurple,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(double amount) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Recharge Successful!',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '৳${amount.toStringAsFixed(2)} added to your wallet',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true); // Return with success
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPurple,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildBalanceCard(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPresetAmounts(),
                      const SizedBox(height: 20),
                      _buildCustomAmount(),
                      const SizedBox(height: 20),
                      _buildPaymentMethods(),
                      const SizedBox(height: 20),
                      _buildPaymentDetails(),
                    ],
                  ),
                ),
              ),
              _buildRechargeButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            'Recharge Wallet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ) ?? const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentPurple.withValues(alpha: 0.3),
            AppColors.accentBlue.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Balance',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                '৳${_currentBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetAmounts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Amounts',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _presetAmounts.length,
          itemBuilder: (BuildContext context, int index) {
            final double amount = _presetAmounts[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _amountController.text = amount.toString();
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _amountController.text == amount.toString()
                        ? AppColors.accentPurple
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '৳$amount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCustomAmount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Custom Amount',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        NeumorphicTextField(
          controller: _amountController,
          hintText: 'Enter amount',
          prefixIcon: Icons.attach_money,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._paymentMethods.map((method) => _buildPaymentMethodTile(method)).toList(),
      ],
    );
  }

  Widget _buildPaymentMethodTile(PaymentMethod method) {
    final bool isSelected = _selectedPaymentMethod == method.name;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method.name;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? method.color.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? method.color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: method.color.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(method.icon, color: method.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                method.name,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: method.color, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetails() {
    if (_selectedPaymentMethod == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Details',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Method', _selectedPaymentMethod!),
          _buildInfoRow('Charge', 'Free'),
          _buildInfoRow('Processing Time', 'Instant'),
          const Divider(color: Colors.white24, height: 24),
          _buildInfoRow(
            'Total',
            '৳${_amountController.text.isEmpty ? '0' : _amountController.text}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? AppColors.accentPurple : Colors.white,
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRechargeButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: NeumorphicButton(
        onPressed: _processRecharge,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: const Center(
            child: Text(
              'RECHARGE NOW',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PaymentMethod {
  final String name;
  final IconData icon;
  final Color color;

  PaymentMethod({
    required this.name,
    required this.icon,
    required this.color,
  });
}