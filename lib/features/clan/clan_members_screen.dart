import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;  // ✅ Supabase User hide

import '../../core/di/service_locator.dart';
import '../../core/models/clan_model.dart';
import '../clan/services/clan_service.dart';
import '../../core/services/auth_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/dialog_mixin.dart';
import '../profile/profile_screen.dart';

class ClanMembersScreen extends StatefulWidget {
  final ClanModel clan;

  const ClanMembersScreen({required this.clan, super.key});

  @override
  State<ClanMembersScreen> createState() => _ClanMembersScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ClanModel>('clan', clan));
  }
}

class _ClanMembersScreenState extends State<ClanMembersScreen>
    with LoadingMixin, ToastMixin, DialogMixin {

  final ClanService _clanService = ServiceLocator().get<ClanService>();
  final AuthService _authService = ServiceLocator().get<AuthService>();

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
    // ✅ Firebase Auth → Supabase Auth
    final session = Supabase.instance.client.auth.currentSession;
    setState(() {
      _currentUserId = session?.user.id;
    });
  }

  List<ClanMember> get _filteredMembers {
    var members = _clan.members;

    if (_selectedRole != 'All') {
      final role = _getRoleFromString(_selectedRole);
      members = members.where((m) => m.role == role).toList();
    }

    if (_searchQuery.isNotEmpty) {
      members = members.where((m) =>
          m.username.toLowerCase().contains(_searchQuery.toLowerCase()),
      ).toList();
    }

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
      final bool success = await _clanService.changeMemberRole(
        _clan.id,
        member.userId,
        newRole,
      );

      if (success) {
        showSuccess('Role updated');
        final ClanModel? updatedClan = await _clanService.getClan(_clan.id);
        if (updatedClan != null) {
          setState(() {
            _clan = updatedClan;
          });
        }
      }
    });
  }

  Future<void> _kickMember(ClanMember member) async {
    final bool? confirmed = await showConfirmDialog(
      context,
      title: 'Kick Member',
      message: 'Are you sure you want to kick ${member.username}?',
    );

    if (confirmed ?? false) {
      await runWithLoading(() async {
        final bool success = await _clanService.kickMember(_clan.id, member.userId);
        if (success) {
          showSuccess('${member.username} has been kicked');
          final ClanModel? updatedClan = await _clanService.getClan(_clan.id);
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
    final bool isSelf = member.userId == _currentUserId;
    final bool canManageThis = _canManage && !isSelf;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => SafeArea(
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
                    builder: (BuildContext context) => ProfileScreen(userId: member.userId),
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
      builder: (BuildContext context) => AlertDialog(
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
      builder: (BuildContext context) => AlertDialog(
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
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  onChanged: (String value) {
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

              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: ['All', 'Leader', 'Co-Leader', 'Elder', 'Member']
                      .map((String role) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(role),
                      selected: _selectedRole == role,
                      onSelected: (bool selected) {
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
        itemBuilder: (BuildContext context, int index) {
          final member = filteredMembers[index];
          final bool isSelf = member.userId == _currentUserId;

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
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 6,
                        backgroundColor: Colors.green,
                      ),
                    ),
                ],
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      member.username,
                      style: TextStyle(
                        fontWeight: isSelf ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isSelf) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'You',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getRoleColor(member.role).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          member.role.toString().split('.').last,
                          style: TextStyle(
                            color: _getRoleColor(member.role),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.flash_on, size: 12, color: Colors.amber.shade700),
                      const SizedBox(width: 2),
                      Text('${member.activityPoints}'),
                      const SizedBox(width: 12),
                      Icon(Icons.card_giftcard, size: 12, color: Colors.green.shade700),
                      const SizedBox(width: 2),
                      Text('${member.donations}'),
                    ],
                  ),
                ],
              ),
              trailing: !isSelf
                  ? IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showMemberOptions(member),
              )
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => ProfileScreen(userId: member.userId),
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