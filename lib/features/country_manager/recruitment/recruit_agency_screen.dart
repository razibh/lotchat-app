import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/neumorphic_button.dart';
import '../../../core/widgets/neumorphic_text_field.dart';
import '../Models/country_manager_models.dart';
class RecruitAgencyScreen extends StatefulWidget {
  final String managerId;

  const RecruitAgencyScreen({required this.managerId, super.key});

  @override
  State<RecruitAgencyScreen> createState() => _RecruitAgencyScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('managerId', managerId));
  }
}

class _RecruitAgencyScreenState extends State<RecruitAgencyScreen> {
  bool _isLoading = true;
  List<AgencyRecruitmentRequest> _requests = [];
  List<AgencyRecruitmentRequest> _filteredRequests = [];
  String _selectedTab = 'pending';

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _requests = _generateSampleRequests();
      _filterRequests();
      _isLoading = false;
    });
  }

  List<AgencyRecruitmentRequest> _generateSampleRequests() {
    return [
      AgencyRecruitmentRequest(
        id: 'req_001',
        agencyName: 'Elite Talent Hub',
        ownerName: 'Karim Ahmed',
        email: 'karim@elite.com',
        phone: '01712345678',
        address: 'Dhaka',
        licenseNumber: 'LIC001',
        businessPlan: 'We will recruit 50 hosts specializing in music and entertainment...',
        proposedHosts: 50,
        expectedInvestment: 500000,
        requestDate: DateTime.now().subtract(const Duration(days: 1)),
        status: AgencyRequestStatus.pending,
      ),
      AgencyRecruitmentRequest(
        id: 'req_002',
        agencyName: 'Digital Stars',
        ownerName: 'Rina Begum',
        email: 'rina@digital.com',
        phone: '01812345678',
        address: 'Chittagong',
        licenseNumber: 'LIC002',
        businessPlan: 'Focus on gaming hosts and esports events...',
        proposedHosts: 30,
        expectedInvestment: 300000,
        requestDate: DateTime.now().subtract(const Duration(days: 2)),
        status: AgencyRequestStatus.pending,
      ),
      AgencyRecruitmentRequest(
        id: 'req_003',
        agencyName: 'Pro Talents',
        ownerName: 'Shahid Khan',
        email: 'shahid@pro.com',
        phone: '01912345678',
        address: 'Sylhet',
        licenseNumber: 'LIC003',
        businessPlan: 'We have 20 experienced hosts ready to join...',
        proposedHosts: 20,
        expectedInvestment: 200000,
        requestDate: DateTime.now().subtract(const Duration(days: 3)),
        status: AgencyRequestStatus.approved,
        reviewedBy: 'cm_001',
        reviewedDate: DateTime.now().subtract(const Duration(days: 1)),
        remarks: 'Approved with 12% commission',
      ),
    ];
  }

  void _filterRequests() {
    setState(() {
      if (_selectedTab == 'pending') {
        _filteredRequests = _requests.where((r) => r.status == AgencyRequestStatus.pending).toList();
      } else if (_selectedTab == 'approved') {
        _filteredRequests = _requests.where((r) => r.status == AgencyRequestStatus.approved).toList();
      } else if (_selectedTab == 'rejected') {
        _filteredRequests = _requests.where((r) => r.status == AgencyRequestStatus.rejected).toList();
      } else {
        _filteredRequests = List.from(_requests);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildRequestsList(),
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Recruit Agencies',
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

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildTab('Pending', 'pending'),
          _buildTab('Approved', 'approved'),
          _buildTab('Rejected', 'rejected'),
          _buildTab('All', 'all'),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String value) {
    final isSelected = _selectedTab == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = value;
            _filterRequests();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsList() {
    if (_filteredRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_center, size: 60, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No requests found',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _filteredRequests.length,
      itemBuilder: (context, index) {
        final request = _filteredRequests[index];
        return _buildRequestCard(request);
      },
    );
  }

  Widget _buildRequestCard(AgencyRecruitmentRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: request.status == AgencyRequestStatus.pending
              ? Colors.orange.withOpacity(0.5)
              : request.status == AgencyRequestStatus.approved
              ? Colors.green.withOpacity(0.5)
              : Colors.red.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.business, color: Colors.purple),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.agencyName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      request.ownerName,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: request.status == AgencyRequestStatus.pending
                      ? Colors.orange.withOpacity(0.2)
                      : request.status == AgencyRequestStatus.approved
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request.status.toString().split('.').last,
                  style: TextStyle(
                    color: request.status == AgencyRequestStatus.pending
                        ? Colors.orange
                        : request.status == AgencyRequestStatus.approved
                        ? Colors.green
                        : Colors.red,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.email, request.email),
          _buildInfoRow(Icons.phone, request.phone),
          _buildInfoRow(Icons.location_on, request.address),
          _buildInfoRow(Icons.badge, 'License: ${request.licenseNumber}'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Business Plan:',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  request.businessPlan,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Proposed Hosts',
                  '${request.proposedHosts}',
                  Icons.people,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Investment',
                  '৳${request.expectedInvestment}',
                  Icons.money,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Date',
                  _formatDate(request.requestDate),
                  Icons.calendar_today,
                ),
              ),
            ],
          ),
          if (request.status == AgencyRequestStatus.pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Approve',
                    Colors.green,
                        () => _showApproveDialog(request),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    'Reject',
                    Colors.red,
                        () => _showRejectDialog(request),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    'Contact',
                    Colors.blue,
                        () {},
                  ),
                ),
              ],
            ),
          ] else if (request.status == AgencyRequestStatus.approved) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Approved by: ${request.reviewedBy}\nRemarks: ${request.remarks ?? 'N/A'}',
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButton() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: NeumorphicButton(
        onPressed: _showNewRequestDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'ADD NEW REQUEST',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showApproveDialog(AgencyRecruitmentRequest request) {
    final TextEditingController commissionController = TextEditingController(text: '10');
    final TextEditingController remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Approve Agency', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Approve ${request.agencyName}?',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            NeumorphicTextField(
              controller: commissionController,
              hintText: 'Commission Rate (%)',
              prefixIcon: Icons.percent,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            NeumorphicTextField(
              controller: remarksController,
              hintText: 'Remarks (optional)',
              maxLines: 3,
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
              setState(() {
                // Create updated request
                final updatedRequest = AgencyRecruitmentRequest(
                  id: request.id,
                  agencyName: request.agencyName,
                  ownerName: request.ownerName,
                  email: request.email,
                  phone: request.phone,
                  address: request.address,
                  licenseNumber: request.licenseNumber,
                  businessPlan: request.businessPlan,
                  proposedHosts: request.proposedHosts,
                  expectedInvestment: request.expectedInvestment,
                  requestDate: request.requestDate,
                  status: AgencyRequestStatus.approved,
                  reviewedBy: 'cm_001',
                  reviewedDate: DateTime.now(),
                  remarks: 'Approved with ${commissionController.text}% commission',
                );

                final index = _requests.indexWhere((r) => r.id == request.id);
                if (index != -1) {
                  _requests[index] = updatedRequest;
                }
              });
              _filterRequests();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${request.agencyName} approved')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(AgencyRecruitmentRequest request) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Reject Agency', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Reject ${request.agencyName}?',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            NeumorphicTextField(
              controller: reasonController,
              hintText: 'Reason for rejection',
              maxLines: 3,
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
              setState(() {
                // Create updated request
                final updatedRequest = AgencyRecruitmentRequest(
                  id: request.id,
                  agencyName: request.agencyName,
                  ownerName: request.ownerName,
                  email: request.email,
                  phone: request.phone,
                  address: request.address,
                  licenseNumber: request.licenseNumber,
                  businessPlan: request.businessPlan,
                  proposedHosts: request.proposedHosts,
                  expectedInvestment: request.expectedInvestment,
                  requestDate: request.requestDate,
                  status: AgencyRequestStatus.rejected,
                  reviewedBy: 'cm_001',
                  reviewedDate: DateTime.now(),
                  remarks: reasonController.text,
                );

                final index = _requests.indexWhere((r) => r.id == request.id);
                if (index != -1) {
                  _requests[index] = updatedRequest;
                }
              });
              _filterRequests();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${request.agencyName} rejected')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showNewRequestDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController ownerController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        backgroundColor: AppColors.surfaceDark,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add New Recruitment Request',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              NeumorphicTextField(
                controller: nameController,
                hintText: 'Agency Name',
              ),
              const SizedBox(height: 12),
              NeumorphicTextField(
                controller: ownerController,
                hintText: 'Owner Name',
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Request added successfully')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Add'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}