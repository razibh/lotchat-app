import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/di/service_locator.dart';
import '../../core/models/clan_model.dart';
import '../clan/services/clan_service.dart';
import '../../core/services/auth_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/dialog_mixin.dart';
import '../../widgets/animation/fade_animation.dart';
import 'clan_members_screen.dart';
import 'clan_chat_screen.dart';
import 'clan_requests_screen.dart';
import 'clan_settings_screen.dart';
import 'widgets/clan_progress_bar.dart';
import 'widgets/clan_badge.dart';

class ClanDetailScreen extends StatefulWidget {
  final ClanModel clan;

  const ClanDetailScreen({required this.clan, super.key});

  @override
  State<ClanDetailScreen> createState() => _ClanDetailScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ClanModel>('clan', clan));
  }
}

class _ClanDetailScreenState extends State<ClanDetailScreen>
    with LoadingMixin, ToastMixin, DialogMixin {

  final ClanService _clanService = ServiceLocator().get<ClanService>();
  final AuthService _authService = ServiceLocator().get<AuthService>();

  late ClanModel _clan;
  String? _currentUserId;
  bool _isMember = false;
  bool _hasPendingRequest = false;

  @override
  void initState() {
    super.initState();
    _clan = widget.clan;
    _checkMembership();
    _setupStream();
  }

  Future<void> _checkMembership() async {
    final User? user = _authService.getCurrentUser();
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
        _isMember = _clan.members.any((m) => m.userId == user.uid);
      });
    }
  }

  void _setupStream() {
    _clanService.streamClan(_clan.id).listen((clan) {
      if (clan != null && mounted) {
        setState(() {
          _clan = clan;
        });
      }
    });
  }

  Future<void> _joinClan() async {
    if (_clan.joinType == ClanJoinType.approval) {
      final bool? confirmed = await showConfirmDialog(
        context,
        title: 'Join Request',
        message: 'Send a join request to ${_clan.name}?',
      );

      if (confirmed ?? false) {
        await runWithLoading(() async {
          final bool success = await _clanService.joinClan(_clan.id);
          if (success) {
            setState(() {
              _hasPendingRequest = true;
            });
            showSuccess('Join request sent!');
          }
        });
      }
    } else {
      final bool? confirmed = await showConfirmDialog(
        context,
        title: 'Join Clan',
        message: 'Join ${_clan.name}?',
      );

      if (confirmed ?? false) {
        await runWithLoading(() async {
          final bool success = await _clanService.joinClan(_clan.id);
          if (success) {
            showSuccess('Joined clan!');
            Navigator.pop(context, true);
          }
        });
      }
    }
  }

  Future<void> _leaveClan() async {
    final bool? confirmed = await showConfirmDialog(
      context,
      title: 'Leave Clan',
      message: 'Are you sure you want to leave ${_clan.name}?',
    );

    if (confirmed ?? false) {
      await runWithLoading(() async {
        final bool success = await _clanService.leaveClan(_clan.id);
        if (success) {
          showSuccess('Left clan');
          Navigator.pop(context, true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLeader = _clan.isLeader(_currentUserId ?? '');
    final canManage = _clan.canManage(_currentUserId ?? '');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.deepPurple, Colors.purple],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_clan.emblem != null)
                      Positioned(
                        right: -50,
                        top: -50,
                        child: Opacity(
                          opacity: 0.2,
                          child: Image.network(
                            _clan.emblem!,
                            width: 200,
                            height: 200,
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 20,
                      left: 16,
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              image: _clan.emblem != null
                                  ? DecorationImage(
                                image: NetworkImage(_clan.emblem!),
                                fit: BoxFit.cover,
                              )
                                  : null,
                            ),
                            child: _clan.emblem == null
                                ? const Icon(
                              Icons.groups,
                              size: 40,
                              color: Colors.deepPurple,
                            )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _clan.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    ClanBadge(level: _clan.level),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_clan.memberCount}/${_clan.maxMembers} members',
                                      style: const TextStyle(
                                        color: Colors.white70,
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
            actions: [
              if (_isMember)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  itemBuilder: (context) => [
                    if (canManage)
                      const PopupMenuItem(
                        value: 'requests',
                        child: Text('Join Requests'),
                      ),
                    if (canManage)
                      const PopupMenuItem(
                        value: 'settings',
                        child: Text('Clan Settings'),
                      ),
                    const PopupMenuItem(
                      value: 'members',
                      child: Text('View Members'),
                    ),
                    const PopupMenuItem(
                      value: 'leave',
                      child: Text('Leave Clan'),
                    ),
                  ],
                  onSelected: (value) async {
                    switch (value) {
                      case 'requests':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClanRequestsScreen(clanId: _clan.id),
                          ),
                        );
                        break;
                      case 'settings':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClanSettingsScreen(clan: _clan),
                          ),
                        ).then((_) => _clanService.getClan(_clan.id));
                        break;
                      case 'members':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClanMembersScreen(clan: _clan),
                          ),
                        );
                        break;
                      case 'leave':
                        _leaveClan();
                        break;
                    }
                  },
                ),
            ],
          ),

          // Clan Info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // XP Progress
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Clan XP'),
                              Text('${_clan.xp}/${_clan.xpToNextLevel}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClanProgressBar(
                            progress: _clan.xpProgress,
                            color: Colors.deepPurple,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  if (_clan.description != null) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_clan.description!),
                    const SizedBox(height: 16),
                  ],

                  // Rules
                  if (_clan.rules != null) ...[
                    const Text(
                      'Rules',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_clan.rules!),
                    const SizedBox(height: 16),
                  ],

                  // Stats
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                'Created',
                                _formatDate(_clan.createdAt),
                                Icons.calendar_today,
                              ),
                              _buildStatItem(
                                'War Record',
                                '${_clan.warWins}W - ${_clan.warLosses}L - ${_clan.warDraws}D',
                                Icons.emoji_events,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                'Total Activity',
                                '${_clan.getTotalActivity()}',
                                Icons.trending_up,
                              ),
                              _buildStatItem(
                                'Clan Coins',
                                '${_clan.clanCoins}',
                                Icons.monetization_on,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Members Preview
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Members',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClanMembersScreen(clan: _clan),
                        ),
                      );
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
          ),

          // Member List
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                if (index >= _clan.members.length) return null;
                final member = _clan.members[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: member.avatar != null
                        ? NetworkImage(member.avatar!)
                        : null,
                    child: member.avatar == null
                        ? Text(member.username[0].toUpperCase())
                        : null,
                  ),
                  title: Row(
                    children: [
                      Text(member.username),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getRoleColor(member.role).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getRoleName(member.role),
                          style: TextStyle(
                            fontSize: 10,
                            color: _getRoleColor(member.role),
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text('Activity: ${member.activityPoints}'),
                  trailing: member.isOnline
                      ? Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  )
                      : null,
                );
              },
              childCount: _clan.members.length,
            ),
          ),
        ],
      ),
      bottomNavigationBar: !_isMember && !_hasPendingRequest
          ? Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _joinClan,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            minimumSize: const Size(double.infinity, 48),
          ),
          child: Text(
            _clan.joinType == ClanJoinType.approval
                ? 'Request to Join'
                : 'Join Clan',
          ),
        ),
      )
          : _hasPendingRequest
          ? Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text(
            'Join request pending',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      )
          : null,
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
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

  String _getRoleName(ClanRole role) {
    switch (role) {
      case ClanRole.leader:
        return 'Leader';
      case ClanRole.coLeader:
        return 'Co-Leader';
      case ClanRole.elder:
        return 'Elder';
      case ClanRole.member:
        return 'Member';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else {
      return 'Today';
    }
  }
}