import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/neumorphic_button.dart';
import '../../../core/widgets/neumorphic_text_field.dart';

class AgencyManageHostsScreen extends StatefulWidget {

  const AgencyManageHostsScreen({Key? key, required this.agencyId}) : super(key: key);
  final String agencyId;

  @override
  State<AgencyManageHostsScreen> createState() => _AgencyManageHostsScreenState();
}

class _AgencyManageHostsScreenState extends State<AgencyManageHostsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _searchQuery = '';
  
  List<AgencyHostModel> _hosts = <AgencyHostModel>[];
  List<AgencyHostModel> _filteredHosts = <AgencyHostModel>[];
  List<AgencyHostModel> _pendingHosts = <AgencyHostModel>[];
  List<AgencyHostModel> _topHosts = <AgencyHostModel>[];
  List<AgencyHostModel> _inactiveHosts = <AgencyHostModel>[];

  // Summary Stats
  int _totalHosts = 0;
  int _activeHosts = 0;
  double _totalEarnings = 0;
  double _totalCommission = 0;
  double _averageRating = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadHosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHosts() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    // Sample data generation
    _hosts = _generateSampleHosts(30);
    _calculateStats();
    _filterHostsByTab();
    
    setState(() => _isLoading = false);
  }

  List<AgencyHostModel> _generateSampleHosts(int count) {
    final var hosts = <AgencyHostModel><AgencyHostModel>[];
    for (var i = 0; i < count; i++) {
      String status;
      if (i < 5) {
        status = 'Pending';
      } else if (i < 8) status = 'Inactive';
      else status = 'Active';

      final var monthlyEarnings = 5000 + (i * 1000);
      var commissionRate = 8 + (i % 8);
      
      hosts.add(AgencyHostModel(
        id: 'host_${100 + i}',
        name: 'Host ${i + 1}',
        username: 'host_${i + 1}',
        email: 'host${i + 1}@example.com',
        phone: '0171${100000 + i}',
        joinDate: DateTime.now().subtract(Duration(days: 30 * (i % 12))),
        status: status,
        totalEarnings: monthlyEarnings * (i % 6 + 1),
        monthlyEarnings: monthlyEarnings,
        weeklyEarnings: monthlyEarnings / 4,
        todayEarnings: monthlyEarnings / 30,
        followers: 500 + (i * 100),
        totalRooms: 20 + i,
        totalHours: 100 + (i * 10),
        rating: 4.0 + (i % 10) / 10,
        commissionRate: commissionRate,
        agencyShare: monthlyEarnings * commissionRate / 100,
        totalGifts: 100 + (i * 20),
        peakViewers: 300 + (i * 50),
        avgViewers: 150 + (i * 20),
        lastActive: i % 3 == 0 ? DateTime.now().subtract(Duration(days: i)) : DateTime.now(),
        bio: 'Professional host specializing in ${i % 2 == 0 ? 'music' : 'gaming'}',
        specialties: i % 2 == 0 ? <String>['Singing', 'Music'] : <String>['Gaming', 'Entertainment'],
      ));
    }
    return hosts;
  }

  void _calculateStats() {
    _totalHosts = _hosts.length;
    _activeHosts = _hosts.where((AgencyHostModel h) => h.status == 'Active').length;
    _totalEarnings = _hosts.fold(0, (double sum, AgencyHostModel h) => sum + h.monthlyEarnings);
    _totalCommission = _hosts.fold(0, (double sum, AgencyHostModel h) => sum + h.agencyShare);
    _averageRating = _hosts.fold(0, (double sum, AgencyHostModel h) => sum + h.rating) / _hosts.length;
  }

  void _filterHostsByTab() {
    setState(() {
      _pendingHosts = _hosts.where((AgencyHostModel h) => h.status == 'Pending').toList();
      _topHosts = _hosts.where((AgencyHostModel h) => h.monthlyEarnings > 20000).toList();
      _inactiveHosts = _hosts.where((AgencyHostModel h) => h.status == 'Inactive').toList();
      
      if (_tabController.index == 0) {
        _filteredHosts = _hosts.where((AgencyHostModel h) => h.status == 'Active').toList();
      } else if (_tabController.index == 1) {
        _filteredHosts = _pendingHosts;
      } else if (_tabController.index == 2) {
        _filteredHosts = _topHosts;
      } else {
        _filteredHosts = _inactiveHosts;
      }
    });
  }

  void _filterHosts(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filterHostsByTab();
      } else {
        _filteredHosts = _filteredHosts.where((AgencyHostModel host) =>
          host.name.toLowerCase().contains(query.toLowerCase()) ||
          host.username.toLowerCase().contains(query.toLowerCase()) ||
          host.email.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: <>[
              _buildHeader(),
              _buildSummaryCards(),
              _buildSearchBar(),
              _buildTabBar(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildHostsList(),
              ),
              _buildFloatingButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <>[
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Manage Hosts',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_totalHosts Total',
              style: const TextStyle(color: Colors.purple, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: <>[
          Expanded(
            child: _buildSummaryCard(
              'Active',
              '$_activeHosts',
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'Pending',
              '${_pendingHosts.length}',
              Icons.hourglass_empty,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'Earnings',
              '৳${_totalEarnings.toStringAsFixed(0)}',
              Icons.money,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'Commission',
              '৳${_totalCommission.toStringAsFixed(0)}',
              Icons.percent,
              Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: <>[
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        onChanged: _filterHosts,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search hosts by name, username or email...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          border: InputBorder.none,
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    _filterHosts('');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          _filterHostsByTab();
        },
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.purple,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const <>[
          Tab(text: 'Active'),
          Tab(text: 'Pending'),
          Tab(text: 'Top'),
          Tab(text: 'Inactive'),
        ],
      ),
    );
  }

  Widget _buildHostsList() {
    if (_filteredHosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <>[
            Icon(
              _tabController.index == 1 ? Icons.hourglass_empty :
              _tabController.index == 3 ? Icons.pause_circle :
              Icons.person_off,
              size: 60,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No hosts match "$_searchQuery"'
                  : _tabController.index == 1
                      ? 'No pending requests'
                      : _tabController.index == 3
                          ? 'No inactive hosts'
                          : 'No hosts found',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _filteredHosts.length,
      itemBuilder: (context, index) {
        final AgencyHostModel host = _filteredHosts[index];
        return _buildHostCard(host);
      },
    );
  }

  Widget _buildHostCard(AgencyHostModel host) {
    Color statusColor;
    switch (host.status) {
      case 'Active':
        statusColor = Colors.green;
      case 'Pending':
        statusColor = Colors.orange;
      case 'Inactive':
        statusColor = Colors.red;
      default:
        statusColor = Colors.grey;
    }

    final var isOnline = host.lastActive.difference(DateTime.now()).inMinutes < 5;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: host.status == 'Pending'
            ? Border.all(color: Colors.orange.withOpacity(0.5))
            : host.status == 'Active'
                ? Border.all(color: Colors.green.withOpacity(0.3))
                : null,
      ),
      child: Column(
        children: <>[
          Row(
            children: <>[
              Stack(
                children: <>[
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.purple,
                    child: Text(
                      host.name[0],
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  if (isOnline)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <>[
                    Row(
                      children: <>[
                        Expanded(
                          child: Text(
                            host.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            host.status,
                            style: TextStyle(color: statusColor, fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '@${host.username}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <>[
              _buildHostStat(Icons.money, '৳${host.monthlyEarnings}', 'Monthly'),
              _buildHostStat(Icons.people, '${host.followers}', 'Followers'),
              _buildHostStat(Icons.star, '${host.rating}', 'Rating'),
              _buildHostStat(Icons.percent, '${host.commissionRate}%', 'Comm'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: <>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <>[
                      Text(
                        'Agency Share: ৳${host.agencyShare}',
                        style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Total: ৳${host.totalEarnings}',
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${host.totalRooms} rooms',
                    style: const TextStyle(color: Colors.blue, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <>[
              Expanded(
                child: _buildActionButton('Details', Colors.blue, () {
                  _showHostDetails(host);
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton('Commission', Colors.purple, () {
                  _showCommissionDialog(host);
                }),
              ),
              const SizedBox(width: 8),
              if (host.status == 'Pending')
                Expanded(
                  child: _buildActionButton('Approve', Colors.green, () {
                    _approveHost(host);
                  }),
                )
              else if (host.status == 'Active')
                Expanded(
                  child: _buildActionButton('Suspend', Colors.red, () {
                    _suspendHost(host);
                  }),
                )
              else
                Expanded(
                  child: _buildActionButton('Activate', Colors.green, () {
                    _activateHost(host);
                  }),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHostStat(IconData icon, String value, String label) {
    return Column(
      children: <>[
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 8),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButton() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: NeumorphicButton(
        onPressed: _showRecruitHostDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <>[
                Icon(Icons.person_add, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'RECRUIT NEW HOST',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRecruitHostDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final commissionController = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Recruit New Host', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <>[
              NeumorphicTextField(
                controller: nameController,
                hintText: 'Full Name',
              ),
              const SizedBox(height: 12),
              NeumorphicTextField(
                controller: emailController,
                hintText: 'Email',
              ),
              const SizedBox(height: 12),
              NeumorphicTextField(
                controller: phoneController,
                hintText: 'Phone',
              ),
              const SizedBox(height: 12),
              NeumorphicTextField(
                controller: commissionController,
                hintText: 'Commission Rate (%)',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: <>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recruitment request sent')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }

  void _showCommissionDialog(AgencyHostModel host) {
    final commissionController = TextEditingController(text: host.commissionRate.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Update Commission', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            Text(
              'Current Rate: ${host.commissionRate}%',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            NeumorphicTextField(
              controller: commissionController,
              hintText: 'New Commission Rate',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            Text(
              'New Agency Share: ৳${(host.monthlyEarnings * double.parse(commissionController.text) / 100).toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.green, fontSize: 12),
            ),
          ],
        ),
        actions: <>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                host.commissionRate = double.parse(commissionController.text);
                host.agencyShare = host.monthlyEarnings * host.commissionRate / 100;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Commission updated for ${host.name}')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showHostDetails(AgencyHostModel host) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surfaceDark,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <>[
              const Text(
                'Host Details',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.purple,
                child: Text(
                  host.name[0],
                  style: const TextStyle(color: Colors.white, fontSize: 30),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                host.name,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '@${host.username}',
                style: const TextStyle(color: Colors.white70),
              ),
              if (host.bio != null) ...<>[
                const SizedBox(height: 8),
                Text(
                  host.bio!,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                children: <>[
                  _buildDetailItem('Email', host.email),
                  _buildDetailItem('Phone', host.phone),
                  _buildDetailItem('Joined', '${host.joinDate.day}/${host.joinDate.month}/${host.joinDate.year}'),
                  _buildDetailItem('Status', host.status),
                  _buildDetailItem('Total', '৳${host.totalEarnings}'),
                  _buildDetailItem('Monthly', '৳${host.monthlyEarnings}'),
                  _buildDetailItem('Commission', '${host.commissionRate}%'),
                  _buildDetailItem('Agency Share', '৳${host.agencyShare}'),
                  _buildDetailItem('Followers', '${host.followers}'),
                  _buildDetailItem('Rooms', '${host.totalRooms}'),
                  _buildDetailItem('Hours', '${host.totalHours}'),
                  _buildDetailItem('Rating', '${host.rating} ⭐'),
                ],
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: <>[
          Text('$label:', style: const TextStyle(color: Colors.white70, fontSize: 10)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _approveHost(AgencyHostModel host) {
    setState(() {
      host.status = 'Active';
      _filterHostsByTab();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${host.name} approved')),
    );
  }

  void _suspendHost(AgencyHostModel host) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Suspend Host', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to suspend ${host.name}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: <>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                host.status = 'Inactive';
                _filterHostsByTab();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${host.name} suspended')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  void _activateHost(AgencyHostModel host) {
    setState(() {
      host.status = 'Active';
      _filterHostsByTab();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${host.name} activated')),
    );
  }
}

class AgencyHostModel {

  AgencyHostModel({
    required this.id,
    required this.name,
    required this.username,
    this.avatar,
    required this.email,
    required this.phone,
    required this.joinDate,
    required this.status,
    required this.totalEarnings,
    required this.monthlyEarnings,
    required this.weeklyEarnings,
    required this.todayEarnings,
    required this.followers,
    required this.totalRooms,
    required this.totalHours,
    required this.rating,
    required this.commissionRate,
    required this.agencyShare,
    required this.totalGifts,
    required this.peakViewers,
    required this.avgViewers,
    required this.lastActive,
    this.bio,
    this.specialties = const [],
  });
  final String id;
  final String name;
  final String username;
  final String? avatar;
  final String email;
  final String phone;
  final DateTime joinDate;
  String status;
  double totalEarnings;
  double monthlyEarnings;
  double weeklyEarnings;
  double todayEarnings;
  int followers;
  int totalRooms;
  int totalHours;
  double rating;
  double commissionRate;
  double agencyShare;
  int totalGifts;
  int peakViewers;
  int avgViewers;
  DateTime lastActive;
  String? bio;
  List<String> specialties;
}