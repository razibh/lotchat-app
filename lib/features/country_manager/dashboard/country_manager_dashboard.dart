import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/neumorphic_button.dart';
import '../models/country_manager_models.dart';
import '../agencies/manage_agencies_screen.dart';
import '../recruitment/recruit_agency_screen.dart';
import '../monitoring/monitor_hosts_screen.dart';
import '../issues/solve_issues_screen.dart';

class CountryManagerDashboard extends StatefulWidget {

  const CountryManagerDashboard({
    Key? key,
    required this.managerId,
  }) : super(key: key);
  final String managerId;

  @override
  State<CountryManagerDashboard> createState() => _CountryManagerDashboardState();
}

class _CountryManagerDashboardState extends State<CountryManagerDashboard> {
  bool _isLoading = true;
  CountryManager? _manager;
  List<ManagerAgency> _recentAgencies = <ManagerAgency>[];
  List<ManagerIssue> _recentIssues = <>[];
  List<AgencyRecruitmentRequest> _pendingRequests = <>[];
  List<HostPerformance> _topHosts = <>[];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _manager = CountryManager(
        id: 'cm_001',
        userId: 'user_001',
        name: 'Rahim Khan',
        email: 'rahim.khan@platform.com',
        phone: '+8801712345678',
        countryId: 'bd',
        joinedDate: DateTime.now().subtract(const Duration(days: 180)),
        status: ManagerStatus.active,
        totalAgencies: 45,
        activeAgencies: 38,
        pendingAgencies: 5,
        totalHosts: 320,
        activeHosts: 280,
        totalCommission: 125000,
        monthlyTarget: 500000,
        achievedTarget: 425000,
        monthlyEarnings: 425000,
        agencyGrowthRate: 12.5,
        hostGrowthRate: 18.3,
        revenueGrowthRate: 15.2,
        resolvedIssues: 28,
        pendingIssues: 5,
      );

      _recentAgencies = _generateSampleAgencies();
      _recentIssues = _generateSampleIssues();
      _pendingRequests = _generateSampleRequests();
      _topHosts = _generateSampleHosts();
      
      _isLoading = false;
    });
  }

  List<ManagerAgency> _generateSampleAgencies() {
    return List.generate(5, (int index) {
      return ManagerAgency(
        id: 'ag_00$index',
        name: 'Agency ${index + 1}',
        ownerName: 'Owner ${index + 1}',
        email: 'agency$index@example.com',
        phone: '017xxxxxx',
        address: 'Dhaka, Bangladesh',
        registrationDate: DateTime.now().subtract(Duration(days: 30 * (index + 1))),
        status: AgencyStatus.active,
        isVerified: true,
        totalHosts: 10 + index * 5,
        activeHosts: 8 + index * 4,
        monthlyEarnings: 50000 + index * 10000,
        totalEarnings: 500000 + index * 100000,
        commissionRate: 10 + index,
        lastContact: DateTime.now().subtract(Duration(days: index)),
        totalIssues: 3 - index,
        resolvedIssues: 2 - index,
        monthlyGrowth: 5 + index * 2,
        topHosts: <String>[],
        stats: ManagerAgencyStats(
          newHostsThisMonth: 2 + index,
          lostHostsThisMonth: 1,
          revenueThisMonth: 50000 + index * 10000,
          revenueLastMonth: 45000 + index * 9000,
          growthRate: 10 + index * 2,
          monthlyData: <dynamic>[],
        ),
      );
    });
  }

  List<ManagerIssue> _generateSampleIssues() {
    return <>[
      ManagerIssue(
        id: 'iss_001',
        agencyId: 'ag_001',
        agencyName: 'Elite Agency',
        reportedBy: 'Host Rahman',
        reportedById: 'host_001',
        title: 'Commission Payment Delay',
        description: "Last month's commission not received yet",
        priority: IssuePriority.high,
        status: IssueStatus.open,
        reportedDate: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ManagerIssue(
        id: 'iss_002',
        agencyId: 'ag_002',
        agencyName: 'Star Makers',
        reportedBy: 'Agency Owner',
        reportedById: 'agency_002',
        title: 'Withdrawal Issue',
        description: 'Withdrawal pending for 5 days',
        priority: IssuePriority.medium,
        status: IssueStatus.inProgress,
        reportedDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ManagerIssue(
        id: 'iss_003',
        agencyId: 'ag_003',
        agencyName: 'Pro Talent',
        reportedBy: 'Host Shilpi',
        reportedById: 'host_003',
        title: 'Account Suspension',
        description: 'Host account suspended without reason',
        priority: IssuePriority.critical,
        status: IssueStatus.open,
        reportedDate: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }

  List<AgencyRecruitmentRequest> _generateSampleRequests() {
    return <>[
      AgencyRecruitmentRequest(
        id: 'req_001',
        agencyName: 'New Talent Agency',
        ownerName: 'Karim Ahmed',
        email: 'karim@newtalent.com',
        phone: '01712345678',
        address: 'Chittagong',
        licenseNumber: 'LIC12345',
        businessPlan: 'We will recruit 50 hosts in first month...',
        proposedHosts: 50,
        expectedInvestment: 500000,
        requestDate: DateTime.now().subtract(const Duration(days: 1)),
        status: AgencyRequestStatus.pending,
      ),
      AgencyRecruitmentRequest(
        id: 'req_002',
        agencyName: 'Digital Stars',
        ownerName: 'Rina Begum',
        email: 'rina@digitalstars.com',
        phone: '01812345678',
        address: 'Sylhet',
        licenseNumber: 'LIC67890',
        businessPlan: 'Focus on female hosts and family content...',
        proposedHosts: 30,
        expectedInvestment: 300000,
        requestDate: DateTime.now().subtract(const Duration(days: 2)),
        status: AgencyRequestStatus.pending,
      ),
    ];
  }

  List<HostPerformance> _generateSampleHosts() {
    return List.generate(5, (int index) {
      return HostPerformance(
        hostId: 'host_00$index',
        name: 'Host ${index + 1}',
        username: 'host_${index + 1}',
        agencyId: 'ag_001',
        agencyName: 'Elite Agency',
        followers: 5000 + (index * 2000),
        followersGrowth: 10 + index * 2,
        monthlyEarnings: 15000 + (index * 5000),
        totalEarnings: 150000 + (index * 50000),
        totalRooms: 50 + index * 10,
        totalHours: 200 + index * 40,
        avgRating: 4.5 + (index * 0.1),
        giftsReceived: 1000 + index * 200,
        recentEvents: <dynamic>[],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: _isLoading
              ? _buildLoadingState()
              : _buildDashboard(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentPurple),
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
                _buildStatsGrid(),
                const SizedBox(height: 20),
                _buildTargetProgress(),
                const SizedBox(height: 20),
                _buildQuickActions(),
                const SizedBox(height: 20),
                _buildPendingRequests(),
                const SizedBox(height: 20),
                _buildRecentIssues(),
                const SizedBox(height: 20),
                _buildTopHosts(),
                const SizedBox(height: 20),
                _buildRecentAgencies(),
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
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.accentPurple,
            child: Text(
              _manager?.name[0] ?? 'M',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  'Welcome, ${_manager?.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _manager?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Stack(
            children: <>[
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {},
              ),
              if (_manager?.pendingIssues != null && _manager!.pendingIssues > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_manager!.pendingIssues}',
                      style: const TextStyle(color: Colors.white, fontSize: 8),
                    ),
                  ),
                ),
            ],
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
            AppColors.accentPurple.withOpacity(0.3),
            AppColors.accentBlue.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: <>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  'Country: ${_manager?.countryId.toUpperCase()}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  'Monthly Target: ৳${_manager?.monthlyTarget}',
                  style: const TextStyle(color: Colors.white70),
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
                  'Active',
                  style: TextStyle(color: Colors.green),
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
        _buildStatCard(
          'Total Agencies',
          '${_manager?.totalAgencies ?? 0}',
          Icons.business,
          Colors.purple,
        ),
        _buildStatCard(
          'Active Agencies',
          '${_manager?.activeAgencies ?? 0}',
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Total Hosts',
          '${_manager?.totalHosts ?? 0}',
          Icons.people,
          Colors.blue,
        ),
        _buildStatCard(
          'Active Hosts',
          '${_manager?.activeHosts ?? 0}',
          Icons.person,
          Colors.orange,
        ),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <>[
          Icon(icon, color: color),
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

  Widget _buildTargetProgress() {
    final double progress = _manager?.targetProgress ?? 0;
    
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
            'Monthly Target Progress',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <>[
              Text(
                'Achieved: ৳${_manager?.achievedTarget}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                'Target: ৳${_manager?.monthlyTarget}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${progress.toStringAsFixed(1)}% Complete',
            style: TextStyle(
              color: progress >= 100 ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
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
        Row(
          children: <>[
            Expanded(
              child: _buildActionButton(
                'Manage\nAgencies',
                Icons.business,
                Colors.purple,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ManageAgenciesScreen(managerId: widget.managerId),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                'Recruit\nAgency',
                Icons.person_add,
                Colors.green,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecruitAgencyScreen(managerId: widget.managerId),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                'Monitor\nHosts',
                Icons.visibility,
                Colors.blue,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MonitorHostsScreen(managerId: widget.managerId),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                'Solve\nIssues',
                Icons.help,
                Colors.orange,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SolveIssuesScreen(managerId: widget.managerId),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: <>[
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRequests() {
    if (_pendingRequests.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <>[
            const Text(
              'Pending Agency Requests',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._pendingRequests.map(_buildRequestTile),
      ],
    );
  }

  Widget _buildRequestTile(AgencyRecruitmentRequest req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        children: <>[
          Row(
            children: <>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.business, color: Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <>[
                    Text(
                      req.agencyName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      req.ownerName,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${req.proposedHosts} hosts',
                  style: const TextStyle(color: Colors.orange, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <>[
              _buildRequestAction('Approve', Colors.green, () {}),
              _buildRequestAction('Reject', Colors.red, () {}),
              _buildRequestAction('Review', Colors.blue, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestAction(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildRecentIssues() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <>[
            const Text(
              'Recent Issues',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._recentIssues.map(_buildIssueTile),
      ],
    );
  }

  Widget _buildIssueTile(ManagerIssue issue) {
    Color priorityColor;
    switch (issue.priority) {
      case IssuePriority.low:
        priorityColor = Colors.green;
      case IssuePriority.medium:
        priorityColor = Colors.orange;
      case IssuePriority.high:
        priorityColor = Colors.red;
      case IssuePriority.critical:
        priorityColor = Colors.purple;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.warning, color: priorityColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  issue.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  issue.agencyName,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: issue.status == IssueStatus.open
                  ? Colors.red.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              issue.status.toString().split('.').last,
              style: TextStyle(
                color: issue.status == IssueStatus.open ? Colors.red : Colors.orange,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHosts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <>[
        const Text(
          'Top Performing Hosts',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _topHosts.length,
            itemBuilder: (context, index) {
              final host = _topHosts[index];
              return _buildHostCard(host);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHostCard(HostPerformance host) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <>[
          Row(
            children: <>[
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.blue,
                child: Text(
                  host.name[0],
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  host.name,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${host.followers} followers',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          Text(
            '৳${host.monthlyEarnings}',
            style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAgencies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <>[
        const Text(
          'Recent Agencies',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._recentAgencies.map(_buildAgencyTile),
      ],
    );
  }

  Widget _buildAgencyTile(ManagerAgency agency) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.business, color: Colors.purple, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  agency.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${agency.activeHosts}/${agency.totalHosts} active hosts',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '৳${agency.monthlyEarnings}',
            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}