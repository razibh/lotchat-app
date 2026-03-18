import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/neumorphic_button.dart';

class AgencyEarningsScreen extends StatefulWidget {
  final String agencyId;

  const AgencyEarningsScreen({required this.agencyId, super.key});

  @override
  State<AgencyEarningsScreen> createState() => _AgencyEarningsScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('agencyId', agencyId));
  }
}

class _AgencyEarningsScreenState extends State<AgencyEarningsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  final double _totalEarnings = 850000;
  final double _monthlyEarnings = 125000;
  final double _weeklyEarnings = 32000;
  final double _todayEarnings = 4500;
  final double _pendingCommission = 25000;
  final double _withdrawnCommission = 125000;

  List<AgencyCommission> _commissions = [];
  List<HostEarningSummary> _hostEarnings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _commissions = _generateCommissions();
        _hostEarnings = _generateHostEarnings();
        _isLoading = false;
      });
    });
  }

  List<AgencyCommission> _generateCommissions() {
    return [
      AgencyCommission(
        id: 'comm_001',
        hostName: 'Sarah Rahman',
        hostId: 'host_001',
        amount: 12500,
        commissionRate: 10,
        commissionAmount: 1250,
        date: DateTime.now().subtract(const Duration(days: 1)),
        status: 'Paid',
      ),
      AgencyCommission(
        id: 'comm_002',
        hostName: 'Karim Ahmed',
        hostId: 'host_002',
        amount: 8500,
        commissionRate: 8,
        commissionAmount: 680,
        date: DateTime.now().subtract(const Duration(days: 2)),
        status: 'Paid',
      ),
      AgencyCommission(
        id: 'comm_003',
        hostName: 'Rina Begum',
        hostId: 'host_003',
        amount: 15000,
        commissionRate: 12,
        commissionAmount: 1800,
        date: DateTime.now().subtract(const Duration(days: 3)),
        status: 'Pending',
      ),
      AgencyCommission(
        id: 'comm_004',
        hostName: 'Shahid Khan',
        hostId: 'host_004',
        amount: 22000,
        commissionRate: 15,
        commissionAmount: 3300,
        date: DateTime.now().subtract(const Duration(days: 4)),
        status: 'Pending',
      ),
    ];
  }

  List<HostEarningSummary> _generateHostEarnings() {
    return [
      HostEarningSummary(
        hostId: 'host_001',
        hostName: 'Sarah Rahman',
        totalEarnings: 125000,
        commissionPaid: 12500,
        commissionPending: 2500,
        thisMonthEarnings: 28500,
      ),
      HostEarningSummary(
        hostId: 'host_002',
        hostName: 'Karim Ahmed',
        totalEarnings: 98000,
        commissionPaid: 7840,
        commissionPending: 1200,
        thisMonthEarnings: 22400,
      ),
      HostEarningSummary(
        hostId: 'host_003',
        hostName: 'Rina Begum',
        totalEarnings: 156000,
        commissionPaid: 18720,
        commissionPending: 3600,
        thisMonthEarnings: 32400,
      ),
      HostEarningSummary(
        hostId: 'host_004',
        hostName: 'Shahid Khan',
        totalEarnings: 210000,
        commissionPaid: 31500,
        commissionPending: 5200,
        thisMonthEarnings: 45200,
      ),
    ];
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
              _buildTabBar(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildCommissionsTab(),
                    _buildHostEarningsTab(),
                  ],
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
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Agency Earnings',
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
          colors: [
            Colors.purple.withOpacity(0.3),
            Colors.blue.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Earnings',
                style: TextStyle(color: Colors.white70),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
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
            '৳$_totalEarnings',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBalanceItem('Monthly', '৳$_monthlyEarnings'),
              _buildBalanceItem('Weekly', '৳$_weeklyEarnings'),
              _buildBalanceItem('Today', '৳$_todayEarnings'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.hourglass_bottom, color: Colors.orange, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Pending: ৳$_pendingCommission',
                        style: const TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Withdrawn: ৳$_withdrawnCommission',
                        style: const TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(String label, String value) {
    return Column(
      children: [
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
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.purple,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Commissions'),
          Tab(text: 'Hosts'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Earnings Overview',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildOverviewChart(),
          const SizedBox(height: 20),
          const Text(
            'Recent Transactions',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._commissions.take(3).map((c) => _buildRecentTransaction(c)).toList(),
        ],
      ),
    );
  }

  Widget _buildOverviewChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildChartBar('Mon', 40),
          _buildChartBar('Tue', 65),
          _buildChartBar('Wed', 55),
          _buildChartBar('Thu', 80),
          _buildChartBar('Fri', 70),
          _buildChartBar('Sat', 90),
          _buildChartBar('Sun', 60),
        ],
      ),
    );
  }

  Widget _buildChartBar(String day, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: height,
          decoration: BoxDecoration(
            color: Colors.purple,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildRecentTransaction(AgencyCommission commission) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.money, color: Colors.green, size: 12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commission.hostName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatDate(commission.date),
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '৳${commission.commissionAmount}',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: commission.status == 'Paid'
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  commission.status,
                  style: TextStyle(
                    color: commission.status == 'Paid' ? Colors.green : Colors.orange,
                    fontSize: 8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _commissions.length,
      itemBuilder: (context, index) {
        final commission = _commissions[index];
        return _buildCommissionTile(commission);
      },
    );
  }

  Widget _buildCommissionTile(AgencyCommission commission) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.purple,
            child: Text(
              commission.hostName[0],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commission.hostName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Earned: ৳${commission.amount}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '৳${commission.commissionAmount}',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              Text(
                '${commission.commissionRate}%',
                style: const TextStyle(color: Colors.purple, fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: commission.status == 'Paid'
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  commission.status,
                  style: TextStyle(
                    color: commission.status == 'Paid' ? Colors.green : Colors.orange,
                    fontSize: 8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHostEarningsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _hostEarnings.length,
      itemBuilder: (context, index) {
        final host = _hostEarnings[index];
        return _buildHostEarningTile(host);
      },
    );
  }

  Widget _buildHostEarningTile(HostEarningSummary host) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue,
                child: Text(
                  host.hostName[0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  host.hostName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '৳${host.thisMonthEarnings}',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHostStat('Total', '৳${host.totalEarnings}'),
              _buildHostStat('Commission', '৳${host.commissionPaid}'),
              _buildHostStat('Pending', '৳${host.commissionPending}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHostStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 8),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}

class AgencyCommission {
  final String id;
  final String hostName;
  final String hostId;
  final double amount;
  final double commissionRate;
  final double commissionAmount;
  final DateTime date;
  final String status;

  AgencyCommission({
    required this.id,
    required this.hostName,
    required this.hostId,
    required this.amount,
    required this.commissionRate,
    required this.commissionAmount,
    required this.date,
    required this.status,
  });
}

class HostEarningSummary {
  final String hostId;
  final String hostName;
  final double totalEarnings;
  final double commissionPaid;
  final double commissionPending;
  final double thisMonthEarnings;

  HostEarningSummary({
    required this.hostId,
    required this.hostName,
    required this.totalEarnings,
    required this.commissionPaid,
    required this.commissionPending,
    required this.thisMonthEarnings,
  });
}