import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../models/host_models.dart';

class HostProfileScreen extends StatefulWidget {

  const HostProfileScreen({Key? key, required this.hostId}) : super(key: key);
  final String hostId;

  @override
  State<HostProfileScreen> createState() => _HostProfileScreenState();
}

class _HostProfileScreenState extends State<HostProfileScreen> {
  bool _isLoading = true;
  Host? _host;
  List<HostFollower> _followers = <>[];
  final bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _host = Host(
        id: 'host_001',
        userId: 'user_001',
        name: 'Sarah Rahman',
        username: 'sarah_live',
        bio: '🎤 Professional Singer | 🎮 Gamer | ❤️ spreading positivity\n'
            '📅 Live daily at 8 PM\n'
            '💌 DM for collaborations',
        avatar: null,
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
        badges: <dynamic>[],
        specialties: <String>['Singing', 'Gaming', 'Talk Show'],
      );

      _followers = List.generate(10, (int index) {
        return HostFollower(
          userId: 'user_${100 + index}',
          username: 'follower_${index + 1}',
          followedDate: DateTime.now().subtract(Duration(days: index * 5)),
          isFollowing: index % 3 == 0,
        );
      });

      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildProfile(),
        ),
      ),
    );
  }

  Widget _buildProfile() {
    return CustomScrollView(
      slivers: <>[
        _buildAppBar(),
        SliverToBoxAdapter(
          child: _buildProfileHeader(),
        ),
        SliverToBoxAdapter(
          child: _buildStats(),
        ),
        SliverToBoxAdapter(
          child: _buildBio(),
        ),
        SliverToBoxAdapter(
          child: _buildBadges(),
        ),
        SliverToBoxAdapter(
          child: _buildTabs(),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: _buildFollowersList(),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: <>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <>[
                    Colors.pink.withOpacity(0.8),
                    Colors.purple.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 50,
              left: 20,
              child: Row(
                children: <>[
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.pink,
                      child: Text(
                        _host!.name[0],
                        style: const TextStyle(color: Colors.white, fontSize: 30),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <>[
                      Text(
                        _host!.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '@${_host!.username}',
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: <>[
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: <>[
          Expanded(
            child: Column(
              children: <>[
                const Text(
                  'Followers',
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  '${_host!.followers}',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: <>[
                const Text(
                  'Following',
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  '${_host!.following}',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: <>[
                const Text(
                  'Rooms',
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  '${_host!.totalRooms}',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <>[
          _buildStatItem('Rating', '${_host!.rating} ⭐'),
          _buildStatItem('Hours', '${_host!.totalHours}h'),
          _buildStatItem('Peak', '${_host!.peakViewers}'),
          _buildStatItem('Streak', '🔥 ${_host!.currentStreak}'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
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

  Widget _buildBio() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <>[
          const Text(
            'About',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _host!.bio ?? 'No bio yet',
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _host!.specialties.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.pink.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  skill,
                  style: const TextStyle(color: Colors.pink, fontSize: 10),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBadges() {
    if (_host!.badges.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <>[
          const Text(
            'Badges',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: _host!.badges.map((badge) {
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: badge.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: <>[
                    Text(badge.icon, style: const TextStyle(fontSize: 20)),
                    Text(
                      badge.name,
                      style: TextStyle(color: badge.color, fontSize: 10),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: <>[
          Expanded(
            child: _buildTab('Followers', true),
          ),
          Expanded(
            child: _buildTab('Following', false),
          ),
          Expanded(
            child: _buildTab('Rooms', false),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isSelected ? Colors.pink : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.pink : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFollowersList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final follower = _followers[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: <>[
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue,
                  child: Text(
                    follower.username[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <>[
                      Text(
                        follower.username,
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Followed ${_formatDate(follower.followedDate)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                if (follower.isFollowing)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Following',
                      style: TextStyle(color: Colors.blue, fontSize: 10),
                    ),
                  ),
              ],
            ),
          );
        },
        childCount: _followers.length,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}