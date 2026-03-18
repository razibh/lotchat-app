import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/neumorphic_button.dart';
import '../../../core/widgets/neumorphic_text_field.dart';
import '../../../core/models/country_model.dart';  // ← ইম্পোর্ট ঠিক করা হয়েছে

class ManageCountryManagersScreen extends StatefulWidget {
  const ManageCountryManagersScreen({super.key});

  @override
  State<ManageCountryManagersScreen> createState() => _ManageCountryManagersScreenState();
}

class _ManageCountryManagersScreenState extends State<ManageCountryManagersScreen> {
  List<CountryManager> _managers = [];
  List<CountryManager> _filteredManagers = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadManagers();
  }

  void _loadManagers() {
    _managers = [
      CountryManager(
        id: 'cm1',
        name: 'Rahim Khan',
        email: 'rahim@platform.com',
        country: 'Bangladesh',
        flag: '🇧🇩',
        status: 'Active',
        agencies: 45,
        hosts: 320,
        revenue: 450000,
        joinedDate: '2024-01-15',
      ),
      CountryManager(
        id: 'cm2',
        name: 'Priya Sharma',
        email: 'priya@platform.com',
        country: 'India',
        flag: '🇮🇳',
        status: 'Active',
        agencies: 78,
        hosts: 650,
        revenue: 890000,
        joinedDate: '2023-11-20',
      ),
      CountryManager(
        id: 'cm3',
        name: 'Ali Ahmed',
        email: 'ali@platform.com',
        country: 'Pakistan',
        flag: '🇵🇰',
        status: 'Inactive',
        agencies: 52,
        hosts: 410,
        revenue: 520000,
        joinedDate: '2024-02-10',
      ),
      CountryManager(
        id: 'cm4',
        name: 'Sita Tamang',
        email: 'sita@platform.com',
        country: 'Nepal',
        flag: '🇳🇵',
        status: 'Pending',
        agencies: 0,
        hosts: 0,
        revenue: 0,
        joinedDate: '2024-03-01',
      ),
    ];
    _filteredManagers = _managers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              Expanded(
                child: _buildManagersList(),
              ),
              _buildAddButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Country Managers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _filteredManagers = _managers.where((m) =>
            m.name.toLowerCase().contains(value.toLowerCase()) ||
                m.country.toLowerCase().contains(value.toLowerCase()),
            ).toList();
          });
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search managers...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildManagersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _filteredManagers.length,
      itemBuilder: (context, index) {
        final manager = _filteredManagers[index];
        return _buildManagerCard(manager);
      },
    );
  }

  Widget _buildManagerCard(CountryManager manager) {
    Color statusColor;
    switch (manager.status) {
      case 'Active':
        statusColor = Colors.green;
        break;
      case 'Inactive':
        statusColor = Colors.red;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.purple,
                child: Text(
                  manager.name[0],
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manager.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      manager.email,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  manager.status,
                  style: TextStyle(color: statusColor, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(manager.flag, manager.country),
              _buildInfoItem('${manager.agencies}', 'Agencies'),
              _buildInfoItem('${manager.hosts}', 'Hosts'),
              _buildInfoItem('৳${manager.revenue}', 'Revenue'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton('View Details', Colors.blue, () {}),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton('Edit', Colors.orange, () {}),
              ),
              const SizedBox(width: 8),
              if (manager.status == 'Pending')
                Expanded(
                  child: _buildActionButton('Approve', Colors.green, () {
                    setState(() {
                      final index = _managers.indexWhere((m) => m.id == manager.id);
                      if (index != -1) {
                        final updatedManager = CountryManager(
                          id: manager.id,
                          name: manager.name,
                          email: manager.email,
                          country: manager.country,
                          flag: manager.flag,
                          status: 'Active',
                          agencies: manager.agencies,
                          hosts: manager.hosts,
                          revenue: manager.revenue,
                          joinedDate: manager.joinedDate,
                        );
                        _managers[index] = updatedManager;
                        _filteredManagers = List.from(_managers);
                      }
                    });
                  }),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: NeumorphicButton(
        onPressed: _showAddManagerDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'ADD NEW MANAGER',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddManagerDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String? selectedCountry;

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Add Country Manager', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: selectedCountry,
                hint: const Text('Select Country', style: TextStyle(color: Colors.white70)),
                dropdownColor: AppColors.surfaceDark,
                isExpanded: true,
                underline: const SizedBox(),
                items: CountryModel.getCountries().map((c) {
                  return DropdownMenuItem<String>(
                    value: c.code,
                    child: Text('${c.flag} ${c.name}', style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCountry = value;
                  });
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Manager added successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class CountryManager {
  final String id;
  final String name;
  final String email;
  final String country;
  final String flag;
  final String status;
  final int agencies;
  final int hosts;
  final double revenue;
  final String joinedDate;

  CountryManager({
    required this.id,
    required this.name,
    required this.email,
    required this.country,
    required this.flag,
    required this.status,
    required this.agencies,
    required this.hosts,
    required this.revenue,
    required this.joinedDate,
  });
}