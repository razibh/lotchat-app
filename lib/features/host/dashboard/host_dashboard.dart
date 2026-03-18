import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../core/services/host_service.dart';
import '../../../core/services/analytics_service.dart';
import '../models/host_models.dart';
import '../profile/host_profile_screen.dart';
import '../../host/earnings/host_earnings_screen.dart';
import '../analytics/host_analytics_screen.dart';
import '../../../features/agency/badge/agency_badge_widget.dart';
import '../../host/earnings/host_earnings_screen.dart';
class HostDashboard extends StatefulWidget {
  const HostDashboard({required this.hostId, super.key});
  final String hostId;

  @override
  State<HostDashboard> createState() => _HostDashboardState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('hostId', hostId));
  }
}

class _HostDashboardState extends State<HostDashboard> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  bool _isLoading = true;
  String? _errorMessage;
  Host? _host;
  List<HostRoom> _recentRooms = [];
  List<HostGift> _recentGifts = [];
  List<HostSchedule> _upcomingSchedules = [];
  int _selectedNavIndex = 0;
  bool _isLive = true;

  // Services
  late final AnalyticsService _analyticsService;

  // Refresh controller
  final RefreshController _refreshController = RefreshController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _analyticsService = AnalyticsService();
    await _analyticsService.initialize();
    _loadHostData();

    _analyticsService.trackScreen(
      'HostDashboard',
      screenClass: 'HostDashboardScreen',
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _analyticsService.trackEvent('app_resumed', parameters: {
        'screen': 'HostDashboard',
      });
    } else if (state == AppLifecycleState.paused) {
      _analyticsService.trackEvent('app_paused', parameters: {
        'screen': 'HostDashboard',
      });
    }
  }

  Future<void> _loadHostData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _analyticsService.trackEvent(
        'host_data_loading',
        parameters: {
          'host_id': widget.hostId,
        },
      );

      final hostService = HostService();
      final host = await hostService.getHostById(widget.hostId);

      setState(() {
        _host = host;
        _recentRooms = _generateRecentRooms();
        _recentGifts = _generateRecentGifts();
        _upcomingSchedules = _generateSchedules();
        _isLoading = false;
      });

      await _analyticsService.trackEvent(
        'host_data_loaded',
        parameters: {
          'host_id': widget.hostId,
          'followers': host.followers.toString(),
          'total_earnings': host.totalEarnings.toString(),
        },
      );

    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      await _analyticsService.trackError(
        errorMessage: e.toString(),
        screen: 'HostDashboard',
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _refreshData() async {
    await _analyticsService.trackEvent(
      'dashboard_refreshed',
      parameters: {
        'host_id': widget.hostId,
      },
    );

    await _loadHostData();
    _refreshController.refreshCompleted();
  }

  void _navigateTo(Widget screen, String screenName) {
    _analyticsService.trackEvent(
      'navigation',
      parameters: {
        'from': 'HostDashboard',
        'to': screenName,
        'host_id': widget.hostId,
      },
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _handleAction(String action) {
    _analyticsService.trackEvent(
      'dashboard_action',
      parameters: {
        'action': action,
        'host_id': widget.hostId,
      },
    );
  }

  List<HostBadge> _generateBadges() {
    return [
      HostBadge(
        id: 'badge_001',
        name: 'Rising Star',
        icon: '⭐',
        color: Colors.amber,
        earnedDate: DateTime.now().subtract(const Duration(days: 30)),
        description: 'Reached 10k followers',
      ),
      HostBadge(
        id: 'badge_002',
        name: 'Gift Master',
        icon: '🎁',
        color: Colors.purple,
        earnedDate: DateTime.now().subtract(const Duration(days: 15)),
        description: 'Received 1000 gifts',
      ),
      HostBadge(
        id: 'badge_003',
        name: 'Consistent',
        icon: '🔥',
        color: Colors.orange,
        earnedDate: DateTime.now().subtract(const Duration(days: 7)),
        description: '15 day streak',
      ),
    ];
  }

  List<HostRoom> _generateRecentRooms() {
    return [
      HostRoom(
        id: 'room_001',
        hostId: widget.hostId,
        title: 'Friday Night Sing-Along',
        type: RoomType.voice,
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
        endTime: DateTime.now().subtract(const Duration(minutes: 30)),
        maxViewers: 1000,
        currentViewers: 0,
        peakViewers: 850,
        totalGifts: 156,
        earnings: 1250,
        status: RoomStatus.ended,
        tags: ['music', 'singing', 'interactive'],
        isPrivate: false,
        password: null,
      ),
      HostRoom(
        id: 'room_002',
        hostId: widget.hostId,
        title: 'Gaming Night: Among Us',
        type: RoomType.video,
        startTime: DateTime.now().subtract(const Duration(days: 1)),
        endTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        maxViewers: 500,
        currentViewers: 0,
        peakViewers: 620,
        totalGifts: 89,
        earnings: 750,
        status: RoomStatus.ended,
        tags: ['gaming', 'amongus', 'fun'],
        isPrivate: false,
        password: null,
      ),
    ];
  }

  List<HostGift> _generateRecentGifts() {
    return [
      HostGift(
        id: 'gift_001',
        senderId: 'user_123',
        senderName: 'John Doe',
        giftType: 'Super Star',
        amount: 10,
        value: 500,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        message: 'Amazing voice!',
      ),
      HostGift(
        id: 'gift_002',
        senderId: 'user_456',
        senderName: 'Jane Smith',
        giftType: 'Rose',
        amount: 50,
        value: 250,
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        message: 'Love your content',
      ),
      HostGift(
        id: 'gift_003',
        senderId: 'user_789',
        senderName: 'Mike Johnson',
        giftType: 'Heart',
        amount: 20,
        value: 300,
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        message: 'You\'re the best!',
      ),
    ];
  }

  List<HostSchedule> _generateSchedules() {
    return [
      HostSchedule(
        id: 'sch_001',
        title: 'Morning Vibes',
        startTime: DateTime.now().add(const Duration(hours: 3)),
        endTime: DateTime.now().add(const Duration(hours: 5)),
        type: RoomType.voice,
        isRecurring: true,
        recurringPattern: 'daily',
      ),
      HostSchedule(
        id: 'sch_002',
        title: 'Weekend Special',
        startTime: DateTime.now().add(const Duration(days: 1, hours: 20)),
        endTime: DateTime.now().add(const Duration(days: 2, hours: 22)),
        type: RoomType.video,
        isRecurring: true,
        recurringPattern: 'weekly',
      ),
      HostSchedule(
        id: 'sch_003',
        title: 'Q&A Session',
        startTime: DateTime.now().add(const Duration(hours: 48)),
        endTime: DateTime.now().add(const Duration(hours: 50)),
        type: RoomType.chat,
        isRecurring: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: _isLoading
              ? LoadingWidget(
            message: 'Loading dashboard...',
            color: Colors.pink,
          )
              : _errorMessage != null
              ? CustomErrorWidget(
            title: 'Failed to Load Dashboard',
            message: _errorMessage!,
            icon: Icons.dashboard,
            color: Colors.pink,
            onRetry: _loadHostData,
          )
              : _buildDashboard(),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: Colors.pink,
      backgroundColor: Colors.white,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildProfileCard(),
                const SizedBox(height: 20),
                _buildStatsGrid(),
                const SizedBox(height: 20),
                _buildEarningsCard(),
                const SizedBox(height: 20),
                _buildQuickActions(),
                const SizedBox(height: 20),
                _buildUpcomingSchedule(),
                const SizedBox(height: 20),
                _buildRecentGifts(),
                const SizedBox(height: 20),
                _buildRecentRooms(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _handleAction('view_profile');
              _navigateTo(
                HostProfileScreen(hostId: widget.hostId),
                'HostProfile',
              );
            },
            child: Hero(
              tag: 'host_avatar_${widget.hostId}',
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.pink,
                backgroundImage: _host?.avatar != null
                    ? NetworkImage(_host!.avatar!)
                    : null,
                child: _host?.avatar == null
                    ? Text(
                  _host!.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _host!.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_host!.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: 16,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '@${_host!.username}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildLiveStatus(),
        ],
      ),
    );
  }

  Widget _buildLiveStatus() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isLive
              ? [Colors.green, Colors.green.withValues(alpha: 0.8)]
              : [Colors.grey, Colors.grey.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: _isLive
            ? [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: _isLive
                  ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
                  : null,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _isLive ? 'LIVE' : 'OFFLINE',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.pink.withValues(alpha: 0.3),
            Colors.purple.withValues(alpha: 0.3),
            Colors.blue.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatNumber(_host!.followers),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'followers',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _host!.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AgencyBadgeWidget(
                agencyName: _host!.agencyName,
                commissionRate: _host!.agencyCommissionRate,
                isVerified: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: _host!.badges.take(3).map((badge) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Tooltip(
                      message: '${badge.name}\n${badge.description}',
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: badge.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: badge.color.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          badge.icon,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_host!.currentStreak} day streak',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildStatItem(
          'Today',
          '৳${_host!.todayEarnings}',
          Icons.today,
          Colors.green,
          _host!.todayEarnings > (_host!.yesterdayEarnings) ? '+12%' : '-5%',
        ),
        _buildStatItem(
          'Week',
          '৳${_host!.weeklyEarnings}',
          Icons.weekend,
          Colors.blue,
          _host!.weeklyEarnings > (_host!.lastWeekEarnings) ? '+8%' : '-3%',
        ),
        _buildStatItem(
          'Month',
          '৳${_host!.monthlyEarnings}',
          Icons.calendar_month,
          Colors.purple,
          _host!.monthlyEarnings > (_host!.lastMonthEarnings) ? '+15%' : '-2%',
        ),
        _buildStatItem(
          'Rating',
          _host!.rating.toStringAsFixed(1),
          Icons.star,
          Colors.amber,
          '★',
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, String trend) {
    final isPositive = trend.contains('+') || trend == '★';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 8,
            ),
          ),
          if (trend.isNotEmpty) ...[
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: (isPositive ? Colors.green : Colors.red).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                trend,
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontSize: 6,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.withValues(alpha: 0.15),
            Colors.blue.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () {
                  _handleAction('view_earnings');
                  _navigateTo(
                    HostEarningsScreen(hostId: widget.hostId),
                    'HostEarnings',
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.pink.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
                      Text(
                        'Details',
                        style: TextStyle(
                          color: Colors.pink,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.pink,
                        size: 12,
                      ),
                    ],
                  ),
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
                '৳${_host!.availableBalance}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'BDT',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              _buildWithdrawButton(),
            ],
          ),
          const SizedBox(height: 12),
          _buildPendingWithdrawal(),
        ],
      ),
    );
  }

  Widget _buildWithdrawButton() {
    return GestureDetector(
      onTap: () {
        _handleAction('withdraw');
        // TODO: Implement withdraw
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.green, Colors.teal],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 4),
            Text(
              'Withdraw',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingWithdrawal() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.hourglass_bottom,
            color: Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Pending: ৳${_host!.pendingWithdrawal}',
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Est. arrival: 2-3 days',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'Go Live',
            Icons.video_call,
            Colors.green,
                () {
              _handleAction('go_live');
              // TODO: Navigate to go live screen
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'Schedule',
            Icons.calendar_today,
            Colors.blue,
                () {
              _handleAction('schedule');
              // TODO: Navigate to schedule screen
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'Analytics',
            Icons.show_chart,
            Colors.purple,
                () {
              _handleAction('view_analytics');
              _navigateTo(
                HostAnalyticsScreen(hostId: widget.hostId),
                'HostAnalytics',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSchedule() {
    if (_upcomingSchedules.isEmpty) {
      return EmptyStateWidget(
        message: 'No upcoming schedules',
        subtitle: 'Schedule your next live session',
        icon: Icons.schedule,
        onAction: () {
          _handleAction('create_schedule');
          // TODO: Navigate to create schedule
        },
        actionLabel: 'Schedule Now',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.schedule,
                      color: Colors.blue,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Upcoming Schedule',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  _handleAction('view_all_schedules');
                  // TODO: Navigate to full schedule
                },
                child: const Text(
                  'View All',
                  style: TextStyle(color: Colors.pink),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ..._upcomingSchedules.map((schedule) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildScheduleTile(schedule),
        )),
      ],
    );
  }

  Widget _buildScheduleTile(HostSchedule schedule) {
    final timeDiff = schedule.startTime.difference(DateTime.now());
    final isUrgent = timeDiff.inHours < 2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUrgent
              ? Colors.orange.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withValues(alpha: 0.3),
                  Colors.blue.withValues(alpha: 0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              schedule.type == RoomType.voice
                  ? Icons.mic
                  : schedule.type == RoomType.video
                  ? Icons.videocam
                  : Icons.chat,
              color: Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.white54,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (schedule.isRecurring)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.repeat,
                        color: Colors.orange,
                        size: 10,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        schedule.recurringPattern ?? 'Recurring',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              if (isUrgent) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Soon',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentGifts() {
    if (_recentGifts.isEmpty) {
      return EmptyStateWidget(
        message: 'No recent gifts',
        subtitle: 'Gifts from your fans will appear here',
        icon: Icons.card_giftcard,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.pink.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.card_giftcard,
                      color: Colors.pink,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Recent Gifts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  _handleAction('view_all_gifts');
                  // TODO: Navigate to gifts history
                },
                child: const Text(
                  'View All',
                  style: TextStyle(color: Colors.pink),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ..._recentGifts.map((gift) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildGiftTile(gift),
        )),
      ],
    );
  }

  Widget _buildGiftTile(HostGift gift) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.pink, Colors.purple],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.card_giftcard,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gift.senderName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  gift.message ?? 'Sent you a gift',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${gift.amount}x',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      gift.giftType,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '৳${gift.value}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRooms() {
    if (_recentRooms.isEmpty) {
      return EmptyStateWidget(
        message: 'No recent rooms',
        subtitle: 'Your recent live sessions will appear here',
        icon: Icons.video_library,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.video_library,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Recent Rooms',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  _handleAction('view_all_rooms');
                  // TODO: Navigate to rooms history
                },
                child: const Text(
                  'View All',
                  style: TextStyle(color: Colors.pink),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ..._recentRooms.map((room) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildRoomTile(room),
        )),
      ],
    );
  }

  Widget _buildRoomTile(HostRoom room) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  room.type == RoomType.voice ? Colors.blue : Colors.green,
                  room.type == RoomType.voice ? Colors.purple : Colors.teal,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              room.type == RoomType.voice ? Icons.mic : Icons.videocam,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      color: Colors.white54,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${room.peakViewers} peak',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.card_giftcard,
                      color: Colors.white54,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${room.totalGifts} gifts',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '৳${room.earnings}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTimeAgo(room.startTime),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.5),
            Colors.black.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 'Home', 0),
          _buildNavItem(Icons.explore, 'Explore', 1),
          _buildNavItem(Icons.add_circle, 'Go Live', 2),
          _buildNavItem(Icons.message, 'Messages', 3),
          _buildNavItem(Icons.person, 'Profile', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedNavIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNavIndex = index;
        });
        _handleAction('nav_${label.toLowerCase()}');
        // TODO: Handle navigation
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.pink.withValues(alpha: 0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.pink : Colors.white70,
              size: index == 2 ? 32 : 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.pink : Colors.white70,
              fontSize: index == 2 ? 8 : 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatTimeAgo(DateTime time) {
    final difference = DateTime.now().difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

// RefreshController class for pull-to-refresh
class RefreshController extends ChangeNotifier {
  bool _isRefreshing = false;

  bool get isRefreshing => _isRefreshing;

  void refreshCompleted() {
    _isRefreshing = false;
    notifyListeners();
  }

  void requestRefresh() {
    _isRefreshing = true;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// EmptyStateWidget class
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  final Color? color;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.subtitle,
    required this.icon,
    this.onAction,
    this.actionLabel,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (color ?? Colors.grey).withValues(alpha: 0.1),
                    (color ?? Colors.grey).withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: color ?? Colors.white70,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ).copyWith(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    return Colors.transparent;
                  }),
                  shadowColor: WidgetStateProperty.all(Colors.transparent),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color ?? Colors.pink,
                        (color ?? Colors.pink).withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    child: Text(
                      actionLabel!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}