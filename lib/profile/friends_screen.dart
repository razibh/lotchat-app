import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_friend_tile.dart';
import '../../../core/models/user_model.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/friend_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../widgets/common/empty_state_widget.dart';
import '../../../widgets/common/search_bar.dart';
import '../../../mixins/dialog_mixin.dart';
import '../../chat/chat_detail_screen.dart';
import '../../profile/profile_screen.dart';

class FriendsScreen extends StatefulWidget {

  const FriendsScreen({required this.userId, super.key});
  final String userId;

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('userId', userId));
  }
}

class _FriendsScreenState extends State<FriendsScreen> with DialogMixin {
  final FriendService _friendService = ServiceLocator().get<FriendService>();
  final NotificationService _notificationService = ServiceLocator().get<NotificationService>();
  
  List<UserModel> _friends = <>[];
  List<UserModel> _filteredFriends = <>[];
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _isLoading = true;

  final List<String> _filters = <String>['All', 'Online', 'Favorites', 'Recent'];

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() => _isLoading = true);
    
    try {
      // In real app, load from service
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _friends = List.generate(25, (int index) {
        return UserModel(
          uid: 'friend_$index',
          username: 'friend${index + 1}',
          displayName: index % 2 == 0 ? 'Friend ${index + 1}' : null,
          email: 'friend${index + 1}@example.com',
          phone: '+1234567890',
          photoURL: index % 3 == 0 ? 'https://i.pravatar.cc/150?u=$index' : null,
          bio: 'This is friend ${index + 1}',
          interests: <String>['Gaming', 'Music', 'Travel'],
          country: 'US',
          region: 'New York',
          coins: 5000,
          diamonds: 200,
          tier: UserTier.values[index % 5],
          isOnline: index % 4 == 0,
          lastActive: DateTime.now().subtract(Duration(hours: index)),
          friends: <dynamic>[],
          followers: <dynamic>[],
          following: <dynamic>[],
          stats: <String, bool>{'favorite': index % 5 == 0},
        );
      });
      
      _applyFilter();
    } catch (e) {
      _notificationService.showError('Failed to load friends');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    List<UserModel> filtered = List<UserModel>.from(_friends);

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((UserModel f) {
        return f.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (f.displayName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    // Apply filters
    switch (_selectedFilter) {
      case 'Online':
        filtered = filtered.where((UserModel f) => f.isOnline).toList();
      case 'Favorites':
        filtered = filtered.where((UserModel f) => f.stats['favorite'] == true).toList();
      case 'Recent':
        filtered.sort((UserModel a, UserModel b) => b.lastActive.compareTo(a.lastActive));
    }

    setState(() {
      _filteredFriends = filtered;
    });
  }

  void _filterFriends(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilter();
    });
  }

  Future<void> _unfriend(UserModel friend) async {
    final bool? confirmed = await showConfirmDialog(
      context,
      title: 'Unfriend',
      message: 'Are you sure you want to remove ${friend.displayName ?? friend.username} from your friends?',
    );

    if (confirmed ?? false) {
      try {
        await _friendService.removeFriend(friend.uid);
        setState(() {
          _friends.removeWhere((UserModel f) => f.uid == friend.uid);
          _applyFilter();
        });
        _notificationService.showSuccess('Friend removed');
      } catch (e) {
        _notificationService.showError('Failed to remove friend');
      }
    }
  }

  Future<void> _blockUser(UserModel friend) async {
    final bool? confirmed = await showConfirmDialog(
      context,
      title: 'Block User',
      message: 'Are you sure you want to block ${friend.displayName ?? friend.username}?',
    );

    if (confirmed ?? false) {
      try {
        await _friendService.blockUser(friend.uid);
        setState(() {
          _friends.removeWhere((UserModel f) => f.uid == friend.uid);
          _applyFilter();
        });
        _notificationService.showSuccess('User blocked');
      } catch (e) {
        _notificationService.showError('Failed to block user');
      }
    }
  }

  void _showFriendOptions(UserModel friend) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Wrap(
          children: <>[
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => ProfileScreen(userId: friend.uid),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.green),
              title: const Text('Send Message'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => ChatDetailScreen(
                      userId: friend.uid,
                      userName: friend.displayName ?? friend.username,
                      userAvatar: friend.photoURL,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.call, color: Colors.orange),
              title: const Text('Voice Call'),
              onTap: () {
                Navigator.pop(context);
                // Start voice call
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.purple),
              title: const Text('Video Call'),
              onTap: () {
                Navigator.pop(context);
                // Start video call
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: Text(
                friend.stats['favorite'] == true ? 'Remove from Favorites' : 'Add to Favorites',
              ),
              onTap: () {
                Navigator.pop(context);
                _toggleFavorite(friend);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Block', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _blockUser(friend);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_remove, color: Colors.red),
              title: const Text('Unfriend', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _unfriend(friend);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFavorite(UserModel friend) {
    setState(() {
      final bool isFavorite = friend.stats['favorite'] == true;
      friend.stats['favorite'] = !isFavorite;
      _applyFilter();
    });
    _notificationService.showSuccess(
      friend.stats['favorite'] == true ? 'Added to favorites' : 'Removed from favorites',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        backgroundColor: Colors.blue,
        actions: <>[
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () {
              // Navigate to add friends
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: <>[
              Padding(
                padding: const EdgeInsets.all(8),
                child: SearchBar(
                  hintText: 'Search friends...',
                  onChanged: _filterFriends,
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: _filters.map((String filter) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedFilter = filter;
                            _applyFilter();
                          });
                        },
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredFriends.isEmpty
              ? EmptyStateWidget(
                  title: 'No Friends',
                  message: _searchQuery.isNotEmpty
                      ? 'No friends match your search'
                      : "You haven't added any friends yet",
                  icon: Icons.people_outline,
                  buttonText: _searchQuery.isEmpty ? 'Find Friends' : null,
                  onButtonPressed: _searchQuery.isEmpty
                      ? () {
                          // Navigate to find friends
                        }
                      : null,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _filteredFriends.length,
                  itemBuilder: (BuildContext context, int index) {
                    final UserModel friend = _filteredFriends[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: Stack(
                          children: <>[
                            CircleAvatar(
                              backgroundImage: friend.photoURL != null
                                  ? NetworkImage(friend.photoURL!)
                                  : null,
                              child: friend.photoURL == null
                                  ? Text(friend.username[0].toUpperCase())
                                  : null,
                            ),
                            if (friend.isOnline)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.fromBorderSide(
                                      BorderSide(color: Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Row(
                          children: <>[
                            Expanded(
                              child: Text(
                                friend.displayName ?? friend.username,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (friend.stats['favorite'] == true)
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                          ],
                        ),
                        subtitle: Text(
                          friend.isOnline
                              ? 'Online'
                              : 'Last seen ${_formatLastActive(friend.lastActive)}',
                          style: TextStyle(
                            color: friend.isOnline ? Colors.green : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => _showFriendOptions(friend),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => ProfileScreen(userId: friend.uid),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }

  String _formatLastActive(DateTime lastActive) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(lastActive);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${lastActive.day}/${lastActive.month}';
    }
  }
}