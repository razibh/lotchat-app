import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;  // ✅ Supabase User hide

import '../../core/di/service_locator.dart';
import '../../core/services/user_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/analytics_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../widgets/animation/fade_animation.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/custom_button.dart';
import '../../core/models/user_models.dart' as app;  // ✅ আপনার নিজের User model

class FollowersScreen extends StatefulWidget {
  final String? userId;
  final FollowersTab initialTab;

  const FollowersScreen({
    super.key,
    this.userId,
    this.initialTab = FollowersTab.followers,
  });

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('userId', userId));
    properties.add(EnumProperty<FollowersTab>('initialTab', initialTab));
  }
}

enum FollowersTab { followers, following }

class _FollowersScreenState extends State<FollowersScreen>
    with LoadingMixin, ToastMixin, TickerProviderStateMixin {

  final UserService _userService = ServiceLocator().get<UserService>();
  final AuthService _authService = ServiceLocator().get<AuthService>();
  final AnalyticsService _analyticsService = ServiceLocator().get<AnalyticsService>();

  late TabController _tabController;

  List<app.User> _followers = [];  // ✅ app.User ব্যবহার করুন
  List<app.User> _following = [];  // ✅ app.User ব্যবহার করুন
  String? _currentUserId;
  String? _profileUserId;

  bool _isLoading = true;
  bool _isLoadingMoreFollowers = false;
  bool _isLoadingMoreFollowing = false;
  String? _errorMessage;

  int _followersPage = 1;
  int _followingPage = 1;
  bool _hasMoreFollowers = true;
  bool _hasMoreFollowing = true;

  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == FollowersTab.followers ? 0 : 1,
    );
    _tabController.addListener(_onTabChanged);
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _getCurrentUser();
      await _loadFollowers();
      await _loadFollowing();

      _analyticsService.trackScreen(
        'FollowersScreen',
        screenClass: 'FollowersScreen',
        parameters: {
          'user_id': _profileUserId,
          'tab': _tabController.index == 0 ? 'followers' : 'following',
        },
      );

    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      _analyticsService.trackError(
        errorMessage: e.toString(),
        screen: 'FollowersScreen',
        stackTrace: stackTrace,
      );
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _analyticsService.trackEvent(
        'followers_tab_changed',
        parameters: {
          'user_id': _profileUserId,
          'tab': _tabController.index == 0 ? 'followers' : 'following',
        },
      );
    }
  }

  Future<void> _getCurrentUser() async {
    final session = Supabase.instance.client.auth.currentSession;
    _currentUserId = session?.user.id;
    _profileUserId = widget.userId ?? _currentUserId;
  }

  Future<void> _loadFollowers({bool refresh = false}) async {
    if (_profileUserId == null) return;

    if (refresh) {
      _followersPage = 1;
      _hasMoreFollowers = true;
      _followers.clear();
    }

    if (!_hasMoreFollowers || _isLoadingMoreFollowers) return;

    setState(() {
      _isLoadingMoreFollowers = true;
    });

    try {
      final users = await _userService.getFollowers(
        _profileUserId!,
        page: _followersPage,
        limit: _pageSize,
      );

      setState(() {
        _followers.addAll(users);
        _hasMoreFollowers = users.length == _pageSize;
        if (_hasMoreFollowers) _followersPage++;
        _isLoading = false;
        _isLoadingMoreFollowers = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMoreFollowers = false;
      });
      showError('Failed to load followers: $e');
    }
  }

  Future<void> _loadFollowing({bool refresh = false}) async {
    if (_profileUserId == null) return;

    if (refresh) {
      _followingPage = 1;
      _hasMoreFollowing = true;
      _following.clear();
    }

    if (!_hasMoreFollowing || _isLoadingMoreFollowing) return;

    setState(() {
      _isLoadingMoreFollowing = true;
    });

    try {
      final users = await _userService.getFollowing(
        _profileUserId!,
        page: _followingPage,
        limit: _pageSize,
      );

      setState(() {
        _following.addAll(users);
        _hasMoreFollowing = users.length == _pageSize;
        if (_hasMoreFollowing) _followingPage++;
        _isLoading = false;
        _isLoadingMoreFollowing = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMoreFollowing = false;
      });
      showError('Failed to load following: $e');
    }
  }

  Future<void> _toggleFollow(app.User user) async {  // ✅ app.User ব্যবহার করুন
    if (_currentUserId == null) {
      showError('Please login to follow users');
      return;
    }

    final isFollowing = _following.any((u) => u.id == user.id);

    try {
      bool success;
      if (isFollowing) {
        success = await _userService.unfollowUser(_currentUserId!, user.id);
      } else {
        success = await _userService.followUser(_currentUserId!, user.id);
      }

      if (success) {
        setState(() {
          if (isFollowing) {
            _following.removeWhere((u) => u.id == user.id);
          } else {
            _following.add(user);
          }
        });

        _analyticsService.trackEvent(
          isFollowing ? 'unfollow_user' : 'follow_user',
          parameters: {
            'user_id': _currentUserId,
            'target_user_id': user.id,
          },
        );

        showSuccess(isFollowing ? 'Unfollowed' : 'Following');
      }
    } catch (e) {
      showError('Failed to ${isFollowing ? 'unfollow' : 'follow'} user');
    }
  }

  Future<void> _refreshFollowers() async {
    await _loadFollowers(refresh: true);
  }

  Future<void> _refreshFollowing() async {
    await _loadFollowing(refresh: true);
  }

  bool _isFollowingUser(String userId) {
    return _following.any((u) => u.id == userId);
  }

  String _getTimeAgo(DateTime? date) {
    if (date == null) return 'Recently';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _onUserTap(app.User user) {  // ✅ app.User ব্যবহার করুন
    _analyticsService.trackEvent(
      'view_profile_from_followers',
      parameters: {
        'user_id': _currentUserId,
        'viewed_user_id': user.id,
      },
    );

    // Navigate to user profile
    Navigator.pushNamed(
      context,
      '/profile/view',
      arguments: user.id,
    );
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
      title: Text(
        _profileUserId == _currentUserId ? 'Followers' : 'Profile',
        style: const TextStyle(fontSize: 18),
      ),
      backgroundColor: Colors.pink,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Followers'),
          Tab(text: 'Following'),
        ],
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _followers.isEmpty && _following.isEmpty) {
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
              onPressed: _initialize,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildFollowersList(),
        _buildFollowingList(),
      ],
    );
  }

  Widget _buildFollowersList() {
    if (_followers.isEmpty && !_isLoadingMoreFollowers) {
      return EmptyStateWidget(
        title: 'No Followers',
        message: _profileUserId == _currentUserId
            ? 'You don\'t have any followers yet'
            : 'This user doesn\'t have any followers yet',
        icon: Icons.people_outline,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshFollowers,
      color: Colors.pink,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _followers.length + (_hasMoreFollowers ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _followers.length) {
            return _buildLoadingMoreIndicator();
          }

          final user = _followers[index];
          return FadeAnimation(
            delay: Duration(milliseconds: index * 50),
            child: _buildUserTile(user),
          );
        },
      ),
    );
  }

  Widget _buildFollowingList() {
    if (_following.isEmpty && !_isLoadingMoreFollowing) {
      return EmptyStateWidget(
        title: 'Not Following Anyone',
        message: _profileUserId == _currentUserId
            ? 'You are not following anyone yet'
            : 'This user is not following anyone yet',
        icon: Icons.person_add_disabled,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshFollowing,
      color: Colors.pink,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _following.length + (_hasMoreFollowing ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _following.length) {
            return _buildLoadingMoreIndicator();
          }

          final user = _following[index];
          return FadeAnimation(
            delay: Duration(milliseconds: index * 50),
            child: _buildUserTile(user, isFollowing: true),
          );
        },
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildUserTile(app.User user, {bool isFollowing = false}) {  // ✅ app.User ব্যবহার করুন
    final isCurrentUser = _currentUserId == user.id;
    final isFollowed = _isFollowingUser(user.id);

    return GestureDetector(
      onTap: () => _onUserTap(user),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
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
            // User Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: user.avatar != null
                      ? NetworkImage(user.avatar!)
                      : null,
                  child: user.avatar == null
                      ? Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  )
                      : null,
                ),
                if (user.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // User Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.isVerified)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${user.username}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.pink.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.role.toString().split('.').last,
                          style: const TextStyle(
                            color: Colors.pink,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (user.stats != null) ...[
                        Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${user.stats?.followers ?? 0}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Follow/Unfollow Button
            if (!isCurrentUser && _currentUserId != null)
              CustomButton(
                text: isFollowed ? 'Following' : 'Follow',
                onPressed: () => _toggleFollow(user),
                color: isFollowed ? Colors.grey : Colors.pink,
                height: 32,
                isFullWidth: false,
                fontSize: 12,
              ),
          ],
        ),
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