import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';

class HostCommissionScreen extends StatefulWidget {

  const HostCommissionScreen({
    Key? key,
    required this.agencyId,
    required this.hostId,
  }) : super(key: key);
  final String agencyId;
  final String hostId;

  @override
  State<HostCommissionScreen> createState() => _HostCommissionScreenState();
}

class _HostCommissionScreenState extends State<HostCommissionScreen> {
  double _commissionRate = 5;
  List<CommissionTransaction> _transactions = <CommissionTransaction>[];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _transactions = <CommissionTransaction>[
      CommissionTransaction(
        amount: 500,
        rate: 5,
        earnings: 10000,
        date: DateTime.now(),
        status: 'Paid',
      ),
      CommissionTransaction(
        amount: 600,
        rate: 6,
        earnings: 10000,
        date: DateTime.now().subtract(const Duration(days: 7)),
        status: 'Paid',
      ),
    ];
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
                      _buildCommissionCard(),
                      const SizedBox(height: 20),
                      _buildRateSelector(),
                      const SizedBox(height: 20),
                      _buildTransactionHistory(),
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
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <>[
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Host Commission',
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

  Widget _buildCommissionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <>[
            Colors.purple.withOpacity(0.3),
            Colors.blue.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: <>[
          const Text(
            'Current Commission Rate',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Text(
            '$_commissionRate%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <>[
          const Text(
            'Select Commission Rate',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            children: <int>[5, 6, 7, 8, 9, 10, 12, 15].map((int rate) {
              return ChoiceChip(
                label: Text('$rate%'),
                selected: _commissionRate == rate,
                onSelected: (selected) {
                  setState(() {
                    _commissionRate = rate.toDouble();
                  });
                },
                backgroundColor: Colors.white.withOpacity(0.1),
                selectedColor: AppColors.accentPurple,
                labelStyle: TextStyle(
                  color: _commissionRate == rate ? Colors.white : Colors.white70,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <>[
        const Text(
          'Commission History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ..._transactions.map(_buildTransactionTile),
      ],
    );
  }

  Widget _buildTransactionTile(CommissionTransaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.money, color: Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  'Commission: ৳${transaction.amount}',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Rate: ${transaction.rate}% of ৳${transaction.earnings}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <>[
              Text(
                _formatDate(transaction.date),
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  transaction.status,
                  style: const TextStyle(color: Colors.green, fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}

class CommissionTransaction {

  CommissionTransaction({
    required this.amount,
    required this.rate,
    required this.earnings,
    required this.date,
    required this.status,
  });
  final double amount;
  final double rate;
  final double earnings;
  final DateTime date;
  final String status;
}