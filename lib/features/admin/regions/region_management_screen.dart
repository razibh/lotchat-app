import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/neumorphic_button.dart';
import '../../../core/widgets/neumorphic_text_field.dart';

class RegionManagementScreen extends StatefulWidget {
  const RegionManagementScreen({super.key});

  @override
  State<RegionManagementScreen> createState() => _RegionManagementScreenState();
}

class _RegionManagementScreenState extends State<RegionManagementScreen> {
  List<Region> _regions = <Region>[];

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  void _loadRegions() {
    _regions = <Region>[
      Region(
        id: 'reg1',
        name: 'South Asia',
        countries: <String>['Bangladesh', 'India', 'Pakistan', 'Nepal', 'Sri Lanka'],
        totalAgencies: 203,
        totalHosts: 1560,
        totalRevenue: 1860000,
        manager: 'Rahim Khan',
        status: 'Active',
      ),
      Region(
        id: 'reg2',
        name: 'Southeast Asia',
        countries: <String>['Indonesia', 'Malaysia', 'Thailand', 'Vietnam', 'Philippines'],
        totalAgencies: 145,
        totalHosts: 980,
        totalRevenue: 1250000,
        manager: 'Sarah Chen',
        status: 'Active',
      ),
      Region(
        id: 'reg3',
        name: 'Middle East',
        countries: <String>['UAE', 'Saudi Arabia', 'Qatar', 'Kuwait', 'Bahrain'],
        totalAgencies: 89,
        totalHosts: 450,
        totalRevenue: 890000,
        manager: 'Ahmed Hassan',
        status: 'Pending',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: <>[
              _buildHeader(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _regions.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Region region = _regions[index];
                    return _buildRegionCard(region);
                  },
                ),
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
        children: <>[
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Region Management',
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

  Widget _buildRegionCard(Region region) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <>[
          Row(
            children: <>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.public, color: Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <>[
                    Text(
                      region.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Manager: ${region.manager}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: region.status == 'Active' 
                      ? Colors.green.withValues(alpha: 0.2) 
                      : Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  region.status,
                  style: TextStyle(
                    color: region.status == 'Active' ? Colors.green : Colors.orange,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: region.countries.map((String country) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  country,
                  style: const TextStyle(color: Colors.blue, fontSize: 10),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <>[
              _buildStatItem('Agencies', '${region.totalAgencies}'),
              _buildStatItem('Hosts', '${region.totalHosts}'),
              _buildStatItem('Revenue', '৳${region.totalRevenue}'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: <>[
              Expanded(
                child: _buildActionButton('Edit', Colors.blue, () {}),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton('View Details', Colors.purple, () {}),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: <>[
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
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.5)),
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
        onPressed: _showAddRegionDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <>[
                Icon(Icons.add, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'ADD NEW REGION',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddRegionDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController managerController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Add New Region', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            NeumorphicTextField(
              controller: nameController,
              hintText: 'Region Name',
            ),
            const SizedBox(height: 12),
            NeumorphicTextField(
              controller: managerController,
              hintText: 'Region Manager',
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Region added successfully')),
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

class Region {

  Region({
    required this.id,
    required this.name,
    required this.countries,
    required this.totalAgencies,
    required this.totalHosts,
    required this.totalRevenue,
    required this.manager,
    required this.status,
  });
  final String id;
  final String name;
  final List<String> countries;
  final int totalAgencies;
  final int totalHosts;
  final double totalRevenue;
  final String manager;
  final String status;
}