import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;  // ✅ Supabase User hide

import '../../core/di/service_locator.dart';
import '../../core/services/user_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/analytics_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/dialog_mixin.dart';
import '../../widgets/animation/fade_animation.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/search_bar.dart';
import '../../core/models/user_models.dart' as app;

class BlockedUsersScreen extends StatefulWidget {
  final String? userId;

  const BlockedUsersScreen({
    super.key,
    this.userId,
  });

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('userId', userId));
  }
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen>
    with LoadingMixin, ToastMixin, DialogMixin {

  final UserService _userService = ServiceLocator.instance.get<UserService>();
  final AuthService _authService = ServiceLocator.instance.get<AuthService>();
  final AnalyticsService _analyticsService = ServiceLocator.instance.get<AnalyticsService>();

  List<app.User> _blockedUsers = [];
  List<app.User> _filteredBlocked = [];
  String _searchQuery = '';
  String? _currentUserId;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isRefreshing = false;

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
      await _loadBlockedUsers();

      _analyticsService.trackScreen(
        'BlockedUsers',
        screenClass: 'BlockedUsersScreen',
        parameters: {'user_id': _currentUserId},
      );

    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      _analyticsService.trackError(
        errorMessage: e.toString(),
        screen: 'BlockedUsersScreen',
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _getCurrentUser() async {
    //  Firebase Auth → Supabase Auth
    final session = Supabase.instance.client.auth.currentSession;
    final userId = widget.userId ?? session?.user.id;

    if (userId == null) {
      throw Exception('User not logged in');
    }

    setState(() {
      _currentUserId = userId;
    });
  }

  Future<void> _loadBlockedUsers() async {
    try {
      final users = await _userService.getBlockedUsers(_currentUserId!);

      setState(() {
        _blockedUsers = users;
        _filteredBlocked = users;
        _isLoading = false;
        _isRefreshing = false;
      });

      _analyticsService.trackEvent(
        'blocked_users_loaded',
        parameters: {
          'user_id': _currentUserId,
          'count': users.length.toString(),
        },
      );

    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _isRefreshing = false;
      });

      _analyticsService.trackError(
        errorMessage: e.toString(),
        screen: 'BlockedUsersScreen',
        stackTrace: stackTrace,
      );
    }
  }

  void _filterBlocked(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredBlocked = _blockedUsers;
      } else {
        _filteredBlocked = _blockedUsers.where((app.User u) {
          return u.username.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _unblockUser(app.User user) async {
    try {
      showLoading('Unblocking...');

      final success = await _userService.unblockUser(_currentUserId!, user.id);

      hideLoading();

      if (success) {
        setState(() {
          _blockedUsers.removeWhere((u) => u.id == user.id);
          _filteredBlocked.removeWhere((u) => u.id == user.id);
        });

        showSuccess('${user.name} has been unblocked');

        _analyticsService.trackEvent(
          'user_unblocked',
          parameters: {
            'user_id': _currentUserId,
            'blocked_user_id': user.id,
          },
        );
      } else {
        showError('Failed to unblock user');
      }

    } catch (e, stackTrace) {
      hideLoading();
      showError('Failed to unblock user: $e');

      _analyticsService.trackError(
        errorMessage: e.toString(),
        screen: 'BlockedUsersScreen',
        stackTrace: stackTrace,
      );
    }
  }

  void _showUnblockDialog(app.User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unblock User'),
        content: Text(
            'Are you sure you want to unblock ${user.name}? '
                'They will be able to see your content and interact with you again.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _unblockUser(user);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Unblock'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadBlockedUsers();
  }

  String _getTimeAgo(DateTime? date) {
    if (date == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(date);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Blocked Users'),
      backgroundColor: Colors.red,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _isRefreshing ? null : _refreshData,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SearchBar(
            hintText: 'Search blocked users...',
            onChanged: _filterBlocked,
          ),
        ),
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
              onPressed: _initialize,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_filteredBlocked.isEmpty) {
      return EmptyStateWidget(
        title: 'No Blocked Users',
        message: _searchQuery.isEmpty
            ? 'You haven\'t blocked anyone yet'
            : 'No results match your search',
        icon: Icons.block,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: Colors.red,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredBlocked.length,
        itemBuilder: (context, index) {
          final user = _filteredBlocked[index];
          return FadeAnimation(
            delay: Duration(milliseconds: index * 50),
            child: _buildUserTile(user),
          );
        },
      ),
    );
  }

  Widget _buildUserTile(app.User user) {
    return Container(
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.role.toString().split('.').last,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Unblock Button
          CustomButton(
            text: 'Unblock',
            onPressed: () => _showUnblockDialog(user),
            color: Colors.red,
            height: 36,
            isFullWidth: false,
            fontSize: 12,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}