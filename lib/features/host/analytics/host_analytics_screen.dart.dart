import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';

class HostAnalyticsScreen extends StatefulWidget {

  const HostAnalyticsScreen({required this.hostId, super.key});
  final String hostId;

  @override
  State<HostAnalyticsScreen> createState() => _HostAnalyticsScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('hostId', hostId));
  }
}

class _HostAnalyticsScreenState extends State<HostAnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'week';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: <>[
              _buildHeader(),
              _buildPeriodSelector(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: <>[
                    _buildViewersAnalytics(),
                    _buildEarningsAnalytics(),
                    _buildGiftsAnalytics(),
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
        children: <>[
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Analytics',
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

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: <>[
          _buildPeriodButton('Day', 'day'),
          _buildPeriodButton('Week', 'week'),
          _buildPeriodButton('Month', 'month'),
          _buildPeriodButton('Year', 'year'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final var isSelected = _selectedPeriod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.pink : Colors.transparent,
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
          color: Colors.pink,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const <>[
          Tab(text: 'Viewers'),
          Tab(text: 'Earnings'),
          Tab(text: 'Gifts'),
        ],
      ),
    );
  }

  Widget _buildViewersAnalytics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <>[
          _buildSummaryCard(
            'Average Viewers',
            '450',
            '↑ 12%',
            Icons.visibility,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'Peak Viewers',
            '1,250',
            '↑ 8%',
            Icons.trending_up,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'Total Hours',
            '312',
            '↓ 2%',
            Icons.access_time,
            Colors.orange,
          ),
          const SizedBox(height: 20),
          const Text(
            'Viewers by Hour',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildViewersChart(),
          const SizedBox(height: 20),
          const Text(
            'Top Locations',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildLocationStats(),
        ],
      ),
    );
  }

  Widget _buildEarningsAnalytics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <>[
          _buildSummaryCard(
            'Total Earnings',
            '৳125,000',
            '↑ 15%',
            Icons.money,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'Monthly Average',
            '৳28,500',
            '↑ 10%',
            Icons.calendar_today,
            Colors.purple,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'Best Day',
            '৳4,500',
            'Friday',
            Icons.weekend,
            Colors.orange,
          ),
          const SizedBox(height: 20),
          const Text(
            'Earnings by Day',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildEarningsChart(),
          const SizedBox(height: 20),
          const Text(
            'Earnings by Source',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildEarningsSource(),
        ],
      ),
    );
  }

  Widget _buildGiftsAnalytics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <>[
          _buildSummaryCard(
            'Total Gifts',
            '3,456',
            '↑ 20%',
            Icons.card_giftcard,
            Colors.pink,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'Top Gifter',
            'John Doe',
            '500 gifts',
            Icons.star,
            Colors.amber,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'Gift Value',
            '৳45,000',
            '↑ 18%',
            Icons.attach_money,
            Colors.green,
          ),
          const SizedBox(height: 20),
          const Text(
            'Popular Gifts',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildGiftStats(),
          const SizedBox(height: 20),
          const Text(
            'Top Supporters',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTopSupporters(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, String change, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: change.startsWith('↑') ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              change,
              style: TextStyle(
                color: change.startsWith('↑') ? Colors.green : Colors.red,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewersChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <>[
          _buildChartBar('12am', 30),
          _buildChartBar('4am', 20),
          _buildChartBar('8am', 45),
          _buildChartBar('12pm', 80),
          _buildChartBar('4pm', 95),
          _buildChartBar('8pm', 100),
          _buildChartBar('11pm', 70),
        ],
      ),
    );
  }

  Widget _buildEarningsChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <>[
          _buildChartBar('Mon', 40),
          _buildChartBar('Tue', 55),
          _buildChartBar('Wed', 48),
          _buildChartBar('Thu', 70),
          _buildChartBar('Fri', 85),
          _buildChartBar('Sat', 90),
          _buildChartBar('Sun', 75),
        ],
      ),
    );
  }

  Widget _buildChartBar(String label, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <>[
        Container(
          width: 20,
          height: height,
          decoration: BoxDecoration(
            color: Colors.pink,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 8),
        ),
      ],
    );
  }

  Widget _buildLocationStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <>[
          _buildLocationRow('Dhaka', 450, 35),
          _buildLocationRow('Chittagong', 280, 22),
          _buildLocationRow('Sylhet', 150, 12),
          _buildLocationRow('Other', 370, 31),
        ],
      ),
    );
  }

  Widget _buildLocationRow(String city, int viewers, int percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: <>[
          Expanded(
            flex: 2,
            child: Text(city, style: const TextStyle(color: Colors.white)),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.pink),
            ),
          ),
          Expanded(
            child: Text(
              '$viewers',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsSource() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <>[
          _buildSourceRow('Gifts', 65, Colors.pink),
          _buildSourceRow('Room Entry', 20, Colors.blue),
          _buildSourceRow('Bonuses', 10, Colors.green),
          _buildSourceRow('Other', 5, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildSourceRow(String source, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: <>[
          Expanded(
            flex: 2,
            child: Text(source, style: const TextStyle(color: Colors.white)),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Expanded(
            child: Text(
              '$percentage%',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <>[
          _buildGiftRow('Super Star', 150, 45),
          _buildGiftRow('Rose', 280, 25),
          _buildGiftRow('Heart', 420, 15),
          _buildGiftRow('Diamond', 50, 100),
        ],
      ),
    );
  }

  Widget _buildGiftRow(String gift, int count, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <>[
          Text(gift, style: const TextStyle(color: Colors.white)),
          Text('$count ×', style: const TextStyle(color: Colors.white70)),
          Text('৳$value', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTopSupporters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <>[
          _buildSupporterRow(1, 'John Doe', 150, 7500),
          _buildSupporterRow(2, 'Jane Smith', 120, 6000),
          _buildSupporterRow(3, 'Mike Johnson', 95, 4750),
          _buildSupporterRow(4, 'Sarah Wilson', 80, 4000),
          _buildSupporterRow(5, 'David Brown', 65, 3250),
        ],
      ),
    );
  }

  Widget _buildSupporterRow(int rank, String name, int gifts, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: <>[
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: rank <= 3 ? Colors.amber : Colors.grey.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: rank <= 3 ? Colors.black : Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name, style: const TextStyle(color: Colors.white)),
          ),
          Text('$gifts gifts', style: const TextStyle(color: Colors.white70, fontSize: 10)),
          const SizedBox(width: 12),
          Text('৳$value', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}