import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/clan_service.dart';
import '../../core/services/auth_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/dialog_mixin.dart';
import '../profile/profile_screen.dart';
import '../chat/chat_detail_screen.dart';

class ClanMembersScreen extends StatefulWidget {
  final ClanModel clan;

  const ClanMembersScreen({Key? key, required this.clan}) : super(key: key);

  @override
  State<ClanMembersScreen> createState() => _ClanMembersScreenState();
}

class _ClanMembersScreenState extends State<ClanMembersScreen> 
    with LoadingMixin, ToastMixin, DialogMixin {
  
  final _clanService = ServiceLocator().get<ClanService>();
  final _authService = ServiceLocator().get<AuthService>();
  
  late ClanModel _clan;
  String? _currentUserId;
  String _searchQuery = '';
  String _selectedRole = 'All';

  @override
  void initState() {
    super.initState();
    _clan = widget.clan;
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      _currentUserId = user?.uid;
    });
  }

  List<ClanMember> get _filteredMembers {
    var members = _clan.members;
    
    // Filter by role
    if (_selectedRole != 'All') {
      final role = _getRoleFromString(_selectedRole);
      members = members.where((m) => m.role == role).toList();
    }
    
    // Filter by search
    if (_searchQuery.isNotEmpty) {
      members = members.where((m) => 
        m.username.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Sort by role (leader first, then co-leader, etc.)
    members.sort((a, b) {
      final roleOrder = {
        ClanRole.leader: 0,
        ClanRole.coLeader: 1,
        ClanRole.elder: 2,
        ClanRole.member: 3,
      };
      return roleOrder[a.role]!.compareTo(roleOrder[b.role]!);
    });
    
    return members;
  }

  ClanRole _getRoleFromString(String role) {
    switch (role) {
      case 'Leader': return ClanRole.leader;
      case 'Co-Leader': return ClanRole.coLeader;
      case 'Elder': return ClanRole.elder;
      default: return ClanRole.member;
    }
  }

  bool get _canManage {
    if (_currentUserId == null) return false;
    return _clan.canManage(_currentUserId!);
  }

  Future<void> _changeRole(ClanMember member, ClanRole newRole) async {
    await runWithLoading(() async {
      final success = await _clanService.changeMemberRole(
        _clan.id,
        member.userId,
        newRole,
      );
      
      if (success) {
        showSuccess('Role updated');
        // Refresh clan
        final updatedClan = await _clanService.getClan(_clan.id);
        if (updatedClan != null) {
          setState(() {
            _clan = updatedClan;
          });
        }
      }
    });
  }

  Future<void> _kickMember(ClanMember member) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Kick Member',
      message: 'Are you sure you want to kick ${member.username}?',
    );

    if (confirmed == true) {
      await runWithLoading(() async {
        final success = await _clanService.kickMember(_clan.id, member.userId);
        if (success) {
          showSuccess('${member.username} has been kicked');
          // Refresh clan
          final updatedClan = await _clanService.getClan(_clan.id);
          if (updatedClan != null) {
            setState(() {
              _clan = updatedClan;
            });
          }
        }
      });
    }
  }

  void _showMemberOptions(ClanMember member) {
    final isSelf = member.userId == _currentUserId;
    final canManageThis = _canManage && !isSelf;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userId: member.userId),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Send Message'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailScreen(
                      userId: member.userId,
                      userName: member.username,
                      userAvatar: member.avatar,
                    ),
                  ),
                );
              },
            ),
            if (canManageThis) ...[
              const Divider(),
              if (member.role != ClanRole.leader)
                ListTile(
                  leading: const Icon(Icons.arrow_upward, color: Colors.green),
                  title: const Text('Promote'),
                  onTap: () {
                    Navigator.pop(context);
                    _showPromoteOptions(member);
                  },
                ),
              if (member.role != ClanRole.member)
                ListTile(
                  leading: const Icon(Icons.arrow_downward, color: Colors.orange),
                  title: const Text('Demote'),
                  onTap: () {
                    Navigator.pop(context);
                    _showDemoteOptions(member);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: const Text('Kick Member'),
                onTap: () {
                  Navigator.pop(context);
                  _kickMember(member);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPromoteOptions(ClanMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promote Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (member.role == ClanRole.member)
              ListTile(
                title: const Text('Elder'),
                onTap: () {
                  Navigator.pop(context);
                  _changeRole(member, ClanRole.elder);
                },
              ),
            if (member.role == ClanRole.elder || member.role == ClanRole.member)
              ListTile(
                title: const Text('Co-Leader'),
                onTap: () {
                  Navigator.pop(context);
                  _changeRole(member, ClanRole.coLeader);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showDemoteOptions(ClanMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Demote Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (member.role == ClanRole.coLeader)
              ListTile(
                title: const Text('Elder'),
                onTap: () {
                  Navigator.pop(context);
                  _changeRole(member, ClanRole.elder);
                },
              ),
            if (member.role == ClanRole.coLeader || member.role == ClanRole.elder)
              ListTile(
                title: const Text('Member'),
                onTap: () {
                  Navigator.pop(context);
                  _changeRole(member, ClanRole.member);
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(ClanRole role) {
    switch (role) {
      case ClanRole.leader:
        return Colors.red;
      case ClanRole.coLeader:
        return Colors.orange;
      case ClanRole.elder:
        return Colors.blue;
      case ClanRole.member:
        return Colors.grey;
    }
  }

  String _getRoleIcon(ClanRole role) {
    switch (role) {
      case ClanRole.leader:
        return '👑';
      case ClanRole.coLeader:
        return '⭐';
      case ClanRole.elder:
        return '🔰';
      case ClanRole.member:
        return '👤';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredMembers = _filteredMembers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clan Members'),
        backgroundColor: Colors.deepPurple,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search members...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              
              // Role Filter
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: ['All', 'Leader', 'Co-Leader', 'Elder', 'Member']
                      .map((role) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(role),
                              selected: _selectedRole == role,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedRole = role;
                                });
                              },
                              backgroundColor: Colors.white.withOpacity(0.2),
                              selectedColor: Colors.white,
                              labelStyle: TextStyle(
                                color: _selectedRole == role ? Colors.deepPurple : Colors.white,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredMembers.length,
              itemBuilder: (context, index) {
                final member = filteredMembers[index];
                final isSelf = member.userId == _currentUserId;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 24,
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
                                border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Row(
                      children: [
                        Text(
                          member.username,
                          style: TextStyle(
                            fontWeight: isSelf ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (isSelf) ...[
                          const SizedBox(width: 4),
                          const Text(
                            '(You)',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _getRoleIcon(member.role),
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              member.role.toString().split('.').last,
                              style: TextStyle(
                                color: _getRoleColor(member.role),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.flash_on, size: 12, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text('${member.activityPoints} activity'),
                            const SizedBox(width: 12),
                            const Icon(Icons.card_giftcard, size: 12, color: Colors.green),
                            const SizedBox(width: 2),
                            Text('${member.donations} donations'),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isSelf)
                          IconButton(
                            icon: const Icon(Icons.message, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatDetailScreen(
                                    userId: member.userId,
                                    userName: member.username,
                                    userAvatar: member.avatar,
                                  ),
                                ),
                              );
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => _showMemberOptions(member),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(userId: member.userId),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}