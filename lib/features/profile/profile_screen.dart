import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/models/user_models.dart';
import '../../widgets/badge_widget.dart';
import '../../widgets/frame_widget.dart';
import '../../core/services/user_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/analytics_service.dart';
import '../../core/di/service_locator.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/empty_state_widget.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final bool isOwnProfile;

  const ProfileScreen({
    super.key,
    required this.userId,
    this.isOwnProfile = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('userId', userId));
    properties.add(DiagnosticsProperty<bool>('isOwnProfile', isOwnProfile));
  }
}

class _ProfileScreenState extends State<ProfileScreen> with LoadingMixin, ToastMixin {
  bool isEditing = false;
  User? user;
  String? _currentUserId;
  bool _isFollowing = false;
  bool _isFriend = false;
  bool _hasSentRequest = false;

  final ImagePicker _picker = ImagePicker();
  final UserService _userService = ServiceLocator().get<UserService>();
  final AuthService _authService = ServiceLocator().get<AuthService>();
  final AnalyticsService _analyticsService = ServiceLocator().get<AnalyticsService>();

  // Text controllers for editing
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late TextEditingController _websiteController;

  List<String> _selectedInterests = [];

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadUser();
    _getCurrentUser();
  }

  void _initControllers() {
    _bioController = TextEditingController();
    _locationController = TextEditingController();
    _websiteController = TextEditingController();
  }

  Future<void> _getCurrentUser() async {
    final currentUser = await _authService.getCurrentUser();
    setState(() {
      _currentUserId = currentUser?.uid;
    });
  }

  Future<void> _loadUser() async {
    showLoading(); // LoadingMixin এর showLoading() ব্যবহার

    try {
      final loadedUser = await _userService.getUserById(widget.userId);

      setState(() {
        user = loadedUser;
        _selectedInterests = List.from(user?.interests ?? []);
        _bioController.text = user?.bio ?? '';
        _locationController.text = user?.location ?? '';
        _websiteController.text = user?.website ?? '';
      });

      hideLoading(); // LoadingMixin এর hideLoading() ব্যবহার

      // Check relationship if not own profile
      if (!widget.isOwnProfile && _currentUserId != null) {
        _checkRelationship();
      }

      _analyticsService.trackScreen(
        'ProfileScreen',
        screenClass: 'ProfileScreen',
        parameters: {'user_id': widget.userId},
      );

    } catch (e, stackTrace) {
      hideLoading();

      _analyticsService.trackError(
        errorMessage: e.toString(),
        screen: 'ProfileScreen',
        stackTrace: stackTrace,
      );

      showError('Failed to load profile: $e');
    }
  }

  Future<void> _checkRelationship() async {
    // Check if following
    final following = await _userService.isFollowing(_currentUserId!, widget.userId);

    setState(() {
      _isFollowing = following;
    });
  }

  Future<void> _toggleFollow() async {
    if (_currentUserId == null) {
      showError('Please login to follow users');
      return;
    }

    try {
      showButtonLoading(); // LoadingMixin এর showButtonLoading() ব্যবহার

      bool success;
      if (_isFollowing) {
        success = await _userService.unfollowUser(_currentUserId!, widget.userId);
      } else {
        success = await _userService.followUser(_currentUserId!, widget.userId);
      }

      hideButtonLoading(); // LoadingMixin এর hideButtonLoading() ব্যবহার

      if (success) {
        setState(() {
          _isFollowing = !_isFollowing;
        });

        _analyticsService.trackEvent(
          _isFollowing ? 'follow_user' : 'unfollow_user',
          parameters: {
            'user_id': _currentUserId,
            'target_user_id': widget.userId,
          },
        );

        showSuccess(_isFollowing ? 'Following' : 'Unfollowed');
      }
    } catch (e) {
      hideButtonLoading();
      showError('Failed to ${_isFollowing ? 'unfollow' : 'follow'} user');
    }
  }

  Future<void> _sendFriendRequest() async {
    // Implement friend request logic
    setState(() {
      _hasSentRequest = true;
    });
    showSuccess('Friend request sent');
  }

  Future<void> _saveProfile() async {
    try {
      showLoading('Saving...');

      final updateData = {
        'bio': _bioController.text,
        'location': _locationController.text,
        'website': _websiteController.text,
        'interests': _selectedInterests,
      };

      final success = await _userService.updateProfile(widget.userId, updateData);

      hideLoading();

      if (success) {
        setState(() {
          isEditing = false;
          user = user?.copyWith(
            bio: _bioController.text,
            location: _locationController.text,
            website: _websiteController.text,
            interests: _selectedInterests,
          );
        });

        _analyticsService.trackEvent(
          'profile_updated',
          parameters: {'user_id': widget.userId},
        );

        showSuccess('Profile updated successfully');
      } else {
        showError('Failed to update profile');
      }

    } catch (e) {
      hideLoading();
      showError('Failed to update profile: $e');
    }
  }

  Future<void> _changeProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Upload image and update user
      showSuccess('Profile picture updated');
    }
  }

  void _cancelEditing() {
    setState(() {
      isEditing = false;
      _bioController.text = user?.bio ?? '';
      _locationController.text = user?.location ?? '';
      _websiteController.text = user?.website ?? '';
      _selectedInterests = List.from(user?.interests ?? []);
    });
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || user == null) {  // isLoading ব্যবহার করুন (_isLoading না)
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  _buildBioSection(),
                  const SizedBox(height: 24),
                  _buildInterestsSection(),
                  const SizedBox(height: 24),
                  _buildLocationSection(),
                  const SizedBox(height: 24),
                  _buildBadgesSection(),
                  const SizedBox(height: 24),
                  _buildRecentActivity(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }
  Widget _buildSliverAppBar() {
    // ফ্রেম পাথ নির্ধারণের জন্য হেল্পার ফাংশন
    String _getFramePath(UserTier? tier) {
      if (tier == null) return 'assets/frames/default_frame.png';

      if (tier.toString().contains('vip')) {
        return 'assets/frames/vip_frame.png';
      } else if (tier.toString().contains('svip')) {
        return 'assets/frames/svip_frame.png';
      }
      return 'assets/frames/default_frame.png';
    }

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.purple,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover Image
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.purple,
                    Colors.pink,
                  ],
                ),
              ),
            ),

            // Profile Info Overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black54,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Profile Picture with Frame
                    Stack(
                      children: [
                        FrameWidget(
                          framePath: _getFramePath(user!.tier), // ✅ framePath দিতে হবে
                          size: 80,
                          child: CircleAvatar(
                            radius: 35,
                            backgroundImage: user!.avatar != null
                                ? NetworkImage(user!.avatar!)
                                : null,
                            child: user!.avatar == null
                                ? Text(
                              user!.name[0].toUpperCase(),
                              style: const TextStyle(fontSize: 30),
                            )
                                : null,
                          ),
                        ),
                        if (widget.isOwnProfile && isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _changeProfilePicture,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.purple,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user!.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '@${user!.username}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              BadgeWidget(
                                tier: user!.tier ?? UserTier.normal, // ✅ tier দিতে হবে
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'ID: ${user!.id.substring(0, 8)}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (widget.isOwnProfile && !isEditing)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            isEditing = true;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          'Coins',
          _formatNumber(user!.coins),
          Icons.monetization_on,
          Colors.amber,
        ),
        _buildStatItem(
          'Diamonds',
          _formatNumber(user!.diamonds),
          Icons.diamond,
          Colors.cyan,
        ),
        _buildStatItem(
          'Followers',
          _formatNumber(user!.stats?.followers ?? 0),
          Icons.people,
          Colors.blue,
        ),
        _buildStatItem(
          'Following',
          _formatNumber(user!.stats?.following ?? 0),
          Icons.person_add,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    if (isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _bioController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Write something about yourself...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            user!.bio?.isNotEmpty == true ? user!.bio! : 'No bio yet',
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    final allInterests = ['Music', 'Travel', 'Gaming', 'Sports', 'Art', 'Food', 'Tech', 'Fashion'];

    if (isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Interests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allInterests.map((interest) {
              final isSelected = _selectedInterests.contains(interest);
              return FilterChip(
                label: Text(interest),
                selected: isSelected,
                onSelected: (_) => _toggleInterest(interest),
                backgroundColor: Colors.grey[100],
                selectedColor: Colors.purple.withValues(alpha: 0.2),
                checkmarkColor: Colors.purple,
              );
            }).toList(),
          ),
        ],
      );
    }

    if (user!.interests.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Interests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: user!.interests.map((interest) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                interest,
                style: const TextStyle(color: Colors.purple),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    if (isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              hintText: 'City, Country',
              prefixIcon: const Icon(Icons.location_on),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Website', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _websiteController,
            decoration: InputDecoration(
              hintText: 'https://example.com',
              prefixIcon: const Icon(Icons.link),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ],
      );
    }

    if (user!.location == null && user!.website == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (user!.location != null) ...[
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(user!.location!),
            ],
          ),
          const SizedBox(height: 4),
        ],
        if (user!.website != null) ...[
          Row(
            children: [
              const Icon(Icons.link, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(user!.website!),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Badges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 8,
            itemBuilder: (context, index) {
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Badge ${index + 1}',
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple.withValues(alpha: 0.1),
                child: const Icon(Icons.card_giftcard, color: Colors.purple, size: 20),
              ),
              title: const Text('Received a gift'),
              subtitle: Text('${index + 1} hours ago'),
              trailing: const Text('+100', style: TextStyle(color: Colors.green)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    if (widget.isOwnProfile && isEditing) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Save Changes'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _cancelEditing,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      );
    }

    if (widget.isOwnProfile) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _toggleFollow,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFollowing ? Colors.grey : Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(_isFollowing ? 'Following' : 'Follow'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: _sendFriendRequest,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.purple,
                side: const BorderSide(color: Colors.purple),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Add Friend'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bioController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    super.dispose();
  }
}