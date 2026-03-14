import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../../../core/models/user_model.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/friend_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../widgets/common/empty_state_widget.dart';
import '../../../widgets/common/search_bar.dart';
import '../../../mixins/dialog_mixin.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> with DialogMixin {
  final FriendService _friendService = ServiceLocator().get<FriendService>();
  final NotificationService _notificationService = ServiceLocator().get<NotificationService>();
  
  List<UserModel> _blockedUsers = <>[];
  List<UserModel> _filteredBlocked = <>[];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    setState(() => _isLoading = true);
    
    try {
      // In real app, load from service
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _blockedUsers = List.generate(5, (int index) {
        return UserModel(
          uid: 'blocked_$index',
          username: 'blocked_user${index + 1}',
          email: 'blocked${index + 1}@example.com',
          phone: '+1234567890',
          country: 'US',
          region: 'New York',
          lastActive: DateTime.now(),
        );
      });
      
      _filteredBlocked = _blockedUsers;
    } catch (e) {
      _notificationService.showError('Failed to load blocked users');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterBlocked(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredBlocked = _blockedUsers;
      } else {
        _filteredBlocked = _blockedUsers.where((UserModel u) {
          return u.username.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _unblockUser(UserModel user) async {
    final bool? confirmed = await showConfirmDialog(
      context,
      title: 'Unblock User',
      message: 'Are you sure you want to unblock ${user.username}?',
    );

    if (confirmed ?? false) {
      try {
        await _friendService.unblockUser(user.uid);
        setState(() {
          _blockedUsers.removeWhere((UserModel u) => u.uid == user.uid);
          _filteredBlocked.removeWhere((UserModel u) => u.uid == user.uid);
        });
        _notificationService.showSuccess('User unblocked');
      } catch (e) {
        _notificationService.showError('Failed to unblock user');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
        backgroundColor: Colors.red,
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredBlocked.isEmpty
              ? EmptyStateWidget(
                  title: 'No Blocked Users',
                  message: _searchQuery.isEmpty
                      ? "You haven't blocked anyone yet"
                      : 'No results match your search',
                  icon: Icons.block,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _filteredBlocked.length,
                  itemBuilder: (BuildContext context, int index) {
                    final UserModel user = _filteredBlocked[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : null,
                          child: user.photoURL == null
                              ? Text(user.username[0].toUpperCase())
                              : null,
                        ),
                        title: Text(user.username),
                        subtitle: Text(user.email),
                        trailing: ElevatedButton(
                          onPressed: () => _unblockUser(user),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Unblock'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}