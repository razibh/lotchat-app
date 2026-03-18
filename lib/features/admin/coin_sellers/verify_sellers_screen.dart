import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/neumorphic_button.dart';

class VerifySellersScreen extends StatefulWidget {
  const VerifySellersScreen({super.key});

  @override
  State<VerifySellersScreen> createState() => _VerifySellersScreenState();
}

class _VerifySellersScreenState extends State<VerifySellersScreen> {
  List<PendingSeller> _sellers = [];

  @override
  void initState() {
    super.initState();
    _loadSellers();
  }

  void _loadSellers() {
    _sellers = [
      PendingSeller(
        id: 's1',
        businessName: 'Fast Coin BD',
        owner: 'Shahid Khan',
        email: 'shahid@fastcoin.com',
        country: 'Bangladesh',
        flag: '🇧🇩',
        discountRate: 15,
        documents: ['NID', 'License'],
        submittedDate: '2024-03-10',
      ),
      PendingSeller(
        id: 's2',
        businessName: 'Coin Hub India',
        owner: 'Rajesh Kumar',
        email: 'rajesh@coinhub.in',
        country: 'India',
        flag: '🇮🇳',
        discountRate: 12,
        documents: ['NID', 'License', 'Bank'],
        submittedDate: '2024-03-09',
      ),
      PendingSeller(
        id: 's3',
        businessName: 'PK Recharge',
        owner: 'Ali Raza',
        email: 'ali@pkrecharge.com',
        country: 'Pakistan',
        flag: '🇵🇰',
        discountRate: 18,
        documents: ['NID', 'License', 'Tax'],
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
            children: [
              _buildHeader(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _sellers.length,
                  itemBuilder: (context, index) {
                    final seller = _sellers[index];
                    return _buildSellerCard(seller);
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
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Verify Coin Sellers',
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
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_sellers.length} Pending',
              style: const TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerCard(PendingSeller seller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.store, color: Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      seller.businessName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      seller.owner,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                seller.flag,
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.email, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(seller.email, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.percent, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text('${seller.discountRate}% discount',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: seller.documents.map((doc) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
            children: [
              Expanded(
                child: _buildActionButton('Approve', Colors.green, () {
                  _showApproveDialog(seller);
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton('Reject', Colors.red, () {
                  _showRejectDialog(seller);
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton('View', Colors.blue, () {
                  _showDetailsDialog(seller);
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

  void _showApproveDialog(PendingSeller seller) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Approve Seller', style: TextStyle(color: Colors.white)),
        content: Text(
          'Approve ${seller.businessName}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _sellers.remove(seller);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${seller.businessName} approved')),
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

  void _showRejectDialog(PendingSeller seller) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Reject Seller', style: TextStyle(color: Colors.white)),
        content: Text(
          'Reject ${seller.businessName}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _sellers.remove(seller);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${seller.businessName} rejected')),
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

  void _showDetailsDialog(PendingSeller seller) {
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
                'Seller Details',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Business', seller.businessName),
              _buildDetailRow('Owner', seller.owner),
              _buildDetailRow('Email', seller.email),
              _buildDetailRow('Country', '${seller.flag} ${seller.country}'),
              _buildDetailRow('Discount', '${seller.discountRate}%'),
              _buildDetailRow('Submitted', seller.submittedDate),
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
        children: [
          Text('$label:', style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class PendingSeller {
  final String id;
  final String businessName;
  final String owner;
  final String email;
  final String country;
  final String flag;
  final int discountRate;
  final List<String> documents;
  final String submittedDate;

  PendingSeller({
    required this.id,
    required this.businessName,
    required this.owner,
    required this.email,
    required this.country,
    required this.flag,
    required this.discountRate,
    required this.documents,
    required this.submittedDate,
  });
}