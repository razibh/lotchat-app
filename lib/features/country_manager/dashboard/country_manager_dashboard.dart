import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class CountryManagerDashboard extends StatefulWidget {
  final String countryId;
  final String? managerId;

  const CountryManagerDashboard({
    super.key,
    required this.countryId,
    this.managerId,
  });

  @override
  State<CountryManagerDashboard> createState() => _CountryManagerDashboardState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('countryId', countryId));
    properties.add(StringProperty('managerId', managerId));
  }
}

class _CountryManagerDashboardState extends State<CountryManagerDashboard> {
  int _selectedIndex = 0;
  int _pendingApprovals = 3;
  int _totalAgencies = 12;
  int _totalHosts = 45;
  int _activeIssues = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Country Manager - ${widget.countryId}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (widget.managerId != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ID: ${widget.managerId}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Row(
        children: [
          // Left Side Menu
          Container(
            width: 250,
            color: Colors.grey.shade100,
            child: Column(
              children: [
                _buildMenuItem(0, Icons.dashboard, 'Dashboard'),
                _buildMenuItem(1, Icons.business, 'Agencies', badge: _pendingApprovals),
                _buildMenuItem(2, Icons.people, 'Hosts'),
                _buildMenuItem(3, Icons.assessment, 'Reports'),
                _buildMenuItem(4, Icons.warning, 'Issues', badge: _activeIssues),
                _buildMenuItem(5, Icons.person_add, 'Recruitment'),
                _buildMenuItem(6, Icons.bar_chart, 'Statistics'),
                _buildMenuItem(7, Icons.settings, 'Settings'),
                const Spacer(),
                _buildLogoutButton(),
              ],
            ),
          ),

          // Right Side Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title, {int? badge}) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (badge != null && badge > 0)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Center(
                  child: Text(
                    '$badge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
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

  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: () {
          _showLogoutDialog();
        },
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 45),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildAgencies();
      case 2:
        return _buildHosts();
      case 3:
        return _buildReports();
      case 4:
        return _buildIssues();
      case 5:
        return _buildRecruitment();
      case 6:
        return _buildStatistics();
      case 7:
        return _buildSettings();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Stats Cards
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard('Total Agencies', '$_totalAgencies', Icons.business, Colors.blue),
              _buildStatCard('Total Hosts', '$_totalHosts', Icons.people, Colors.green),
              _buildStatCard('Pending Approvals', '$_pendingApprovals', Icons.pending, Colors.orange),
              _buildStatCard('Active Issues', '$_activeIssues', Icons.warning, Colors.red),
            ],
          ),

          const SizedBox(height: 30),

          // Recent Activities
          const Text(
            'Recent Activities',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: index % 3 == 0 ? Colors.green : Colors.blue,
                    child: Icon(
                      index % 3 == 0 ? Icons.check : Icons.access_time,
                      color: Colors.white,
                    ),
                  ),
                  title: Text('Agency Application ${index + 1}'),
                  subtitle: Text('Submitted ${index + 1} hours ago'),
                  trailing: index % 3 == 0
                      ? const Text('Approved', style: TextStyle(color: Colors.green))
                      : const Text('Pending', style: TextStyle(color: Colors.orange)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgencies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Agency Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/country-manager/agencies',
                  arguments: {'countryId': widget.countryId},
                );
              },
              icon: const Icon(Icons.visibility),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Pending Approvals
        const Text(
          'Pending Approvals',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _pendingApprovals,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade100,
                  child: const Icon(Icons.business, color: Colors.orange),
                ),
                title: Text('Agency ${index + 1}'),
                subtitle: Text('Applied ${index + 1} day${index == 0 ? '' : 's'} ago'),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/country-manager/agency-approval',
                      arguments: {
                        'agencyId': 'agency_${index + 1}',
                        'countryId': widget.countryId,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Review'),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHosts() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Host Management',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Total Hosts: $_totalHosts',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildReports() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assessment, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Reports',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/country-manager/statistics',
                arguments: widget.countryId,
              );
            },
            child: const Text('View Statistics'),
          ),
        ],
      ),
    );
  }

  Widget _buildIssues() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Issue Management',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Active Issues: $_activeIssues',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRecruitment() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_add, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Recruitment',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/country-manager/recruitment',
                arguments: widget.countryId,
              );
            },
            child: const Text('Open Recruitment'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bar_chart, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Statistics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/country-manager/statistics',
                arguments: widget.countryId,
              );
            },
            child: const Text('View Statistics'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.settings, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Country: ${widget.countryId}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('selectedIndex', _selectedIndex));
    properties.add(IntProperty('pendingApprovals', _pendingApprovals));
    properties.add(IntProperty('totalAgencies', _totalAgencies));
    properties.add(IntProperty('totalHosts', _totalHosts));
    properties.add(IntProperty('activeIssues', _activeIssues));
  }
}