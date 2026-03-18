import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../core/di/service_locator.dart';
import '../../core/services/friend_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/user_models.dart'; // User model এর জন্য
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/dialog_mixin.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/animation/fade_animation.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen>
    with LoadingMixin, ToastMixin, DialogMixin {

  final FriendService _friendService = ServiceLocator().get<FriendService>();
  final AuthService _authService = ServiceLocator().get<AuthService>();

  List<User> _blockedUsers = []; // List<Map<String, dynamic>> থেকে List<User> এ পরিবর্তন
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    setState(() => _isLoading = true);

    try {
      _friendService.getBlockedUsers().listen((users) {
        if (mounted) {
          setState(() {
            _blockedUsers = users;
            _isLoading = false;
          });
        }
      }, onError: (error) {
        if (mounted) {
          setState(() => _isLoading = false);
          showError('Failed to load blocked users');
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showError('Error: $e');
      }
    }
  }

  Future<void> _unblockUser(String userId, String username) async {
    final bool? confirmed = await showConfirmDialog(
      context,
      title: 'Unblock User',
      message: 'Are you sure you want to unblock $username?',
    );

    if (confirmed ?? false) {
      await runWithLoading(() async {
        final bool success = await _friendService.unblockUser(userId);
        if (success) {
          showSuccess('$username unblocked');
          // Refresh the list
          _loadBlockedUsers();
        } else {
          showError('Failed to unblock user');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _blockedUsers.isEmpty
          ? const EmptyStateWidget(
        title: 'No Blocked Users',
        message: "You haven't blocked anyone yet",
        icon: Icons.block,
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _blockedUsers.length,
        itemBuilder: (context, index) {
          final user = _blockedUsers[index];

          return FadeAnimation(
            delay: Duration(milliseconds: index * 50),
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : null,
                  backgroundColor: Colors.grey.shade200,
                  child: user.photoURL == null
                      ? Text(
                    user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : null,
                ),
                title: Text(
                  user.displayName ?? user.username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: user.email != null ? Text(user.email!) : null,
                trailing: ElevatedButton(
                  onPressed: () => _unblockUser(user.id, user.username),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Unblock'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}