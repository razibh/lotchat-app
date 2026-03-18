import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../core/di/service_locator.dart';
import '../../core/services/friend_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/analytics_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../widgets/animation/fade_animation.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/custom_button.dart';
import '../../core/models/user_models.dart' as app;  // alias ব্যবহার

class FriendsScreen extends StatefulWidget {
  final String? userId;
  final FriendsTab initialTab;

  const FriendsScreen({
    super.key,
    this.userId,
    this.initialTab = FriendsTab.friends,
  });

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('userId', userId));
    properties.add(EnumProperty<FriendsTab>('initialTab', initialTab));
  }
}

enum FriendsTab { friends, requests, suggestions }

class _FriendsScreenState extends State<FriendsScreen>
    with LoadingMixin, ToastMixin, TickerProviderStateMixin {

  final FriendService _friendService = ServiceLocator.instance.get<FriendService>();  // ✅ ServiceLocator.instance
  final AuthService _authService = ServiceLocator.instance.get<AuthService>();        // ✅ ServiceLocator.instance
  final AnalyticsService _analyticsService = ServiceLocator.instance.get<AnalyticsService>(); // ✅ ServiceLocator.instance

  late TabController _tabController;

  List<app.User> _friends = [];
  List<Map<String, dynamic>> _incomingRequests = [];
  List<Map<String, dynamic>> _outgoingRequests = [];
  List<FriendSuggestion> _suggestions = [];

  String? _currentUserId;
  String? _profileUserId;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.index,
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

      // Load friends
      _friendService.getFriends(_profileUserId!).listen((users) {
        if (mounted) {
          setState(() {
            _friends = users;
          });
        }
      });

      // Load incoming friend requests
      _friendService.getFriendRequests(_profileUserId!).listen((requests) {
        if (mounted) {
          setState(() {
            _incomingRequests = requests.map((r) => r.toJson()).toList();
          });
        }
      });

      // Load sent requests
      _friendService.getSentRequests(_profileUserId!).listen((requests) {
        if (mounted) {
          setState(() {
            _outgoingRequests = requests.map((r) => r.toJson()).toList();
          });
        }
      });

      // Load suggestions
      final suggestions = await _friendService.getFriendSuggestions(limit: 20);
      setState(() {
        _suggestions = suggestions;
        _isLoading = false;
      });

      _analyticsService.trackScreen(
        'FriendsScreen',
        screenClass: 'FriendsScreen',
        parameters: {
          'user_id': _profileUserId,
          'tab': _getCurrentTab().toString(),
        },
      );

    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      _analyticsService.trackError(
        errorMessage: e.toString(),
        screen: 'FriendsScreen',
        stackTrace: stackTrace,
      );
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _analyticsService.trackEvent(
        'friends_tab_changed',
        parameters: {
          'user_id': _profileUserId,
          'tab': _getCurrentTab().toString(),
        },
      );
    }
  }

  FriendsTab _getCurrentTab() {
    return FriendsTab.values[_tabController.index];
  }

  Future<void> _getCurrentUser() async {
    final firebase_auth.User? user = await _authService.getCurrentUser();
    _currentUserId = user?.uid;
    _profileUserId = widget.userId ?? _currentUserId;
  }

  Future<void> _acceptFriendRequest(String requestId, String senderId) async {
    try {
      showLoading('Accepting...');

      final success = await _friendService.acceptFriendRequest(requestId, senderId);

      hideLoading();

      if (success) {
        _analyticsService.trackEvent(
          'friend_request_accepted',
          parameters: {
            'user_id': _currentUserId,
            'friend_id': senderId,
          },
        );

        showSuccess('Friend request accepted');
      } else {
        showError('Failed to accept request');
      }

    } catch (e) {
      hideLoading();
      showError('Failed to accept request: $e');
    }
  }

  Future<void> _rejectFriendRequest(String requestId) async {
    try {
      showLoading('Rejecting...');

      final success = await _friendService.rejectFriendRequest(requestId);

      hideLoading();

      if (success) {
        _analyticsService.trackEvent(
          'friend_request_rejected',
          parameters: {
            'user_id': _currentUserId,
          },
        );

        showSuccess('Friend request rejected');
      } else {
        showError('Failed to reject request');
      }

    } catch (e) {
      hideLoading();
      showError('Failed to reject request: $e');
    }
  }

  Future<void> _cancelFriendRequest(String requestId) async {
    try {
      showLoading('Canceling...');

      final success = await _friendService.cancelFriendRequest(requestId);

      hideLoading();

      if (success) {
        showSuccess('Friend request canceled');
      } else {
        showError('Failed to cancel request');
      }

    } catch (e) {
      hideLoading();
      showError('Failed to cancel request: $e');
    }
  }

  Future<void> _sendFriendRequest(String userId) async {
    try {
      showLoading('Sending request...');

      final success = await _friendService.sendFriendRequest(userId);

      hideLoading();

      if (success) {
        _analyticsService.trackEvent(
          'friend_request_sent',
          parameters: {
            'user_id': _currentUserId,
            'target_id': userId,
          },
        );

        showSuccess('Friend request sent');
      } else {
        showError('Failed to send request');
      }

    } catch (e) {
      hideLoading();
      showError('Failed to send request: $e');
    }
  }

  Future<void> _removeFriend(String friendId) async {
    try {
      showLoading('Removing...');

      final success = await _friendService.removeFriend(friendId);

      hideLoading();

      if (success) {
        _analyticsService.trackEvent(
          'friend_removed',
          parameters: {
            'user_id': _currentUserId,
            'friend_id': friendId,
          },
        );

        showSuccess('Friend removed');
      } else {
        showError('Failed to remove friend');
      }

    } catch (e) {
      hideLoading();
      showError('Failed to remove friend: $e');
    }
  }

  void _showFriendOptions(app.User friend) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundImage: friend.avatar != null
                    ? NetworkImage(friend.avatar!)
                    : null,
                child: friend.avatar == null
                    ? Text(friend.name[0].toUpperCase())
                    : null,
              ),
              title: Text(friend.name),
              subtitle: Text('@${friend.username}'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                _onUserTap(friend.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.green),
              title: const Text('Send Message'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to chat
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_remove, color: Colors.red),
              title: const Text('Unfriend'),
              onTap: () {
                Navigator.pop(context);
                _removeFriend(friend.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onUserTap(String userId) {
    _analyticsService.trackEvent(
      'view_profile_from_friends',
      parameters: {
        'user_id': _currentUserId,
        'viewed_user_id': userId,
      },
    );

    // Navigate to user profile
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => ProfileScreen(userId: userId),
    //   ),
    // );
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
        _profileUserId == _currentUserId ? 'Friends' : 'Friends',
        style: const TextStyle(fontSize: 18),
      ),
      backgroundColor: Colors.green,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Friends'),
          Tab(text: 'Requests'),
          Tab(text: 'Suggestions'),
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
        _buildFriendsList(),
        _buildRequestsList(),
        _buildSuggestionsList(),
      ],
    );
  }

  Widget _buildFriendsList() {
    if (_friends.isEmpty) {
      return EmptyStateWidget(
        title: 'No Friends Yet',
        message: _profileUserId == _currentUserId
            ? 'Connect with people to build your friend list'
            : 'This user doesn\'t have any friends yet',
        icon: Icons.people_outline,
        buttonText: _profileUserId == _currentUserId ? 'Find Friends' : null,
        onButtonPressed: _profileUserId == _currentUserId
            ? () {
          _tabController.animateTo(2); // Go to suggestions tab
        }
            : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _friends.length,
      itemBuilder: (context, index) {
        final friend = _friends[index];
        return FadeAnimation(
          delay: Duration(milliseconds: index * 50),
          child: _buildFriendTile(friend),
        );
      },
    );
  }

  Widget _buildRequestsList() {
    final totalRequests = _incomingRequests.length + _outgoingRequests.length;

    if (totalRequests == 0) {
      return EmptyStateWidget(
        title: 'No Friend Requests',
        message: 'You don\'t have any pending friend requests',
        icon: Icons.person_add_disabled,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_incomingRequests.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Incoming Requests',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ..._incomingRequests.map((request) => _buildIncomingRequestTile(request)),
        ],
        if (_outgoingRequests.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Outgoing Requests',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ..._outgoingRequests.map((request) => _buildOutgoingRequestTile(request)),
        ],
      ],
    );
  }

  Widget _buildSuggestionsList() {
    if (_suggestions.isEmpty) {
      return EmptyStateWidget(
        title: 'No Suggestions',
        message: 'We\'ll suggest people you may know',
        icon: Icons.person_search,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
        return FadeAnimation(
          delay: Duration(milliseconds: index * 50),
          child: _buildSuggestionTile(suggestion),
        );
      },
    );
  }

  Widget _buildFriendTile(app.User friend) {
    return GestureDetector(
      onTap: () => _onUserTap(friend.id),
      onLongPress: () => _showFriendOptions(friend),
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
                  backgroundImage: friend.avatar != null
                      ? NetworkImage(friend.avatar!)
                      : null,
                  child: friend.avatar == null
                      ? Text(
                    friend.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  )
                      : null,
                ),
                if (friend.isOnline)
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
                          friend.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${friend.username}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Message Button
            IconButton(
              icon: const Icon(Icons.message, color: Colors.green),
              onPressed: () {
                // Navigate to chat
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomingRequestTile(Map<String, dynamic> request) {
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
          // User Avatar (placeholder)
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            child: Text(
              request['senderName']?[0].toUpperCase() ?? '?',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // User Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request['senderName'] ?? 'Unknown User',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (request['message'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    request['message'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Accept/Reject Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.check, color: Colors.white),
                  onPressed: () => _acceptFriendRequest(
                    request['id'],
                    request['senderId'],
                  ),
                  iconSize: 20,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => _rejectFriendRequest(request['id']),
                  iconSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutgoingRequestTile(Map<String, dynamic> request) {
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
          // User Avatar (placeholder)
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            child: Text(
              request['receiverName']?[0].toUpperCase() ?? '?',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // User Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request['receiverName'] ?? 'Unknown User',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cancel Button
          TextButton(
            onPressed: () => _cancelFriendRequest(request['id']),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionTile(FriendSuggestion suggestion) {
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
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            backgroundImage: suggestion.avatar != null
                ? NetworkImage(suggestion.avatar!)
                : null,
            child: suggestion.avatar == null
                ? Text(
              suggestion.name[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            )
                : null,
          ),
          const SizedBox(width: 16),

          // User Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (suggestion.mutualFriends > 0)
                  Text(
                    '${suggestion.mutualFriends} mutual friends',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                if (suggestion.commonInterests.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Common: ${suggestion.commonInterests.join(', ')}',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Add Friend Button
          CustomButton(
            text: 'Add',
            onPressed: () => _sendFriendRequest(suggestion.userId),
            color: Colors.green,
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
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }
}