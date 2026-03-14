import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/neumorphic_button.dart';
import '../models/host_models.dart';

class HostEarningsScreen extends StatefulWidget {

  const HostEarningsScreen({required this.hostId, super.key});
  final String hostId;

  @override
  State<HostEarningsScreen> createState() => _HostEarningsScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('hostId', hostId));
  }
}

class _HostEarningsScreenState extends State<HostEarningsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  
  List<HostEarning> _earnings = <>[];
  final double _totalEarnings = 125000;
  final double _monthlyEarnings = 28500;
  final double _weeklyEarnings = 7200;
  final double _todayEarnings = 1250;
  final double _availableBalance = 8500;
  final double _pendingWithdrawal = 3500;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEarnings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEarnings() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _earnings = _generateEarnings();
      _isLoading = false;
    });
  }

  List<HostEarning> _generateEarnings() {
    return <>[
      HostEarning(
        id: 'earn_001',
        type: EarningType.gift,
        amount: 1250,
        source: 'Gift from John',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        status: EarningStatus.available,
      ),
      HostEarning(
        id: 'earn_002',
        type: EarningType.room,
        amount: 3500,
        source: 'Friday Night Room',
        date: DateTime.now().subtract(const Duration(days: 1)),
        status: EarningStatus.available,
      ),
      HostEarning(
        id: 'earn_003',
        type: EarningType.bonus,
        amount: 500,
        source: 'Streak Bonus',
        date: DateTime.now().subtract(const Duration(days: 2)),
        status: EarningStatus.available,
      ),
      HostEarning(
        id: 'earn_004',
        type: EarningType.gift,
        amount: 750,
        source: 'Gift from Sarah',
        date: DateTime.now().subtract(const Duration(days: 3)),
        status: EarningStatus.pending,
      ),
      HostEarning(
        id: 'earn_005',
        type: EarningType.commission,
        amount: 1200,
        source: 'Referral Commission',
        date: DateTime.now().subtract(const Duration(days: 5)),
        status: EarningStatus.withdrawn,
      ),
    ];
  }

  List<HostEarning> get _filteredEarnings {
    if (_tabController.index == 0) {
      return _earnings.where((Object? e) => e.status == EarningStatus.available).toList();
    } else if (_tabController.index == 1) {
      return _earnings.where((Object? e) => e.status == EarningStatus.pending).toList();
    } else {
      return _earnings.where((Object? e) => e.status == EarningStatus.withdrawn).toList();
    }
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
                    : _buildEarningsList(),
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
            'My Earnings',
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

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <>[
              const Text(
                'Available Balance',
                style: TextStyle(color: Colors.white70),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Withdraw',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '৳$_availableBalance',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <>[
              _buildBalanceItem('Today', '৳$_todayEarnings'),
              _buildBalanceItem('Week', '৳$_weeklyEarnings'),
              _buildBalanceItem('Month', '৳$_monthlyEarnings'),
              _buildBalanceItem('Total', '৳$_totalEarnings'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(String label, String value) {
    return Column(
      children: <>[
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.green,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const <>[
          Tab(text: 'Available'),
          Tab(text: 'Pending'),
          Tab(text: 'Withdrawn'),
        ],
      ),
    );
  }

  Widget _buildEarningsList() {
    final earnings = _filteredEarnings;
    
    if (earnings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <>[
            Icon(
              _tabController.index == 0 ? Icons.account_balance_wallet :
              _tabController.index == 1 ? Icons.hourglass_empty : Icons.history,
              size: 60,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${_tabController.index == 0 ? 'available' : 
                  _tabController.index == 1 ? 'pending' : 'withdrawn'} earnings',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: earnings.length,
      itemBuilder: (BuildContext context, int index) {
        final earning = earnings[index];
        return _buildEarningTile(earning);
      },
    );
  }

  Widget _buildEarningTile(HostEarning earning) {
    Color statusColor;
    IconData statusIcon;
    
    switch (earning.status) {
      case EarningStatus.available:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
      case EarningStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
      case EarningStatus.withdrawn:
        statusColor = Colors.blue;
        statusIcon = Icons.history;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  '${earning.type.toString().split('.').last} - ${earning.source}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatDate(earning.date),
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <>[
              Text(
                '৳${earning.amount}',
                style: TextStyle(
                  color: earning.status == EarningStatus.available ? Colors.green : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  earning.status.toString().split('.').last,
                  style: TextStyle(color: statusColor, fontSize: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour}:${date.minute}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}