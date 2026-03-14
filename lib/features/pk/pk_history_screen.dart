import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/pk_service.dart';
import '../../core/services/auth_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/pagination_mixin.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/animation/fade_animation.dart';

class PKHistoryScreen extends StatefulWidget {
  const PKHistoryScreen({super.key});

  @override
  State<PKHistoryScreen> createState() => _PKHistoryScreenState();
}

class _PKHistoryScreenState extends State<PKHistoryScreen> 
    with LoadingMixin, PaginationMixin<Map<String, dynamic>> {
  
  final _pkService = ServiceLocator().get<PkService>();
  final AuthService _authService = ServiceLocator().get<AuthService>();
  
  String _selectedFilter = 'All';
  final List<String> _filters = <String>['All', 'Won', 'Lost'];

  @override
  void initState() {
    super.initState();
    initPagination();
    loadMore();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPage(int page) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return List.generate(20, (int index) {
      final bool won = index % 3 != 0;
      return <String, dynamic>{
        'id': 'pk_$index',
        'opponentName': 'Room ${index + 1}',
        'ourScore': won ? 5000 + (index * 100) : 3000 + (index * 100),
        'opponentScore': won ? 3000 + (index * 100) : 5000 + (index * 100),
        'date': DateTime.now().subtract(Duration(days: index)),
        'won': won,
        'rewards': won ? '${500 + index * 50} coins' : '0 coins',
        'topGifter': 'User ${index + 1}',
      };
    });
  }

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  List<Map<String, dynamic>> get _filteredHistory {
    if (_selectedFilter == 'All') return items;
    final bool wantWon = _selectedFilter == 'Won';
    return items.where((Map<String, dynamic> item) => item['won'] == wantWon).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PK History'),
        backgroundColor: Colors.red,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _filters.map((String filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: _selectedFilter == filter,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    selectedColor: Colors.white,
                    labelStyle: TextStyle(
                      color: _selectedFilter == filter ? Colors.red : Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: _filteredHistory.isEmpty && !isLoadingMore
          ? const EmptyStateWidget(
              title: 'No PK History',
              message: 'Join PK battles to see your history',
              icon: Icons.history,
            )
          : ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _filteredHistory.length + (hasMore ? 1 : 0),
              itemBuilder: (BuildContext context, int index) {
                if (index == _filteredHistory.length) {
                  return buildPaginationLoadingIndicator();
                }
                
                final Map<String, dynamic> battle = _filteredHistory[index];
                final bool won = battle['won'] as bool;
                
                return FadeAnimation(
                  delay: Duration(milliseconds: index * 50),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: <>[
                          // Header
                          Row(
                            children: <>[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: won ? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  won ? 'VICTORY' : 'DEFEAT',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _formatDate(battle['date']),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Score
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <>[
                              Column(
                                children: <>[
                                  const Text('Your Team'),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${battle['ourScore']}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: won ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const Text(
                                'VS',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Column(
                                children: <>[
                                  const Text('Opponent'),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${battle['opponentScore']}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: won ? Colors.red : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Details
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <>[
                              Row(
                                children: <>[
                                  const Icon(Icons.emoji_events, size: 16, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text('Top: ${battle['topGifter']}'),
                                ],
                              ),
                              Row(
                                children: <>[
                                  const Icon(Icons.monetization_on, size: 16, color: Colors.green),
                                  const SizedBox(width: 4),
                                  Text(battle['rewards']),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}