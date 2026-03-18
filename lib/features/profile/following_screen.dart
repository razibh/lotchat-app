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
import '../../widgets/common/custom_button.dart';
import '../../core/models/user_models.dart';

class FollowingScreen extends StatefulWidget {
  final String? userId;
  final bool showAppBar;

  const FollowingScreen({
    super.key,
    this.userId,
    this.showAppBar = true,
  });

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('userId', userId));
    properties.add(DiagnosticsProperty<bool>('showAppBar', showAppBar));
  }
}

class _FollowingScreenState extends State<FollowingScreen>
    with LoadingMixin, ToastMixin {

  final UserService _userService = ServiceLocator().get<UserService>();
  final AuthService _authService = ServiceLocator().get<AuthService>();
  final AnalyticsService _analyticsService = ServiceLocator().get<AnalyticsService>();

  List<User> _following = [];
  String? _currentUserId;
  String? _profileUserId;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  int _currentPage = 1;
  bool _hasMore = true;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _getCurrentUser();
      await _loadFollowing();

      _analyticsService.trackScreen(
        'FollowingScreen',
        screenClass: 'FollowingScreen',
        parameters: {
          'user_id': _profileUserId,
          'count': _following.length.toString(),
        },
      );

    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      _analyticsService.trackError(
        errorMessage: e.toString(),
        screen: 'FollowingScreen',
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _getCurrentUser() async {
    final user = await _authService.getCurrentUser();
    _currentUserId = user?.uid;
    _profileUserId = widget.userId ?? _currentUserId;
  }

  Future<void> _loadFollowing({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _following.clear();
    }

    if (!_hasMore || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final users = await _userService.getFollowing(
        _profileUserId!,
        page: _currentPage,
        limit: _pageSize,
      );

      setState(() {
        _following.addAll(users);
        _hasMore = users.length == _pageSize;
        if (_hasMore) _currentPage++;
        _isLoading = false;
        _isLoadingMore = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      showError('Failed to load following: $e');
    }
  }

  Future<void> _toggleFollow(User user) async {
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

  Future<void> _refreshData() async {
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

  void _onUserTap(User user) {
    _analyticsService.trackEvent(
      'view_profile_from_following',
      parameters: {
        'user_id': _currentUserId,
        'viewed_user_id': user.id,
      },
    );

    // Navigate to user profile
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => UserProfileScreen(userId: user.id),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? _buildAppBar() : null,
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _profileUserId == _currentUserId ? 'Following' : 'Following',
        style: const TextStyle(fontSize: 18),
      ),
      backgroundColor: Colors.pink,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _isLoading ? null : _refreshData,
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading && _following.isEmpty) {
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

    if (_following.isEmpty && !_isLoadingMore) {
      return EmptyStateWidget(
        title: 'Not Following Anyone',
        message: _profileUserId == _currentUserId
            ? 'You are not following anyone yet.\nDiscover people to follow!'
            : 'This user is not following anyone yet',
        icon: Icons.person_add_disabled,
        buttonText: _profileUserId == _currentUserId ? 'Discover People' : null,
        onButtonPressed: _profileUserId == _currentUserId
            ? () {
          // Navigate to discover people screen
        }
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: Colors.pink,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _following.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _following.length) {
            return _buildLoadingMoreIndicator();
          }

          final user = _following[index];
          return FadeAnimation(
            delay: Duration(milliseconds: index * 50),
            child: _buildUserTile(user),
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

  Widget _buildUserTile(User user) {
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
    super.dispose();
  }
}