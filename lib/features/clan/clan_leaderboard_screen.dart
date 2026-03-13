import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/clan_service.dart';
import '../../core/services/auth_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../widgets/animation/fade_animation.dart';
import '../../widgets/common/empty_state_widget.dart';
import 'clan_detail_screen.dart';

class ClanLeaderboardScreen extends StatefulWidget {
  const ClanLeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<ClanLeaderboardScreen> createState() => _ClanLeaderboardScreenState();
}

class _ClanLeaderboardScreenState extends State<ClanLeaderboardScreen> 
    with LoadingMixin, ToastMixin {
  
  final ClanService _clanService = ServiceLocator().get<ClanService>();
  final AuthService _authService = ServiceLocator().get<AuthService>();
  
  List<ClanLeaderboardEntry> _clans = <ClanLeaderboardEntry>[];
  List<ClanMemberLeaderboardEntry> _members = <ClanMemberLeaderboardEntry>[];
  String _selectedTab = 'Clans';
  String _selectedPeriod = 'All Time';
  final bool _isLoading = true;
  String? _userClanId;

  final List<String> _tabs = <String>['Clans', 'Members'];
  final List<String> _periods = <String>['Daily', 'Weekly', 'Monthly', 'All Time'];
  final List<String> _categories = <String>['Level', 'Activity', 'Wars', 'Donations'];

  @override
  void initState() {
    super.initState();
    _getUserClan();
    _loadLeaderboard();
  }

  Future<void> _getUserClan() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      setState(() {
        _userClanId = user.clanId;
      });
    }
  }

  Future<void> _loadLeaderboard() async {
    await runWithLoading(() async {
      await Future.delayed(const Duration(seconds: 1));
      
      if (_selectedTab == 'Clans') {
        _loadClanLeaderboard();
      } else {
        _loadMemberLeaderboard();
      }
    });
  }

  void _loadClanLeaderboard() {
    // Mock data - in real app, fetch from service
    _clans = List.generate(100, (int index) {
      final bool isUserClan = _userClanId == 'clan_${index + 1}';
      return ClanLeaderboardEntry(
        rank: index + 1,
        clanId: 'clan_${index + 1}',
        clanName: '${_getClanName(index)} Clan',
        level: 50 - index,
        members: 50 - (index % 10),
        activityPoints: 100000 - (index * 800),
        warWins: 200 - index,
        donations: 50000 - (index * 400),
        isUserClan: isUserClan,
        change: index % 3 == 0 ? 5 : (index % 3 == 1 ? -3 : 0),
      );
    });
  }

  void _loadMemberLeaderboard() {
    _members = List.generate(100, (int index) {
      final bool isUser = index == 42; // Mock user position
      return ClanMemberLeaderboardEntry(
        rank: index + 1,
        userId: 'user_${index + 1}',
        username: 'Player ${index + 1}',
        clanName: '${_getClanName(index % 10)} Clan',
        activityPoints: 50000 - (index * 450),
        donations: 25000 - (index * 200),
        warPoints: 1000 - (index * 8),
        isUser: isUser,
        change: index % 4 == 0 ? 2 : (index % 4 == 1 ? -1 : 0),
      );
    });
  }

  String _getClanName(int index) {
    final List<String> names = <String>['Dragon', 'Phoenix', 'Wolf', 'Tiger', 'Lion', 'Eagle', 'Shark', 'Bear', 'Falcon', 'Cobra'];
    return names[index % names.length];
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey;
    if (rank == 3) return Colors.brown;
    return Colors.blue;
  }

  IconData _getRankIcon(int rank) {
    if (rank == 1) return Icons.emoji_events;
    if (rank == 2) return Icons.military_tech;
    if (rank == 3) return Icons.star;
    return Icons.circle;
  }

  double _getRankIconSize(int rank) {
    if (rank <= 3) return 24;
    return 16;
  }

  Widget _buildRankBadge(int rank) {
    if (rank <= 3) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getRankColor(rank).withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getRankIcon(rank),
          color: _getRankColor(rank),
          size: _getRankIconSize(rank),
        ),
      );
    } else {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '#$rank',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildChangeIndicator(int change) {
    if (change == 0) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: change > 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <>[
          Icon(
            change > 0 ? Icons.arrow_upward : Icons.arrow_downward,
            color: change > 0 ? Colors.green : Colors.red,
            size: 12,
          ),
          const SizedBox(width: 2),
          Text(
            '${change.abs()}',
            style: TextStyle(
              color: change > 0 ? Colors.green : Colors.red,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clan Leaderboard'),
        backgroundColor: Colors.deepPurple,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: <>[
              // Tab Bar
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _tabs.map((String tab) {
                    final bool isSelected = _selectedTab == tab;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTab = tab;
                            _loadLeaderboard();
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              tab,
                              style: TextStyle(
                                color: isSelected ? Colors.deepPurple : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Period Filter
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _periods.map((String period) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(period),
                        selected: _selectedPeriod == period,
                        onSelected: (selected) {
                          setState(() {
                            _selectedPeriod = period;
                            _loadLeaderboard();
                          });
                        },
                        backgroundColor: Colors.white.withOpacity(0.2),
                        selectedColor: Colors.white,
                        labelStyle: TextStyle(
                          color: _selectedPeriod == period ? Colors.deepPurple : Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        actions: <>[
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedTab == 'Clans'
              ? _buildClanLeaderboard()
              : _buildMemberLeaderboard(),
    );
  }

  Widget _buildClanLeaderboard() {
    if (_clans.isEmpty) {
      return const EmptyStateWidget(
        title: 'No Data',
        message: 'No clan leaderboard data available',
        icon: Icons.leaderboard,
      );
    }

    return Column(
      children: <>[
        // Top 3 Podium
        if (_clans.length >= 3)
          Container(
            height: 180,
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <>[
                // 2nd Place
                Expanded(
                  child: _buildPodiumItem(
                    clan: _clans[1],
                    rank: 2,
                    height: 100,
                  ),
                ),
                // 1st Place
                Expanded(
                  child: _buildPodiumItem(
                    clan: _clans[0],
                    rank: 1,
                    height: 140,
                  ),
                ),
                // 3rd Place
                Expanded(
                  child: _buildPodiumItem(
                    clan: _clans[2],
                    rank: 3,
                    height: 80,
                  ),
                ),
              ],
            ),
          ),

        // Leaderboard List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _clans.length,
            itemBuilder: (context, index) {
              final ClanLeaderboardEntry clan = _clans[index];
              
              return FadeAnimation(
                delay: Duration(milliseconds: index * 50),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: clan.isUserClan ? Colors.deepPurple.withOpacity(0.1) : null,
                    borderRadius: BorderRadius.circular(12),
                    border: clan.isUserClan
                        ? Border.all(color: Colors.deepPurple, width: 2)
                        : null,
                  ),
                  child: ListTile(
                    leading: _buildRankBadge(clan.rank),
                    title: Row(
                      children: <>[
                        Expanded(
                          child: Text(
                            clan.clanName,
                            style: TextStyle(
                              fontWeight: clan.isUserClan ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (clan.isUserClan)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'YOUR CLAN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <>[
                        Row(
                          children: <>[
                            Icon(Icons.people, size: 12, color: Colors.grey.shade600),
                            const SizedBox(width: 2),
                            Text('${clan.members} members'),
                            const SizedBox(width: 8),
                            Icon(Icons.emoji_events, size: 12, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text('${clan.warWins} wins'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: <>[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: <>[
                                  const Icon(Icons.flash_on, size: 10, color: Colors.blue),
                                  const SizedBox(width: 2),
                                  Text(
                                    _formatNumber(clan.activityPoints),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: <>[
                                  const Icon(Icons.monetization_on, size: 10, color: Colors.green),
                                  const SizedBox(width: 2),
                                  Text(
                                    _formatNumber(clan.donations),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <>[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <>[
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 2),
                            Text(
                              '${clan.level}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        _buildChangeIndicator(clan.change),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClanDetailScreen(
                            clan: ClanModel(
                              id: clan.clanId,
                              name: clan.clanName,
                              // Add other required fields
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemberLeaderboard() {
    if (_members.isEmpty) {
      return const EmptyStateWidget(
        title: 'No Data',
        message: 'No member leaderboard data available',
        icon: Icons.leaderboard,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _members.length,
      itemBuilder: (context, index) {
        final ClanMemberLeaderboardEntry member = _members[index];
        
        return FadeAnimation(
          delay: Duration(milliseconds: index * 50),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: member.isUser ? Colors.deepPurple.withOpacity(0.1) : null,
              borderRadius: BorderRadius.circular(12),
              border: member.isUser
                  ? Border.all(color: Colors.deepPurple, width: 2)
                  : null,
            ),
            child: ListTile(
              leading: Stack(
                children: <>[
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: member.avatar != null
                        ? NetworkImage(member.avatar!)
                        : null,
                    child: member.avatar == null
                        ? Text(member.username[0].toUpperCase())
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _getRankColor(member.rank),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '#${member.rank}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
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
                      member.username,
                      style: TextStyle(
                        fontWeight: member.isUser ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (member.isUser)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'YOU',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <>[
                  Text(
                    member.clanName,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: <>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: <>[
                            const Icon(Icons.flash_on, size: 10, color: Colors.blue),
                            const SizedBox(width: 2),
                            Text(
                              _formatNumber(member.activityPoints),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: <>[
                            const Icon(Icons.monetization_on, size: 10, color: Colors.green),
                            const SizedBox(width: 2),
                            Text(
                              _formatNumber(member.donations),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: <>[
                            const Icon(Icons.emoji_events, size: 10, color: Colors.orange),
                            const SizedBox(width: 2),
                            Text(
                              _formatNumber(member.warPoints),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: _buildChangeIndicator(member.change),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPodiumItem({
    required ClanLeaderboardEntry clan,
    required int rank,
    required double height,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClanDetailScreen(
              clan: ClanModel(
                id: clan.clanId,
                name: clan.clanName,
                // Add other required fields
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <>[
            // Clan Emblem
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getRankColor(rank).withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _getRankColor(rank),
                  width: 3,
                ),
                image: clan.emblem != null
                    ? DecorationImage(
                        image: NetworkImage(clan.emblem!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: clan.emblem == null
                  ? Icon(
                      Icons.groups,
                      color: _getRankColor(rank),
                      size: 30,
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              clan.clanName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Level ${clan.level}',
              style: TextStyle(
                fontSize: 10,
                color: _getRankColor(rank),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 60,
              height: height,
              decoration: BoxDecoration(
                color: _getRankColor(rank).withOpacity(0.3),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Leaderboard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <>[
            Text('Rankings are based on:'),
            SizedBox(height: 8),
            Text('• Clan Level - Total XP earned'),
            Text('• Activity Points - Member participation'),
            Text('• War Wins - Clan war victories'),
            Text('• Donations - Coins donated to clan'),
            SizedBox(height: 8),
            Text('Leaderboards reset:'),
            Text('• Daily - Every 24 hours'),
            Text('• Weekly - Every Monday'),
            Text('• Monthly - 1st of each month'),
          ],
        ),
        actions: <>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Model Classes
class ClanLeaderboardEntry {

  ClanLeaderboardEntry({
    required this.rank,
    required this.clanId,
    required this.clanName,
    this.emblem,
    required this.level,
    required this.members,
    required this.activityPoints,
    required this.warWins,
    required this.donations,
    required this.isUserClan,
    required this.change,
  });
  final int rank;
  final String clanId;
  final String clanName;
  final String? emblem;
  final int level;
  final int members;
  final int activityPoints;
  final int warWins;
  final int donations;
  final bool isUserClan;
  final int change;
}

class ClanMemberLeaderboardEntry {

  ClanMemberLeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    this.avatar,
    required this.clanName,
    required this.activityPoints,
    required this.donations,
    required this.warPoints,
    required this.isUser,
    required this.change,
  });
  final int rank;
  final String userId;
  final String username;
  final String? avatar;
  final String clanName;
  final int activityPoints;
  final int donations;
  final int warPoints;
  final bool isUser;
  final int change;
}