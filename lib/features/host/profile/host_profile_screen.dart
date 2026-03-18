import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/host_service.dart';
import '../models/host_models.dart';
import '../dashboard/host_dashboard.dart';
import '../earnings/host_earnings_screen.dart';
import '../analytics/host_analytics_screen.dart';

class HostProfileScreen extends StatefulWidget {
  const HostProfileScreen({required this.hostId, super.key});
  final String hostId;

  @override
  State<HostProfileScreen> createState() => _HostProfileScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('hostId', hostId));
  }
}

class _HostProfileScreenState extends State<HostProfileScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  Host? _host;
  List<HostFollower> _followers = [];
  List<HostFollower> _following = [];
  List<HostRoom> _recentRooms = [];

  bool _isFollowing = false;
  int _selectedTabIndex = 0;

  // Services
  late final AnalyticsService _analyticsService;
  late final HostService _hostService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _analyticsService = AnalyticsService();
    _hostService = HostService();
    await _analyticsService.initialize();
    _loadProfile();

    _analyticsService.trackScreen(
      'HostProfile',
      screenClass: 'HostProfileScreen',
      parameters: {'host_id': widget.hostId},
    );
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Track profile view
      await _analyticsService.trackEvent(
        'profile_viewed',
        parameters: {'host_id': widget.hostId},
      );

      // Load host data
      final host = await _hostService.getHostById(widget.hostId);

      // Load followers and following
      final followers = await _hostService.getHostFollowers(widget.hostId);
      final following = await _hostService.getHostFollowing(widget.hostId);
      final rooms = await _hostService.getHostRooms(widget.hostId, limit: 5);

      setState(() {
        _host = host;
        _followers = followers;
        _following = following;
        _recentRooms = rooms;
        _isLoading = false;
      });

    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      await _analyticsService.trackError(
        errorMessage: e.toString(),
        screen: 'HostProfileScreen',
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _toggleFollow() async {
    try {
      setState(() {
        _isFollowing = !_isFollowing;
        if (_isFollowing) {
          _host = _host!.copyWith(followers: _host!.followers + 1);
        } else {
          _host = _host!.copyWith(followers: _host!.followers - 1);
        }
      });

      await _analyticsService.trackEvent(
        _isFollowing ? 'follow_host' : 'unfollow_host',
        parameters: {'host_id': widget.hostId},
      );

      // TODO: API call to follow/unfollow

    } catch (e, stackTrace) {
      // Revert on error
      setState(() {
        _isFollowing = !_isFollowing;
        if (_isFollowing) {
          _host = _host!.copyWith(followers: _host!.followers - 1);
        } else {
          _host = _host!.copyWith(followers: _host!.followers + 1);
        }
      });

      await _analyticsService.trackError(
        errorMessage: e.toString(),
        screen: 'HostProfileScreen',
        stackTrace: stackTrace,
      );
    }
  }

  void _navigateTo(Widget screen, String screenName) {
    _analyticsService.trackEvent(
      'navigation',
      parameters: {
        'from': 'HostProfile',
        'to': screenName,
        'host_id': widget.hostId,
      },
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: _isLoading
              ? LoadingWidget(
            message: 'Loading profile...',
            color: Colors.pink,
          )
              : _errorMessage != null
              ? CustomErrorWidget(
            title: 'Failed to Load Profile',
            message: _errorMessage!,
            icon: Icons.person,
            color: Colors.pink,
            onRetry: _loadProfile,
          )
              : _buildProfile(),
        ),
      ),
    );
  }

  Widget _buildProfile() {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(
          child: _buildProfileInfo(),
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
          child: _buildActionButtons(),
        ),
        SliverToBoxAdapter(
          child: _buildTabs(),
        ),
        _buildContentList(),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover Image or Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.pink.withValues(alpha: 0.9),
                    Colors.purple.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Profile Info Overlay
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.pink,
                      backgroundImage: _host?.avatar != null
                          ? NetworkImage(_host!.avatar!)
                          : null,
                      child: _host?.avatar == null
                          ? Text(
                        _host!.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Name and Username
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _host!.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_host!.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${_host!.username}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Agency Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.business_center,
                                color: Colors.white70,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _host!.agencyName,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: Colors.grey[900],
            onSelected: (value) {
              _analyticsService.trackEvent(
                'profile_menu_selected',
                parameters: {'option': value, 'host_id': widget.hostId},
              );
              // Handle menu actions
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Text('Share Profile', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Text('Report', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'block',
                child: Text('Block', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoColumn(
              'Followers',
              _formatNumber(_host!.followers),
              Icons.people,
            ),
          ),
          Expanded(
            child: _buildInfoColumn(
              'Following',
              _formatNumber(_host!.following),
              Icons.person_add,
            ),
          ),
          Expanded(
            child: _buildInfoColumn(
              'Rooms',
              '${_host!.totalRooms}',
              Icons.video_library,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.pink, size: 16),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
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

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.all(20),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Rating', '${_host!.rating} ⭐', Icons.star),
          _buildStatItem('Hours', '${_host!.totalHours}h', Icons.access_time),
          _buildStatItem('Peak', '${_host!.peakViewers}', Icons.trending_up),
          _buildStatItem('Streak', '${_host!.currentStreak} 🔥', Icons.local_fire_department),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.pink, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildBio() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  Icons.info_outline,
                  color: Colors.pink,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'About',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _host!.bio ?? 'No bio yet',
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                if (_host!.specialties.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _host!.specialties.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.pink.withValues(alpha: 0.2),
                              Colors.purple.withValues(alpha: 0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.pink.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          skill,
                          style: const TextStyle(
                            color: Colors.pink,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadges() {
    if (_host!.badges.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.military_tech,
                  color: Colors.amber,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Badges',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _host!.badges.map((badge) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      badge.color.withOpacity(0.2),
                      badge.color.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: badge.color.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      badge.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      badge.name,
                      style: TextStyle(
                        color: badge.color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _toggleFollow,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFollowing ? Colors.transparent : Colors.pink,
                foregroundColor: _isFollowing ? Colors.pink : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                side: _isFollowing
                    ? const BorderSide(color: Colors.pink)
                    : BorderSide.none,
              ),
              child: Text(_isFollowing ? 'Following' : 'Follow'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                _navigateTo(
                  HostDashboard(hostId: widget.hostId),
                  'HostDashboard',
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                side: const BorderSide(color: Colors.white30),
              ),
              child: const Text('Dashboard'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          _buildTab('Followers', 0, _followers.length),
          _buildTab('Following', 1, _following.length),
          _buildTab('Rooms', 2, _recentRooms.length),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index, int count) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTabIndex = index);
          _analyticsService.trackEvent(
            'profile_tab_changed',
            parameters: {
              'tab': label.toLowerCase(),
              'host_id': widget.hostId,
            },
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.pink : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: Colors.pink.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentList() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildList(
          items: _followers,
          emptyMessage: 'No followers yet',
          emptyIcon: Icons.people_outline,
          itemBuilder: (context, follower) => _buildFollowerTile(follower),
        );
      case 1:
        return _buildList(
          items: _following,
          emptyMessage: 'Not following anyone',
          emptyIcon: Icons.person_add_disabled,
          itemBuilder: (context, user) => _buildFollowingTile(user),
        );
      case 2:
        return _buildList(
          items: _recentRooms,
          emptyMessage: 'No rooms yet',
          emptyIcon: Icons.video_library,
          itemBuilder: (context, room) => _buildRoomTile(room),
        );
      default:
        return const SliverToBoxAdapter(child: SizedBox());
    }
  }

  Widget _buildList<T>({
    required List<T> items,
    required String emptyMessage,
    required IconData emptyIcon,
    required Widget Function(BuildContext, T) itemBuilder,
  }) {
    if (items.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                emptyIcon,
                size: 60,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: itemBuilder(context, items[index]),
          ),
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildFollowerTile(HostFollower follower) {
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
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blue,
            backgroundImage: follower.avatar != null
                ? NetworkImage(follower.avatar!)
                : null,
            child: follower.avatar == null
                ? Text(
              follower.username[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  follower.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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
                      'Followed ${_formatTimeAgo(follower.followedDate)}',
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
          if (follower.isFollowing)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withValues(alpha: 0.2),
                    Colors.blue.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                ),
              ),
              child: const Text(
                'Following',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFollowingTile(HostFollower user) {
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
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.purple,
            backgroundImage: user.avatar != null
                ? NetworkImage(user.avatar!)
                : null,
            child: user.avatar == null
                ? Text(
              user.username[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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
                      'Following ${_formatTimeAgo(user.followedDate)}',
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
          OutlinedButton(
            onPressed: () {
              // TODO: Unfollow
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.pink,
              side: const BorderSide(color: Colors.pink),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Unfollow'),
          ),
        ],
      ),
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
            padding: const EdgeInsets.all(12),
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
              size: 20,
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
                      '${room.peakViewers} viewers',
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
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
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

  String _formatTimeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}