import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_model.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/friend_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/date_formatter.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/dialog_mixin.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/animation/fade_animation.dart';
import '../profile/profile_screen.dart';
import '../chat/chat_detail_screen.dart';
import 'mutual_friends_screen.dart';

class FriendProfileScreen extends StatefulWidget {

  const FriendProfileScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);
  final String userId;

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> 
    with LoadingMixin, ToastMixin, DialogMixin {
  
  final FriendService _friendService = ServiceLocator().get<FriendService>();
  final NotificationService _notificationService = ServiceLocator().get<NotificationService>();
  
  UserModel? _user;
  String? _friendStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    await runWithLoading(() async {
      try {
        // Load user data
        await Future.delayed(const Duration(seconds: 1));
        
        _user = UserModel(
          uid: widget.userId,
          username: 'Wares Ahmed',
          displayName: 'Ritu',
          email: 'ritu@cook.com',
          phone: '+1234567890',
  photoURL: 'https://i.pravatar.cc/300?u=${widget.userId}',
          bio: 'Life is beautiful! 🌟\nTravel enthusiast ✈️\nPhotography lover 📸',
          interests: <String>['Travel', 'Photography', 'Music', 'Gaming'],
          country: 'Oman',
          region: 'Muscat',
          coins: 15000,
          diamonds: 500,
          tier: UserTier.vip3,
          isOnline: true,
          lastActive: DateTime.now(),
          friends: <String>[],
          followers: <String>[],
          following: <String>[],
          stats: <String, dynamic>{
            'posts': 42,
            'followers': 1234,
            'following': 567,
          },
        );

        _friendStatus = await _friendService.getFriendStatus(widget.userId);
      } catch (e) {
        showError('Failed to load profile');
      } finally {
        _isLoading = false;
      }
    });
  }

  Future<void> _sendFriendRequest() async {
    await runWithLoading(() async {
      try {
        final bool success = await _friendService.sendFriendRequest(widget.userId);
        if (success) {
          setState(() => _friendStatus = 'request_sent');
          showSuccess('Friend request sent');
        }
      } catch (e) {
        showError('Failed to send request');
      }
    });
  }

  Future<void> _acceptFriendRequest() async {
    // This would need the request ID
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
      await runWithLoading(() async {
        try {
          await _friendService.removeFriend(widget.userId);
          setState(() => _friendStatus = null);
          showSuccess('Friend removed');
        } catch (e) {
          showError('Failed to remove friend');
        }
      });
    }
  }

  Future<void> _blockUser() async {
    final bool? confirmed = await showConfirmDialog(
      context,
      title: 'Block User',
      message: 'Are you sure you want to block this user?',
    );

    if (confirmed ?? false) {
      await runWithLoading(() async {
        try {
          await _friendService.blockUser(widget.userId);
          setState(() => _friendStatus = 'blocked');
          showSuccess('User blocked');
          Navigator.pop(context);
        } catch (e) {
          showError('Failed to block user');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final UserModel user = _user!;

    return Scaffold(
      body: CustomScrollView(
        slivers: <>[
          // Profile Header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: <>[
                  // Cover Image
                  Container(
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
                          colors: <>[
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
                      children: <>[
                        // Avatar
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : null,
                          child: user.photoURL == null
                              ? Text(
                                  user.username[0].toUpperCase(),
                                  style: const TextStyle(fontSize: 30),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        
                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <>[
                              Text(
                                user.displayName ?? user.username,
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
                                children: <>[
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
                children: <>[
                  // Stats
                  FadeAnimation(
                    child: _buildStats(),
                  ),
                  const SizedBox(height: 20),

                  // Bio
                  FadeAnimation(
                    delay: const Duration(milliseconds: 100),
                    child: _buildBio(),
                  ),
                  const SizedBox(height: 20),

                  // Interests
                  FadeAnimation(
                    delay: const Duration(milliseconds: 150),
                    child: _buildInterests(),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  FadeAnimation(
                    delay: const Duration(milliseconds: 200),
                    child: _buildActionButtons(),
                  ),
                  const SizedBox(height: 20),

                  // Mutual Friends
                  FadeAnimation(
                    delay: const Duration(milliseconds: 250),
                    child: _buildMutualFriends(),
                  ),
                  const SizedBox(height: 20),

                  // Recent Activity
                  FadeAnimation(
                    delay: const Duration(milliseconds: 300),
                    child: _buildRecentActivity(),
                  ),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <>[
            _buildStatItem(
              'Posts',
              '${_user!.stats['posts'] ?? 0}',
              Icons.post_add,
              Colors.blue,
            ),
            _buildStatItem(
              'Followers',
              '${_user!.stats['followers'] ?? 0}',
              Icons.people,
              Colors.green,
            ),
            _buildStatItem(
              'Following',
              '${_user!.stats['following'] ?? 0}',
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
      children: <>[
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

  Widget _buildBio() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <>[
            const Row(
              children: <>[
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
              _user!.bio ?? 'No bio yet',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterests() {
    if (_user!.interests.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <>[
            const Row(
              children: <>[
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
              children: _user!.interests.map((String interest) {
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

  Widget _buildActionButtons() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <>[
            if (_friendStatus == 'friends') ...<>[
              Row(
                children: <>[
                  Expanded(
                    child: CustomButton(
                      text: 'Message',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
           builder: (context) => ChatDetailScreen(
                       userId: _user!.uid,
    userName: _user!.displayName ?? _user!.username,
                              userAvatar: _user!.photoURL,
                            ),
                          ),
                        );
                      },
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Unfriend',
                      onPressed: _unfriend,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ] else if (_friendStatus == 'request_sent') ...<>[
              Row(
                children: <>[
                  Expanded(
                    child: CustomButton(
                      text: 'Request Sent',
                      onPressed: null,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      onPressed: () => setState(() => _friendStatus = null),
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ] else if (_friendStatus == 'request_received') ...<>[
              Row(
                children: <>[
                  Expanded(
                    child: CustomButton(
                      text: 'Accept',
                      onPressed: _acceptFriendRequest,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Reject',
                      onPressed: _rejectFriendRequest,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ] else if (_friendStatus != 'blocked') ...<CustomButton>[
              CustomButton(
                text: 'Add Friend',
                onPressed: _sendFriendRequest,
                color: Colors.green,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMutualFriends() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <>[
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
                          userId: _user!.uid,
  userName: _user!.displayName ?? _user!.username,
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
                      children: <>[
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <>[
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(3, (int index) {
              return ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: <>[Colors.blue, Colors.green, Colors.purple][index],
                  child: Icon(
                    <>[Icons.card_giftcard, Icons.favorite, Icons.comment][index],
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                title: Text(
                  <String>[
                    'Received a gift',
                    'Liked a post',
                    'Commented on a post',
                  ][index],
                ),
                subtitle: Text('${index + 1} hour${index == 0 ? '' : 's'} ago'),
                trailing: Text(
                  <String>['🎁', '❤️', '💬'][index],
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