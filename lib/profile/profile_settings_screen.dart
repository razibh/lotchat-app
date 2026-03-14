import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/constants/shared_pref_keys.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../mixins/dialog_mixin.dart';
import '../../auth/login_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> with DialogMixin {
  final NotificationService _notificationService = ServiceLocator().get<NotificationService>();
  final AuthService _authService = ServiceLocator().get<AuthService>();

  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkMode = false;
  String _language = 'English';
  String _privacyLevel = 'Public';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    // Load from shared preferences
    setState(() {
      _notificationsEnabled = true;
      _soundEnabled = true;
      _vibrationEnabled = true;
      _darkMode = false;
      _language = 'English';
      _privacyLevel = 'Public';
    });
  }

  Future<void> _logout() async {
    final bool? confirmed = await showConfirmDialog(
      context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
    );

    if (confirmed ?? false) {
      try {
        await _authService.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
        _notificationService.showSuccess('Logged out successfully');
      } catch (e) {
        _notificationService.showError('Failed to logout');
      }
    }
  }

  Future<void> _deleteAccount() async {
    final bool? confirmed = await showConfirmDialog(
      context,
      title: 'Delete Account',
      message: 'Are you sure you want to delete your account? This action cannot be undone.',
    );

    if (confirmed ?? false) {
      // Implement account deletion
      _notificationService.showInfo('Account deletion requested');
    }
  }

  void _changeLanguage() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <String>[
            'English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese', 'Korean', 'Hindi', 'Bengali',
          ].map((String lang) => ListTile(
                title: Text(lang),
                onTap: () {
                  setState(() => _language = lang);
                  Navigator.pop(context);
                  _notificationService.showSuccess('Language changed to $lang');
                },
              ),).toList(),
        ),
      ),
    );
  }

  void _changePrivacyLevel() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Privacy Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <String>[
            'Public', 'Friends Only', 'Private',
          ].map((String level) => ListTile(
                title: Text(level),
                subtitle: Text(_getPrivacyDescription(level)),
                onTap: () {
                  setState(() => _privacyLevel = level);
                  Navigator.pop(context);
                  _notificationService.showSuccess('Privacy level updated');
                },
              ),).toList(),
        ),
      ),
    );
  }

  String _getPrivacyDescription(String level) {
    switch (level) {
      case 'Public':
        return 'Everyone can see your profile and posts';
      case 'Friends Only':
        return 'Only your friends can see your profile';
      case 'Private':
        return 'Only you can see your profile';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.grey,
      ),
      body: ListView(
        children: <>[
          // Account Section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            child: Column(
              children: <>[
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/profile/edit');
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.lock, color: Colors.green),
                  title: const Text('Privacy'),
                  subtitle: Text(_privacyLevel),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _changePrivacyLevel,
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.orange),
                  title: const Text('Notifications'),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (bool value) {
                      setState(() => _notificationsEnabled = value);
                      _notificationService.showSuccess(
                        value ? 'Notifications enabled' : 'Notifications disabled',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Appearance Section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Appearance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            child: Column(
              children: <>[
                ListTile(
                  leading: const Icon(Icons.brightness_4, color: Colors.purple),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: _darkMode,
                    onChanged: (bool value) {
                      setState(() => _darkMode = value);
                      context.read<ThemeProvider>().toggleTheme();
                    },
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.language, color: Colors.teal),
                  title: const Text('Language'),
                  subtitle: Text(_language),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _changeLanguage,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Sound & Vibration
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Sound & Vibration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            child: Column(
              children: <>[
                ListTile(
                  leading: const Icon(Icons.volume_up, color: Colors.blue),
                  title: const Text('Sound Effects'),
                  trailing: Switch(
                    value: _soundEnabled,
                    onChanged: (bool value) {
                      setState(() => _soundEnabled = value);
                    },
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.vibration, color: Colors.orange),
                  title: const Text('Vibration'),
                  trailing: Switch(
                    value: _vibrationEnabled,
                    onChanged: (bool value) {
                      setState(() => _vibrationEnabled = value);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Privacy & Security
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Privacy & Security',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            child: Column(
              children: <>[
                ListTile(
                  leading: const Icon(Icons.block, color: Colors.red),
                  title: const Text('Blocked Users'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/blocked');
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.security, color: Colors.green),
                  title: const Text('Two-Factor Authentication'),
                  subtitle: const Text('Enhance account security'),
                  trailing: Switch(
                    value: false,
                    onChanged: (bool value) {},
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.history, color: Colors.blue),
                  title: const Text('Login History'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Data & Storage
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Data & Storage',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            child: Column(
              children: <>[
                ListTile(
                  leading: const Icon(Icons.storage, color: Colors.blue),
                  title: const Text('Storage Usage'),
                  subtitle: const Text('245 MB used'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.cloud_download, color: Colors.green),
                  title: const Text('Download Quality'),
                  subtitle: const Text('Auto'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Clear Cache'),
                  subtitle: const Text('Free up storage space'),
                  onTap: () {
                    _notificationService.showSuccess('Cache cleared');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // About & Support
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'About & Support',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            child: Column(
              children: <>[
                ListTile(
                  leading: const Icon(Icons.info, color: Colors.blue),
                  title: const Text('About LotChat'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.help, color: Colors.green),
                  title: const Text('Help Center'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.feedback, color: Colors.orange),
                  title: const Text('Send Feedback'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: const Text('Rate the App'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomButton(
              text: 'Logout',
              onPressed: _logout,
              color: Colors.red,
            ),
          ),

          const SizedBox(height: 12),

          // Delete Account
          Center(
            child: TextButton(
              onPressed: _deleteAccount,
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete Account'),
            ),
          ),

          const SizedBox(height: 16),

          // App Version
          const Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}