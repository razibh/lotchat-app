import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/services/auth_service.dart';
import '../../chat/chat_detail_screen.dart';
import '../../gifts/gift_screen.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';
import '../widgets/profile_tab_bar.dart';
import 'achievements_screen.dart';
import 'badges_screen.dart';
import 'edit_profile_screen.dart';
import 'followers_screen.dart';
import 'following_screen.dart';
import 'frames_screen.dart';
import 'friends_screen.dart';

class ProfileScreen extends StatefulWidget {

  const ProfileScreen({super.key, this.userId});
  final String? userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('userId', userId));
  }
}

class _ProfileScreenState extends State<ProfileScreen> 
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;
  final AuthService _authService = ServiceLocator().get<AuthService>();
  bool _isCurrentUser = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkCurrentUser();
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkCurrentUser() async {
    final User? currentUser = _authService.getCurrentUser();
    setState(() {
      _isCurrentUser = currentUser?.uid == widget.userId;
    });
  }

  Future<void> _loadProfile() async {
    await context.read<ProfileProvider>().loadProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (BuildContext context, Object? provider, Widget? child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <>[
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading profile',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProfile,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final profile = provider.profile;
        if (profile == null) {
          return const Scaffold(
            body: Center(child: Text('Profile not found')),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: <>[
              // Profile Header (with cover image and avatar)
              SliverToBoxAdapter(
                child: ProfileHeader(
                  profile: profile,
                  isCurrentUser: _isCurrentUser,
                  onEditPressed: _isCurrentUser
                      ? () => _navigateToEditProfile(profile)
                      : null,
                  onMessagePressed: _isCurrentUser
                      ? null
                      : () => _navigateToChat(profile),
                  onFollowPressed: _isCurrentUser
                      ? null
                      : () => _toggleFollow(profile.userId),
                  onSharePressed: () => _shareProfile(profile),
                ),
              ),

              // Profile Stats
              SliverToBoxAdapter(
                child: ProfileStats(profile: profile),
              ),

              // Tab Bar
              SliverToBoxAdapter(
                child: ProfileTabBar(tabController: _tabController),
              ),

              // Tab Content
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: <>[
                    _buildPostsTab(),
                    _buildGiftsTab(),
                    _buildAboutTab(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostsTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 12,
      itemBuilder: (BuildContext context, int index) {
        return ColoredBox(
          color: Colors.grey.shade300,
          child: Center(
            child: Icon(Icons.image, color: Colors.grey.shade600),
          ),
        );
      },
    );
  }

  Widget _buildGiftsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 10,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.purple.shade100,
            child: const Icon(Icons.card_giftcard, color: Colors.purple),
          ),
          title: Text('Gift ${index + 1}'),
          subtitle: Text('Received ${index + 1} days ago'),
          trailing: Text('${100 * (index + 1)} coins'),
        );
      },
    );
  }

  Widget _buildAboutTab() {
    final profile = context.read<ProfileProvider>().profile;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <>[
        if (profile.bio != null) ...<>[
          const Text(
            'Bio',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(profile.bio!),
          const SizedBox(height: 16),
        ],

        if (profile.interests.isNotEmpty) ...<>[
          const Text(
            'Interests',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: profile.interests.map((interest) {
              return Chip(
                label: Text(interest),
                backgroundColor: Colors.blue.withValues(alpha: 0.1),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],

        if (profile.location != null) ...<>[
          ListTile(
            leading: const Icon(Icons.location_on, color: Colors.blue),
            title: const Text('Location'),
            subtitle: Text(profile.location!),
          ),
        ],

        if (profile.website != null) ...<>[
          ListTile(
            leading: const Icon(Icons.link, color: Colors.blue),
            title: const Text('Website'),
            subtitle: Text(profile.website!),
            onTap: () => _launchUrl(profile.website!),
          ),
        ],

        if (profile.birthDate != null) ...<>[
          ListTile(
            leading: const Icon(Icons.cake, color: Colors.pink),
            title: const Text('Birthday'),
            subtitle: Text(_formatDate(profile.birthDate!)),
          ),
        ],

        if (profile.gender != null) ...<>[
          ListTile(
            leading: const Icon(Icons.person, color: Colors.green),
            title: const Text('Gender'),
            subtitle: Text(profile.gender!),
          ),
        ],

        const Divider(),

        ListTile(
          leading: const Icon(Icons.calendar_today, color: Colors.orange),
          title: const Text('Joined'),
          subtitle: Text(_formatDate(profile.joinedAt)),
        ),

        ListTile(
          leading: const Icon(Icons.stars, color: Colors.amber),
          title: const Text('Level'),
          subtitle: Text('${profile.level} • ${profile.xp} XP'),
          trailing: Text('${(profile.xpProgress * 100).toInt()}%'),
        ),

        if (profile.badges.isNotEmpty) ...<>[
          const Divider(),
          ListTile(
            leading: const Icon(Icons.emoji_events, color: Colors.amber),
            title: const Text('Badges'),
            trailing: Text('${profile.badges.length} badges'),
            onTap: () => _navigateToBadges(profile),
          ),
        ],

        ListTile(
          leading: const Icon(Icons.photo_frame, color: Colors.purple),
          title: const Text('Frames'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _navigateToFrames(profile),
        ),

        ListTile(
          leading: const Icon(Icons.emoji_events, color: Colors.orange),
          title: const Text('Achievements'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _navigateToAchievements(profile),
        ),

        if (_isCurrentUser) ...<>[
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _navigateToSettings,
          ),
          ListTile(
            leading: const Icon(Icons.block, color: Colors.red),
            title: const Text('Blocked Users'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _navigateToBlocked,
          ),
        ],
      ],
    );
  }

  void _navigateToEditProfile(ProfileModel profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => EditProfileScreen(profile: profile),
      ),
    );
  }

  void _navigateToChat(ProfileModel profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => ChatDetailScreen(
          userId: profile.userId,
          userName: profile.displayNameOrUsername,
          userAvatar: profile.avatar,
        ),
      ),
    );
  }

  void _navigateToBadges(ProfileModel profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => BadgesScreen(userId: profile.userId),
      ),
    );
  }

  void _navigateToFrames(ProfileModel profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => FramesScreen(userId: profile.userId),
      ),
    );
  }

  void _navigateToAchievements(ProfileModel profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => AchievementsScreen(userId: profile.userId),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  void _navigateToBlocked() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const BlockedUsersScreen(),
      ),
    );
  }

  void _toggleFollow(String userId) {
    // Implement follow/unfollow
  }

  void _shareProfile(ProfileModel profile) {
    // Implement share
  }

  void _launchUrl(String url) {
    // Implement URL launch
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}