import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/neumorphic_button.dart';
import '../../core/widgets/neumorphic_text_field.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({Key? key}) : super(key: key);

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _amountController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();
  
  String? _selectedMethod;
  final double _currentBalance = 250.50;
  final double _withdrawableBalance = 200; // After deducting pending etc.
  
  final List<WithdrawMethod> _withdrawMethods = <WithdrawMethod>[
    WithdrawMethod(name: 'bKash', icon: Icons.phone_android, color: Colors.pink, minAmount: 50, maxAmount: 25000, charge: 0),
    WithdrawMethod(name: 'Nagad', icon: Icons.mobile_friendly, color: Colors.orange, minAmount: 50, maxAmount: 25000, charge: 0),
    WithdrawMethod(name: 'Rocket', icon: Icons.rocket_launch, color: Colors.red, minAmount: 50, maxAmount: 25000, charge: 0),
    WithdrawMethod(name: 'Bank Transfer', icon: Icons.account_balance, color: Colors.blue, minAmount: 500, maxAmount: 100000, charge: 20),
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  WithdrawMethod? get _selectedMethodObj {
    return _withdrawMethods.firstWhere(
      (WithdrawMethod m) => m.name == _selectedMethod,
      orElse: () => _withdrawMethods.first,
    );
  }

  double get _withdrawAmount {
    return double.tryParse(_amountController.text) ?? 0;
  }

  double get _charge {
    if (_selectedMethodObj == null) return 0;
    return _selectedMethodObj!.charge;
  }

  double get _totalDeduction {
    return _withdrawAmount + _charge;
  }

  bool get _isValidAmount {
    if (_selectedMethodObj == null) return false;
    return _withdrawAmount >= _selectedMethodObj!.minAmount &&
           _withdrawAmount <= _selectedMethodObj!.maxAmount &&
           _totalDeduction <= _withdrawableBalance;
  }

  void _processWithdraw() {
    if (!_isValidAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a valid amount between ${_selectedMethodObj?.minAmount} and ${_selectedMethodObj?.maxAmount}',
          ),
        ),
      );
      return;
    }

    if (_accountNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter account number')),
      );
      return;
    }

    if (_accountNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter account name')),
      );
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Confirm Withdrawal', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            _buildConfirmRow('Amount', '৳${_withdrawAmount.toStringAsFixed(2)}'),
            _buildConfirmRow('Charge', '৳${_charge.toStringAsFixed(2)}'),
            const Divider(color: Colors.white24),
            _buildConfirmRow('Total Deduction', '৳${_totalDeduction.toStringAsFixed(2)}', isTotal: true),
            const SizedBox(height: 16),
            _buildConfirmRow('Method', _selectedMethod!),
            _buildConfirmRow('Account', _accountNumberController.text),
            _buildConfirmRow('Name', _accountNameController.text),
          ],
        ),
        actions: <>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessDialog();
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

  Widget _buildConfirmRow(String label, String value, {bool isTotal = false}) {
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
              color: isTotal ? AppColors.accentPurple : Colors.white,
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            const Text(
              'Withdrawal Request Submitted!',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '৳${_withdrawAmount.toStringAsFixed(2)} will be sent to your account within 24 hours',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: <>[
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
            children: <>[
              _buildHeader(),
              _buildBalanceInfo(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <>[
                      _buildWithdrawMethods(),
                      const SizedBox(height: 20),
                      _buildAmountInput(),
                      const SizedBox(height: 20),
                      _buildAccountInfo(),
                      const SizedBox(height: 20),
                      _buildWithdrawSummary(),
                    ],
                  ),
                ),
              ),
              _buildWithdrawButton(),
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
          Text(
            'Withdraw Funds',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <>[
            Colors.orange.withOpacity(0.3),
            Colors.red.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: <>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                const Text(
                  'Withdrawable Balance',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '৳${_withdrawableBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Total: ৳${_currentBalance.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <>[
        const Text(
          'Withdraw Method',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._withdrawMethods.map(_buildMethodTile),
      ],
    );
  }

  Widget _buildMethodTile(WithdrawMethod method) {
    final bool isSelected = _selectedMethod == method.name;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method.name;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? method.color.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? method.color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: <>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: method.color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(method.icon, color: method.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <>[
                  Text(
                    method.name,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    'Min: ৳${method.minAmount} | Max: ৳${method.maxAmount}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (method.charge > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Charge: ৳${method.charge}',
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ),
            const SizedBox(width: 8),
            if (isSelected)
              Icon(Icons.check_circle, color: method.color, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    if (_selectedMethod == null) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <>[
        const Text(
          'Withdraw Amount',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        NeumorphicTextField(
          controller: _amountController,
          hintText: 'Enter amount',
          prefixIcon: Icons.attach_money,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {});
          },
        ),
        if (_selectedMethodObj != null && _amountController.text.isNotEmpty) ...<>[
          const SizedBox(height: 8),
          Text(
            'Min: ৳${_selectedMethodObj!.minAmount} | Max: ৳${_selectedMethodObj!.maxAmount}',
            style: TextStyle(
              color: _isValidAmount ? Colors.green : Colors.orange,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAccountInfo() {
    if (_selectedMethod == null) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <>[
        const Text(
          'Account Information',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        NeumorphicTextField(
          controller: _accountNumberController,
          hintText: 'Account Number',
          prefixIcon: Icons.numbers,
        ),
        const SizedBox(height: 12),
        NeumorphicTextField(
          controller: _accountNameController,
          hintText: 'Account Holder Name',
          prefixIcon: Icons.person,
        ),
      ],
    );
  }

  Widget _buildWithdrawSummary() {
    if (_selectedMethod == null || _amountController.text.isEmpty) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <>[
          _buildSummaryRow('Withdraw Amount', '৳${_withdrawAmount.toStringAsFixed(2)}'),
          _buildSummaryRow('Charge', '৳${_charge.toStringAsFixed(2)}'),
          const Divider(color: Colors.white24, height: 24),
          _buildSummaryRow('You will receive', '৳${(_withdrawAmount - _charge).toStringAsFixed(2)}'),
          _buildSummaryRow('Total Deduction', '৳${_totalDeduction.toStringAsFixed(2)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
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
              color: isTotal ? AppColors.accentPurple : Colors.white,
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: NeumorphicButton(
        onPressed: _selectedMethod == null ? null : _processWithdraw,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              'WITHDRAW NOW',
              style: TextStyle(
                color: _selectedMethod == null ? Colors.white38 : Colors.white,
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

class WithdrawMethod {

  WithdrawMethod({
    required this.name,
    required this.icon,
    required this.color,
    required this.minAmount,
    required this.maxAmount,
    required this.charge,
  });
  final String name;
  final IconData icon;
  final Color color;
  final double minAmount;
  final double maxAmount;
  final double charge;
}