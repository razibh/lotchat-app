import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../core/models/user_models.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/friend_service.dart';
import '../../core/services/notification_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/dialog_mixin.dart';
import '../profile/profile_screen.dart';
import '../../chat/chat_detail_screen.dart';
import '../../chat/models/chat_model.dart';
import 'mutual_friends_screen.dart';

class FriendProfileScreen extends StatefulWidget {
  final String userId;

  const FriendProfileScreen({
    required this.userId,
    super.key,
  });

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('userId', userId));
  }
}

class _FriendProfileScreenState extends State<FriendProfileScreen>
    with LoadingMixin, ToastMixin, DialogMixin {

  final FriendService _friendService = ServiceLocator().get<FriendService>();
  final NotificationService _notificationService = ServiceLocator().get<NotificationService>();

  User? _user;
  String? _friendStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 1));

      _user = User(
        id: widget.userId,
        username: 'wares_ahmed',
        name: 'Wares Ahmed',
        email: 'wares@example.com',
        role: UserRole.user,
        countryId: 'bd',
        createdAt: DateTime.now(),
        avatar: 'https://i.pravatar.cc/300?u=${widget.userId}',
        bio: 'Life is beautiful! 🌟\nTravel enthusiast ✈️\nPhotography lover 📸',
        isOnline: true,
        interests: ['Travel', 'Photography', 'Music', 'Gaming'],
        phoneNumber: '+1234567890',
        coins: 15000,
        diamonds: 500,
        tier: UserTier.vip3,
      );

      _friendStatus = 'none';
    } catch (e) {
      showError('Failed to load profile');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendFriendRequest() async {
    setState(() => _friendStatus = 'request_sent');
    showSuccess('Friend request sent');
  }

  Future<void> _acceptFriendRequest() async {
    showSuccess('Friend request accepted');
    setState(() => _friendStatus = 'friends');
  }

  Future<void> _rejectFriendRequest() async {
    final bool? confirmed = await showConfirmDialog(
      context,
      title: 'Reject Request',
      message: 'Are you sure you want to reject this friend request?',
    );

    if (confirmed ?? false) {
      setState(() => _friendStatus = null);
      showSuccess('Request rejected');
    }
  }

  Future<void> _unfriend() async {
    final bool? confirmed = await showConfirmDialog(
      context,
      title: 'Unfriend',
      message: 'Are you sure you want to remove this friend?',
    );

    if (confirmed ?? false) {
      setState(() => _friendStatus = null);
      showSuccess('Friend removed');
    }
  }

  Future<void> _blockUser() async {
    final bool? confirmed = await showConfirmDialog(
      context,
      title: 'Block User',
      message: 'Are you sure you want to block this user?',
    );

    if (confirmed ?? false) {
      setState(() => _friendStatus = 'blocked');
      showSuccess('User blocked');
      Navigator.pop(context);
    }
  }

  void _openChat() {
    if (_user == null) return;

    final chat = ChatModel(
      id: 'chat_${_user!.id}_current',
      type: 'private',
      participants: [_user!.id, 'current_user_id'],
      groupName: _user!.name,
      groupAvatar: _user!.avatar,
      lastMessageTime: DateTime.now(),
      lastMessage: '',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          chat: chat,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = _user!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Profile Header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover Image
                  ColoredBox(
                    color: Colors.purple.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        size: 100,
                        color: Colors.white54,
                      ),
                    ),
                  ),

                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Profile Info
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: user.avatar != null
                              ? NetworkImage(user.avatar!)
                              : null,
                          backgroundColor: Colors.grey.shade200,
                          child: user.avatar == null
                              ? Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 30),
                          )
                              : null,
                        ),
                        const SizedBox(width: 16),

                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '@${user.username}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    user.isOnline ? Icons.circle : Icons.circle_outlined,
                                    color: user.isOnline ? Colors.green : Colors.grey,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    user.isOnline ? 'Online' : 'Offline',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
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
          ),

          // Profile Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats
                  _buildStats(),
                  const SizedBox(height: 20),

                  // Bio
                  _buildBio(user),
                  const SizedBox(height: 20),

                  // Interests
                  _buildInterests(user),
                  const SizedBox(height: 20),

                  // Action Buttons
                  _buildActionButtons(user),
                  const SizedBox(height: 20),

                  // Mutual Friends
                  _buildMutualFriends(user),
                  const SizedBox(height: 20),

                  // Recent Activity
                  _buildRecentActivity(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Posts',
              '42',
              Icons.post_add,
              Colors.blue,
            ),
            _buildStatItem(
              'Followers',
              '1.2K',
              Icons.people,
              Colors.green,
            ),
            _buildStatItem(
              'Following',
              '567',
              Icons.person_add,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
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
    );
  }

  Widget _buildBio(User user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info, size: 20, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Bio',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              user.bio ?? 'No bio yet',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterests(User user) {
    if (user.interests.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.interests, size: 20, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Interests',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: user.interests.map((interest) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    interest,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.purple,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(User user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_friendStatus == 'friends') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _openChat,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Message'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _unfriend,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Unfriend'),
                    ),
                  ),
                ],
              ),
            ] else if (_friendStatus == 'request_sent') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Request Sent'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _friendStatus = null),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ] else if (_friendStatus == 'request_received') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _acceptFriendRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _rejectFriendRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              ),
            ] else if (_friendStatus != 'blocked') ...[
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: _sendFriendRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Add Friend'),
                ),
              ),
            ],

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _blockUser,
              icon: const Icon(Icons.block, color: Colors.red),
              label: const Text('Block User', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMutualFriends(User user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mutual Friends',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MutualFriendsScreen(
                          userId: user.id,
                          userName: user.name,
                        ),
                      ),
                    );
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 8),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/150?u=$index',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'User ${index + 1}',
                          style: const TextStyle(fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(3, (index) {
              return ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: [Colors.blue, Colors.green, Colors.purple][index],
                  child: Icon(
                    [Icons.card_giftcard, Icons.favorite, Icons.comment][index],
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                title: Text(
                  [
                    'Received a gift',
                    'Liked a post',
                    'Commented on a post',
                  ][index],
                ),
                subtitle: Text('${index + 1} hour${index == 0 ? '' : 's'} ago'),
                trailing: Text(
                  ['🎁', '❤️', '💬'][index],
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// FadeAnimation Widget
class FadeAnimation extends StatelessWidget {
  final Widget child;
  final Duration delay;

  const FadeAnimation({
    required this.child,
    this.delay = Duration.zero,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 500),
      child: child,
    );
  }
}