import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/neumorphic_button.dart';
import '../../../core/widgets/neumorphic_text_field.dart';

class AgencyCommissionScreen extends StatefulWidget {
  final String managerId;
  final String agencyId;
  final String agencyName;

  const AgencyCommissionScreen({
    required this.managerId,
    required this.agencyId,
    required this.agencyName,
    super.key,
  });

  @override
  State<AgencyCommissionScreen> createState() => _AgencyCommissionScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('managerId', managerId));
    properties.add(StringProperty('agencyId', agencyId));
    properties.add(StringProperty('agencyName', agencyName));
  }
}

class _AgencyCommissionScreenState extends State<AgencyCommissionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // Agency Commission Data
  AgencyCommission? _agencyCommission;
  List<HostCommission> _hostCommissions = [];
  List<CommissionTransaction> _transactions = [];
  List<CommissionRule> _commissionRules = [];

  // Summary Stats
  double _totalCommission = 0;
  double _paidCommission = 0;
  double _pendingCommission = 0;
  double _thisMonthCommission = 0;
  int _totalHosts = 0;
  double _averageCommissionRate = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCommissionData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCommissionData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    // Sample data generation - সব int মানকে double এ convert করা হয়েছে
    _agencyCommission = AgencyCommission(
      agencyId: widget.agencyId,
      agencyName: widget.agencyName,
      baseCommissionRate: 10.0,
      totalEarnings: 1250000.0,
      totalCommission: 125000.0,
      paidCommission: 85000.0,
      pendingCommission: 40000.0,
      thisMonthEarnings: 145000.0,
      thisMonthCommission: 14500.0,
      lastPaymentDate: DateTime.now().subtract(const Duration(days: 5)),
      nextPaymentDate: DateTime.now().add(const Duration(days: 25)),
      commissionStructure: 'Tiered',
      paymentMethod: 'Bank Transfer',
      bankDetails: 'DBBL, Account: 1234567890',
    );

    _hostCommissions = _generateHostCommissions(8);
    _transactions = _generateTransactions(15);
    _commissionRules = _generateCommissionRules();

    _calculateStats();

    setState(() => _isLoading = false);
  }

  List<HostCommission> _generateHostCommissions(int count) {
    final hosts = <HostCommission>[];
    for (var i = 0; i < count; i++) {
      final earnings = (50000 + (i * 15000)).toDouble(); // int to double
      final rate = (8 + (i % 8)).toDouble(); // int to double
      final commission = earnings * rate / 100;

      hosts.add(HostCommission(
        hostId: 'host_${100 + i}',
        hostName: 'Host ${i + 1}',
        hostUsername: 'host_${i + 1}',
        totalEarnings: earnings * 6,
        monthlyEarnings: earnings,
        commissionRate: rate,
        commissionAmount: commission,
        paidCommission: commission * 0.8,
        pendingCommission: commission * 0.2,
        lastPaidDate: i % 2 == 0 ? DateTime.now().subtract(Duration(days: i * 2)) : null,
        status: i % 3 == 0 ? 'Active' : (i % 3 == 1 ? 'Pending' : 'Suspended'),
        performanceScore: 70 + (i % 30),
        rank: i + 1,
      ));
    }
    return hosts;
  }

  List<CommissionTransaction> _generateTransactions(int count) {
    final transactions = <CommissionTransaction>[];
    for (var i = 0; i < count; i++) {
      final amount = (5000 + (i * 2000)).toDouble(); // int to double
      transactions.add(CommissionTransaction(
        id: 'txn_${100 + i}',
        date: DateTime.now().subtract(Duration(days: i * 3)),
        amount: amount,
        type: i % 3 == 0 ? 'Commission' : (i % 3 == 1 ? 'Withdrawal' : 'Bonus'),
        status: i % 4 == 0 ? 'Pending' : 'Completed',
        description: i % 2 == 0 ? 'Monthly commission' : 'Host earnings commission',
        reference: 'REF${1000 + i}',
        fromTo: i % 2 == 0 ? 'Platform to Agency' : 'Agency to Bank',
      ));
    }
    return transactions;
  }

  List<CommissionRule> _generateCommissionRules() {
    return [
      CommissionRule(
        id: 'rule_1',
        name: 'Base Rule',
        minEarnings: 0.0,
        maxEarnings: 50000.0,
        rate: 8.0,
        description: 'Standard commission for earnings up to 50k',
        isActive: true,
      ),
      CommissionRule(
        id: 'rule_2',
        name: 'Silver Tier',
        minEarnings: 50001.0,
        maxEarnings: 100000.0,
        rate: 10.0,
        description: 'Increased commission for 50k-100k earnings',
        isActive: true,
      ),
      CommissionRule(
        id: 'rule_3',
        name: 'Gold Tier',
        minEarnings: 100001.0,
        maxEarnings: 200000.0,
        rate: 12.0,
        description: 'Premium rate for top performers',
        isActive: true,
      ),
      CommissionRule(
        id: 'rule_4',
        name: 'Platinum Tier',
        minEarnings: 200001.0,
        maxEarnings: double.infinity,
        rate: 15.0,
        description: 'Maximum commission rate',
        isActive: true,
      ),
    ];
  }

  void _calculateStats() {
    _totalCommission = _agencyCommission?.totalCommission ?? 0.0;
    _paidCommission = _agencyCommission?.paidCommission ?? 0.0;
    _pendingCommission = _agencyCommission?.pendingCommission ?? 0.0;
    _thisMonthCommission = _agencyCommission?.thisMonthCommission ?? 0.0;
    _totalHosts = _hostCommissions.length;
    _averageCommissionRate = _hostCommissions.isEmpty
        ? 0.0
        : _hostCommissions.fold(0.0, (sum, h) => sum + h.commissionRate) / _hostCommissions.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              if (!_isLoading) ...[
                _buildSummaryCards(),
                _buildTabBar(),
              ],
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildHostsTab(),
                    _buildTransactionsTab(),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Commission Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.agencyName,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_agencyCommission?.baseCommissionRate ?? 0}% Base',
              style: const TextStyle(color: Colors.green, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Commission',
                  '৳${_totalCommission.toStringAsFixed(0)}',
                  Icons.account_balance_wallet,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  'Paid',
                  '৳${_paidCommission.toStringAsFixed(0)}',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  'Pending',
                  '৳${_pendingCommission.toStringAsFixed(0)}',
                  Icons.hourglass_empty,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'This Month',
                  '৳${_thisMonthCommission.toStringAsFixed(0)}',
                  Icons.calendar_month,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  'Total Hosts',
                  '$_totalHosts',
                  Icons.people,
                  Colors.teal,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  'Avg Rate',
                  '${_averageCommissionRate.toStringAsFixed(1)}%',
                  Icons.percent,
                  Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
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
          Tab(text: 'Hosts'),
          Tab(text: 'Transactions'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildAgencyInfoCard(),
          const SizedBox(height: 20),
          _buildCommissionRulesCard(),
          const SizedBox(height: 20),
          _buildPaymentInfoCard(),
          const SizedBox(height: 20),
          _buildCommissionChart(),
          const SizedBox(height: 20),
          _buildRecentTransactions(),
        ],
      ),
    );
  }

  Widget _buildAgencyInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.3),
            Colors.blue.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.business, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.agencyName,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Agency ID: ${widget.agencyId}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('Total Earnings', '৳${_agencyCommission?.totalEarnings ?? 0}'),
              _buildInfoItem('Commission Rate', '${_agencyCommission?.baseCommissionRate ?? 0}%'),
              _buildInfoItem('Payment Method', _agencyCommission?.paymentMethod ?? 'N/A'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
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

  Widget _buildCommissionRulesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Commission Rules',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.edit, color: Colors.white70, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          ..._commissionRules.map(_buildRuleTile).toList(),
        ],
      ),
    );
  }

  Widget _buildRuleTile(CommissionRule rule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: rule.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: rule.isActive ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  rule.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${rule.rate}%',
                  style: const TextStyle(color: Colors.purple, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '৳${rule.minEarnings} - ${rule.maxEarnings == double.infinity ? "∞" : "৳${rule.maxEarnings}"}',
                style: const TextStyle(color: Colors.white54, fontSize: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Information',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPaymentRow('Payment Method', _agencyCommission?.paymentMethod ?? 'N/A'),
          _buildPaymentRow('Bank Details', _agencyCommission?.bankDetails ?? 'N/A'),
          _buildPaymentRow('Last Payment', _agencyCommission?.lastPaymentDate != null
              ? _formatDate(_agencyCommission!.lastPaymentDate!)
              : 'No payments yet'),
          _buildPaymentRow('Next Payment', _agencyCommission?.nextPaymentDate != null
              ? _formatDate(_agencyCommission!.nextPaymentDate!)
              : 'Not scheduled'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPaymentAction('Request Payout', Colors.green, () {}),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPaymentAction('Update Details', Colors.blue, () {}),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentAction(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildCommissionChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Commission',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildChartBar('Jan', 65.0),
                _buildChartBar('Feb', 45.0),
                _buildChartBar('Mar', 80.0),
                _buildChartBar('Apr', 70.0),
                _buildChartBar('May', 90.0),
                _buildChartBar('Jun', 55.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String month, double percentage) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: percentage,
                width: 30,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple,
                      Colors.purple.withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          month,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._transactions.take(5).map(_buildTransactionTile).toList(),
        if (_transactions.length > 5)
          Center(
            child: TextButton(
              onPressed: () {
                _tabController.animateTo(2);
              },
              child: const Text('View All Transactions'),
            ),
          ),
      ],
    );
  }

  Widget _buildHostsTab() {
    return Column(
      children: [
        _buildHostSummary(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _hostCommissions.length,
            itemBuilder: (BuildContext context, int index) {
              final host = _hostCommissions[index];
              return _buildHostCommissionTile(host);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHostSummary() {
    final totalHostEarnings = _hostCommissions.fold(0.0, (sum, h) => sum + h.monthlyEarnings);
    final totalHostCommission = _hostCommissions.fold(0.0, (sum, h) => sum + h.commissionAmount);

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildHostSummaryItem('Total Hosts', '${_hostCommissions.length}'),
          _buildHostSummaryItem('Total Earnings', '৳${totalHostEarnings.toStringAsFixed(0)}'),
          _buildHostSummaryItem('Total Commission', '৳${totalHostCommission.toStringAsFixed(0)}'),
        ],
      ),
    );
  }

  Widget _buildHostSummaryItem(String label, String value) {
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

  Widget _buildHostCommissionTile(HostCommission host) {
    final statusColor = host.status == 'Active' ? Colors.green :
    host.status == 'Pending' ? Colors.orange : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                backgroundColor: Colors.purple,
                child: Text(
                  host.hostName[0],
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            host.hostName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            host.status,
                            style: TextStyle(color: statusColor, fontSize: 8),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '@${host.hostUsername}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHostStat('Earnings', '৳${host.monthlyEarnings}'),
              _buildHostStat('Rate', '${host.commissionRate}%'),
              _buildHostStat('Commission', '৳${host.commissionAmount}'),
              _buildHostStat('Score', '${host.performanceScore}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildHostAction('Details', Colors.blue, () {
                  _showHostCommissionDetails(host);
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHostAction('Adjust Rate', Colors.orange, () {
                  _showAdjustRateDialog(host);
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHostAction('Pay', Colors.green, () {
                  _showPayCommissionDialog(host);
                }),
              ),
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

  Widget _buildHostAction(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return Column(
      children: [
        _buildTransactionFilters(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _transactions.length,
            itemBuilder: (BuildContext context, int index) {
              final transaction = _transactions[index];
              return _buildTransactionTile(transaction);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionFilters() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterChip('All', true),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterChip('Commission', false),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterChip('Withdrawal', false),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTile(CommissionTransaction transaction) {
    final typeColor = transaction.type == 'Commission' ? Colors.green :
    transaction.type == 'Withdrawal' ? Colors.blue : Colors.orange;
    final statusColor = transaction.status == 'Completed' ? Colors.green : Colors.orange;

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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.type == 'Commission' ? Icons.arrow_downward :
              transaction.type == 'Withdrawal' ? Icons.arrow_upward : Icons.star,
              color: typeColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        transaction.description,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        transaction.status,
                        style: TextStyle(color: statusColor, fontSize: 8),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${transaction.fromTo} • ${_formatDate(transaction.date)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '৳${transaction.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  color: transaction.type == 'Commission' ? Colors.green : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                transaction.reference,
                style: const TextStyle(color: Colors.white38, fontSize: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHostCommissionDetails(HostCommission host) {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        backgroundColor: AppColors.surfaceDark,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Host Commission Details',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.purple,
                child: Text(
                  host.hostName[0],
                  style: const TextStyle(color: Colors.white, fontSize: 30),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                host.hostName,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '@${host.hostUsername}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2,
                children: [
                  _buildDetailItem('Total Earnings', '৳${host.totalEarnings}'),
                  _buildDetailItem('Monthly', '৳${host.monthlyEarnings}'),
                  _buildDetailItem('Commission Rate', '${host.commissionRate}%'),
                  _buildDetailItem('Commission', '৳${host.commissionAmount}'),
                  _buildDetailItem('Paid', '৳${host.paidCommission}'),
                  _buildDetailItem('Pending', '৳${host.pendingCommission}'),
                  _buildDetailItem('Rank', '#${host.rank}'),
                  _buildDetailItem('Score', '${host.performanceScore}'),
                ],
              ),
              if (host.lastPaidDate != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Last Paid: ${_formatDate(host.lastPaidDate!)}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Text('$label:', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _showAdjustRateDialog(HostCommission host) {
    final TextEditingController rateController = TextEditingController(text: host.commissionRate.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Adjust Commission Rate', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current rate: ${host.commissionRate}%',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            NeumorphicTextField(
              controller: rateController,
              hintText: 'New commission rate',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            Text(
              'New commission: ৳${(host.monthlyEarnings * double.parse(rateController.text) / 100).toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.green, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newRate = double.parse(rateController.text);
              setState(() {
                final updatedHost = HostCommission(
                  hostId: host.hostId,
                  hostName: host.hostName,
                  hostUsername: host.hostUsername,
                  avatar: host.avatar,
                  totalEarnings: host.totalEarnings,
                  monthlyEarnings: host.monthlyEarnings,
                  commissionRate: newRate,
                  commissionAmount: host.monthlyEarnings * newRate / 100,
                  paidCommission: host.paidCommission,
                  pendingCommission: host.pendingCommission,
                  lastPaidDate: host.lastPaidDate,
                  status: host.status,
                  performanceScore: host.performanceScore,
                  rank: host.rank,
                );

                final index = _hostCommissions.indexWhere((h) => h.hostId == host.hostId);
                if (index != -1) {
                  _hostCommissions[index] = updatedHost;
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Commission rate updated for ${host.hostName}')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showPayCommissionDialog(HostCommission host) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Pay Commission', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pay commission to ${host.hostName}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Text(
              'Pending Amount: ৳${host.pendingCommission}',
              style: const TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final updatedHost = HostCommission(
                  hostId: host.hostId,
                  hostName: host.hostName,
                  hostUsername: host.hostUsername,
                  avatar: host.avatar,
                  totalEarnings: host.totalEarnings,
                  monthlyEarnings: host.monthlyEarnings,
                  commissionRate: host.commissionRate,
                  commissionAmount: host.commissionAmount,
                  paidCommission: host.paidCommission + host.pendingCommission,
                  pendingCommission: 0,
                  lastPaidDate: DateTime.now(),
                  status: host.status,
                  performanceScore: host.performanceScore,
                  rank: host.rank,
                );

                final index = _hostCommissions.indexWhere((h) => h.hostId == host.hostId);
                if (index != -1) {
                  _hostCommissions[index] = updatedHost;
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Commission paid to ${host.hostName}')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Models
class AgencyCommission {
  final String agencyId;
  final String agencyName;
  final double baseCommissionRate;
  final double totalEarnings;
  final double totalCommission;
  final double paidCommission;
  final double pendingCommission;
  final double thisMonthEarnings;
  final double thisMonthCommission;
  final DateTime? lastPaymentDate;
  final DateTime? nextPaymentDate;
  final String commissionStructure;
  final String paymentMethod;
  final String bankDetails;

  AgencyCommission({
    required this.agencyId,
    required this.agencyName,
    required this.baseCommissionRate,
    required this.totalEarnings,
    required this.totalCommission,
    required this.paidCommission,
    required this.pendingCommission,
    required this.thisMonthEarnings,
    required this.thisMonthCommission,
    required this.commissionStructure,
    required this.paymentMethod,
    required this.bankDetails,
    this.lastPaymentDate,
    this.nextPaymentDate,
  });
}

class HostCommission {
  final String hostId;
  final String hostName;
  final String hostUsername;
  final String? avatar;
  final double totalEarnings;
  final double monthlyEarnings;
  final double commissionRate;
  final double commissionAmount;
  final double paidCommission;
  final double pendingCommission;
  final DateTime? lastPaidDate;
  final String status;
  final int performanceScore;
  final int rank;

  HostCommission({
    required this.hostId,
    required this.hostName,
    required this.hostUsername,
    this.avatar,
    required this.totalEarnings,
    required this.monthlyEarnings,
    required this.commissionRate,
    required this.commissionAmount,
    required this.paidCommission,
    required this.pendingCommission,
    this.lastPaidDate,
    required this.status,
    required this.performanceScore,
    required this.rank,
  });
}

class CommissionTransaction {
  final String id;
  final DateTime date;
  final double amount;
  final String type;
  final String status;
  final String description;
  final String reference;
  final String fromTo;

  CommissionTransaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.type,
    required this.status,
    required this.description,
    required this.reference,
    required this.fromTo,
  });
}

class CommissionRule {
  final String id;
  final String name;
  final double minEarnings;
  final double maxEarnings;
  final double rate;
  final String description;
  final bool isActive;

  CommissionRule({
    required this.id,
    required this.name,
    required this.minEarnings,
    required this.maxEarnings,
    required this.rate,
    required this.description,
    required this.isActive,
  });
}