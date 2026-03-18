import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/user_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/analytics_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../widgets/animation/fade_animation.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../core/models/user_models.dart';

class ProfileStatsScreen extends StatefulWidget {
  final String userId;

  const ProfileStatsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ProfileStatsScreen> createState() => _ProfileStatsScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('userId', userId));
  }
}

class _ProfileStatsScreenState extends State<ProfileStatsScreen>
    with LoadingMixin, ToastMixin, TickerProviderStateMixin {

  final UserService _userService = ServiceLocator.instance.get<UserService>();
  final AuthService _authService = ServiceLocator.instance.get<AuthService>();
  final AnalyticsService _analyticsService = ServiceLocator.instance.get<AnalyticsService>();

  User? _user;
  UserStats? _stats;
  Map<String, dynamic>? _detailedStats;

  bool _isLoading = true;
  String? _errorMessage;

  late TabController _tabController;

  final List<String> _periods = ['Week', 'Month', 'Year', 'All'];
  String _selectedPeriod = 'Month';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadStats();

    _analyticsService.trackScreen(
      'ProfileStats',
      screenClass: 'ProfileStatsScreen',
    );
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _userService.getUserById(widget.userId);
      final stats = await _userService.getUserStats(widget.userId);

      setState(() {
        _user = user;
        _stats = user?.stats;
        _detailedStats = stats;
        _isLoading = false;
      });

    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      _analyticsService.trackError(
        errorMessage: e.toString(),
        screen: 'ProfileStatsScreen',
        stackTrace: stackTrace,
      );
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _analyticsService.trackEvent(
        'stats_tab_changed',
        parameters: {
          'user_id': widget.userId,
          'tab': _getTabName(_tabController.index),
        },
      );
    }
  }

  String _getTabName(int index) {
    switch (index) {
      case 0:
        return 'Overview';
      case 1:
        return 'Activity';
      case 2:
        return 'Earnings';
      case 3:
        return 'Gifts';
      default:
        return 'Overview';
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final hours = (minutes / 60).floor();
      final remainingMinutes = minutes % 60;
      return '$hours h ${remainingMinutes} m';
    }
    return '$minutes m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Profile Statistics'),
      backgroundColor: Colors.purple,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Activity'),
          Tab(text: 'Earnings'),
          Tab(text: 'Gifts'),
        ],
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
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
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStats,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildActivityTab(),
        _buildEarningsTab(),
        _buildGiftsTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatsGrid(),
          const SizedBox(height: 20),
          _buildLevelProgress(),
          const SizedBox(height: 20),
          _buildStreakCard(),
          const SizedBox(height: 20),
          _buildRankCard(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          'Total Rooms',
          _formatNumber(_stats?.totalRooms ?? 0),
          Icons.video_library,
          Colors.blue,
        ),
        _buildStatCard(
          'Total Hours',
          _formatDuration(_stats?.totalHours ?? 0),
          Icons.access_time,
          Colors.green,
        ),
        _buildStatCard(
          'Followers',
          _formatNumber(_stats?.followers ?? 0),
          Icons.people,
          Colors.orange,
        ),
        _buildStatCard(
          'Following',
          _formatNumber(_stats?.following ?? 0),
          Icons.person_add,
          Colors.purple,
        ),
        _buildStatCard(
          'Gifts Sent',
          _formatNumber(_stats?.totalGiftsSent ?? 0),
          Icons.card_giftcard,
          Colors.pink,
        ),
        _buildStatCard(
          'Gifts Received',
          _formatNumber(_stats?.totalGiftsReceived ?? 0),
          Icons.card_giftcard,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgress() {
    final level = _stats?.level ?? 1;
    final xp = _stats?.xp ?? 0;
    final xpToNextLevel = _stats?.xpToNextLevel ?? 100;
    final progress = xp / xpToNextLevel;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.stars, color: Colors.amber),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Level Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level $level',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              Text(
                '$xp / $xpToNextLevel XP',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.orange, Colors.deepOrange],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Streak',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${_stats?.streak ?? 0} days',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Longest',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                '${_stats?.longestStreak ?? 0} days',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.purple, Colors.pink],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Global Rank',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '#${_stats?.rank ?? 0}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Rating',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                (_stats?.rating ?? 0).toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildActivityCard(
          'Rooms Hosted',
          '${_stats?.totalRooms ?? 0}',
          Icons.video_library,
          Colors.blue,
          'Total live rooms created',
        ),
        _buildActivityCard(
          'Hours Streamed',
          _formatDuration(_stats?.totalHours ?? 0),
          Icons.timer,
          Colors.green,
          'Total streaming time',
        ),
        _buildActivityCard(
          'Average Viewers',
          '${_stats?.followers ?? 0}',
          Icons.visibility,
          Colors.orange,
          'Per stream average',
        ),
        _buildActivityCard(
          'Peak Viewers',
          '${_stats?.followers ?? 0}',
          Icons.trending_up,
          Colors.purple,
          'Highest concurrent viewers',
        ),
        _buildPeriodSelector(),
        const SizedBox(height: 20),
        _buildActivityChart(),
      ],
    );
  }

  Widget _buildActivityCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: _periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.purple : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActivityChart() {
    // Chart data
    final List<Map<String, dynamic>> chartData = [
      {'label': 'Mon', 'value': 40.0},
      {'label': 'Tue', 'value': 55.0},
      {'label': 'Wed', 'value': 48.0},
      {'label': 'Thu', 'value': 70.0},
      {'label': 'Fri', 'value': 85.0},
      {'label': 'Sat', 'value': 90.0},
      {'label': 'Sun', 'value': 75.0},
    ];

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: chartData.map((data) {
          return _buildChartBar(
              data['label'] as String,
              data['value'] as double
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartBar(String label, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.purple, Colors.pink],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildEarningsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildEarningsSummary(),
        const SizedBox(height: 20),
        _buildEarningsBreakdown(),
        const SizedBox(height: 20),
        _buildRecentTransactions(),
      ],
    );
  }

  Widget _buildEarningsSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.green, Colors.teal],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Total Earnings',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '৳${_formatNumber(_stats?.totalEarnings?.toInt() ?? 0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildEarningStat('This Month', '৳${_detailedStats?['monthlyEarnings'] ?? 0}'),
              _buildEarningStat('This Week', '৳${_detailedStats?['weeklyEarnings'] ?? 0}'),
              _buildEarningStat('Today', '৳${_detailedStats?['todayEarnings'] ?? 0}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsBreakdown() {
    // Breakdown data
    final List<Map<String, dynamic>> breakdownData = [
      {'label': 'Gifts', 'percentage': 65, 'color': Colors.pink},
      {'label': 'Room Entry', 'percentage': 20, 'color': Colors.blue},
      {'label': 'Bonuses', 'percentage': 10, 'color': Colors.green},
      {'label': 'Other', 'percentage': 5, 'color': Colors.orange},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Earnings Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...breakdownData.map((data) => _buildBreakdownItem(
            data['label'] as String,
            data['percentage'] as int,
            data['color'] as Color,
          )),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(String label, int percentage, Color color) {
    final screenWidth = MediaQuery.of(context).size.width;
    final barWidth = (screenWidth - 100) * (percentage / 100);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  height: 8,
                  width: barWidth,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$percentage%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  child: const Icon(Icons.card_giftcard, color: Colors.green),
                ),
                title: const Text('Gift Received'),
                subtitle: Text('${index + 1} hours ago'),
                trailing: Text(
                  '+৳${(index + 1) * 100}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGiftsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildGiftsSummary(),
        const SizedBox(height: 20),
        _buildGiftCategories(),
        const SizedBox(height: 20),
        _buildTopGifters(),
      ],
    );
  }

  Widget _buildGiftsSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.pink, Colors.purple],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text(
                'Received',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 4),
              Text(
                _formatNumber(_stats?.totalGiftsReceived ?? 0),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            children: [
              const Text(
                'Sent',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 4),
              Text(
                _formatNumber(_stats?.totalGiftsSent ?? 0),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGiftCategories() {
    // Gift categories data
    final List<Map<String, dynamic>> giftData = [
      {'name': 'Super Star', 'count': 150, 'color': Colors.pink},
      {'name': 'Rose', 'count': 280, 'color': Colors.red},
      {'name': 'Heart', 'count': 420, 'color': Colors.purple},
      {'name': 'Diamond', 'count': 50, 'color': Colors.blue},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gift Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...giftData.map((data) => _buildGiftCategory(
            data['name'] as String,
            data['count'] as int,
            data['color'] as Color,
          )),
        ],
      ),
    );
  }

  Widget _buildGiftCategory(String name, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.card_giftcard, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$count received',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopGifters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Supporters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: index < 3 ? Colors.amber : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '#${index + 1}',
                          style: TextStyle(
                            color: index < 3 ? Colors.black : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 20,
                      child: Text('U${index + 1}'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'User ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${(index + 1) * 100} gifts',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '৳${(index + 1) * 500}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }
}