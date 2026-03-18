import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../core/di/service_locator.dart';
import '../../core/models/user_models.dart' as app_models;
import '../../chat/chat_detail_screen.dart';
import '../../chat/models/chat_model.dart';
import '../../core/services/friend_service.dart';
import '../../core/services/auth_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/pagination_mixin.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/animation/fade_animation.dart';
import '../../features/friends/models/friend_model.dart';
import 'widgets/friend_tile.dart';
import 'friend_requests_screen.dart';
import 'find_friends_screen.dart';
import 'blocked_users_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with LoadingMixin, ToastMixin, PaginationMixin<FriendModel> {

  final FriendService _friendService = ServiceLocator.instance.get<FriendService>();
  final AuthService _authService = ServiceLocator.instance.get<AuthService>();

  List<FriendModel> _friends = [];
  List<FriendModel> _filteredFriends = [];
  String _searchQuery = '';
  String _selectedFilter = 'All';
  int _pendingRequests = 0;
  String? _currentUserId;

  final List<String> _filters = ['All', 'Online', 'Favorites', 'Recent'];

  @override
  void initState() {
    super.initState();
    initPagination(); // PaginationMixin এর initPagination কল
    _getCurrentUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadFirstPage(setState); // setState প্যারামিটার সহ
    });
  }

  @override
  void dispose() {
    disposePagination(); // PaginationMixin এর disposePagination কল
    super.dispose();
  }

  @override
  Future<PaginationResult<FriendModel>> fetchPage(int page) async {
    // এখানে আপনার API কল হবে
    await Future.delayed(const Duration(seconds: 1));

    // Mock data generation
    if (_friends.isEmpty) {
      _friends = _generateMockFriends(15);
      _pendingRequests = 3;
      _applyFilter();
    }

    final items = _filteredFriends.isEmpty ? _friends : _filteredFriends;

    return PaginationResult<FriendModel>(
      items: items,
      totalPages: 1,
      totalItems: items.length,
      currentPage: page,
    );
  }

  Future<void> _getCurrentUser() async {
    final firebase_auth.User? user = _authService.getCurrentUser();
    setState(() {
      _currentUserId = user?.uid;
    });
  }

  List<FriendModel> _generateMockFriends(int count) {
    return List.generate(count, (index) {
      return FriendModel(
        userId: 'user_$index',
        username: 'user$index',
        displayName: 'User $index',
        avatar: 'https://i.pravatar.cc/150?u=$index',
        onlineStatus: index % 3 == 0 ? OnlineStatus.online : OnlineStatus.offline,
        friendsSince: DateTime.now().subtract(Duration(days: index * 10)),
        mutualFriends: index * 2,
        commonInterests: ['music', 'games'],
        isFavorite: index % 5 == 0,
        note: index % 7 == 0 ? 'Best friend' : null,
        lastActive: DateTime.now().subtract(Duration(hours: index)),
        stats: {},
        tags: [],
      );
    });
  }

  void _applyFilter() {
    var filtered = List<FriendModel>.from(_friends);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((f) =>
      f.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (f.displayName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false),
      ).toList();
    }

    switch (_selectedFilter) {
      case 'Online':
        filtered = filtered.where((f) => f.isOnline).toList();
        break;
      case 'Favorites':
        filtered = filtered.where((f) => f.isFavorite).toList();
        break;
      case 'Recent':
        filtered.sort((a, b) => b.friendsSince.compareTo(a.friendsSince));
        break;
    }

    setState(() {
      _filteredFriends = filtered;
    });
  }

  Future<void> _navigateToChat(FriendModel friend) async {
    final chat = ChatModel(
      id: 'chat_${friend.userId}_current',
      type: 'private',
      participants: [friend.userId, _currentUserId ?? ''],
      groupName: friend.displayNameOrUsername,
      groupAvatar: friend.avatar,
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

  void _showFriendOptions(FriendModel friend) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.blue),
              title: const Text('Send Message'),
              onTap: () {
                Navigator.pop(context);
                _navigateToChat(friend);
              },
            ),
            ListTile(
              leading: const Icon(Icons.call, color: Colors.green),
              title: const Text('Voice Call'),
              onTap: () {
                Navigator.pop(context);
                showInfo('Voice call feature coming soon');
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.orange),
              title: const Text('Video Call'),
              onTap: () {
                Navigator.pop(context);
                showInfo('Video call feature coming soon');
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                friend.isFavorite ? Icons.star : Icons.star_border,
                color: friend.isFavorite ? Colors.amber : null,
              ),
              title: Text(friend.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
              onTap: () async {
                Navigator.pop(context);
                showSuccess(friend.isFavorite
                    ? 'Removed from favorites'
                    : 'Added to favorites');
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Add Note'),
              onTap: () {
                Navigator.pop(context);
                _showAddNoteDialog(friend);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Block User'),
              onTap: () {
                Navigator.pop(context);
                _showBlockDialog(friend);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_remove, color: Colors.red),
              title: const Text('Remove Friend'),
              onTap: () {
                Navigator.pop(context);
                _showRemoveFriendDialog(friend);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog(FriendModel friend) {
    final TextEditingController controller = TextEditingController(text: friend.note);

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter a note...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showSuccess('Note updated');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showBlockDialog(FriendModel friend) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Block User'),
        content: Text('Are you sure you want to block ${friend.displayNameOrUsername}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Block'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      showSuccess('User blocked');
    }
  }

  Future<void> _showRemoveFriendDialog(FriendModel friend) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Remove Friend'),
        content: Text('Are you sure you want to remove ${friend.displayNameOrUsername}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      showSuccess('Friend removed');
    }
  }

  void _showInviteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Invite Friends'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: const Text('Share Invite Link'),
              onTap: () {
                Navigator.pop(context);
                showInfo('Share feature coming soon');
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_phone, color: Colors.green),
              title: const Text('Invite via Contacts'),
              onTap: () {
                Navigator.pop(context);
                showInfo('Contacts sync coming soon');
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code, color: Colors.purple),
              title: const Text('Show QR Code'),
              onTap: () {
                Navigator.pop(context);
                showInfo('QR code feature coming soon');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FriendRequestsScreen(),
                    ),
                  );
                },
              ),
              if (_pendingRequests > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_pendingRequests',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.explore),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FindFriendsScreen(),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'blocked',
                child: Text('Blocked Users'),
              ),
              const PopupMenuItem(
                value: 'requests',
                child: Text('Friend Requests'),
              ),
              const PopupMenuItem(
                value: 'suggestions',
                child: Text('Find Friends'),
              ),
              const PopupMenuItem(
                value: 'invite',
                child: Text('Invite Friends'),
              ),
            ],
            onSelected: (String value) {
              switch (value) {
                case 'blocked':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BlockedUsersScreen(),
                    ),
                  );
                  break;
                case 'requests':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FriendRequestsScreen(),
                    ),
                  );
                  break;
                case 'suggestions':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FindFriendsScreen(),
                    ),
                  );
                  break;
                case 'invite':
                  _showInviteDialog();
                  break;
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _applyFilter();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search friends...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _applyFilter();
                        });
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: _filters.map((filter) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                            _applyFilter();
                          });
                        },
                        backgroundColor: Colors.white.withOpacity(0.2),
                        selectedColor: Colors.white,
                        labelStyle: TextStyle(
                          color: _selectedFilter == filter ? Colors.blue : Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: isLoading && _friends.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _filteredFriends.isEmpty
          ? EmptyStateWidget(
        title: _searchQuery.isNotEmpty
            ? 'No Results Found'
            : 'No Friends Yet',
        message: _searchQuery.isNotEmpty
            ? 'Try searching with a different name'
            : 'Start adding friends to connect with them',
        icon: _searchQuery.isNotEmpty
            ? Icons.search_off
            : Icons.people_outline,
        buttonText: _searchQuery.isEmpty ? 'Find Friends' : null,
        onButtonPressed: _searchQuery.isEmpty
            ? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FindFriendsScreen(),
            ),
          );
        }
            : null,
      )
          : RefreshIndicator(
        onRefresh: () async {
          loadFirstPage(setState);
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _filteredFriends.length,
          itemBuilder: (context, index) {
            final friend = _filteredFriends[index];
            return FadeAnimation(
              delay: Duration(milliseconds: index * 50),
              child: FriendTile(
                friend: friend,
                onTap: () => _navigateToChat(friend),
                onMoreTap: () => _showFriendOptions(friend),
              ),
            );
          },
        ),
      ),
    );
  }
}