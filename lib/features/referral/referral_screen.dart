import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/referral_service.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  late final ReferralService _referralService;
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _history = [];
  Map<String, dynamic>? _referredBy;
  final List<Map<String, dynamic>> _leaderboard = [];

  @override
  void initState() {
    super.initState();
    _referralService = ReferralService();
    _loadReferralData();
  }

  Future<void> _loadReferralData() async {
    setState(() => _isLoading = true);

    try {
      final stats = await _referralService.getReferralStats();
      final referredBy = await _referralService.getReferredBy();
      final leaderboard = await _referralService.getReferralLeaderboard();

      if (mounted) {
        setState(() {
          _stats = stats;
          _referredBy = referredBy;
          _leaderboard.addAll(leaderboard);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading referral data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refer & Earn'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadReferralData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReferralCodeCard(),
              const SizedBox(height: 16),
              _buildStatsCard(),
              const SizedBox(height: 16),
              if (_referredBy != null) _buildReferredByCard(),
              if (_referredBy != null) const SizedBox(height: 16),
              _buildMilestoneCard(),
              const SizedBox(height: 16),
              _buildHowItWorks(),
              const SizedBox(height: 16),
              _buildReferralHistory(),
              const SizedBox(height: 16),
              _buildLeaderboard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReferralCodeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.deepPurple, Colors.purple],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(
                Icons.card_giftcard,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your Referral Code',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _stats['code'] ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _copyReferralCode,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _shareReferralCode,
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
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

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total',
                  '${_stats['totalReferrals'] ?? 0}',
                  Icons.people,
                  Colors.blue,
                ),
                _buildStatItem(
                  'This Month',
                  '${_stats['monthReferrals'] ?? 0}',
                  Icons.calendar_today,
                  Colors.green,
                ),
                _buildStatItem(
                  'This Week',
                  '${_stats['weekReferrals'] ?? 0}',
                  Icons.weekend,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Earnings:'),
                Text(
                  '${_stats['totalEarnings'] ?? 0} coins',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildReferredByCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Referred By',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: _referredBy?['avatar'] != null
                    ? NetworkImage(_referredBy!['avatar'])
                    : null,
                child: _referredBy?['avatar'] == null
                    ? Text(_referredBy?['name'][0].toUpperCase() ?? 'U')
                    : null,
              ),
              title: Text(_referredBy?['name'] ?? 'User'),
              subtitle: Text('Joined on ${_formatDate(_referredBy?['referredAt'])}'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneCard() {
    final milestone = _stats['nextMilestone'] as Map<String, dynamic>?;
    if (milestone == null) return const SizedBox();

    final progress = (_stats['totalReferrals'] ?? 0) / milestone['next'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Next Milestone',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_stats['totalReferrals'] ?? 0}/${milestone['next']} referrals'),
                Text('+${milestone['bonus']} coins', style: const TextStyle(color: Colors.green)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How it Works',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildStep(1, 'Share your referral code with friends'),
            _buildStep(2, 'They sign up using your code'),
            _buildStep(3, 'You earn ${_stats['bonusPerReferral'] ?? 1000} coins'),
            _buildStep(4, 'Withdraw your earnings anytime'),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int number, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(description)),
        ],
      ),
    );
  }

  Widget _buildReferralHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Referrals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _referralService.getReferralHistory(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error loading referrals'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final history = snapshot.data!;

                if (history.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No referrals yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length > 5 ? 5 : history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: item['referredAvatar'] != null
                            ? NetworkImage(item['referredAvatar'])
                            : null,
                        child: item['referredAvatar'] == null
                            ? Text(item['referredName'][0].toUpperCase())
                            : null,
                      ),
                      title: Text(item['referredName']),
                      subtitle: Text(_formatDate(item['timestamp'])),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+${item['bonus']}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Referrers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_leaderboard.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No data yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _leaderboard.length,
                itemBuilder: (context, index) {
                  final item = _leaderboard[index];
                  final isCurrentUser = item['userId'] == FirebaseAuth.instance.currentUser?.uid;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCurrentUser ? Colors.deepPurple.shade100 : null,
                      backgroundImage: item['avatar'] != null
                          ? NetworkImage(item['avatar'])
                          : null,
                      child: item['avatar'] == null
                          ? Text(item['name'][0].toUpperCase())
                          : null,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['name'],
                            style: TextStyle(
                              fontWeight: isCurrentUser ? FontWeight.bold : null,
                              color: isCurrentUser ? Colors.deepPurple : null,
                            ),
                          ),
                        ),
                        if (isCurrentUser)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'You',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${item['totalReferrals']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _copyReferralCode() async {
    final code = _stats['code'];
    if (code != null) {
      await _referralService.getReferralLink();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Referral code copied!')),
      );
    }
  }

  void _shareReferralCode() {
    _referralService.shareReferral();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening share dialog...')),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Referrals'),
        content: Text(
          'Earn rewards by inviting your friends to join LotChat!\n\n'
              '• You get ${_stats['bonusPerReferral'] ?? 1000} coins per referral\n'
              '• Bonus rewards at referral milestones\n'
              '• No limit on total referrals\n'
              '• Withdraw earnings anytime\n\n'
              'Your total earnings: ${_stats['totalEarnings'] ?? 0} coins',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';

    final DateTime dt;
    if (date is Timestamp) {
      dt = date.toDate();
    } else if (date is DateTime) {
      dt = date;
    } else {
      return 'Unknown';
    }

    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inDays > 7) {
      return '${dt.day}/${dt.month}/${dt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}