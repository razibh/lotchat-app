import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/neumorphic_button.dart';

class VerifyAgenciesScreen extends StatefulWidget {
  const VerifyAgenciesScreen({super.key});

  @override
  State<VerifyAgenciesScreen> createState() => _VerifyAgenciesScreenState();
}

class _VerifyAgenciesScreenState extends State<VerifyAgenciesScreen> {
  List<PendingAgency> _agencies = <PendingAgency>[];

  @override
  void initState() {
    super.initState();
    _loadAgencies();
  }

  void _loadAgencies() {
    _agencies = <PendingAgency>[
      PendingAgency(
        id: 'ag1',
        name: 'Elite Talent Hub',
        owner: 'Karim Ahmed',
        email: 'karim@elite.com',
        country: 'Bangladesh',
        flag: '🇧🇩',
        proposedHosts: 50,
        documents: <String>['NID', 'License', 'Tax'],
        submittedDate: '2024-03-10',
      ),
      PendingAgency(
        id: 'ag2',
        name: 'Digital Stars',
        owner: 'Rina Begum',
        email: 'rina@digital.com',
        country: 'India',
        flag: '🇮🇳',
        proposedHosts: 30,
        documents: <String>['NID', 'License'],
        submittedDate: '2024-03-09',
      ),
      PendingAgency(
        id: 'ag3',
        name: 'Pro Talents',
        owner: 'Shahid Khan',
        email: 'shahid@pro.com',
        country: 'Pakistan',
        flag: '🇵🇰',
        proposedHosts: 25,
        documents: <String>['NID', 'License', 'Tax', 'Bank'],
        submittedDate: '2024-03-08',
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
                  itemCount: _agencies.length,
                  itemBuilder: (BuildContext context, int index) {
                    final PendingAgency agency = _agencies[index];
                    return _buildAgencyCard(agency);
                  },
                ),
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
            'Verify Agencies',
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
              color: Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_agencies.length} Pending',
              style: const TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgencyCard(PendingAgency agency) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <>[
          Row(
            children: <>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.business, color: Colors.purple),
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
                      agency.owner,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                agency.flag,
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <>[
              const Icon(Icons.email, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(agency.email, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <>[
              const Icon(Icons.people, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text('${agency.proposedHosts} proposed hosts', 
                style: const TextStyle(color: Colors.white70, fontSize: 12),),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: agency.documents.map((String doc) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <>[
                    const Icon(Icons.check_circle, color: Colors.green, size: 12),
                    const SizedBox(width: 4),
                    Text(doc, style: const TextStyle(color: Colors.green, fontSize: 10)),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: <>[
              Expanded(
                child: _buildActionButton('Approve', Colors.green, () {
                  _showApproveDialog(agency);
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton('Reject', Colors.red, () {
                  _showRejectDialog(agency);
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton('View', Colors.blue, () {
                  _showDetailsDialog(agency);
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
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

  void _showApproveDialog(PendingAgency agency) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Approve Agency', style: TextStyle(color: Colors.white)),
        content: Text(
          'Approve ${agency.name}?',
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
                _agencies.remove(agency);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${agency.name} approved')),
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

  void _showRejectDialog(PendingAgency agency) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Reject Agency', style: TextStyle(color: Colors.white)),
        content: Text(
          'Reject ${agency.name}?',
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
                _agencies.remove(agency);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${agency.name} rejected')),
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

  void _showDetailsDialog(PendingAgency agency) {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        backgroundColor: AppColors.surfaceDark,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <>[
              const Text(
                'Agency Details',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Name', agency.name),
              _buildDetailRow('Owner', agency.owner),
              _buildDetailRow('Email', agency.email),
              _buildDetailRow('Country', '${agency.flag} ${agency.country}'),
              _buildDetailRow('Proposed Hosts', '${agency.proposedHosts}'),
              _buildDetailRow('Submitted', agency.submittedDate),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <>[
          Text('$label:', style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class PendingAgency {

  PendingAgency({
    required this.id,
    required this.name,
    required this.owner,
    required this.email,
    required this.country,
    required this.flag,
    required this.proposedHosts,
    required this.documents,
    required this.submittedDate,
  });
  final String id;
  final String name;
  final String owner;
  final String email;
  final String country;
  final String flag;
  final int proposedHosts;
  final List<String> documents;
  final String submittedDate;
}