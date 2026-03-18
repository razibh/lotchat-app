import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class GameLeaderboardScreen extends StatefulWidget {
  const GameLeaderboardScreen({super.key});

  @override
  State<GameLeaderboardScreen> createState() => _GameLeaderboardScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }
}

class _GameLeaderboardScreenState extends State<GameLeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _selectedPeriod = 'All Time';
  String _selectedGame = 'All Games';

  List<GameLeaderboardEntry> _entries = [];
  List<GameLeaderboardEntry> _filteredEntries = [];

  final List<String> _periods = ['Daily', 'Weekly', 'Monthly', 'All Time'];
  final List<String> _games = [
    'All Games',
    'Roulette',
    'Three Patti',
    'Ludo',
    'Carrom',
    'Greedy Cat',
    'Werewolf',
    'Trivia',
    'Pictionary',
    'Chess',
    'Truth or Dare',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    _filterEntries();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    _entries = List.generate(100, (index) {
      final gameIndex = index % 10;
      return GameLeaderboardEntry(
        rank: index + 1,
        userId: 'user_${index + 1000}',
        username: 'Player ${index + 1}',
        avatar: null,
        gameName: _getGameName(gameIndex),
        gameIcon: _getGameIcon(gameIndex),
        gameColor: _getGameColor(gameIndex),
        score: 10000 - (index * 95),
        wins: 500 - index,
        losses: index ~/ 2,
        winRate: 0.75 - (index * 0.005),
        totalEarnings: 50000 - (index * 450),
        gamesPlayed: 1000 - (index * 8),
        isUser: index == 42,
        change: index % 4 == 0 ? 2 : (index % 4 == 1 ? -1 : 0),
      );
    });

    _filterEntries();
    setState(() => _isLoading = false);
  }

  String _getGameName(int index) {
    const games = [
      'Roulette',
      'Three Patti',
      'Ludo',
      'Carrom',
      'Greedy Cat',
      'Werewolf',
      'Trivia',
      'Pictionary',
      'Chess',
      'Truth or Dare',
    ];
    return games[index % games.length];
  }

  IconData _getGameIcon(int index) {
    final icons = [
      Icons.casino,
      Icons.casino_outlined, // playing_cards এর পরিবর্তে
      Icons.sports_esports,
      Icons.games,
      Icons.pets,
      Icons.whatshot,
      Icons.quiz,
      Icons.draw,
      Icons.psychology, // chess_board এর পরিবর্তে
      Icons.psychology_outlined,
    ];
    return icons[index % icons.length];
  }

  Color _getGameColor(int index) {
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];
    return colors[index % colors.length];
  }

  void _filterEntries() {
    setState(() {
      _filteredEntries = _entries.where((entry) {
        if (_selectedGame != 'All Games' && entry.gameName != _selectedGame) {
          return false;
        }
        return true;
      }).toList();

      _filteredEntries.sort((a, b) => a.rank.compareTo(b.rank));
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Leaderboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Game Filter
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _games.map((game) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(game),
                        selected: _selectedGame == game,
                        onSelected: (selected) {
                          setState(() {
                            _selectedGame = game;
                            _filterEntries();
                          });
                        },
                        backgroundColor: Colors.white.withOpacity(0.2),
                        selectedColor: Colors.white,
                        labelStyle: TextStyle(
                          color: _selectedGame == game ? Colors.deepPurple : Colors.white,
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
                  children: _periods.map((period) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(period),
                        selected: _selectedPeriod == period,
                        onSelected: (selected) {
                          setState(() {
                            _selectedPeriod = period;
                            _filterEntries();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredEntries.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredEntries.length,
        itemBuilder: (context, index) {
          final entry = _filteredEntries[index];
          return _buildLeaderboardItem(entry, index);
        },
      ),
    );
  }

  Widget _buildLeaderboardItem(GameLeaderboardEntry entry, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: entry.isUser ? Colors.deepPurple.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(12),
        border: entry.isUser ? Border.all(color: Colors.deepPurple, width: 2) : null,
      ),
      child: ListTile(
        leading: _buildRankBadge(entry.rank),
        title: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: entry.gameColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                entry.gameIcon,
                color: entry.gameColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                entry.username,
                style: TextStyle(
                  fontWeight: entry.isUser ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (entry.isUser)
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
          children: [
            Text(
              entry.gameName,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatItem(
                  icon: Icons.score,
                  value: _formatNumber(entry.score),
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildStatItem(
                  icon: Icons.emoji_events,
                  value: '${entry.wins} wins',
                  color: Colors.amber,
                ),
                const SizedBox(width: 8),
                _buildStatItem(
                  icon: Icons.monetization_on,
                  value: _formatNumber(entry.totalEarnings),
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${entry.gamesPlayed} games',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${(entry.winRate * 100).toStringAsFixed(1)}% win rate',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatNumber(entry.score),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            _buildChangeIndicator(entry.change),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
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
          size: rank == 1 ? 24 : 20,
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
        children: [
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No leaderboard data',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No entries found for the selected filters',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Game Leaderboard'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rankings are based on:'),
            SizedBox(height: 8),
            Text('• Total score across all games'),
            Text('• Number of wins'),
            Text('• Win rate percentage'),
            Text('• Total earnings'),
            SizedBox(height: 8),
            Text('Leaderboards reset:'),
            Text('• Daily - Every 24 hours'),
            Text('• Weekly - Every Monday'),
            Text('• Monthly - 1st of each month'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class GameLeaderboardEntry {
  final int rank;
  final String userId;
  final String username;
  final String? avatar;
  final String gameName;
  final IconData gameIcon;
  final Color gameColor;
  final int score;
  final int wins;
  final int losses;
  final double winRate;
  final int totalEarnings;
  final int gamesPlayed;
  final bool isUser;
  final int change;

  GameLeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    this.avatar,
    required this.gameName,
    required this.gameIcon,
    required this.gameColor,
    required this.score,
    required this.wins,
    required this.losses,
    required this.winRate,
    required this.totalEarnings,
    required this.gamesPlayed,
    required this.isUser,
    required this.change,
  });
}

// Simplified version for error fixing
class GameLeaderboardScreenSimple extends StatelessWidget {
  const GameLeaderboardScreenSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Game Leaderboard Screen'),
      ),
    );
  }
}