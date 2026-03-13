import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/neumorphic_button.dart';
import '../country_managers/manage_country_managers.dart';
import '../agencies/verify_agencies_screen.dart';
import '../coin_sellers/verify_sellers_screen.dart';
import '../regions/region_management_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _stats = <String, dynamic>{
        'totalCountries': 15,
        'totalCountryManagers': 12,
        'totalAgencies': 245,
        'pendingAgencies': 18,
        'totalHosts': 3250,
        'activeHosts': 2800,
        'totalCoinSellers': 45,
        'pendingSellers': 8,
        'totalUsers': 125000,
        'totalRevenue': 2500000,
        'monthlyRevenue': 450000,
        'growth': 15.5,
      };
      _isLoading = false;
    });
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
                _buildWelcomeCard(),
                const SizedBox(height: 20),
                _buildMainStats(),
                const SizedBox(height: 20),
                _buildQuickActions(),
                const SizedBox(height: 20),
                _buildPendingApprovals(),
                const SizedBox(height: 20),
                _buildRevenueCard(),
                const SizedBox(height: 20),
                _buildRegionStats(),
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
            backgroundColor: Colors.red,
            child: Icon(Icons.admin_panel_settings, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Platform Overview',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <>[
            Colors.red.withOpacity(0.3),
            Colors.purple.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <>[
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  'Welcome back, Admin!',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Platform is running smoothly',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: <>[
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Live',
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: <>[
        _buildStatCard('Total Users', '${_stats['totalUsers']}', Icons.people, Colors.blue),
        _buildStatCard('Total Hosts', '${_stats['totalHosts']}', Icons.person, Colors.green),
        _buildStatCard('Agencies', '${_stats['totalAgencies']}', Icons.business, Colors.purple),
        _buildStatCard('Sellers', '${_stats['totalCoinSellers']}', Icons.store, Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <>[
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <>[
        const Text(
          'Quick Actions',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: <>[
            _buildActionTile(
              'Country Managers',
              Icons.public,
              Colors.purple,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageCountryManagersScreen()),
                );
              },
            ),
            _buildActionTile(
              'Verify Agencies',
              Icons.business,
              Colors.blue,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VerifyAgenciesScreen()),
                );
              },
            ),
            _buildActionTile(
              'Verify Sellers',
              Icons.store,
              Colors.orange,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VerifySellersScreen()),
                );
              },
            ),
            _buildActionTile(
              'Regions',
              Icons.map,
              Colors.green,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegionManagementScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          children: <>[
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: color, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingApprovals() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <>[
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <>[
              Text(
                'Pending Approvals',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                'View All →',
                style: TextStyle(color: Colors.blue, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildApprovalItem(
            'Agencies',
            '${_stats['pendingAgencies']}',
            Icons.business,
            Colors.purple,
          ),
          const SizedBox(height: 12),
          _buildApprovalItem(
            'Coin Sellers',
            '${_stats['pendingSellers']}',
            Icons.store,
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildApprovalItem(
            'Country Managers',
            '3',
            Icons.public,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalItem(String label, String count, IconData icon, Color color) {
    return Row(
      children: <>[
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <>[
            Colors.green.withOpacity(0.3),
            Colors.blue.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <>[
              const Text(
                'Revenue Overview',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${_stats['growth']}%',
                  style: const TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <>[
              _buildRevenueItem('Total', '৳${_stats['totalRevenue']}'),
              _buildRevenueItem('Monthly', '৳${_stats['monthlyRevenue']}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueItem(String label, String amount) {
    return Column(
      children: <>[
        Text(
          amount,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildRegionStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <>[
        const Text(
          'Top Regions',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildRegionTile('Bangladesh', '🇧🇩', 45, 320),
        _buildRegionTile('India', '🇮🇳', 78, 650),
        _buildRegionTile('Pakistan', '🇵🇰', 52, 410),
        _buildRegionTile('Nepal', '🇳🇵', 28, 180),
      ],
    );
  }

  Widget _buildRegionTile(String name, String flag, int agencies, int hosts) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <>[
          Text(flag, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$agencies agencies',
              style: const TextStyle(color: Colors.purple, fontSize: 10),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$hosts hosts',
              style: const TextStyle(color: Colors.green, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}