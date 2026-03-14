import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/user_models.dart';
import '../../core/services/navigation_service.dart';

class RoleBasedDrawer extends StatelessWidget {

  const RoleBasedDrawer({
    required this.user, required this.onLogout, super.key,
  });
  final User? user;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surfaceDark,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        children: <>[
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: _getDrawerItems(context),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <>[
            AppColors.accentPurple,
            AppColors.accentBlue,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <>[
            // Avatar with badge
            Stack(
              children: <>[
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: user?.avatar != null
                      ? NetworkImage(user!.avatar!)
                      : null,
                  child: user?.avatar == null
                      ? Text(
                          user?.initials ?? 'U',
                          style: const TextStyle(
                            color: AppColors.accentPurple,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                if (user?.badge != null && user!.badge!.hasBadge)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: user!.badge!.badgeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        _getBadgeIcon(user!.badge!.type),
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // User name
            Text(
              user?.displayName ?? 'Guest User',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            // User email
            Text(
              user?.email ?? 'guest@example.com',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            // User role badge
            if (user != null) ...<>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <>[
                    Icon(
                      _getRoleIcon(user!.role),
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getRoleName(user!.role),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _getDrawerItems(BuildContext context) {
    if (user == null) {
      return _getGuestItems(context);
    }

    switch (user!.role) {
      case UserRole.admin:
        return _getAdminItems(context);
      case UserRole.countryManager:
        return _getCountryManagerItems(context);
      case UserRole.agency:
        return _getAgencyItems(context);
      case UserRole.coinSeller:
        return _getCoinSellerItems(context);
      case UserRole.host:
        return _getHostItems(context);
      default:
        return _getUserItems(context);
    }
  }

  List<Widget> _getGuestItems(BuildContext context) {
    return <>[
      _buildSectionHeader('Main Menu'),
      _buildDrawerItem(
        icon: Icons.home,
        title: 'Home',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/home');
        },
      ),
      _buildDrawerItem(
        icon: Icons.explore,
        title: 'Explore',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/explore');
        },
      ),
      _buildDrawerItem(
        icon: Icons.sports_esports,
        title: 'Games',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/games');
        },
      ),
      const Divider(color: Colors.white24),
      _buildSectionHeader('Account'),
      _buildDrawerItem(
        icon: Icons.login,
        title: 'Login',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/login');
        },
      ),
      _buildDrawerItem(
        icon: Icons.app_registration,
        title: 'Register',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/register');
        },
      ),
      const Divider(color: Colors.white24),
      _buildSectionHeader('Support'),
      _buildDrawerItem(
        icon: Icons.help,
        title: 'Help Center',
        onTap: () {
          Navigator.pop(context);
          _showComingSoon(context);
        },
      ),
      _buildDrawerItem(
        icon: Icons.info,
        title: 'About',
        onTap: () {
          Navigator.pop(context);
          _showAboutDialog(context);
        },
      ),
      _buildDrawerItem(
        icon: Icons.privacy_tip,
        title: 'Privacy Policy',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/webview', arguments: <String, String>{
            'title': 'Privacy Policy',
            'url': 'https://gamelive.com/privacy',
          },);
        },
      ),
      _buildDrawerItem(
        icon: Icons.description,
        title: 'Terms of Service',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/webview', arguments: <String, String>{
            'title': 'Terms of Service',
            'url': 'https://gamelive.com/terms',
          },);
        },
      ),
    ];
  }

  List<Widget> _getUserItems(BuildContext context) {
    return <>[
      _buildSectionHeader('Main Menu'),
      _buildDrawerItem(
        icon: Icons.home,
        title: 'Home',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/home');
        },
      ),
      _buildDrawerItem(
        icon: Icons.explore,
        title: 'Explore',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/explore');
        },
      ),
      _buildDrawerItem(
        icon: Icons.sports_esports,
        title: 'Games',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/games');
        },
      ),
      _buildDrawerItem(
        icon: Icons.account_balance_wallet,
        title: 'Wallet',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/wallet');
        },
      ),
      const Divider(color: Colors.white24),
      _buildSectionHeader('Social'),
      _buildDrawerItem(
        icon: Icons.people,
        title: 'Friends',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/friends');
        },
      ),
      _buildDrawerItem(
        icon: Icons.group,
        title: 'Communities',
        onTap: () {
          Navigator.pop(context);
          _showComingSoon(context);
        },
      ),
      _buildDrawerItem(
        icon: Icons.message,
        title: 'Messages',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/chats');
        },
        trailing: _buildBadge('3'),
      ),
      _buildDrawerItem(
        icon: Icons.notifications,
        title: 'Notifications',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/notifications');
        },
        trailing: _buildBadge('5'),
      ),
      const Divider(color: Colors.white24),
      _buildSectionHeader('Account'),
      _buildDrawerItem(
        icon: Icons.person,
        title: 'Profile',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/profile');
        },
      ),
      _buildDrawerItem(
        icon: Icons.settings,
        title: 'Settings',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/settings');
        },
      ),
      _buildDrawerItem(
        icon: Icons.history,
        title: 'History',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/history');
        },
      ),
      const Divider(color: Colors.white24),
      _buildSectionHeader('Support'),
      _buildDrawerItem(
        icon: Icons.help,
        title: 'Help Center',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/webview', arguments: <String, String>{
            'title': 'Help Center',
            'url': 'https://gamelive.com/help',
          },);
        },
      ),
      _buildDrawerItem(
        icon: Icons.support_agent,
        title: 'Contact Support',
        onTap: () {
          Navigator.pop(context);
          _showContactSupport(context);
        },
      ),
      _buildDrawerItem(
        icon: Icons.report,
        title: 'Report an Issue',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/report');
        },
      ),
    ];
  }

  List<Widget> _getAdminItems(BuildContext context) {
    return <>[
      _buildSectionHeader('Admin Dashboard'),
      _buildDrawerItem(
        icon: Icons.dashboard,
        title: 'Dashboard',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/admin/dashboard');
        },
      ),
      _buildDrawerItem(
        icon: Icons.public,
        title: 'Country Managers',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/admin/country-managers');
        },
      ),
      _buildDrawerItem(
        icon: Icons.business,
        title: 'Agencies',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/admin/agencies');
        },
        trailing: _buildBadge('5', color: Colors.orange),
      ),
      _buildDrawerItem(
        icon: Icons.store,
        title: 'Coin Sellers',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/admin/sellers');
        },
        trailing: _buildBadge('3', color: Colors.orange),
      ),
      _buildDrawerItem(
        icon: Icons.people,
        title: 'Users',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/admin/users');
        },
      ),
      _buildDrawerItem(
        icon: Icons.report,
        title: 'Reports',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/admin/reports');
        },
        trailing: _buildBadge('12'),
      ),
      const Divider(color: Colors.white24),
      _buildSectionHeader('Management'),
      _buildDrawerItem(
        icon: Icons.games,
        title: 'Games',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/admin/games');
        },
      ),
      _buildDrawerItem(
        icon: Icons.card_giftcard,
        title: 'Gifts',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/admin/gifts');
        },
      ),
      _buildDrawerItem(
        icon: Icons.analytics,
        title: 'Analytics',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/admin/analytics');
        },
      ),
      _buildDrawerItem(
        icon: Icons.settings,
        title: 'Settings',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/admin/settings');
        },
      ),
    ];
  }

  List<Widget> _getCountryManagerItems(BuildContext context) {
    return <>[
      _buildSectionHeader('Country Manager'),
      _buildDrawerItem(
        icon: Icons.dashboard,
        title: 'Dashboard',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/country-manager/dashboard', arguments: <String, String?>{
            'managerId': user?.id,
          },);
        },
      ),
      _buildDrawerItem(
        icon: Icons.business,
        title: 'Manage Agencies',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/country-manager/agencies', arguments: <String, String?>{
            'managerId': user?.id,
            'countryId': user?.countryId,
            'countryName': _getCountryName(user?.countryId),
          },);
        },
        trailing: _buildBadge('8'),
      ),
      _buildDrawerItem(
        icon: Icons.person_add,
        title: 'Recruit Agency',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/country-manager/recruit', arguments: <String, String?>{
            'managerId': user?.id,
          },);
        },
      ),
      _buildDrawerItem(
        icon: Icons.people,
        title: 'Monitor Hosts',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/country-manager/hosts', arguments: <String, String?>{
            'managerId': user?.id,
          },);
        },
      ),
      _buildDrawerItem(
        icon: Icons.warning,
        title: 'Issues',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/country-manager/issues', arguments: <String, String?>{
            'managerId': user?.id,
          },);
        },
        trailing: _buildBadge('3'),
      ),
      _buildDrawerItem(
        icon: Icons.analytics,
        title: 'Reports',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/country-manager/reports', arguments: <String, String?>{
            'managerId': user?.id,
          },);
        },
      ),
      const Divider(color: Colors.white24),
      _buildDrawerItem(
        icon: Icons.percent,
        title: 'Commission Settings',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/country-manager/commission', arguments: <String, String?>{
            'managerId': user?.id,
          },);
        },
      ),
      _buildDrawerItem(
        icon: Icons.settings,
        title: 'Settings',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/settings');
        },
      ),
    ];
  }

  List<Widget> _getAgencyItems(BuildContext context) {
    return <>[
      _buildSectionHeader('Agency Dashboard'),
      _buildDrawerItem(
        icon: Icons.dashboard,
        title: 'Dashboard',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/agency/dashboard', arguments: <String, dynamic>{
            'agencyId': user?.metadata?['agencyId'],
          },);
        },
      ),
      _buildDrawerItem(
        icon: Icons.people,
        title: 'Manage Hosts',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/agency/hosts', arguments: <String, dynamic>{
            'agencyId': user?.metadata?['agencyId'],
          },);
        },
        trailing: _buildBadge('4'),
      ),
      _buildDrawerItem(
        icon: Icons.person_add,
        title: 'Recruit Host',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/agency/recruit-host', arguments: <String, dynamic>{
            'agencyId': user?.metadata?['agencyId'],
          },);
        },
      ),
      _buildDrawerItem(
        icon: Icons.money,
        title: 'Earnings',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/agency/earnings', arguments: <String, dynamic>{
            'agencyId': user?.metadata?['agencyId'],
          },);
        },
      ),
      _buildDrawerItem(
        icon: Icons.percent,
        title: 'Commission',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/agency/commission', arguments: <String, dynamic>{
            'agencyId': user?.metadata?['agencyId'],
          },);
        },
      ),
      const Divider(color: Colors.white24),
      _buildDrawerItem(
        icon: Icons.analytics,
        title: 'Analytics',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/agency/analytics', arguments: <String, dynamic>{
            'agencyId': user?.metadata?['agencyId'],
          },);
        },
      ),
      _buildDrawerItem(
        icon: Icons.settings,
        title: 'Settings',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/settings');
        },
      ),
    ];
  }

  List<Widget> _getCoinSellerItems(BuildContext context) {
    return <>[
      _buildSectionHeader('Seller Dashboard'),
      _buildDrawerItem(
        icon: Icons.dashboard,
        title: 'Dashboard',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/seller/dashboard', arguments: <String, dynamic>{
            'sellerId': user?.metadata?['sellerId'],
          },);
        },
      ),
      _buildDrawerItem(
        icon: Icons.inventory,
        title: 'Inventory',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/seller/inventory', arguments: <String, dynamic>{
            'sellerId': user?.metadata?['sellerId'],
          },);
        },
      ),
      _buildDrawerItem(
        icon: Icons.send,
        title: 'Transfer Coins',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/seller/transfer', arguments: <String, dynamic>{
            'sellerId': user?.metadata?['sellerId'],
          },);
        },
      ),
      _buildDrawerItem(
        icon: Icons.shopping_bag,
        title: 'Packages',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/seller/packages', arguments: <String, dynamic>{
            'sellerId': user?.metadata?['sellerId'],
          },);
        },
      ),
      _buildDrawerItem(
        icon: Icons.money,
        title: 'Earnings',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/seller/earnings', arguments: <String, dynamic>{
            'sellerId': user?.metadata?['sellerId'],
          },);
        },
      ),
      _buildDrawerItem(
        icon: Icons.people,
        title: 'Customers',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/seller/customers', arguments: <String, dynamic>{
            'sellerId': user?.metadata?['sellerId'],
          },);
        },
      ),
      const Divider(color: Colors.white24),
      _buildDrawerItem(
        icon: Icons.analytics,
        title: 'Sales Analytics',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/seller/analytics', arguments: <String, dynamic>{
            'sellerId': user?.metadata?['sellerId'],
          },);
        },
      ),
      _buildDrawerItem(
        icon: Icons.settings,
        title: 'Settings',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/settings');
        },
      ),
    ];
  }

  List<Widget> _getHostItems(BuildContext context) {
    return <>[
      _buildSectionHeader('Host Dashboard'),
      _buildDrawerItem(
        icon: Icons.dashboard,
        title: 'Dashboard',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/host/dashboard', arguments: <String, String?>{
            'hostId': user?.id,
          },);
        },
      ),
      _buildDrawerItem(
        icon: Icons.video_call,
        title: 'Go Live',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/host/go-live', arguments: <String, String?>{
            'hostId': user?.id,
          },);
        },
      ),
      _buildDrawerItem(
        icon: Icons.money,
        title: 'Earnings',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/host/earnings', arguments: <String, String?>{
            'hostId': user?.id,
          },);
        },
      ),
      _buildDrawerItem(
        icon: Icons.analytics,
        title: 'Analytics',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/host/analytics', arguments: <String, String?>{
            'hostId': user?.id,
          },);
        },
      ),
      _buildDrawerItem(
        icon: Icons.people,
        title: 'Followers',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/host/followers', arguments: <String, String?>{
            'hostId': user?.id,
          },);
        },
      ),
      _buildDrawerItem(
        icon: Icons.schedule,
        title: 'Schedule',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/host/schedule', arguments: <String, String?>{
            'hostId': user?.id,
          },);
        },
      ),
      _buildDrawerItem(
        icon: Icons.card_giftcard,
        title: 'Gifts',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/host/gifts', arguments: <String, String?>{
            'hostId': user?.id,
          },);
        },
      ),
      const Divider(color: Colors.white24),
      _buildDrawerItem(
        icon: Icons.star,
        title: 'Achievements',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/host/achievements', arguments: <String, String?>{
            'hostId': user?.id,
          },);
        },
      ),
      _buildDrawerItem(
        icon: Icons.settings,
        title: 'Settings',
        onTap: () {
          Navigator.pop(context);
          NavigationService.navigateTo('/settings');
        },
      ),
    ];
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.white70),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.accentPurple,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildBadge(String count, {Color color = Colors.red}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <>[
          const Divider(color: Colors.white24),
          if (user != null) ...<>[
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: _showLogoutConfirmation,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  IconData _getBadgeIcon(BadgeType type) {
    switch (type) {
      case BadgeType.agency:
        return Icons.business;
      case BadgeType.coinSeller:
        return Icons.store;
      case BadgeType.official:
        return Icons.verified;
      case BadgeType.vip:
        return Icons.star;
      case BadgeType.host:
        return Icons.mic;
      case BadgeType.moderator:
        return Icons.security;
      case BadgeType.streamer:
        return Icons.live_tv;
      default:
        return Icons.person;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.countryManager:
        return Icons.public;
      case UserRole.agency:
        return Icons.business;
      case UserRole.coinSeller:
        return Icons.store;
      case UserRole.host:
        return Icons.mic;
      default:
        return Icons.person;
    }
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.countryManager:
        return 'Country Manager';
      case UserRole.agency:
        return 'Agency Owner';
      case UserRole.coinSeller:
        return 'Coin Seller';
      case UserRole.host:
        return 'Host';
      default:
        return 'User';
    }
  }

  String _getCountryName(String? countryId) {
    switch (countryId) {
      case 'bd':
        return 'Bangladesh';
      case 'in':
        return 'India';
      case 'pk':
        return 'Pakistan';
      case 'np':
        return 'Nepal';
      case 'lk':
        return 'Sri Lanka';
      default:
        return 'Unknown';
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: NavigationService.navigatorKey.currentContext!,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: <>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This feature is coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showContactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text(
          'Contact Support',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text(
                'Email',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'support@gamelive.com',
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () {
                Navigator.pop(context);
                // Launch email
              },
            ),
            ListTile(
              leading: const Icon(Icons.telegram, color: Colors.blue),
              title: const Text(
                'Telegram',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                '@gamelive_support',
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () {
                Navigator.pop(context);
                // Launch telegram
              },
            ),
            ListTile(
              leading: const Icon(Icons.discord, color: Colors.purple),
              title: const Text(
                'Discord',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'discord.gg/gamelive',
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () {
                Navigator.pop(context);
                // Launch discord
              },
            ),
          ],
        ),
        actions: <>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text(
          'About',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentPurple.withValues(alpha: 0.2),
              ),
              child: const Icon(
                Icons.sports_esports,
                size: 50,
                color: AppColors.accentPurple,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Game & Live Platform',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            const Text(
              'A complete platform for gaming and live streaming with agency, host, and coin seller management.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: <>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<User?>('user', user));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onLogout', onLogout));
  }
}