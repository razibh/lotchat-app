import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/models/user_model.dart';
import '../../core/services/friend_service.dart';
import '../../core/services/auth_service.dart';
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
  
  List<Map<String, dynamic>> _blockedUsers = <Map<String, dynamic>>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    await runWithLoading(() async {
      _friendService.getBlockedUsers().listen((List<UserModel> users) {
        if (mounted) {
          setState(() {
            _blockedUsers = users;
            _isLoading = false;
          });
        }
      });
    });
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
                  itemBuilder: (BuildContext context, int index) {
                    final Map<String, dynamic> user = _blockedUsers[index];
                    return FadeAnimation(
                      delay: Duration(milliseconds: index * 50),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user['photoURL'] != null
                                ? NetworkImage(user['photoURL'])
                                : null,
                            child: user['photoURL'] == null
                                ? Text(user['username'][0].toUpperCase())
                                : null,
                          ),
                          title: Text(user['username'] ?? 'Unknown'),
                          subtitle: Text(user['email'] ?? ''),
                          trailing: ElevatedButton(
                            onPressed: () => _unblockUser(
                              user['uid'],
                              user['username'] ?? 'User',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
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