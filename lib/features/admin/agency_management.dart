import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/admin_service.dart';
import '../../core/models/agency_model.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/dialog_mixin.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class AgencyManagement extends StatefulWidget {
  const AgencyManagement({super.key});

  @override
  State<AgencyManagement> createState() => _AgencyManagementState();
}

class _AgencyManagementState extends State<AgencyManagement>
    with LoadingMixin, ToastMixin, DialogMixin {

  final AdminService _adminService = ServiceLocator().get<AdminService>();
  final TextEditingController _searchController = TextEditingController();

  List<AgencyModel> _agencies = [];
  List<AgencyModel> _filteredAgencies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAgencies();
  }

  Future<void> _loadAgencies() async {
    await runWithLoading(() async {
      try {
        // মক ডাটা লোড করুন
        _agencies = _getMockAgencies();
        _filteredAgencies = _agencies;
      } catch (e) {
        showError('Failed to load agencies: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  // মক ডাটা তৈরি করুন (পরবর্তীতে API কল করবেন)
  List<AgencyModel> _getMockAgencies() {
    return [
      AgencyModel(
        id: 'ag_001',
        name: 'Elite Talent Hub',
        ownerId: 'user_123',
        ownerName: 'Karim Ahmed',
        memberIds: ['user_124', 'user_125', 'user_126'],
        memberEarnings: {
          'user_124': 5000,
          'user_125': 3000,
          'user_126': 2000,
        },
        totalEarnings: 10000,
        commissionRate: 0.1,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        status: AgencyStatus.active,
      ),
      AgencyModel(
        id: 'ag_002',
        name: 'Digital Stars',
        ownerId: 'user_456',
        ownerName: 'Rina Begum',
        memberIds: ['user_457', 'user_458'],
        memberEarnings: {
          'user_457': 4000,
          'user_458': 2500,
        },
        totalEarnings: 6500,
        commissionRate: 0.12,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        status: AgencyStatus.active,
      ),
      AgencyModel(
        id: 'ag_003',
        name: 'Pro Talents',
        ownerId: 'user_789',
        ownerName: 'Shahid Khan',
        memberIds: ['user_790', 'user_791', 'user_792', 'user_793'],
        memberEarnings: {
          'user_790': 8000,
          'user_791': 6000,
          'user_792': 4500,
          'user_793': 3000,
        },
        totalEarnings: 21500,
        commissionRate: 0.15,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        status: AgencyStatus.pending,
      ),
    ];
  }

  Future<void> _createAgency() async {
    final String? name = await showInputDialog(
      context,
      title: 'Agency Name',
      hintText: 'Enter agency name',
    );

    if (name != null && name.isNotEmpty) {
      final String? ownerId = await showInputDialog(
        context,
        title: 'Owner ID',
        hintText: 'Enter owner user ID',
      );

      if (ownerId != null && ownerId.isNotEmpty) {
        final String? ownerName = await showInputDialog(
          context,
          title: 'Owner Name',
          hintText: 'Enter owner name',
        );

        if (ownerName != null && ownerName.isNotEmpty) {
          final String? commission = await showInputDialog(
            context,
            title: 'Commission Rate',
            hintText: 'Enter commission rate (0.1 = 10%)',
          );

          if (commission != null && commission.isNotEmpty) {
            final double? rate = double.tryParse(commission);
            if (rate != null) {
              await runWithLoading(() async {
                try {
                  // এখানে API কল করবেন
                  showSuccess('Agency created successfully');
                  _loadAgencies();
                } catch (e) {
                  showError('Failed to create agency: $e');
                }
              });
            }
          }
        }
      }
    }
  }

  Future<void> _deleteAgency(AgencyModel agency) async {
    final bool? confirmed = await showConfirmDialog(
      context,
      title: 'Delete Agency',
      message: 'Are you sure you want to delete ${agency.name}?',
    );

    if (confirmed ?? false) {
      await runWithLoading(() async {
        try {
          // এখানে API কল করবেন
          showSuccess('Agency deleted successfully');
          _loadAgencies();
        } catch (e) {
          showError('Failed to delete agency: $e');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agency Management'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createAgency,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredAgencies.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.business, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No Agencies Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first agency',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Create Agency',
              onPressed: _createAgency,
              color: Colors.blue,
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _filteredAgencies.length,
        itemBuilder: (context, index) {
          final agency = _filteredAgencies[index];
          return _buildAgencyCard(agency);
        },
      ),
    );
  }

  Widget _buildAgencyCard(AgencyModel agency) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            agency.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(agency.name),
        subtitle: Text('ID: ${agency.id.substring(0, 8)}... • ${agency.memberCount} members'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(agency.status),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _getStatusText(agency.status),
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Agency Info
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow('Owner', agency.ownerName),
                    ),
                    Expanded(
                      child: _buildInfoRow('Commission', '${(agency.commissionRate * 100).toInt()}%'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow('Total Earnings', '${agency.totalEarnings} coins'),
                    ),
                    Expanded(
                      child: _buildInfoRow('Created', _formatDate(agency.createdAt)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Members List
                const Text(
                  'Members',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    itemCount: agency.memberIds.length,
                    itemBuilder: (context, index) {
                      final memberId = agency.memberIds[index];
                      final earnings = agency.getMemberEarnings(memberId);
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person, size: 20),
                        ),
                        title: Text('User ${memberId.substring(0, 8)}...'),
                        trailing: Text('$earnings coins'),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.person_add,
                        label: 'Add Member',
                        color: Colors.green,
                        onTap: () => _addMember(agency),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.edit,
                        label: 'Edit',
                        color: Colors.orange,
                        onTap: () => _editAgency(agency),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.delete,
                        label: 'Delete',
                        color: Colors.red,
                        onTap: () => _deleteAgency(agency),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AgencyStatus status) {
    switch (status) {
      case AgencyStatus.active:
        return Colors.green;
      case AgencyStatus.inactive:
        return Colors.grey;
      case AgencyStatus.pending:
        return Colors.orange;
      case AgencyStatus.suspended:
        return Colors.red;
      case AgencyStatus.verified:
        return Colors.blue;
    }
  }

  String _getStatusText(AgencyStatus status) {
    switch (status) {
      case AgencyStatus.active:
        return 'active';
      case AgencyStatus.inactive:
        return 'inactive';
      case AgencyStatus.pending:
        return 'pending';
      case AgencyStatus.suspended:
        return 'suspended';
      case AgencyStatus.verified:
        return 'verified';
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addMember(AgencyModel agency) async {
    final String? userId = await showInputDialog(
      context,
      title: 'Add Member',
      hintText: 'Enter user ID',
    );

    if (userId != null && userId.isNotEmpty) {
      showSuccess('Member added (demo)');
    }
  }

  Future<void> _editAgency(AgencyModel agency) async {
    // এডিট ডায়ালগ দেখান
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Agency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Agency Name',
                hintText: agency.name,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Commission Rate',
                hintText: '${(agency.commissionRate * 100).toInt()}%',
              ),
              keyboardType: TextInputType.number,
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
              showSuccess('Agency updated (demo)');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}