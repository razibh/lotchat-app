import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/referral_service.dart';
import '../../core/services/auth_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/animation/fade_animation.dart';
import 'dart:ui' as ui;

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> 
    with LoadingMixin, ToastMixin {
  
  final ReferralService _referralService = ServiceLocator().get<ReferralService>();
  final AuthService _authService = ServiceLocator().get<AuthService>();
  
  String? _referralCode;
  int _totalReferrals = 0;
  int _totalEarnings = 0;
  List<Map<String, dynamic>> _referralHistory = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _loadReferralData();
  }

  Future<void> _loadReferralData() async {
    await runWithLoading(() async {
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _referralCode = 'LOTCHAT123';
        _totalReferrals = 24;
        _totalEarnings = 12500;
        _referralHistory = List.generate(10, (int index) {
          return <String, dynamic>{
            'name': 'User ${index + 1}',
            'date': DateTime.now().subtract(Duration(days: index)),
            'earnings': 500,
            'status': 'completed',
          };
        });
      });
    });
  }

  Future<void> _copyReferralCode() async {
    if (_referralCode != null) {
      await ui.TextureLayer.handle ??
      // Copy to clipboard
      showSuccess('Referral code copied!');
    }
  }

  Future<void> _shareReferral() async {
    // Share referral link
    showSuccess('Sharing referral link...');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refer & Earn'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <>[
                  // Header Card
                  Card(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: <>[Colors.green, Colors.lightGreen],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: <>[
                          const Icon(
                            Icons.card_giftcard,
                            size: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Invite Friends, Earn Coins!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Get 500 coins for each friend who joins',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 24),
                          
                          // Referral Code
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: <>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <>[
                                      const Text(
                                        'Your Referral Code',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _referralCode ?? 'LOADING',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, color: Colors.white),
                                  onPressed: _copyReferralCode,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.share, color: Colors.white),
                                  onPressed: _shareReferral,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stats
                  Row(
                    children: <>[
                      Expanded(
                        child: _buildStatCard(
                          'Total Referrals',
                          '$_totalReferrals',
                          Icons.people,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Total Earnings',
                          '$_totalEarnings',
                          Icons.monetization_on,
                          Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // How it works
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <>[
                          const Text(
                            'How it works',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildStep(
                            '1',
                            'Share your code',
                            'Send your referral code to friends',
                            Icons.share,
                            Colors.blue,
                          ),
                          _buildStep(
                            '2',
                            'Friend joins',
                            'They sign up using your code',
                            Icons.person_add,
                            Colors.green,
                          ),
                          _buildStep(
                            '3',
                            'You earn coins',
                            'Get 500 coins for each referral',
                            Icons.monetization_on,
                            Colors.amber,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Referral History
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <>[
                          const Text(
                            'Referral History',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._referralHistory.map((Map<String, dynamic> ref) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: <>[
                                const CircleAvatar(
                                  radius: 16,
                                  child: Icon(Icons.person, size: 16),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <>[
                                      Text(
                                        ref['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _formatDate(ref['date']),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: <>[
                                      const Icon(
                                        Icons.monetization_on,
                                        size: 12,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '+${ref['earnings']}',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <>[
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String title, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: <>[
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Icon(icon, color: color, size: 20),
        ],
      ),
    );
  }
}