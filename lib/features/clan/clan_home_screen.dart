import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../clan/services/clan_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/clan_model.dart';  // ← এই ইম্পোর্ট যোগ করুন
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/animation/fade_animation.dart';
import 'clan_detail_screen.dart';
import 'create_clan_screen.dart';
import 'widgets/clan_card.dart';

class ClanHomeScreen extends StatefulWidget {
  const ClanHomeScreen({super.key});

  @override
  State<ClanHomeScreen> createState() => _ClanHomeScreenState();
}

class _ClanHomeScreenState extends State<ClanHomeScreen>
    with LoadingMixin, ToastMixin {

  final ClanService _clanService = ServiceLocator().get<ClanService>();
  final AuthService _authService = ServiceLocator().get<AuthService>();

  List<ClanModel> _clans = [];
  ClanModel? _myClan;
  String _selectedTab = 'My Clan';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // যখন স্ক্রিনে ফিরে আসি তখন ডাটা রিলোড করি
    _loadData();
  }

  Future<void> _loadData() async {
    await runWithLoading(() async {
      // Get user's clan
      final User? user = _authService.getCurrentUser();
      if (user != null) {
        // ইউজারের ডকুমেন্ট থেকে clanId পাওয়ার জন্য
        final userDoc = await _authService.getUserData(user.uid);
        final clanId = userDoc?['clanId'] as String?;

        if (clanId != null) {
          _myClan = await _clanService.getClan(clanId);
        } else {
          _myClan = null;
        }
      }

      // Get recommended clans (open/public clans)
      _clans = await _clanService.searchClans('');

      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Clans'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Navigate to search
                Navigator.pushNamed(context, '/clan/search');
              },
            ),
            IconButton(
              icon: const Icon(Icons.leaderboard),
              onPressed: () {
                Navigator.pushNamed(context, '/clan/leaderboard');
              },
            ),
          ],
          bottom: TabBar(
            onTap: (int index) {
              setState(() {
                _selectedTab = index == 0 ? 'My Clan' : 'Discover';
              });
            },
            tabs: const [
              Tab(text: 'My Clan'),
              Tab(text: 'Discover'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _selectedTab == 'My Clan'
            ? _buildMyClanView()
            : _buildDiscoverView(),
        floatingActionButton: _selectedTab == 'Discover' && _myClan == null
            ? FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateClanScreen(),
              ),
            ).then((_) => _loadData());
          },
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        )
            : null,
      ),
    );
  }

  Widget _buildMyClanView() {
    if (_myClan == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.groups,
                  size: 60,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'You are not in a clan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join or create a clan to connect with others',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedTab = 'Discover';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Browse Clans'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateClanScreen(),
                        ),
                      ).then((_) => _loadData());
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                    ),
                    child: const Text('Create Clan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Clan Card
          ClanCard(
            clan: _myClan!,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClanDetailScreen(clan: _myClan!),
                ),
              ).then((_) => _loadData());
            },
          ),
          const SizedBox(height: 20),

          // Quick Actions
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(
                        icon: Icons.chat,
                        label: 'Chat',
                        color: Colors.blue,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/clan/chat',
                            arguments: {
                              'clanId': _myClan!.id,
                              'clanName': _myClan!.name,
                            },
                          );
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.task,
                        label: 'Tasks',
                        color: Colors.green,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/clan/tasks',
                            arguments: _myClan!.id,
                          );
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.shopping_bag,
                        label: 'Shop',
                        color: Colors.orange,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/clan/shop',
                            arguments: _myClan!.id,
                          );
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.emoji_events,
                        label: 'War',
                        color: Colors.red,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/clan/wars',
                            arguments: _myClan!.id,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Recent Activity
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(5, (index) {
                    final activities = [
                      'completed a task',
                      'donated 100 coins',
                      'joined the clan',
                      'won a war battle',
                      'sent a gift',
                    ];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.deepPurple.shade100,
                        child: Text(
                          'U${index + 1}',
                          style: const TextStyle(color: Colors.deepPurple),
                        ),
                      ),
                      title: Text('User ${index + 1}'),
                      subtitle: Text(activities[index % activities.length]),
                      trailing: Text('${index + 1}h ago'),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverView() {
    if (_clans.isEmpty) {
      return EmptyStateWidget(
        title: 'No Clans Found',
        message: _myClan == null
            ? 'Be the first to create a clan!'
            : 'No other clans available',
        icon: Icons.groups,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _clans.length,
      itemBuilder: (context, index) {
        final clan = _clans[index];
        // নিজের ক্লান ডিসকভারে দেখাবো না
        if (_myClan?.id == clan.id) {
          return const SizedBox.shrink();
        }
        return FadeAnimation(
          delay: Duration(milliseconds: index * 100),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ClanCard(
              clan: clan,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClanDetailScreen(clan: clan),
                  ),
                ).then((_) => _loadData());
              },
            ),
          ),
        );
      },
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
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}