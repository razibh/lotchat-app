import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/dialog_mixin.dart';
import '../../widgets/common/custom_button.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> 
    with LoadingMixin, ToastMixin, DialogMixin {
  
  final AuthService _authService = ServiceLocator().get<AuthService>();
  final StorageService _storageService = ServiceLocator().get<StorageService>();
  
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkMode = false;
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _notificationsEnabled = _storageService.areNotificationsEnabled();
      _soundEnabled = _storageService.isSoundEnabled();
      _vibrationEnabled = _storageService.isVibrationEnabled();
      _darkMode = _storageService.getThemeMode() == 'dark';
      _language = _storageService.getLanguage();
    });
  }

  Future<void> _logout() async {
    final bool? confirmed = await showConfirmDialog(
      context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
    );

    if (confirmed ?? false) {
      await runWithLoading(() async {
        await _authService.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
        showSuccess('Logged out successfully');
      });
    }
  }

  Future<void> _clearCache() async {
    final bool? confirmed = await showConfirmDialog(
      context,
      title: 'Clear Cache',
      message: 'Are you sure you want to clear app cache?',
    );

    if (confirmed ?? false) {
      await runWithLoading(() async {
        await _storageService.clearAllData();
        showSuccess('Cache cleared');
      });
    }
  }

  void _changeLanguage() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <String>['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese', 'Korean', 'Hindi', 'Bengali']
              .map((String lang) => ListTile(
                    title: Text(lang),
                    onTap: () {
                      setState(() {
                        _language = lang;
                        _storageService.setLanguage(lang);
                      });
                      Navigator.pop(context);
                      showSuccess('Language changed to $lang');
                    },
                  ),)
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blueGrey,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <>[
          // Account Section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
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
                  title: const Text('Privacy & Security'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to privacy settings
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.orange),
                  title: const Text('Notifications'),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _notificationsEnabled = value;
                        _storageService.setNotificationsEnabled(value);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Appearance Section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
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
                      setState(() {
                        _darkMode = value;
                        _storageService.setThemeMode(value ? 'dark' : 'light');
                      });
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

          // Sound Section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
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
                      setState(() {
                        _soundEnabled = value;
                        _storageService.setSoundEnabled(value);
                      });
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
                      setState(() {
                        _vibrationEnabled = value;
                        _storageService.setVibrationEnabled(value);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Storage Section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Storage',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            child: Column(
              children: <>[
                ListTile(
                  leading: const Icon(Icons.storage, color: Colors.green),
                  title: const Text('Clear Cache'),
                  subtitle: const Text('Free up storage space'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _clearCache,
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.download, color: Colors.blue),
                  title: const Text('Download Quality'),
                  subtitle: const Text('High'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Change download quality
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // About Section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'About',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            child: Column(
              children: <>[
                ListTile(
                  leading: const Icon(Icons.info, color: Colors.grey),
                  title: const Text('About LotChat'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showInfoDialog(
                      context,
                      title: 'About LotChat',
                      message: 'LotChat v1.0.0\n\nA social voice chat app where you can meet new people, play games, and have fun!',
                    );
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.privacy_tip, color: Colors.blue),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Open privacy policy
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.description, color: Colors.orange),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Open terms of service
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: const Text('Rate the App'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Open app store for rating
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Support Section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Support',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            child: Column(
              children: <>[
                ListTile(
                  leading: const Icon(Icons.help, color: Colors.purple),
                  title: const Text('Help Center'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Open help center
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.support_agent, color: Colors.green),
                  title: const Text('Contact Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Contact support
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.feedback, color: Colors.orange),
                  title: const Text('Send Feedback'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Send feedback
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout Button
          CustomButton(
            text: 'Logout',
            onPressed: _logout,
            color: Colors.red,
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