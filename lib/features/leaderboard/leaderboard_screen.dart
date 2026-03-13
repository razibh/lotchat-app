import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/leaderboard_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../widgets/animation/fade_animation.dart';
import '../../widgets/common/empty_state_widget.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with LoadingMixin {
  
  final LeaderboardService _leaderboardService = ServiceLocator().get<LeaderboardService>();
  String _selectedPeriod = 'Weekly';
  String _selectedCategory = 'Gifts';
  
  final List<String> _periods = <String>['Daily', 'Weekly', 'Monthly', 'All Time'];
  final List<String> _categories = <String>['Gifts', 'Diamonds', 'Games', 'Followers'];

  List<Map<String, dynamic>> _leaderboardData = <Map<String, dynamic>>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    await runWithLoading(() async {
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _leaderboardData = List.generate(50, (int index) {
          final bool isCurrentUser = index == 5;
          return <String, dynamic>{
            'rank': index + 1,
            'userId': 'user_$index',
            'name': isCurrentUser ? 'You' : 'User ${index + 1}',
            'username': isCurrentUser ? '@you' : '@user${index + 1}',
            'avatar': null,
            'value': 1000000 - (index * 50000),
            'change': index % 3 == 0 ? 5 : (index % 3 == 1 ? -3 : 0),
            'isCurrentUser': isCurrentUser,
            'badges': index < 3 ? <String>['🥇', '🥈', '🥉'][index] : null,
          };
        });
        _isLoading = false;
      });
    });
  }

  String _formatValue(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toString();
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  IconData _getChangeIcon(int change) {
    if (change > 0) return Icons.arrow_upward;
    if (change < 0) return Icons.arrow_downward;
    return Icons.remove;
  }

  Color _getChangeColor(int change) {
    if (change > 0) return Colors.green;
    if (change < 0) return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Colors.amber,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: <>[
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
                          color: _selectedPeriod == period ? Colors.amber : Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Category Filter
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _categories.map((String category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                            _loadLeaderboard();
                          });
                        },
                        backgroundColor: Colors.white.withOpacity(0.2),
                        selectedColor: Colors.white,
                        labelStyle: TextStyle(
                          color: _selectedCategory == category ? Colors.amber : Colors.white,
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
          : _leaderboardData.isEmpty
              ? const EmptyStateWidget(
                  title: 'No Data',
                  message: 'No leaderboard data available',
                  icon: Icons.leaderboard,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _leaderboardData.length,
                  itemBuilder: (context, index) {
                    final Map<String, dynamic> item = _leaderboardData[index];
                    return FadeAnimation(
                      delay: Duration(milliseconds: index * 50),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: item['isCurrentUser'] 
                              ? Colors.amber.withOpacity(0.1)
                              : null,
                          borderRadius: BorderRadius.circular(12),
                          border: item['isCurrentUser']
                              ? Border.all(color: Colors.amber, width: 2)
                              : null,
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _getRankColor(item['rank']).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: item['badges'] != null
                                  ? Text(
                                      item['badges'],
                                      style: const TextStyle(fontSize: 20),
                                    )
                                  : Text(
                                      '#${item['rank']}',
                                      style: TextStyle(
                                        color: _getRankColor(item['rank']),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundImage: item['avatar'] != null
                                ? NetworkImage(item['avatar'])
                                : null,
                            child: item['avatar'] == null
                                ? Text(item['name'][0].toUpperCase())
                                : null,
                          ),
                          title: Row(
                            children: <>[
                              Text(
                                item['name'],
                                style: TextStyle(
                                  fontWeight: item['isCurrentUser'] 
                                      ? FontWeight.bold 
                                      : FontWeight.normal,
                                ),
                              ),
                              if (item['isCurrentUser'])
                                const Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Text(item['username']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <>[
                                  Text(
                                    _formatValue(item['value']),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (item['change'] != 0)
                                    Row(
                                      children: <>[
                                        Icon(
                                          _getChangeIcon(item['change']),
                                          color: _getChangeColor(item['change']),
                                          size: 12,
                                        ),
                                        Text(
                                          '${item['change'].abs()}',
                                          style: TextStyle(
                                            color: _getChangeColor(item['change']),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                          onTap: () {
                            // Navigate to user profile
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}