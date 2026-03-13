import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_background.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = <String>['All', 'Recharge', 'Withdraw', 'Game', 'Reward'];
  
  List<Transaction> _transactions = <Transaction>[];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    // Simulate loading transactions
    _transactions = <Transaction>[
      Transaction(
        id: 'TXN001',
        type: 'Recharge',
        amount: 500,
        date: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'Success',
        method: 'bKash',
      ),
      Transaction(
        id: 'TXN002',
        type: 'Game',
        amount: -50,
        date: DateTime.now().subtract(const Duration(days: 1)),
        status: 'Success',
        description: 'Chess Game Entry Fee',
      ),
      Transaction(
        id: 'TXN003',
        type: 'Reward',
        amount: 100,
        date: DateTime.now().subtract(const Duration(days: 2)),
        status: 'Success',
        description: 'Tournament Win',
      ),
      Transaction(
        id: 'TXN004',
        type: 'Withdraw',
        amount: -200,
        date: DateTime.now().subtract(const Duration(days: 3)),
        status: 'Pending',
        method: 'Nagad',
      ),
      Transaction(
        id: 'TXN005',
        type: 'Recharge',
        amount: 1000,
        date: DateTime.now().subtract(const Duration(days: 5)),
        status: 'Success',
        method: 'Credit Card',
      ),
      Transaction(
        id: 'TXN006',
        type: 'Game',
        amount: -100,
        date: DateTime.now().subtract(const Duration(days: 6)),
        status: 'Failed',
        description: 'Tournament Entry',
      ),
      Transaction(
        id: 'TXN007',
        type: 'Reward',
        amount: 50,
        date: DateTime.now().subtract(const Duration(days: 7)),
        status: 'Success',
        description: 'Daily Bonus',
      ),
    ];
  }

  List<Transaction> get _filteredTransactions {
    if (_selectedFilter == 'All') return _transactions;
    return _transactions.where((Transaction t) => t.type == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: <>[
              _buildHeader(),
              _buildFilterChips(),
              Expanded(
                child: _buildTransactionList(),
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
          Text(
            'Transaction History',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final String filter = _filters[index];
          final bool isSelected = _selectedFilter == filter;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: Colors.white.withOpacity(0.1),
              selectedColor: AppColors.accentPurple,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
              ),
              checkmarkColor: Colors.white,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionList() {
    final List<Transaction> transactions = _filteredTransactions;
    
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <>[
            Icon(
              Icons.history,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions found',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final Transaction transaction = transactions[index];
        return _buildTransactionTile(transaction);
      },
    );
  }

  Widget _buildTransactionTile(Transaction transaction) {
    final bool isCredit = transaction.amount > 0;
    final amountColor = isCredit ? Colors.green : Colors.red;
    final iconData = _getTransactionIcon(transaction.type);
    final iconColor = _getTransactionColor(transaction.type);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Row(
                  children: <>[
                    Expanded(
                      child: Text(
                        transaction.description ?? transaction.type,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(transaction.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        transaction.status,
                        style: TextStyle(
                          color: _getStatusColor(transaction.status),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.date),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                if (transaction.method != null) ...<>[
                  const SizedBox(height: 2),
                  Text(
                    'via ${transaction.method}',
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <>[
              Text(
                '${isCredit ? '+' : ''}৳${transaction.amount.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  color: amountColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                transaction.id,
                style: const TextStyle(color: Colors.white38, fontSize: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'Recharge':
        return Icons.account_balance_wallet;
      case 'Withdraw':
        return Icons.logout;
      case 'Game':
        return Icons.sports_esports;
      case 'Reward':
        return Icons.emoji_events;
      default:
        return Icons.receipt;
    }
  }

  Color _getTransactionColor(String type) {
    switch (type) {
      case 'Recharge':
        return Colors.blue;
      case 'Withdraw':
        return Colors.orange;
      case 'Game':
        return Colors.purple;
      case 'Reward':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Success':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class Transaction {

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.status,
    this.method,
    this.description,
  });
  final String id;
  final String type;
  final double amount;
  final DateTime date;
  final String status;
  final String? method;
  final String? description;
}