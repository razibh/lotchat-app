import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/neumorphic_button.dart';
import '../badge/agency_badge_widget.dart';
import '../hosts/manage_hosts_screen.dart';
import '../earnings/agency_earnings_screen.dart';

class AgencyDashboard extends StatefulWidget {

  const AgencyDashboard({Key? key, required this.agencyId}) : super(key: key);
  final String agencyId;

  @override
  State<AgencyDashboard> createState() => _AgencyDashboardState();
}

class _AgencyDashboardState extends State<AgencyDashboard> {
  bool _isLoading = true;
  Map<String, dynamic> _agencyData = <String, dynamic>{};
  List<AgencyHost> _hosts = <>[];

  @override
  void initState() {
    super.initState();
    _loadAgencyData();
  }

  Future<void> _loadAgencyData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _agencyData = <String, dynamic>{
        'id': 'ag_001',
        'name': 'Elite Talent Agency',
        'ownerName': 'Karim Rahman',
        'email': 'contact@eliteagency.com',
        'phone': '01712345678',
        'countryId': 'bd',
        'baseCommissionRate': 10.0, // 10% base commission
        'totalHosts': 25,
        'activeHosts': 18,
        'monthlyEarnings': 125000,
        'totalEarnings': 850000,
        'pendingCommission': 25000,
        'badge': AgencyBadge(
          agencyId: 'ag_001',
          agencyName: 'Elite Talent Agency',
          totalHosts: 25,
          totalEarnings: 850000,
          commissionRate: 10.0,
          isVerified: true,
        ),
      };

      _hosts = _generateSampleHosts();
      _isLoading = false;
    });
  }

  List<AgencyHost> _generateSampleHosts() {
    return List.generate(5, (int index) {
      final var earnings = 5000 + (index * 3000);
      return AgencyHost(
        hostId: 'host_00$index',
        name: 'Host ${index + 1}',
        username: 'host_${index + 1}',
        joinedDate: DateTime.now().subtract(Duration(days: 30 * index)),
        status: HostStatus.active,
        followers: 1000 + (index * 500),
        totalEarnings: earnings * 3,
        thisMonthEarnings: earnings,
        commissionRate: _getCommissionRate(earnings),
        commissionPaid: earnings * 0.08,
        commissionPending: earnings * 0.02,
      );
    });
  }

  double _getCommissionRate(double earnings) {
    if (earnings < 5000) return 5;
    if (earnings < 10000) return 6;
    if (earnings < 20000) return 7;
    return 8;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildDashboard(),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return Column(
      children: <>[
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <>[
                _buildAgencyBadgeSection(),
                const SizedBox(height: 20),
                _buildStatsGrid(),
                const SizedBox(height: 20),
                _buildCommissionSection(),
                const SizedBox(height: 20),
                _buildHostList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <>[
          const CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.accentPurple,
            child: Icon(Icons.business, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  _agencyData['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Owner: ${_agencyData['ownerName']}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAgencyBadgeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <>[
            Colors.purple.withOpacity(0.3),
            Colors.blue.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: <>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Row(
                  children: const <>[
                    Text(
                      'Official Agency',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.verified, color: Colors.blue, size: 16),
                  ],
                ),
                Text(
                  'Commission Rate: ${_agencyData['baseCommissionRate']}%',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: <>[
        _buildStatCard('Total Hosts', '${_agencyData['totalHosts']}', Icons.people),
        _buildStatCard('Active Hosts', '${_agencyData['activeHosts']}', Icons.person),
        _buildStatCard('Monthly Earnings', '৳${_agencyData['monthlyEarnings']}', Icons.money),
        _buildStatCard('Pending Commission', '৳${_agencyData['pendingCommission']}', Icons.pending),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <>[
          Icon(icon, color: AppColors.accentPurple),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <>[
          const Text(
            'Commission Rules',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildCommissionRule('0 - 5,000', '5%'),
          _buildCommissionRule('5,000 - 10,000', '6%'),
          _buildCommissionRule('10,000 - 20,000', '7%'),
          _buildCommissionRule('20,000+', '8%'),
        ],
      ),
    );
  }

  Widget _buildCommissionRule(String range, String rate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <>[
          Text(range, style: const TextStyle(color: Colors.white70)),
          Text(
            rate,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <>[
            const Text(
              'Your Hosts',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ManageHostsScreen(agencyId: widget.agencyId),
                  ),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._hosts.map(_buildHostTile),
      ],
    );
  }

  Widget _buildHostTile(AgencyHost host) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <>[
          CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.3),
            child: Text(host.name[0]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  host.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Earnings: ৳${host.thisMonthEarnings}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${host.commissionRate}%',
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}