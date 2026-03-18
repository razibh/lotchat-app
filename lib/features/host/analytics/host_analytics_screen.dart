import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/host_analytics_service.dart'; // নতুন service import

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
  bool _isLoading = false;
  Map<String, dynamic>? _analyticsData;
  String? _errorMessage;

  // Services
  late final AnalyticsService _analyticsService;
  late final HostAnalyticsService _hostAnalyticsService;

  // Analytics periods
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
    _hostAnalyticsService = HostAnalyticsService();
    await _analyticsService.initialize();
    _loadAnalyticsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Track screen view
      await _analyticsService.trackScreen(
        'HostAnalytics',
        screenClass: 'HostAnalyticsScreen',
      );

      // Track period selection
      await _analyticsService.trackEvent(
        'analytics_period_selected',
        parameters: {
          'host_id': widget.hostId,
          'period': _selectedPeriod,
        },
      );

      // Get host analytics data
      final data = await _hostAnalyticsService.getHostAnalytics(
        widget.hostId,
        _selectedPeriod,
      );

      setState(() {
        _analyticsData = data;
        _isLoading = false;
      });

      // Track successful data load
      await _analyticsService.trackEvent(
        'analytics_data_loaded',
        parameters: {
          'host_id': widget.hostId,
          'period': _selectedPeriod,
          'data_size': data.length.toString(),
        },
      );

    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      // Track error
      await _analyticsService.trackError(
        errorMessage: e.toString(),
        screen: 'HostAnalyticsScreen',
        stackTrace: stackTrace,
      );
    }
  }

  // Track tab changes
  void _onTabChanged(int index) {
    final tabs = ['viewers', 'earnings', 'gifts'];
    _analyticsService.trackEvent(
      'analytics_tab_changed',
      parameters: {
        'host_id': widget.hostId,
        'tab': tabs[index],
        'period': _selectedPeriod,
      },
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
              _buildPeriodSelector(),
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
      return const LoadingWidget(
        message: 'Loading analytics...',
      );
    }

    if (_errorMessage != null) {
      return CustomErrorWidget(
        title: 'Failed to Load Analytics',
        message: _errorMessage!,
        icon: Icons.analytics,
        color: Colors.pink,
        onRetry: _loadAnalyticsData,
      );
    }

    if (_analyticsData == null || _analyticsData!.isEmpty) {
      return EmptyStateWidget(
        message: 'No analytics data available',
        subtitle: 'Try changing the time period or check back later',
        icon: Icons.analytics_outlined,
        onAction: _loadAnalyticsData,
        actionLabel: 'Refresh',
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildViewersAnalytics(),
        _buildEarningsAnalytics(),
        _buildGiftsAnalytics(),
      ],
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
            'Analytics Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.pink.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Icon(Icons.refresh, color: Colors.pink, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Live',
                  style: TextStyle(
                    color: Colors.pink,
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
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
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
        onTap: () {
          setState(() {
            _selectedPeriod = value;
          });
          _loadAnalyticsData();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.pink : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.pink.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
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
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: _onTabChanged,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.pink,
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'Viewers', icon: Icon(Icons.visibility, size: 16)),
          Tab(text: 'Earnings', icon: Icon(Icons.attach_money, size: 16)),
          Tab(text: 'Gifts', icon: Icon(Icons.card_giftcard, size: 16)),
        ],
      ),
    );
  }

  // Viewers Analytics Section
  Widget _buildViewersAnalytics() {
    final data = _analyticsData?['viewers'] ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(
            'Average Viewers',
            '${data['average'] ?? '450'}',
            data['avgTrend'] ?? '↑ 12%',
            Icons.visibility,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'Peak Viewers',
            '${data['peak'] ?? '1,250'}',
            data['peakTrend'] ?? '↑ 8%',
            Icons.trending_up,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'Total Hours',
            '${data['totalHours'] ?? '312'}',
            data['hoursTrend'] ?? '↓ 2%',
            Icons.access_time,
            Colors.orange,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Viewers by Hour', Icons.show_chart),
          const SizedBox(height: 16),
          _buildViewersChart(),
          const SizedBox(height: 24),
          _buildSectionHeader('Top Locations', Icons.location_on),
          const SizedBox(height: 16),
          _buildLocationStats(),
        ],
      ),
    );
  }

  // Earnings Analytics Section
  Widget _buildEarningsAnalytics() {
    final data = _analyticsData?['earnings'] ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(
            'Total Earnings',
            '৳${data['total'] ?? '125,000'}',
            data['totalTrend'] ?? '↑ 15%',
            Icons.money,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'Monthly Average',
            '৳${data['monthlyAvg'] ?? '28,500'}',
            data['monthlyTrend'] ?? '↑ 10%',
            Icons.calendar_today,
            Colors.purple,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'Best Day',
            '৳${data['bestDay'] ?? '4,500'}',
            data['bestDayLabel'] ?? 'Friday',
            Icons.weekend,
            Colors.orange,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Earnings Trend', Icons.trending_up),
          const SizedBox(height: 16),
          _buildEarningsChart(),
          const SizedBox(height: 24),
          _buildSectionHeader('Revenue Sources', Icons.pie_chart),
          const SizedBox(height: 16),
          _buildEarningsSource(),
        ],
      ),
    );
  }

  // Gifts Analytics Section
  Widget _buildGiftsAnalytics() {
    final data = _analyticsData?['gifts'] ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(
            'Total Gifts',
            '${data['total'] ?? '3,456'}',
            data['totalTrend'] ?? '↑ 20%',
            Icons.card_giftcard,
            Colors.pink,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'Top Gifter',
            data['topGifter'] ?? 'John Doe',
            '${data['topGifterGifts'] ?? '500'} gifts',
            Icons.star,
            Colors.amber,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'Gift Value',
            '৳${data['value'] ?? '45,000'}',
            data['valueTrend'] ?? '↑ 18%',
            Icons.attach_money,
            Colors.green,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Popular Gifts', Icons.card_giftcard),
          const SizedBox(height: 16),
          _buildGiftStats(),
          const SizedBox(height: 24),
          _buildSectionHeader('Top Supporters', Icons.people),
          const SizedBox(height: 16),
          _buildTopSupporters(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.pink.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.pink, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, String change, IconData icon, Color color) {
    final isPositive = change.startsWith('↑');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (isPositive ? Colors.green : Colors.red).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isPositive ? Colors.green : Colors.red).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 12,
                ),
                const SizedBox(width: 2),
                Text(
                  change.replaceAll('↑', '').replaceAll('↓', ''),
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontSize: 11,
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

  Widget _buildViewersChart() {
    final data = _analyticsData?['viewers']?['hourlyData'] ?? [
      {'label': '12am', 'value': 30},
      {'label': '4am', 'value': 20},
      {'label': '8am', 'value': 45},
      {'label': '12pm', 'value': 80},
      {'label': '4pm', 'value': 95},
      {'label': '8pm', 'value': 100},
      {'label': '11pm', 'value': 70},
    ];

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final color = index >= 3 && index <= 5 ? Colors.pink : Colors.blue;
          return _buildChartBar(
            item['label'] as String,
            (item['value'] as num).toDouble(),
            color,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEarningsChart() {
    final data = _analyticsData?['earnings']?['dailyData'] ?? [
      {'label': 'Mon', 'value': 40},
      {'label': 'Tue', 'value': 55},
      {'label': 'Wed', 'value': 48},
      {'label': 'Thu', 'value': 70},
      {'label': 'Fri', 'value': 85},
      {'label': 'Sat', 'value': 90},
      {'label': 'Sun', 'value': 75},
    ];

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final color = index == 4 || index == 5 ? Colors.pink : Colors.green;
          return _buildChartBar(
            item['label'] as String,
            (item['value'] as num).toDouble(),
            color,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartBar(String label, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: height * 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                color.withValues(alpha: 0.5),
                color,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildLocationStats() {
    final locations = _analyticsData?['viewers']?['locations'] ?? [
      {'city': 'Dhaka', 'viewers': 450, 'percentage': 35},
      {'city': 'Chittagong', 'viewers': 280, 'percentage': 22},
      {'city': 'Sylhet', 'viewers': 150, 'percentage': 12},
      {'city': 'Other', 'viewers': 370, 'percentage': 31},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: locations.map((location) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildLocationRow(
            location['city'] as String,
            (location['viewers'] as num).toInt(),
            (location['percentage'] as num).toInt(),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildLocationRow(String city, int viewers, int percentage) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            city,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          flex: 4,
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 8,
                width: (percentage / 100) * MediaQuery.of(context).size.width * 0.4,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.pink, Colors.purple],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$viewers',
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(width: 8),
        Text(
          '$percentage%',
          style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildEarningsSource() {
    final sources = _analyticsData?['earnings']?['sources'] ?? [
      {'source': 'Gifts', 'percentage': 65},
      {'source': 'Room Entry', 'percentage': 20},
      {'source': 'Bonuses', 'percentage': 10},
      {'source': 'Other', 'percentage': 5},
    ];

    // Colors for different sources
    final List<Color> sourceColors = [
      Colors.pink,
      Colors.blue,
      Colors.green,
      Colors.orange,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: sources.asMap().entries.map((entry) {
          final index = entry.key;
          final source = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildSourceRow(
              source['source'] as String,
              (source['percentage'] as num).toInt(),
              sourceColors[index % sourceColors.length],
            ),
          );
        }).toList(),
      ),
    );
  }
  Widget _buildSourceRow(String source, int percentage, Color color) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            source,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          flex: 4,
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 8,
                width: (percentage / 100) * MediaQuery.of(context).size.width * 0.4,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$percentage%',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildGiftStats() {
    final gifts = _analyticsData?['gifts']?['popular'] ?? [
      {'gift': 'Super Star', 'count': 150, 'value': 45},
      {'gift': 'Rose', 'count': 280, 'value': 25},
      {'gift': 'Heart', 'count': 420, 'value': 15},
      {'gift': 'Diamond', 'count': 50, 'value': 100},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: gifts.map((gift) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildGiftRow(
            gift['gift'] as String,
            (gift['count'] as num).toInt(),
            (gift['value'] as num).toInt(),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildGiftRow(String gift, int count, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.pink.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.card_giftcard,
                  color: Colors.pink,
                  size: 14,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                gift,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '$count ×',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '৳$value',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopSupporters() {
    final supporters = _analyticsData?['gifts']?['topSupporters'] ?? [
      {'rank': 1, 'name': 'PoPi ', 'gifts': 150, 'value': 7500},
      {'rank': 2, 'name': 'Ritu', 'gifts': 120, 'value': 6000},
      {'rank': 3, 'name': 'Ismail', 'gifts': 95, 'value': 4750},
      {'rank': 4, 'name': 'Kakuli', 'gifts': 80, 'value': 4000},
      {'rank': 5, 'name': 'Razib', 'gifts': 65, 'value': 3250},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: supporters.map((supporter) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSupporterRow(
            (supporter['rank'] as num).toInt(),
            supporter['name'] as String,
            (supporter['gifts'] as num).toInt(),
            (supporter['value'] as num).toInt(),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildSupporterRow(int rank, String name, int gifts, int value) {
    final isTopThree = rank <= 3;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: isTopThree
                  ? const LinearGradient(
                colors: [Colors.amber, Colors.orange],
              )
                  : null,
              color: isTopThree ? null : Colors.grey.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: isTopThree ? Colors.black : Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.pink.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$gifts gifts',
              style: TextStyle(
                color: Colors.pink.withValues(alpha: 0.8),
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '৳$value',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}