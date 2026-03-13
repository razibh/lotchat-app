import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/agency_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/models/agency_model.dart';
import '../../core/models/user_model.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/dialog_mixin.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../profile/profile_screen.dart';

class MemberManagement extends StatefulWidget {

  const MemberManagement({
    Key? key,
    required this.agencyId,
  }) : super(key: key);
  final String agencyId;

  @override
  State<MemberManagement> createState() => _MemberManagementState();
}

class _MemberManagementState extends State<MemberManagement> 
    with LoadingMixin, ToastMixin, DialogMixin {
  
  final AgencyService _agencyService = ServiceLocator().get<AgencyService>();
  final NotificationService _notificationService = ServiceLocator().get<NotificationService>();
  
  List<AgencyMember> _members = <>[];
  List<AgencyMember> _filteredMembers = <>[];
  AgencyModel? _agency;
  String _searchQuery = '';
  String _selectedRole = 'All';
  bool _isLoading = true;

  final List<String> _roles = <String>['All', 'Leader', 'Co-Leader', 'Elder', 'Member'];

  @override
  void initState() {
    super.initState();
    _loadAgencyData();
  }

  Future<void> _loadAgencyData() async {
    await runWithLoading(() async {
      try {
        _agency = await _agencyService.getAgency(widget.agencyId);
        if (_agency != null) {
          _members = _agency!.members;
          _applyFilter();
        }
      } catch (e) {
        showError('Failed to load members: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _applyFilter() {
    var filtered = List<AgencyMember>.from(_members);

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((Object? m) =>
        m.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (m.displayName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }

    // Apply role filter
    if (_selectedRole != 'All') {
      filtered = filtered.where((Object? m) => 
        m.role.toString().split('.').last == _selectedRole
      ).toList();
    }

    setState(() {
      _filteredMembers = filtered;
    });
  }

  Future<void> _addMember() async {
    final String? userId = await showInputDialog(
      context,
      title: 'Add Member',
      hintText: 'Enter User ID',
    );

    if (userId != null && userId.isNotEmpty) {
      await runWithLoading(() async {
        try {
          await _agencyService.addMember(widget.agencyId, userId);
          showSuccess('Member added successfully');
          _loadAgencyData();
          
          // Send notification to new member
          await _notificationService.sendNotification(
            userId: userId,
            type: 'agency',
            title: 'Added to Agency',
            body: 'You have been added to ${_agency!.name} agency',
            data: <String, >{'agencyId': widget.agencyId},
          );
        } catch (e) {
          showError('Failed to add member: $e');
        }
      });
    }
  }

  Future<void> _removeMember(AgencyMember member) async {
    final bool? confirmed = await showConfirmDialog(
      context,
      title: 'Remove Member',
      message: 'Are you sure you want to remove ${member.username} from the agency?',
    );

    if (confirmed ?? false) {
      await runWithLoading(() async {
        try {
          await _agencyService.removeMember(widget.agencyId, member.userId);
          showSuccess('Member removed successfully');
          _loadAgencyData();
        } catch (e) {
          showError('Failed to remove member: $e');
        }
      });
    }
  }

  Future<void> _changeRole(AgencyMember member) async {
    final newRole = await showDialog<AgencyRole>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AgencyRole.values.map((role) {
            if (role == AgencyRole.leader) return const SizedBox.shrink();
            return ListTile(
              title: Text(role.toString().split('.').last),
              onTap: () => Navigator.pop(context, role),
            );
          }).toList(),
        ),
      ),
    );

    if (newRole != null) {
      await runWithLoading(() async {
        try {
          await _agencyService.changeMemberRole(
            widget.agencyId,
            member.userId,
            newRole,
          );
          showSuccess('Role updated successfully');
          _loadAgencyData();
        } catch (e) {
          showError('Failed to update role: $e');
        }
      });
    }
  }

  Future<void> _viewEarnings(AgencyMember member) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: <>[
            const Text(
              'Earnings History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _agencyService.getMemberEarnings(
                  widget.agencyId,
                  member.userId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final earnings = snapshot.data ?? <dynamic>[];

                  if (earnings.isEmpty) {
                    return const EmptyStateWidget(
                      title: 'No Earnings',
                      message: 'This member has no earnings yet',
                      icon: Icons.attach_money,
                    );
                  }

                  return ListView.builder(
                    itemCount: earnings.length,
                    itemBuilder: (context, index) {
                      final earning = earnings[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: earning['amount'] > 0
                                ? Colors.green
                                : Colors.red,
                            child: Icon(
                              earning['amount'] > 0
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(earning['description'] ?? 'Earning'),
                          subtitle: Text(
                            _formatDate(earning['timestamp']),
                          ),
                          trailing: Text(
                            '${earning['amount'] > 0 ? '+' : ''}${earning['amount']}',
                            style: TextStyle(
                              color: earning['amount'] > 0
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }

  Color _getRoleColor(AgencyRole role) {
    switch (role) {
      case AgencyRole.leader:
        return Colors.red;
      case AgencyRole.coLeader:
        return Colors.orange;
      case AgencyRole.elder:
        return Colors.blue;
      case AgencyRole.member:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Management'),
        backgroundColor: Colors.blue,
        actions: <>[
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _addMember,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: <>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SearchBar(
                  hintText: 'Search members...',
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _applyFilter();
                    });
                  },
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: _roles.map((String role) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(role),
                        selected: _selectedRole == role,
                        onSelected: (selected) {
                          setState(() {
                            _selectedRole = role;
                            _applyFilter();
                          });
                        },
                        backgroundColor: Colors.white.withOpacity(0.2),
                        selectedColor: Colors.white,
                        labelStyle: TextStyle(
                          color: _selectedRole == role ? Colors.blue : Colors.white,
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
          : _filteredMembers.isEmpty
              ? EmptyStateWidget(
                  title: 'No Members Found',
                  message: _searchQuery.isNotEmpty
                      ? 'No members match your search'
                      : 'Add members to your agency',
                  icon: _searchQuery.isNotEmpty
                      ? Icons.search_off
                      : Icons.people_outline,
                  buttonText: _searchQuery.isEmpty ? 'Add Member' : null,
                  onButtonPressed: _searchQuery.isEmpty ? _addMember : null,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredMembers.length,
                  itemBuilder: (context, index) {
                    final member = _filteredMembers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        leading: Stack(
                          children: <>[
                            CircleAvatar(
                              backgroundImage: member.avatar != null
                                  ? NetworkImage(member.avatar!)
                                  : null,
                              child: member.avatar == null
                                  ? Text(member.username[0].toUpperCase())
                                  : null,
                            ),
                            if (member.isOnline)
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
                        title: Text(
                          member.displayName ?? member.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <>[
                            Text('@${member.username}'),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getRoleColor(member.role).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                member.role.toString().split('.').last,
                                style: TextStyle(
                                  color: _getRoleColor(member.role),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <>[
                            Text(
                              '${member.earnings} coins',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton(
                              icon: const Icon(Icons.more_vert),
                              itemBuilder: (context) => <>[
                                const PopupMenuItem(
                                  value: 'profile',
                                  child: Text('View Profile'),
                                ),
                                const PopupMenuItem(
                                  value: 'earnings',
                                  child: Text('View Earnings'),
                                ),
                                if (member.role != AgencyRole.leader) ...<>[
                                  const PopupMenuItem(
                                    value: 'role',
                                    child: Text('Change Role'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'remove',
                                    child: Text(
                                      'Remove Member',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ],
                              onSelected: (value) async {
                                switch (value) {
                                  case 'profile':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProfileScreen(
                                          userId: member.userId,
                                        ),
                                      ),
                                    );
                                  case 'earnings':
                                    await _viewEarnings(member);
                                  case 'role':
                                    await _changeRole(member);
                                  case 'remove':
                                    await _removeMember(member);
                                }
                              },
                            ),
                          ],
                        ),
                        children: <>[
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: <>[
                                // Stats Grid
                                Row(
                                  children: <>[
                                    Expanded(
                                      child: _buildStatCard(
                                        'Total Earnings',
                                        '${member.earnings}',
                                        Icons.attach_money,
                                        Colors.green,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildStatCard(
                                        'This Month',
                                        '${member.monthlyEarnings}',
                                        Icons.calendar_today,
                                        Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: <>[
                                    Expanded(
                                      child: _buildStatCard(
                                        'This Week',
                                        '${member.weeklyEarnings}',
                                        Icons.trending_up,
                                        Colors.orange,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildStatCard(
                                        'Joined',
                                        _formatDate(member.joinedAt),
                                        Icons.access_time,
                                        Colors.purple,
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
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMember,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: <>[
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}