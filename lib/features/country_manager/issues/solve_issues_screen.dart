import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/neumorphic_button.dart';
import '../../../core/widgets/neumorphic_text_field.dart';
import '../models/country_manager_models.dart';

class SolveIssuesScreen extends StatefulWidget {

  const SolveIssuesScreen({required this.managerId, super.key});
  final String managerId;

  @override
  State<SolveIssuesScreen> createState() => _SolveIssuesScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('managerId', managerId));
  }
}

class _SolveIssuesScreenState extends State<SolveIssuesScreen> {
  bool _isLoading = true;
  List<ManagerIssue> _issues = <>[];
  List<ManagerIssue> _filteredIssues = <>[];
  String _selectedFilter = 'open';
  String _selectedPriority = 'all';

  final List<String> _filters = <String>['open', 'inProgress', 'resolved', 'all'];
  final List<String> _priorities = <String>['all', 'low', 'medium', 'high', 'critical'];

  @override
  void initState() {
    super.initState();
    _loadIssues();
  }

  Future<void> _loadIssues() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _issues = _generateSampleIssues(20);
      _filterIssues();
      _isLoading = false;
    });
  }

  List<ManagerIssue> _generateSampleIssues(int count) {
    return List.generate(count, (int index) {
      return ManagerIssue(
        id: 'iss_${100 + index}',
        agencyId: 'ag_${100 + (index % 5)}',
        agencyName: 'Agency ${(index % 5) + 1}',
        reportedBy: 'User ${index + 1}',
        reportedById: 'user_${100 + index}',
        title: 'Issue #${index + 1}',
        description: 'This is a sample issue description for testing purposes.',
        priority: IssuePriority.values[index % 5],
        status: IssueStatus.values[index % 4],
        reportedDate: DateTime.now().subtract(Duration(hours: index * 2)),
        attachments: <dynamic>[],
        comments: <dynamic>[],
      );
    });
  }

  void _filterIssues() {
    setState(() {
      _filteredIssues = _issues.where((Object? issue) {
        // Status filter
        if (_selectedFilter != 'all' && issue.status.toString().split('.').last != _selectedFilter) {
          return false;
        }
        
        // Priority filter
        if (_selectedPriority != 'all' && issue.priority.toString().split('.').last != _selectedPriority) {
          return false;
        }
        
        return true;
      }).toList();

      // Sort by priority and date
      _filteredIssues.sort((Object? a, Object? b) {
        final int priorityCompare = b.priority.index.compareTo(a.priority.index);
        if (priorityCompare != 0) return priorityCompare;
        return b.reportedDate.compareTo(a.reportedDate);
      });
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
              _buildFilterBar(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildIssuesList(),
              ),
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
            'Solve Issues',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            'Open: ${_issues.where((Object? i) => i.status == IssueStatus.open).length}',
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Column(
      children: <>[
        Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            itemBuilder: (BuildContext context, int index) {
              final String filter = _filters[index];
              final bool isSelected = _selectedFilter == filter;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter.toUpperCase()),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedFilter = filter;
                      _filterIssues();
                    });
                  },
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  selectedColor: Colors.orange,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _priorities.length,
            itemBuilder: (BuildContext context, int index) {
              final String priority = _priorities[index];
              final bool isSelected = _selectedPriority == priority;
              MaterialColor color = Colors.grey;
              
              if (priority == 'high') {
                color = Colors.red;
              } else if (priority == 'medium') color = Colors.orange;
              else if (priority == 'low') color = Colors.green;
              else if (priority == 'critical') color = Colors.purple;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(priority.toUpperCase()),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedPriority = priority;
                      _filterIssues();
                    });
                  },
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  selectedColor: color,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIssuesList() {
    if (_filteredIssues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <>[
            Icon(Icons.check_circle, size: 60, color: Colors.green.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'No issues found',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _filteredIssues.length,
      itemBuilder: (BuildContext context, int index) {
        final issue = _filteredIssues[index];
        return _buildIssueCard(issue);
      },
    );
  }

  Widget _buildIssueCard(ManagerIssue issue) {
    Color priorityColor;
    String priorityText;
    
    switch (issue.priority) {
      case IssuePriority.low:
        priorityColor = Colors.green;
        priorityText = 'LOW';
      case IssuePriority.medium:
        priorityColor = Colors.orange;
        priorityText = 'MEDIUM';
      case IssuePriority.high:
        priorityColor = Colors.red;
        priorityText = 'HIGH';
      case IssuePriority.critical:
        priorityColor = Colors.purple;
        priorityText = 'CRITICAL';
    }

    Color statusColor;
    String statusText;
    
    switch (issue.status) {
      case IssueStatus.open:
        statusColor = Colors.red;
        statusText = 'OPEN';
      case IssueStatus.inProgress:
        statusColor = Colors.orange;
        statusText = 'IN PROGRESS';
      case IssueStatus.resolved:
        statusColor = Colors.green;
        statusText = 'RESOLVED';
      case IssueStatus.closed:
        statusColor = Colors.grey;
        statusText = 'CLOSED';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: issue.priority == IssuePriority.critical
              ? Colors.purple.withValues(alpha: 0.5)
              : issue.priority == IssuePriority.high
                  ? Colors.red.withValues(alpha: 0.5)
                  : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <>[
          Row(
            children: <>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  issue.priority == IssuePriority.critical
                      ? Icons.warning
                      : Icons.error,
                  color: priorityColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <>[
                    Text(
                      issue.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      issue.agencyName,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      priorityText,
                      style: TextStyle(color: priorityColor, fontSize: 8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontSize: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              issue.description,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <>[
              const Icon(Icons.person, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(
                'Reported by: ${issue.reportedBy}',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
              const Spacer(),
              const Icon(Icons.access_time, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(
                _formatDate(issue.reportedDate),
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
          if (issue.status != IssueStatus.resolved && issue.status != IssueStatus.closed) ...<>[
            const SizedBox(height: 12),
            Row(
              children: <>[
                Expanded(
                  child: _buildActionButton(
                    'Take Action',
                    Colors.orange,
                    () => _showResolveDialog(issue),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    'Assign',
                    Colors.blue,
                    () {},
                  ),
                ),
              ],
            ),
          ] else if (issue.resolution != null) ...<>[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: <>[
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Resolution: ${issue.resolution}',
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
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _showResolveDialog(ManagerIssue issue) {
    final TextEditingController resolutionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Resolve Issue', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            Text(
              issue.title,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            NeumorphicTextField(
              controller: resolutionController,
              hintText: 'Enter resolution',
              maxLines: 3,
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
              setState(() {
                issue.status = IssueStatus.resolved;
                issue.resolution = resolutionController.text;
                issue.resolvedDate = DateTime.now();
              });
              _filterIssues();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Issue resolved')),
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

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

    if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}