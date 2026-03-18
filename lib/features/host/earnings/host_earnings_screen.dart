import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../core/services/analytics_service.dart';
import '../../host/earnings/host_earnings_screen.dart';
import '../models/host_models.dart';
import '../../../core/services/host_earnings_service.dart';
class HostEarningsScreen extends StatefulWidget {
  final String hostId;

  const HostEarningsScreen({
    super.key,
    required this.hostId,
  });

  @override
  State<HostEarningsScreen> createState() => _HostEarningsScreenState();
}

class _HostEarningsScreenState extends State<HostEarningsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;

  late final AnalyticsService _analyticsService;
  late final HostEarningsService _earningsService;

  List<HostEarning> _earnings = [];
  EarningsSummary? _summary;
  String _selectedPeriod = 'month';

  final List<Map<String, String>> _periods = const [
    {'label': 'Day', 'value': 'day'},
    {'label': 'Week', 'value': 'week'},
    {'label': 'Month', 'value': 'month'},
    {'label': 'Year', 'value': 'year'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _analyticsService = AnalyticsService();
    _earningsService = HostEarningsService();
    await _analyticsService.initialize();
    _loadEarnings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEarnings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _earningsService.getHostEarnings(
        widget.hostId,
        _selectedPeriod,
      );

      setState(() {
        _earnings = data['earnings'] as List<HostEarning>;
        _summary = data['summary'] as EarningsSummary;
        _isLoading = false;
      });

    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<HostEarning> get _filteredEarnings {
    if (_tabController.index == 0) {
      return _earnings.where((e) => e.status == EarningStatus.available).toList();
    } else if (_tabController.index == 1) {
      return _earnings.where((e) => e.status == EarningStatus.pending).toList();
    } else {
      return _earnings.where((e) => e.status == EarningStatus.withdrawn).toList();
    }
  }

  void _handlePeriodChange(String period) {
    setState(() {
      _selectedPeriod = period;
    });
    _loadEarnings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildPeriodSelector(),
              _buildBalanceCard(),
              _buildTabBar(),
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.green),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEarnings,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEarnings,
      color: Colors.green,
      backgroundColor: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredEarnings.length,
        itemBuilder: (context, index) {
          final earning = _filteredEarnings[index];
          return _buildEarningTile(earning);
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'My Earnings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(
                  '৳${_summary?.totalEarnings ?? 0}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: _periods.map((period) => _buildPeriodButton(
          period['label']!,
          period['value']!,
        )).toList(),
      ),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => _handlePeriodChange(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.3),
            Colors.blue.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available Balance',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.green, Colors.teal]),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Withdraw',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '৳${_summary?.availableBalance ?? 0}',
                style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              const Text('BDT', style: TextStyle(color: Colors.white54, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.hourglass_bottom, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Pending: ৳${_summary?.pendingWithdrawal ?? 0}',
                  style: const TextStyle(color: Colors.orange, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.green,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(text: 'Available'),
          Tab(text: 'Pending'),
          Tab(text: 'Withdrawn'),
        ],
      ),
    );
  }

  Widget _buildEarningTile(HostEarning earning) {
    Color statusColor;
    IconData statusIcon;

    switch (earning.status) {
      case EarningStatus.available:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case EarningStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case EarningStatus.withdrawn:
        statusColor = Colors.blue;
        statusIcon = Icons.history;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
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
              children: [
                Text(
                  earning.source,
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
            children: [
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
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}