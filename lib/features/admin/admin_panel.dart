import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_model.dart';
import '../../core/models/gift_model.dart';
import '../../core/services/admin_service.dart';
import '../../core/services/agency_service.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AdminService _adminService = AdminService();
  final AgencyService _agencyService = AgencyService();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: <>[
            Tab(text: 'Dashboard'),
            Tab(text: 'Users'),
            Tab(text: 'Agencies'),
            Tab(text: 'Sellers'),
            Tab(text: 'Gifts'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <>[
          _buildDashboard(),
          _buildUserManagement(),
          _buildAgencyManagement(),
          _buildSellerManagement(),
          _buildGiftManagement(),
          _buildReports(),
        ],
      ),
    );
  }
  
  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <>[
          Text(
            'Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: <>[
              _buildStatCard('Total Users', '1.2M', Icons.people, Colors.blue),
              _buildStatCard('Active Now', '45K', Icons.online_prediction, Colors.green),
              _buildStatCard('Total Revenue', r'$2.5M', Icons.attach_money, Colors.orange),
              _buildStatCard('Total Gifts', '500+', Icons.card_giftcard, Colors.purple),
            ],
          ),
          SizedBox(height: 24),
          Text(
            'Recent Activity',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text('User ${index + 1} purchased 1000 coins'),
                subtitle: Text('2 minutes ago'),
                trailing: Text(r'$10'),
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
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <>[
            Icon(icon, color: color, size: 30),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(title, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUserManagement() {
    return Column(
      children: <>[
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: <>[
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search user by ID or name...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: _showAddUserDialog,
                child: Text('Add User'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 20,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  child: Text('U${index + 1}'),
                ),
                title: Text('User ${index + 1}'),
                subtitle: Text('ID: ${1000 + index} • Coins: 5000'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <>[
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditUserDialog(index),
                    ),
                    IconButton(
                      icon: Icon(Icons.block, color: Colors.red),
                      onPressed: () => _banUser(index),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_card, color: Colors.green),
                      onPressed: () => _showAddCoinsDialog(index),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildAgencyManagement() {
    return Column(
      children: <>[
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <>[
              Text(
                'Agencies',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: _showAddAgencyDialog,
                child: Text('Add Agency'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    child: Text('A${index + 1}'),
                  ),
                  title: Text('Agency ${index + 1}'),
                  subtitle: Text('Members: ${(index + 1) * 10} • Revenue: \$${(index + 1) * 1000}'),
                  children: <>[
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: <>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <>[
                              _buildAgencyAction('Add User', Icons.person_add, () {}),
                              _buildAgencyAction('Remove User', Icons.person_remove, () {}),
                              _buildAgencyAction('View Earnings', Icons.trending_up, () {}),
                              _buildAgencyAction('Settings', Icons.settings, () {}),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text('Top Performers'),
                          SizedBox(height: 8),
                          Container(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 5,
                              itemBuilder: (context, i) {
                                return Container(
                                  width: 80,
                                  margin: EdgeInsets.only(right: 8),
                                  child: Column(
                                    children: <>[
                                      CircleAvatar(
                                        radius: 25,
                                        child: Text('U${i + 1}'),
                                      ),
                                      Text('User ${i + 1}'),
                                      Text('\$${(i + 1) * 100}', style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildAgencyAction(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <>[
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.purple),
          ),
          SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
  
  Widget _buildSellerManagement() {
    return Column(
      children: <>[
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <>[
              Text(
                'Coin Sellers',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: _showAddSellerDialog,
                child: Text('Add Seller'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('S${index + 1}'),
                  ),
                  title: Text('Seller ${index + 1}'),
                  subtitle: Text('Coins Sold: ${(index + 1) * 5000} • Commission: ${(index + 1) * 5}%'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <>[
                      IconButton(
                        icon: Icon(Icons.monetization_on, color: Colors.green),
                        onPressed: () => _showSellerCoinDialog(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildGiftManagement() {
    return Column(
      children: <>[
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <>[
              Text(
                'Gift Management',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: _showAddGiftDialog,
                child: Text('Add New Gift'),
              ),
            ],
          ),
        ),
        Expanded(
          child: DefaultTabController(
            length: 4,
            child: Column(
              children: <>[
                TabBar(
                  tabs: <>[
                    Tab(text: 'All Gifts'),
                    Tab(text: 'VIP'),
                    Tab(text: 'SVIP'),
                    Tab(text: 'Effects'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: <>[
                      _buildGiftList('all'),
                      _buildGiftList('vip'),
                      _buildGiftList('svip'),
                      _buildGiftList('effects'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildGiftList(String type) {
    final List<GiftModel> gifts = GiftModel.getGifts();
    
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          child: Column(
            children: <>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: Icon(Icons.card_giftcard, size: 50),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: <>[
                    Text('Gift ${index + 1}'),
                    Text('100 coins', style: TextStyle(fontSize: 12)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <>[
                        IconButton(
                          icon: Icon(Icons.edit, size: 16),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, size: 16),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.music_note, size: 16),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildReports() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: <>[
        Text(
          'User Reports',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        ...List.generate(5, (int index) {
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: CircleAvatar(
                child: Icon(Icons.warning, color: Colors.red),
              ),
              title: Text('Report #${index + 1}'),
              subtitle: Text('User ${index + 1} reported by User ${index + 2}'),
              children: <>[
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <>[
                      Text('Reason: Inappropriate behavior'),
                      Text('Evidence: Screen recording available'),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <>[
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: Text('Ignore'),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Text('Ban User'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
  
  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <>[
              TextField(
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Phone'),
              ),
              DropdownButtonFormField(
                value: 'user',
                items: <String>['user', 'seller', 'agency', 'admin'].map((String role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {},
                decoration: InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
          actions: <>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add user logic
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
  
  void _showAddCoinsDialog(int userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Coins'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <>[
              Text('User ID: $userId'),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter coin amount',
                ),
              ),
              SizedBox(height: 16),
              Text('1$ = 10000 coins'),
            ],
          ),
          actions: <>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add coins logic
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
  
  void _showAddAgencyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Agency'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <>[
              TextField(
                decoration: InputDecoration(labelText: 'Agency Name'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Owner Name'),
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Commission %'),
              ),
            ],
          ),
          actions: <>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add agency logic
                Navigator.pop(context);
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }
  
  void _showAddSellerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Coin Seller'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <>[
              TextField(
                decoration: InputDecoration(labelText: 'Seller Name'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Commission %'),
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Initial Coin Balance',
                ),
              ),
            ],
          ),
          actions: <>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add seller logic
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
  
  void _showAddGiftDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Gift'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <>[
                TextField(
                  decoration: InputDecoration(labelText: 'Gift Name'),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Price (coins)'),
                ),
                DropdownButtonFormField(
                  value: 'Cute',
                  items: <String>['Cute', 'Luxury', 'VIP', 'SVIP', 'Special'].map((String cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (value) {},
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Animation File'),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Sound File'),
                ),
                SwitchListTile(
                  title: Text('VIP Gift'),
                  value: false,
                  onChanged: (value) {},
                ),
                SwitchListTile(
                  title: Text('SVIP Gift'),
                  value: false,
                  onChanged: (value) {},
                ),
              ],
            ),
          ),
          actions: <>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add gift logic
                Navigator.pop(context);
              },
              child: Text('Add Gift'),
            ),
          ],
        );
      },
    );
  }
  
  void _showEditUserDialog(int userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <>[
              TextField(
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Bio'),
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Coins'),
              ),
              DropdownButtonFormField(
                value: UserTier.normal,
                items: UserTier.values.map((UserTier tier) {
                  return DropdownMenuItem(
                    value: tier,
                    child: Text(tier.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {},
                decoration: InputDecoration(labelText: 'Tier'),
              ),
            ],
          ),
          actions: <>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Edit user logic
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
  
  void _showSellerCoinDialog(int sellerId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Coins to Seller'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <>[
              Text('Seller ID: $sellerId'),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Coin Amount',
                ),
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: r'Price ($)',
                ),
              ),
            ],
          ),
          actions: <>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add coins to seller
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
  
  void _banUser(int userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ban User'),
          content: Text('Are you sure you want to ban User #$userId?'),
          actions: <>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Ban user logic
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User banned successfully')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Ban'),
            ),
          ],
        );
      },
    );
  }
}