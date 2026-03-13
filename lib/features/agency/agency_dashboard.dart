import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/agency_service.dart';
import '../../core/models/agency_model.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../widgets/common/custom_button.dart';

class AgencyDashboard extends StatefulWidget {
  const AgencyDashboard({Key? key}) : super(key: key);

  @override
  State<AgencyDashboard> createState() => _AgencyDashboardState();
}

class _AgencyDashboardState extends State<AgencyDashboard> 
    with LoadingMixin, ToastMixin {
  
  final AgencyService _agencyService = ServiceLocator().get<AgencyService>();
  
  AgencyModel? _agency;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAgency();
  }

  Future<void> _loadAgency() async {
    await runWithLoading(() async {
      try {
        // Load agency data
        _agency = await _agencyService.getAgency('agency_id');
      } catch (e) {
        showError('Failed to load agency: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_agency == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <>[
              const Icon(Icons.business, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No Agency Found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'You are not a member of any agency',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_agency!.name),
        backgroundColor: Colors.blue,
        actions: <>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAgency,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <>[
            // Stats Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: <>[
                _buildStatCard(
                  'Total Earnings',
                  '${_agency!.totalEarnings}',
                  Icons.trending_up,
                  Colors.green,
                ),
                _buildStatCard(
                  'Members',
                  '${_agency!.members.length}',
                  Icons.people,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Commission',
                  '${(_agency!.commissionRate * 100).toInt()}%',
                  Icons.percent,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Active Now',
                  '12',
                  Icons.online_prediction,
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Member Leaderboard
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <>[
                    const Text(
                      'Top Performers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(5, (int index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: <>[
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _getRankColor(index + 1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <>[
                                  const Text(
                                    'User Name',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Earnings: ${50000 - (index * 5000)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '+${15 - index}%',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Recent Activities
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <>[
                    const Text(
                      'Recent Activities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(5, (int index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: <>[Colors.green, Colors.blue, Colors.orange][index % 3],
                          child: Icon(
                            <>[Icons.attach_money, Icons.person_add, Icons.card_giftcard][index % 3],
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(<String>[
                          'New member joined',
                          'Withdrawal processed',
                          'Gift sent',
                        ][index % 3]),
                        subtitle: Text('${index + 1} hour${index == 0 ? '' : 's'} ago'),
                        trailing: Text(
                          <String>['+500', '-200', '+1000'][index % 3],
                          style: TextStyle(
                            color: <>[Colors.green, Colors.red, Colors.green][index % 3],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
              title,
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

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.blue.withOpacity(0.5);
    }
  }
}