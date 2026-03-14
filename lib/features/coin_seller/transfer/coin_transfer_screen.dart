import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/neumorphic_button.dart';
import '../../../core/widgets/neumorphic_text_field.dart';

class CoinTransferScreen extends StatefulWidget {

  const CoinTransferScreen({required this.sellerId, super.key});
  final String sellerId;

  @override
  State<CoinTransferScreen> createState() => _CoinTransferScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('sellerId', sellerId));
  }
}

class _CoinTransferScreenState extends State<CoinTransferScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _coinsController = TextEditingController();
  
  final double _discountRate = 15; // 15% discount
  final int _officialPricePerCoin = 1; // 1 coin = 1 taka
  bool _isLoading = false;
  String _selectedPaymentMethod = 'Cash';

  int get _coins => int.tryParse(_coinsController.text) ?? 0;
  double get _originalPrice => _coins * _officialPricePerCoin;
  double get _discountAmount => _originalPrice * _discountRate / 100;
  double get _finalPrice => _originalPrice - _discountAmount;
  double get _profit => _finalPrice * 0.2; // 20% profit margin

  final List<String> _paymentMethods = <String>['Cash', 'bKash', 'Nagad', 'Bank Transfer'];

  Future<void> _transferCoins() async {
    if (_userIdController.text.isEmpty) {
      _showError('Please enter user ID');
      return;
    }

    if (_coins <= 0) {
      _showError('Please enter valid coin amount');
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    _showSuccessDialog();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            const Text(
              'Transfer Successful!',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '$_coins coins sent to user ${_userIdController.text}',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              'Amount: ৳${_finalPrice.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: <>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: const Text('Done', style: TextStyle(color: Colors.white)),
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
            children: <>[
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: <>[
                      _buildSellerInfo(),
                      const SizedBox(height: 20),
                      _buildTransferForm(),
                      const SizedBox(height: 20),
                      _buildPriceBreakdown(),
                      const SizedBox(height: 20),
                      _buildPaymentMethod(),
                      const SizedBox(height: 20),
                      _buildTransferButton(),
                    ],
                  ),
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <>[
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Transfer Coins',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: <>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_offer, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                const Text(
                  'Fast Coin BD',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$_discountRate% discount on all coins',
                  style: const TextStyle(color: Colors.orange),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Verified',
              style: TextStyle(color: Colors.green, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <>[
          const Text(
            'Transfer Details',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          NeumorphicTextField(
            controller: _userIdController,
            hintText: 'Enter User ID',
            prefixIcon: Icons.person,
          ),
          const SizedBox(height: 12),
          NeumorphicTextField(
            controller: _coinsController,
            hintText: 'Enter Coin Amount',
            prefixIcon: Icons.monetization_on,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    if (_coins <= 0) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <>[
          _buildPriceRow('Original Price', '৳${_originalPrice.toStringAsFixed(2)}'),
          _buildPriceRow('Discount ($_discountRate%)', '-৳${_discountAmount.toStringAsFixed(2)}', color: Colors.green),
          const Divider(color: Colors.white24, height: 24),
          _buildPriceRow('Final Price', '৳${_finalPrice.toStringAsFixed(2)}', isTotal: true),
          _buildPriceRow('Your Profit', '৳${_profit.toStringAsFixed(2)}', color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <>[
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
              color: color ?? (isTotal ? Colors.orange : Colors.white),
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <>[
          const Text(
            'Payment Method',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _paymentMethods.map((String method) {
              return ChoiceChip(
                label: Text(method),
                selected: _selectedPaymentMethod == method,
                onSelected: (bool selected) {
                  setState(() {
                    _selectedPaymentMethod = method;
                  });
                },
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                selectedColor: Colors.orange,
                labelStyle: TextStyle(
                  color: _selectedPaymentMethod == method ? Colors.white : Colors.white70,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferButton() {
    return NeumorphicButton(
      onPressed: _isLoading ? null : _transferCoins,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'TRANSFER COINS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}