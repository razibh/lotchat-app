import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/user_stats_provider.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/analytics_service.dart';
import '../../../widgets/common/loading_widget.dart';

class ProfileStatsScreen extends StatefulWidget {

  const ProfileStatsScreen({required this.userId, super.key});
  final String userId;

  @override
  State<ProfileStatsScreen> createState() => _ProfileStatsScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('userId', userId));
  }
}

class _ProfileStatsScreenState extends State<ProfileStatsScreen> {
  final AnalyticsService _analytics = ServiceLocator().get<AnalyticsService>();

  @override
  void initState() {
    super.initState();
    _analytics.trackScreen('ProfileStats');
    _loadStats();
  }

  Future<void> _loadStats() async {
    await context.read<UserStatsProvider>().loadStats(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserStatsProvider>(
      builder: (BuildContext context, Object? provider, Widget? child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final stats = provider.stats;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Statistics'),
            backgroundColor: Colors.indigo,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <>[
                // Overview Cards
                _buildOverviewCards(stats),

                const SizedBox(height: 24),

                // Activity Chart
                _buildActivityChart(stats),

                const SizedBox(height: 24),

                // Detailed Stats
                _buildDetailedStats(stats),

                const SizedBox(height: 24),

                // Achievements Progress
                _buildAchievementsProgress(stats),

                const SizedBox(height: 24),

                // Game Stats
                _buildGameStats(stats),

                const SizedBox(height: 24),

                // Gift Stats
                _buildGiftStats(stats),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewCards(Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: <>[
        _buildStatCard(
          'Posts',
          '${stats['postsCount'] ?? 0}',
          Icons.post_add,
          Colors.blue,
        ),
        _buildStatCard(
          'Comments',
          '${stats['commentsCount'] ?? 0}',
          Icons.comment,
          Colors.green,
        ),
        _buildStatCard(
          'Likes Received',
          '${stats['likesReceived'] ?? 0}',
          Icons.favorite,
          Colors.red,
        ),
        _buildStatCard(
          'Views',
          '${stats['totalViews'] ?? 0}',
          Icons.visibility,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <>[
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChart(Map<String, dynamic> stats) {
    final Map<String, dynamic> activityData = stats['activityData'] as Map<String, dynamic>? ?? <String, dynamic>{};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <>[
            const Text(
              'Activity Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (int index) {
                  final String day = _getDayName(index);
                  final value = activityData[day] ?? 0;
                  final double maxValue = _getMaxValue(activityData);
                  final height = maxValue > 0 ? (value / maxValue) * 150 : 0;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <>[
                      Container(
                        width: 30,
                        height: height,
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.5 + (value / 100) * 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        day.substring(0, 3),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(int index) {
    final List<String> days = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[index % 7];
  }

  double _getMaxValue(Map<String, dynamic> data) {
    double max = 1;
    data.forEach((_, value) {
      if (value > max) max = value.toDouble();
    });
    return max;
  }

  Widget _buildDetailedStats(Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <>[
            const Text(
              'Detailed Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Profile Views', '${stats['profileViews'] ?? 0}'),
            _buildStatRow('Search Appearances', '${stats['searchAppearances'] ?? 0}'),
            _buildStatRow('Times Shared', '${stats['shareCount'] ?? 0}'),
            _buildStatRow('Reports Received', '${stats['reportsCount'] ?? 0}'),
            _buildStatRow('Warnings', '${stats['warningsCount'] ?? 0}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <>[
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsProgress(Map<String, dynamic> stats) {
    final Map<String, dynamic> achievements = stats['achievements'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final total = achievements['total'] ?? 0;
    final unlocked = achievements['unlocked'] ?? 0;
    final progress = total > 0 ? unlocked / total : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <>[
            const Text(
              'Achievements Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <>[
                      Text(
                        '$unlocked/$total',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Achievements Unlocked',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <>[
                      CircularProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                        strokeWidth: 8,
                      ),
                      Center(
                        child: Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameStats(Map<String, dynamic> stats) {
    final Map<String, dynamic> games = stats['games'] as Map<String, dynamic>? ?? <String, dynamic>{};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <>[
            const Text(
              'Game Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Games Played', '${games['played'] ?? 0}'),
            _buildStatRow('Games Won', '${games['won'] ?? 0}'),
            _buildStatRow('Games Lost', '${games['lost'] ?? 0}'),
            _buildStatRow('Win Rate', '${_calculateWinRate(games)}%'),
            _buildStatRow('Total Bet', '${games['totalBet'] ?? 0} coins'),
            _buildStatRow('Total Won', '${games['totalWon'] ?? 0} coins'),
            _buildStatRow('Net Profit', '${_calculateNetProfit(games)} coins'),
          ],
        ),
      ),
    );
  }

  String _calculateWinRate(Map<String, dynamic> games) {
    final played = games['played'] ?? 0;
    final won = games['won'] ?? 0;
    if (played == 0) return '0';
    return ((won / played) * 100).toStringAsFixed(1);
  }

  int _calculateNetProfit(Map<String, dynamic> games) {
    final totalWon = games['totalWon'] ?? 0;
    final totalBet = games['totalBet'] ?? 0;
    return totalWon - totalBet;
  }

  Widget _buildGiftStats(Map<String, dynamic> stats) {
    final Map<String, dynamic> gifts = stats['gifts'] as Map<String, dynamic>? ?? <String, dynamic>{};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <>[
            const Text(
              'Gift Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Gifts Sent', '${gifts['sent'] ?? 0}'),
            _buildStatRow('Gifts Received', '${gifts['received'] ?? 0}'),
            _buildStatRow('Coins Spent', '${gifts['coinsSpent'] ?? 0} coins'),
            _buildStatRow('Diamonds Earned', '${gifts['diamondsEarned'] ?? 0}'),
            _buildStatRow('Favorite Gift', '${gifts['favoriteGift'] ?? 'None'}'),
            _buildStatRow('Top Gifter', '${gifts['topGifter'] ?? 'None'}'),
          ],
        ),
      ),
    );
  }
}