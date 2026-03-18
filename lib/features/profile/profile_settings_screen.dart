import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/user_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/storage_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../core/models/user_models.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final String userId;

  const ProfileSettingsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('userId', userId));
  }
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen>
    with LoadingMixin, ToastMixin {

  final UserService _userService = ServiceLocator.instance.get<UserService>();
  final AuthService _authService = ServiceLocator.instance.get<AuthService>();
  final AnalyticsService _analyticsService = ServiceLocator.instance.get<AnalyticsService>();
  final StorageService _storageService = ServiceLocator.instance.get<StorageService>();

  User? _user;
  bool _isLoading = true;
  String? _errorMessage;

  // Settings state
  bool _isPrivate = false;
  bool _showOnlineStatus = true;
  bool _allowFriendRequests = true;
  bool _allowMessages = true;
  bool _allowGifts = true;
  bool _allowComments = true;
  bool _saveHistory = true;
  bool _autoPlay = true;
  int _videoQuality = 720;

  // Notification settings
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // Security settings
  bool _twoFactorEnabled = false;
  bool _biometricEnabled = false;
  String? _pinCode;
  bool _pinEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();

    _analyticsService.trackScreen(
      'ProfileSettings',
      screenClass: 'ProfileSettingsScreen',
    );
  }

  Future<void> _loadUserSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _userService.getUserById(widget.userId);

      setState(() {
        _user = user;

        if (user?.settings != null) {
          _isPrivate = user!.settings!.privateAccount;
          _showOnlineStatus = user.settings!.showOnlineStatus;
          _allowFriendRequests = user.settings!.allowFriendRequests;
          _allowMessages = user.settings!.allowMessages;
          _allowGifts = user.settings!.allowGifts;
          _allowComments = user.settings!.allowComments;
          _saveHistory = user.settings!.saveHistory;
          _autoPlay = user.settings!.autoPlay;
          _videoQuality = user.settings!.videoQuality;

          // Notification settings
          _notificationsEnabled = user.settings!.notifications;
          _soundEnabled = user.settings!.soundEnabled;
          _vibrationEnabled = user.settings!.vibrationEnabled;
        }

        _isLoading = false;
      });

    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      _analyticsService.trackError(
        errorMessage: e.toString(),
        screen: 'ProfileSettingsScreen',
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _saveSettings() async {
    try {
      showLoading('Saving settings...');

      final updateData = {
        'settings': {
          'privateAccount': _isPrivate,
          'showOnlineStatus': _showOnlineStatus,
          'allowFriendRequests': _allowFriendRequests,
          'allowMessages': _allowMessages,
          'allowGifts': _allowGifts,
          'allowComments': _allowComments,
          'saveHistory': _saveHistory,
          'autoPlay': _autoPlay,
          'videoQuality': _videoQuality,

          'notifications': _notificationsEnabled,
          'soundEnabled': _soundEnabled,
          'vibrationEnabled': _vibrationEnabled,
        },
        'twoFactorEnabled': _twoFactorEnabled,
      };

      final success = await _userService.updateProfile(widget.userId, updateData);

      hideLoading();

      if (success) {
        _analyticsService.trackEvent(
          'profile_settings_updated',
          parameters: {'user_id': widget.userId},
        );

        showSuccess('Settings saved successfully');
        Navigator.pop(context, true);
      } else {
        showError('Failed to save settings');
      }

    } catch (e) {
      hideLoading();
      showError('Failed to save settings: $e');
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performLogout();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      showLoading('Logging out...');

      await _authService.signOut(); // logout এর পরিবর্তে signOut
      await _storageService.clearUserData();

      hideLoading();

      _analyticsService.trackEvent('user_logout');

      // Navigate to login screen
      Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
              (route) => false
      );

    } catch (e) {
      hideLoading();
      showError('Failed to logout: $e');
    }
  }

  Future<void> _deleteAccount() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone. All your data will be permanently removed.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performDeleteAccount();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteAccount() async {
    try {
      showLoading('Deleting account...');

      final success = await _userService.deleteAccount(widget.userId);

      hideLoading();

      if (success) {
        _analyticsService.trackEvent('account_deleted');

        // Navigate to login screen
        Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
                (route) => false
        );

      } else {
        showError('Failed to delete account');
      }

    } catch (e) {
      hideLoading();
      showError('Failed to delete account: $e');
    }
  }

  Future<void> _changePassword() async {
    // Navigate to change password screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => ChangePasswordScreen(userId: widget.userId),
    //   ),
    // );
  }

  Future<void> _setupPin() async {
    // Navigate to PIN setup screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Profile Settings'),
      backgroundColor: Colors.purple,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        TextButton(
          onPressed: _saveSettings,
          child: const Text(
            'Save',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserSettings,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAccountSettings(),
          const SizedBox(height: 16),
          _buildPrivacySettings(),
          const SizedBox(height: 16),
          _buildNotificationSettings(),
          const SizedBox(height: 16),
          _buildSecuritySettings(),
          const SizedBox(height: 16),
          _buildVideoSettings(),
          const SizedBox(height: 24),
          _buildDangerZone(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Private Account'),
              subtitle: const Text('Only followers can see your content'),
              value: _isPrivate,
              onChanged: (value) {
                setState(() {
                  _isPrivate = value;
                });
              },
              activeColor: Colors.purple,
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock, color: Colors.purple),
              ),
            ),

            const Divider(),

            SwitchListTile(
              title: const Text('Show Online Status'),
              subtitle: const Text('Let others see when you\'re online'),
              value: _showOnlineStatus,
              onChanged: (value) {
                setState(() {
                  _showOnlineStatus = value;
                });
              },
              activeColor: Colors.purple,
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.circle, color: Colors.green, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy & Permissions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Allow Friend Requests'),
              subtitle: const Text('Anyone can send you friend requests'),
              value: _allowFriendRequests,
              onChanged: (value) {
                setState(() {
                  _allowFriendRequests = value;
                });
              },
              activeColor: Colors.purple,
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_add, color: Colors.blue),
              ),
            ),

            const Divider(),

            SwitchListTile(
              title: const Text('Allow Messages'),
              subtitle: const Text('Anyone can message you'),
              value: _allowMessages,
              onChanged: (value) {
                setState(() {
                  _allowMessages = value;
                });
              },
              activeColor: Colors.purple,
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.message, color: Colors.green),
              ),
            ),

            const Divider(),

            SwitchListTile(
              title: const Text('Allow Gifts'),
              subtitle: const Text('Anyone can send you gifts'),
              value: _allowGifts,
              onChanged: (value) {
                setState(() {
                  _allowGifts = value;
                });
              },
              activeColor: Colors.purple,
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.pink.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.card_giftcard, color: Colors.pink),
              ),
            ),

            const Divider(),

            SwitchListTile(
              title: const Text('Allow Comments'),
              subtitle: const Text('Anyone can comment on your posts'),
              value: _allowComments,
              onChanged: (value) {
                setState(() {
                  _allowComments = value;
                });
              },
              activeColor: Colors.purple,
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.comment, color: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive push notifications'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              activeColor: Colors.purple,
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications, color: Colors.blue),
              ),
            ),

            const Divider(),

            SwitchListTile(
              title: const Text('Sound'),
              subtitle: const Text('Play sound for notifications'),
              value: _soundEnabled,
              onChanged: (value) {
                setState(() {
                  _soundEnabled = value;
                });
              },
              activeColor: Colors.purple,
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.volume_up, color: Colors.green),
              ),
            ),

            const Divider(),

            SwitchListTile(
              title: const Text('Vibration'),
              subtitle: const Text('Vibrate for notifications'),
              value: _vibrationEnabled,
              onChanged: (value) {
                setState(() {
                  _vibrationEnabled = value;
                });
              },
              activeColor: Colors.purple,
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.vibration, color: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock, color: Colors.blue),
              ),
              title: const Text('Change Password'),
              subtitle: const Text('Update your account password'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _changePassword,
            ),

            const Divider(),

            SwitchListTile(
              title: const Text('Two-Factor Authentication'),
              subtitle: const Text('Add extra security to your account'),
              value: _twoFactorEnabled,
              onChanged: (value) {
                setState(() {
                  _twoFactorEnabled = value;
                });
                // Implement 2FA setup
              },
              activeColor: Colors.purple,
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.security, color: Colors.green),
              ),
            ),

            const Divider(),

            SwitchListTile(
              title: const Text('Biometric Login'),
              subtitle: const Text('Use fingerprint or face to login'),
              value: _biometricEnabled,
              onChanged: (value) {
                setState(() {
                  _biometricEnabled = value;
                });
              },
              activeColor: Colors.purple,
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.fingerprint, color: Colors.orange),
              ),
            ),

            const Divider(),

            SwitchListTile(
              title: const Text('PIN Lock'),
              subtitle: const Text('Secure app with PIN code'),
              value: _pinEnabled,
              onChanged: (value) {
                setState(() {
                  _pinEnabled = value;
                });
                if (value) _setupPin();
              },
              activeColor: Colors.purple,
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pin, color: Colors.purple),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Video Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Auto-play Videos'),
              subtitle: const Text('Automatically play videos in feed'),
              value: _autoPlay,
              onChanged: (value) {
                setState(() {
                  _autoPlay = value;
                });
              },
              activeColor: Colors.purple,
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow, color: Colors.blue),
              ),
            ),

            const Divider(),

            SwitchListTile(
              title: const Text('Save History'),
              subtitle: const Text('Keep watch history'),
              value: _saveHistory,
              onChanged: (value) {
                setState(() {
                  _saveHistory = value;
                });
              },
              activeColor: Colors.purple,
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.history, color: Colors.green),
              ),
            ),

            const Divider(),

            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.settings, color: Colors.orange), // quality এর পরিবর্তে settings
              ),
              title: const Text('Video Quality'),
              subtitle: Text('$_videoQuality' + 'p'),
              trailing: DropdownButton<int>(
                value: _videoQuality,
                items: const [
                  DropdownMenuItem(value: 360, child: Text('360p')),
                  DropdownMenuItem(value: 480, child: Text('480p')),
                  DropdownMenuItem(value: 720, child: Text('720p')),
                  DropdownMenuItem(value: 1080, child: Text('1080p')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _videoQuality = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.red, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Danger Zone',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),

            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, color: Colors.red),
              ),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              subtitle: const Text('Sign out from your account'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
              onTap: _logout,
            ),

            const Divider(),

            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_forever, color: Colors.red),
              ),
              title: const Text(
                'Delete Account',
                style: TextStyle(color: Colors.red),
              ),
              subtitle: const Text('Permanently delete your account'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
              onTap: _deleteAccount,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}