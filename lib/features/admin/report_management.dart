import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

enum ReportType {
  user,
  message,
  room,
  gift,
  game,
  other
}

enum ReportStatus {
  pending,
  reviewing,
  resolved,
  dismissed
}

class ReportModel {
  final String id;
  final ReportType type;
  final String reporterId;
  final String reporterName;
  final String targetId;
  final String targetName;
  final String reason;
  final String? description;
  final DateTime reportedAt;
  ReportStatus status;
  final List<String>? evidence;
  String? assignedTo;
  DateTime? resolvedAt;
  String? resolution;

  ReportModel({
    required this.id,
    required this.type,
    required this.reporterId,
    required this.reporterName,
    required this.targetId,
    required this.targetName,
    required this.reason,
    this.description,
    required this.reportedAt,
    required this.status,
    this.evidence,
    this.assignedTo,
    this.resolvedAt,
    this.resolution,
  });
}

class ReportManagement extends StatefulWidget {
  const ReportManagement({super.key});

  @override
  State<ReportManagement> createState() => _ReportManagementState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    // Add any properties if needed
  }
}

class _ReportManagementState extends State<ReportManagement> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<ReportModel> _reports = [];
  List<ReportModel> _filteredReports = [];
  String _searchQuery = '';
  ReportStatus _selectedStatus = ReportStatus.pending;
  ReportType? _selectedType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    setState(() {
      switch (_tabController.index) {
        case 0:
          _selectedStatus = ReportStatus.pending;
          break;
        case 1:
          _selectedStatus = ReportStatus.reviewing;
          break;
        case 2:
          _selectedStatus = ReportStatus.resolved;
          break;
        case 3:
          _selectedStatus = ReportStatus.dismissed;
          break;
      }
      _filterReports();
    });
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Sample data
    _reports = List.generate(20, (index) {
      final statusIndex = index % 4;
      ReportStatus status;
      switch (statusIndex) {
        case 0:
          status = ReportStatus.pending;
          break;
        case 1:
          status = ReportStatus.reviewing;
          break;
        case 2:
          status = ReportStatus.resolved;
          break;
        default:
          status = ReportStatus.dismissed;
      }

      return ReportModel(
        id: 'REP${1000 + index}',
        type: ReportType.values[index % 5],
        reporterId: 'user_${100 + index}',
        reporterName: 'User ${index + 1}',
        targetId: 'target_${200 + index}',
        targetName: index % 2 == 0 ? 'User ${index + 10}' : 'Room ${index + 5}',
        reason: ['Harassment', 'Spam', 'Inappropriate content', 'Fake profile', 'Scam'][index % 5],
        description: index % 3 == 0 ? 'Detailed description of the report...' : null,
        reportedAt: DateTime.now().subtract(Duration(hours: index * 3)),
        status: status,
        evidence: index % 2 == 0 ? ['screenshot1.jpg', 'screenshot2.jpg'] : null,
        assignedTo: status != ReportStatus.pending ? 'admin_${index % 3 + 1}' : null,
        resolvedAt: status == ReportStatus.resolved ? DateTime.now().subtract(Duration(days: index % 5)) : null,
        resolution: status == ReportStatus.resolved ? 'User warned' : null,
      );
    });

    _filterReports();
    setState(() => _isLoading = false);
  }

  void _filterReports() {
    _filteredReports = _reports.where((report) {
      // Filter by status
      if (report.status != _selectedStatus) return false;

      // Filter by type
      if (_selectedType != null && report.type != _selectedType) return false;

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return report.reporterName.toLowerCase().contains(query) ||
            report.targetName.toLowerCase().contains(query) ||
            report.reason.toLowerCase().contains(query) ||
            report.id.toLowerCase().contains(query);
      }

      return true;
    }).toList();
  }

  String _getReportTypeText(ReportType type) {
    switch (type) {
      case ReportType.user:
        return 'User Report';
      case ReportType.message:
        return 'Message Report';
      case ReportType.room:
        return 'Room Report';
      case ReportType.gift:
        return 'Gift Report';
      case ReportType.game:
        return 'Game Report';
      case ReportType.other:
        return 'Other';
    }
  }

  Color _getReportTypeColor(ReportType type) {
    switch (type) {
      case ReportType.user:
        return Colors.blue;
      case ReportType.message:
        return Colors.green;
      case ReportType.room:
        return Colors.orange;
      case ReportType.gift:
        return Colors.purple;
      case ReportType.game:
        return Colors.red;
      case ReportType.other:
        return Colors.grey;
    }
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return Colors.orange;
      case ReportStatus.reviewing:
        return Colors.blue;
      case ReportStatus.resolved:
        return Colors.green;
      case ReportStatus.dismissed:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Management'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Reviewing'),
            Tab(text: 'Resolved'),
            Tab(text: 'Dismissed'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredReports.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredReports.length,
              itemBuilder: (context, index) {
                final report = _filteredReports[index];
                return _buildReportCard(report);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _filterReports();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search reports...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade200,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildReportCard(ReportModel report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showReportDetails(report),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getReportTypeColor(report.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getReportTypeText(report.type),
                      style: TextStyle(
                        color: _getReportTypeColor(report.type),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(report.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report.status.toString().split('.').last.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(report.status),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(report.reportedAt),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Report ID
              Text(
                'ID: ${report.id}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),

              // Reporter and Target
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reporter',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          report.reporterName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Target',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          report.targetName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Reason
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reason:',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      report.reason,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (report.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        report.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (report.assignedTo != null)
                    Text(
                      'Assigned to: ${report.assignedTo}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                      ),
                    ),
                  if (report.resolution != null)
                    Text(
                      'Resolution: ${report.resolution}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.green,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No reports found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no ${_selectedStatus.toString().split('.').last} reports',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Reports'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Report Type:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _selectedType == null,
                  onSelected: (_) {
                    setState(() {
                      _selectedType = null;
                      _filterReports();
                    });
                    Navigator.pop(context);
                  },
                ),
                ...ReportType.values.map((type) {
                  return ChoiceChip(
                    label: Text(_getReportTypeText(type)),
                    selected: _selectedType == type,
                    onSelected: (_) {
                      setState(() {
                        _selectedType = type;
                        _filterReports();
                      });
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showReportDetails(ReportModel report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Details Grid
            _buildDetailRow('Report ID', report.id),
            _buildDetailRow('Type', _getReportTypeText(report.type)),
            _buildDetailRow('Status', report.status.toString().split('.').last.toUpperCase()),
            _buildDetailRow('Reported', _formatDate(report.reportedAt)),
            _buildDetailRow('Reporter', report.reporterName),
            _buildDetailRow('Target', report.targetName),

            const Divider(height: 24),

            // Reason
            const Text(
              'Reason:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(report.reason),
            if (report.description != null) ...[
              const SizedBox(height: 8),
              Text(report.description!),
            ],

            if (report.evidence != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Evidence:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: report.evidence!.map((file) {
                  return Chip(
                    label: Text(file),
                    avatar: const Icon(Icons.attach_file, size: 16),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 20),

            // Actions
            Row(
              children: [
                if (report.status == ReportStatus.pending) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Assign to self
                        setState(() {
                          report.status = ReportStatus.reviewing;
                          report.assignedTo = 'admin_current';
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('Take'),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (report.status == ReportStatus.reviewing) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showResolveDialog(report),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Resolve'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showDismissDialog(report),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Dismiss'),
                    ),
                  ),
                ],
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showResolveDialog(ReportModel report) {
    final resolutionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter resolution details:'),
            const SizedBox(height: 8),
            TextField(
              controller: resolutionController,
              decoration: const InputDecoration(
                hintText: 'e.g., User warned, Content removed',
                border: OutlineInputBorder(),
              ),
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
              setState(() {
                report.status = ReportStatus.resolved;
                report.resolution = resolutionController.text;
                report.resolvedAt = DateTime.now();
              });
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report resolved')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  void _showDismissDialog(ReportModel report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dismiss Report'),
        content: const Text('Are you sure you want to dismiss this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                report.status = ReportStatus.dismissed;
                report.resolvedAt = DateTime.now();
              });
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report dismissed')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }
}

// Simplified version for error fixing
class ReportManagementSimple extends StatelessWidget {
  const ReportManagementSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Report Management Screen'),
      ),
    );
  }
}