import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/admin_service.dart';
import '../../core/models/user_model.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/dialog_mixin.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/empty_state_widget.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({Key? key}) : super(key: key);

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> 
    with LoadingMixin, ToastMixin, DialogMixin {
  
  final _adminService = ServiceLocator().get<AdminService>();
  final _searchController = TextEditingController();
  
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    await runWithLoading(() async {
      try {
        _users = await _adminService.getAllUsers();
        _filteredUsers = _users;
      } catch (e) {
        showError('Failed to load users: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _users;
      } else {
        _filteredUsers = _users.where((user) {
          return user.username.toLowerCase().contains(query.toLowerCase()) ||
                 user.email.toLowerCase().contains(query.toLowerCase()) ||
                 user.phone.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _banUser(UserModel user) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Ban User',
      message: 'Are you sure you want to ban ${user.username}?',
    );

    if (confirmed == true) {
      await runWithLoading(() async {
        try {
          await _adminService.banUser(
            userId: user.uid,
            reason: 'Violation of terms',
          );
          showSuccess('User banned successfully');
          _loadUsers();
        } catch (e) {
          showError('Failed to ban user: $e');
        }
      });
    }
  }

  Future<void> _unbanUser(UserModel user) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Unban User',
      message: 'Are you sure you want to unban ${user.username}?',
    );

    if (confirmed == true) {
      await runWithLoading(() async {
        try {
          await _adminService.unbanUser(user.uid);
          showSuccess('User unbanned successfully');
          _loadUsers();
        } catch (e) {
          showError('Failed to unban user: $e');
        }
      });
    }
  }

  Future<void> _addCoins(UserModel user) async {
    final amount = await showInputDialog(
      context,
      title: 'Add Coins',
      hintText: 'Enter amount',
    );

    if (amount != null && amount.isNotEmpty) {
      final coins = int.tryParse(amount);
      if (coins != null && coins > 0) {
        await runWithLoading(() async {
          try {
            await _adminService.addCoinsToUser(
              userId: user.uid,
              amount: coins,
              reason: 'Admin addition',
            );
            showSuccess('$coins coins added to ${user.username}');
            _loadUsers();
          } catch (e) {
            showError('Failed to add coins: $e');
          }
        });
      } else {
        showError('Invalid amount');
      }
    }
  }

  Future<void> _changeRole(UserModel user) async {
    final role = await showDialog<UserRole>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: UserRole.values.map((role) {
            return ListTile(
              title: Text(role.toString().split('.').last),
              onTap: () => Navigator.pop(context, role),
            );
          }).toList(),
        ),
      ),
    );

    if (role != null) {
      await runWithLoading(() async {
        try {
          await _adminService.changeUserRole(
            userId: user.uid,
            newRole: role,
          );
          showSuccess('Role changed successfully');
          _loadUsers();
        } catch (e) {
          showError('Failed to change role: $e');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.purple,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterUsers,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredUsers.isEmpty
              ? const EmptyStateWidget(
                  title: 'No Users Found',
                  message: 'No users match your search',
                  icon: Icons.person_off,
                )
              : ListView.builder(
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = _filteredUsers[index];
                    return _buildUserTile(user);
                  },
                ),
    );
  }

  Widget _buildUserTile(UserModel user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundImage: user.photoURL != null
              ? NetworkImage(user.photoURL!)
              : null,
          child: user.photoURL == null
              ? Text(user.username[0].toUpperCase())
              : null,
        ),
        title: Text(user.username),
        subtitle: Text('ID: ${user.uid.substring(0, 8)}... • ${user.email}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getRoleColor(user.role),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            user.role.toString().split('.').last,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // User Info
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow('Phone', user.phone),
                    ),
                    Expanded(
                      child: _buildInfoRow('Country', user.country),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow('Coins', '${user.coins}'),
                    ),
                    Expanded(
                      child: _buildInfoRow('Diamonds', '${user.diamonds}'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow('Status', user.isOnline ? 'Online' : 'Offline'),
                    ),
                    Expanded(
                      child: _buildInfoRow('Tier', user.tier.toString().split('.').last),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.attach_money,
                        label: 'Add Coins',
                        color: Colors.green,
                        onTap: () => _addCoins(user),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.admin_panel_settings,
                        label: 'Change Role',
                        color: Colors.blue,
                        onTap: () => _changeRole(user),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: user.isBanned ? Icons.block : Icons.block,
                        label: user.isBanned ? 'Unban' : 'Ban',
                        color: user.isBanned ? Colors.green : Colors.red,
                        onTap: () => user.isBanned ? _unbanUser(user) : _banUser(user),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.delete,
                        label: 'Delete',
                        color: Colors.red,
                        onTap: () => _deleteUser(user),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteUser(UserModel user) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete User',
      message: 'Are you sure you want to permanently delete ${user.username}?',
    );

    if (confirmed == true) {
      showSuccess('User deleted (demo)');
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Colors.red;
      case UserRole.admin:
        return Colors.orange;
      case UserRole.agency:
        return Colors.blue;
      case UserRole.seller:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}