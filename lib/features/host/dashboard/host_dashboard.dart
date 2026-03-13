import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/neumorphic_button.dart';
import '../models/host_models.dart';
import '../profile/host_profile_screen.dart';
import '../earnings/host_earnings_screen.dart';
import '../../../features/agency/badge/agency_badge_widget.dart';

class HostDashboard extends StatefulWidget {

  const HostDashboard({Key? key, required this.hostId}) : super(key: key);
  final String hostId;

  @override
  State<HostDashboard> createState() => _HostDashboardState();
}

class _HostDashboardState extends State<HostDashboard> {
  bool _isLoading = true;
  Host? _host;
  List<HostRoom> _recentRooms = <>[];
  List<HostGift> _recentGifts = <>[];
  List<HostSchedule> _upcomingSchedules = <>[];

  @override
  void initState() {
    super.initState();
    _loadHostData();
  }

  Future<void> _loadHostData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _host = Host(
        id: 'host_001',
        userId: 'user_001',
        name: 'Sarah Rahman',
        username: 'sarah_live',
        bio: 'Professional singer and entertainer',
        agencyId: 'ag_001',
        agencyName: 'Elite Talent Agency',
        joinedDate: DateTime.now().subtract(const Duration(days: 180)),
        status: HostStatus.active,
        followers: 15230,
        following: 1250,
        totalGifts: 3456,
        totalEarnings: 125000,
        monthlyEarnings: 28500,
        weeklyEarnings: 7200,
        todayEarnings: 1250,
        rating: 4.8,
        totalRooms: 156,
        totalHours: 312,
        avgViewers: 450,
        peakViewers: 1250,
        agencyCommissionRate: 10,
        platformCommissionRate: 5,
        pendingWithdrawal: 3500,
        availableBalance: 8500,
        currentStreak: 15,
        longestStreak: 30,
        totalStreakRewards: 5,
        badges: _generateBadges(),
        specialties: <String>['Singing', 'Gaming', 'Talk Show'],
      );

      _recentRooms = _generateRecentRooms();
      _recentGifts = _generateRecentGifts();
      _upcomingSchedules = _generateSchedules();
      
      _isLoading = false;
    });
  }

  List<HostBadge> _generateBadges() {
    return <>[
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
    return <>[
      HostRoom(
        id: 'room_001',
        hostId: 'host_001',
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
        tags: <String>['music', 'singing', 'interactive'],
        isPrivate: false,
      ),
      HostRoom(
        id: 'room_002',
        hostId: 'host_001',
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
        tags: <String>['gaming', 'amongus', 'fun'],
        isPrivate: false,
      ),
    ];
  }

  List<HostGift> _generateRecentGifts() {
    return <>[
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
    ];
  }

  List<HostSchedule> _generateSchedules() {
    return <>[
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
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildDashboard(),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return Column(
      children: <>[
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <>[
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
              ],
            ),
          ),
        ),
        _buildBottomNav(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <>[
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HostProfileScreen(hostId: widget.hostId),
                ),
              );
            },
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.pink,
              child: Text(
                _host!.name[0],
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  _host!.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '@${_host!.username}',
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
            child: Row(
              children: <>[
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'LIVE',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <>[
            Colors.pink.withOpacity(0.3),
            Colors.purple.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: <>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Row(
                  children: <>[
                    const Icon(Icons.favorite, color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_host!.followers} followers',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AgencyBadgeWidget(
                  agencyName: _host!.agencyName,
                  commissionRate: _host!.agencyCommissionRate,
                  isVerified: true,
                ),
              ],
            ),
          ),
          Column(
            children: <>[
              Row(
                children: _host!.badges.take(3).map((badge) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Tooltip(
                      message: badge.name,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: badge.color.withOpacity(0.2),
                          shape: BoxShape.circle,
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
              const SizedBox(height: 4),
              Text(
                '🔥 ${_host!.currentStreak} day streak',
                style: const TextStyle(color: Colors.orange, fontSize: 12),
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
      childAspectRatio: 1,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: <>[
        _buildStatItem('Today', '৳${_host!.todayEarnings}', Icons.today, Colors.green),
        _buildStatItem('Week', '৳${_host!.weeklyEarnings}', Icons.weekend, Colors.blue),
        _buildStatItem('Month', '৳${_host!.monthlyEarnings}', Icons.month, Colors.purple),
        _buildStatItem('Rating', '${_host!.rating}', Icons.star, Colors.amber),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <>[
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
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
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HostEarningsScreen(hostId: widget.hostId),
                    ),
                  );
                },
                child: const Text(
                  'View All →',
                  style: TextStyle(color: Colors.pink, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <>[
              Text(
                '৳${_host!.availableBalance}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          Row(
            children: <>[
              Icon(Icons.hourglass_bottom, color: Colors.orange, size: 14),
              const SizedBox(width: 4),
              Text(
                'Pending: ৳${_host!.pendingWithdrawal}',
                style: const TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: <>[
        Expanded(
          child: _buildActionButton(
            'Start Room',
            Icons.video_call,
            Colors.green,
            () {},
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            'Schedule',
            Icons.calendar_today,
            Colors.blue,
            () {},
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            'Analytics',
            Icons.show_chart,
            Colors.purple,
            () {},
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: <>[
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <>[
        const Text(
          'Upcoming Schedule',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._upcomingSchedules.map(_buildScheduleTile),
      ],
    );
  }

  Widget _buildScheduleTile(HostSchedule schedule) {
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
              color: Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              schedule.type == RoomType.voice ? Icons.mic : Icons.videocam,
              color: Colors.blue,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  schedule.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
          if (schedule.isRecurring)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Recurring',
                style: TextStyle(color: Colors.orange, fontSize: 8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentGifts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <>[
        const Text(
          'Recent Gifts',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._recentGifts.map(_buildGiftTile),
      ],
    );
  }

  Widget _buildGiftTile(HostGift gift) {
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
              color: Colors.pink.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.card_giftcard, color: Colors.pink, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  gift.senderName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  gift.message ?? 'Sent a gift',
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <>[
              Text(
                '${gift.amount}x ${gift.giftType}',
                style: const TextStyle(color: Colors.green, fontSize: 12),
              ),
              Text(
                '৳${gift.value}',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <>[
          _buildNavItem(Icons.home, 'Home', true),
          _buildNavItem(Icons.explore, 'Explore', false),
          _buildNavItem(Icons.add_circle, 'Go Live', false),
          _buildNavItem(Icons.message, 'Messages', false),
          _buildNavItem(Icons.person, 'Profile', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <>[
        Icon(
          icon,
          color: isSelected ? Colors.pink : Colors.white70,
          size: 24,
        ),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.pink : Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}