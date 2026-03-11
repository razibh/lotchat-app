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
  const AgencyManagement({Key? key}) : super(key: key);

  @override
  State<AgencyManagement> createState() => _AgencyManagementState();
}

class _AgencyManagementState extends State<AgencyManagement> 
    with LoadingMixin, ToastMixin, DialogMixin {
  
  final _adminService = ServiceLocator().get<AdminService>();
  final _searchController = TextEditingController();
  
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
        // Load agencies from service
        _agencies = [];
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

  Future<void> _createAgency() async {
    final name = await showInputDialog(
      context,
      title: 'Agency Name',
      hintText: 'Enter agency name',
    );

    if (name != null && name.isNotEmpty) {
      final ownerId = await showInputDialog(
        context,
        title: 'Owner ID',
        hintText: 'Enter owner user ID',
      );

      if (ownerId != null && ownerId.isNotEmpty) {
        final commission = await showInputDialog(
          context,
          title: 'Commission Rate',
          hintText: 'Enter commission rate (0.1 = 10%)',
        );

        if (commission != null && commission.isNotEmpty) {
          final rate = double.tryParse(commission);
          if (rate != null) {
            await runWithLoading(() async {
              try {
                await _adminService.createAgency(
                  name: name,
                  ownerId: ownerId,
                  commissionRate: rate,
                );
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

  Future<void> _deleteAgency(AgencyModel agency) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Agency',
      message: 'Are you sure you want to delete ${agency.name}?',
    );

    if (confirmed == true) {
      await runWithLoading(() async {
        try {
          await _adminService.deleteAgency(agency.id);
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
        subtitle: Text('ID: ${agency.id.substring(0, 8)}... • ${agency.members.length} members'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: agency.status == 'active' ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            agency.status,
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
                      child: _buildInfoRow('Owner', agency.ownerId),
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
                      child: _buildInfoRow('Total Earnings', '${agency.totalEarnings}'),
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
                Container(
                  height: 150,
                  child: ListView.builder(
                    itemCount: agency.members.length,
                    itemBuilder: (context, index) {
                      final memberId = agency.members[index];
                      final earnings = agency.memberEarnings[memberId] ?? 0;
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
                        icon: Icons.star,
                        label: 'Co-Owners',
                        color: Colors.orange,
                        onTap: () => _manageCoOwners(agency),
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

  void _addMember(AgencyModel agency) async {
    final userId = await showInputDialog(
      context,
      title: 'Add Member',
      hintText: 'Enter user ID',
    );

    if (userId != null && userId.isNotEmpty) {
      showSuccess('Member added (demo)');
    }
  }

  void _manageCoOwners(AgencyModel agency) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Co-Owners'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: agency.coOwners.length + 1,
            itemBuilder: (context, index) {
              if (index == agency.coOwners.length) {
                return ListTile(
                  leading: const Icon(Icons.add, color: Colors.green),
                  title: const Text('Add Co-Owner'),
                  onTap: () {
                    Navigator.pop(context);
                    _addCoOwner(agency);
                  },
                );
              }
              final coOwner = agency.coOwners[index];
              return ListTile(
                title: Text('User ${coOwner.substring(0, 8)}...'),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () {
                    Navigator.pop(context);
                    _removeCoOwner(agency, coOwner);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _addCoOwner(AgencyModel agency) async {
    final userId = await showInputDialog(
      context,
      title: 'Add Co-Owner',
      hintText: 'Enter user ID',
    );

    if (userId != null && userId.isNotEmpty) {
      showSuccess('Co-owner added (demo)');
    }
  }

  void _removeCoOwner(AgencyModel agency, String userId) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove Co-Owner',
      message: 'Are you sure you want to remove this co-owner?',
    );

    if (confirmed == true) {
      showSuccess('Co-owner removed (demo)');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}