import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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

class EditProfileScreen extends StatefulWidget {
  final User? user; // UserModel → User

  const EditProfileScreen({
    super.key,
    this.user,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<User?>('user', user));
  }
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with LoadingMixin, ToastMixin {

  final UserService _userService = ServiceLocator().get<UserService>();
  final AuthService _authService = ServiceLocator().get<AuthService>();
  final AnalyticsService _analyticsService = ServiceLocator().get<AnalyticsService>();
  final StorageService _storageService = ServiceLocator().get<StorageService>();

  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late TextEditingController _websiteController;
  late TextEditingController _phoneController;

  // Image Picker
  final ImagePicker _imagePicker = ImagePicker();
  File? _profileImage;
  String? _profileImageUrl;
  File? _coverImage;
  String? _coverImageUrl;

  // User Data
  User? _currentUser; // UserModel → User
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  // Settings
  bool _isPrivate = false;
  bool _isVerified = false;
  String _selectedGender = 'Not specified';
  DateTime? _selectedDateOfBirth;

  final List<String> _genders = ['Not specified', 'Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _initControllers();
  }

  Future<void> _initializeUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = widget.user; // UserModel → User

      if (user == null) {
        final currentUser = await _authService.getCurrentUser();
        if (currentUser != null) {
          user = await _userService.getUserById(currentUser.uid);
        }
      }

      setState(() {
        _currentUser = user;
        _isLoading = false;
        _initControllersWithUser(user);
      });

      // Track screen view
      _analyticsService.trackScreen(
        'EditProfile',
        screenClass: 'EditProfileScreen',
      );

    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      _analyticsService.trackError(
        errorMessage: e.toString(),
        screen: 'EditProfileScreen',
        stackTrace: stackTrace,
      );
    }
  }

  void _initControllers() {
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _bioController = TextEditingController();
    _locationController = TextEditingController();
    _websiteController = TextEditingController();
    _phoneController = TextEditingController();
  }

  // _initControllersWithUser
  void _initControllersWithUser(User? user) {
    if (user != null) {
      _nameController.text = user.name ?? '';
      _usernameController.text = user.username ?? '';
      _bioController.text = user.bio ?? '';
      _locationController.text = user.address ?? '';
      _websiteController.text = '';
      _phoneController.text = user.phoneNumber ?? '';
      _profileImageUrl = user.avatar;
      _coverImageUrl = user.coverImage;
      _isPrivate = user.settings?.privateAccount ?? false;
      _isVerified = user.isVerified;
      _selectedGender = user.gender?.toString().split('.').last ?? 'Not specified';
      _selectedDateOfBirth = user.dateOfBirth;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, bool isProfile) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: isProfile ? 500 : 1500,
        maxHeight: isProfile ? 500 : 500,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          if (isProfile) {
            _profileImage = File(image.path);
          } else {
            _coverImage = File(image.path);
          }
        });

        _analyticsService.trackEvent(
          'image_selected',
          parameters: {
            'type': isProfile ? 'profile' : 'cover',
            'source': source.toString(),
          },
        );
      }
    } catch (e) {
      showError('Failed to pick image: $e');
    }
  }

  void _showImagePickerDialog(bool isProfile) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, isProfile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, isProfile);
              },
            ),
            if (!isProfile && (_coverImage != null || _coverImageUrl != null)) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Cover Image'),
                onTap: () {
                  setState(() {
                    _coverImage = null;
                    _coverImageUrl = null;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
            if (isProfile && (_profileImage != null || _profileImageUrl != null)) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Profile Image'),
                onTap: () {
                  setState(() {
                    _profileImage = null;
                    _profileImageUrl = null;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      String? newProfileImageUrl = _profileImageUrl;
      String? newCoverImageUrl = _coverImageUrl;

      // Upload profile image if changed
      if (_profileImage != null) {
        newProfileImageUrl = await _storageService.uploadFile(
          file: _profileImage!,
          path: 'profiles/${_currentUser?.id}',
          fileName: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      // Upload cover image if changed
      if (_coverImage != null) {
        newCoverImageUrl = await _storageService.uploadFile(
          file: _coverImage!,
          path: 'covers/${_currentUser?.id}',
          fileName: 'cover_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      // Prepare update data
      final updateData = {
        'name': _nameController.text,
        'username': _usernameController.text,
        'bio': _bioController.text,
        'location': _locationController.text,
        'website': _websiteController.text,
        'phoneNumber': _phoneController.text,
        'gender': _selectedGender,
        'dateOfBirth': _selectedDateOfBirth?.toIso8601String(),
        'isPrivate': _isPrivate,
        if (newProfileImageUrl != null) 'avatar': newProfileImageUrl,
        if (newCoverImageUrl != null) 'coverImage': newCoverImageUrl,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Update profile
      await _userService.updateProfile(_currentUser!.id, updateData);

      // Track event
      _analyticsService.trackEvent(
        'profile_updated',
        parameters: {
          'user_id': _currentUser?.id,
          'fields_updated': updateData.keys.join(','),
        },
      );

      showSuccess('Profile updated successfully!');
      Navigator.pop(context, true);

    } catch (e, stackTrace) {
      showError('Failed to update profile: $e');

      _analyticsService.trackError(
        errorMessage: e.toString(),
        screen: 'EditProfileScreen',
        stackTrace: stackTrace,
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Edit Profile'),
      backgroundColor: Colors.pink,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : _saveProfile,
          child: Text(
            _isSaving ? 'Saving...' : 'Save',
            style: const TextStyle(
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
      return const Center(child: CircularProgressIndicator());
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
              onPressed: _initializeUser,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCoverAndProfileSection(),
            const SizedBox(height: 24),
            _buildPersonalInfoSection(),
            const SizedBox(height: 16),
            _buildAccountSettingsSection(),
            const SizedBox(height: 16),
            _buildSocialSection(),
            const SizedBox(height: 16),
            _buildPrivacySection(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverAndProfileSection() {
    return Stack(
      children: [
        // Cover Image
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            image: _coverImage != null
                ? DecorationImage(
              image: FileImage(_coverImage!),
              fit: BoxFit.cover,
            )
                : (_coverImageUrl != null
                ? DecorationImage(
              image: NetworkImage(_coverImageUrl!),
              fit: BoxFit.cover,
            )
                : null),
          ),
          child: Stack(
            children: [
              // Cover Image Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
              // Edit Cover Button
              Positioned(
                bottom: 8,
                right: 8,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, size: 16),
                    onPressed: () => _showImagePickerDialog(false),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Profile Image
        Positioned(
          left: 16,
          bottom: -40,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : (_profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : null) as ImageProvider<Object>?,
                child: _profileImage == null && _profileImageUrl == null
                    ? Text(
                  _currentUser?.name?[0].toUpperCase() ?? 'U',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.pink,
                  child: IconButton(
                    icon: const Icon(Icons.edit, size: 12, color: Colors.white),
                    onPressed: () => _showImagePickerDialog(true),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _nameController,
              label: 'Full Name',
              prefixIcon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            CustomTextField(
              controller: _usernameController,
              label: 'Username',
              prefixIcon: Icons.alternate_email,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a username';
                }
                if (value.length < 3) {
                  return 'Username must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            CustomTextField(
              controller: _bioController,
              label: 'Bio',
              prefixIcon: Icons.info,
              maxLines: 3,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _locationController,
                    label: 'Location',
                    prefixIcon: Icons.location_on,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomTextField(
                    controller: _phoneController,
                    label: 'Phone',
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: _genders.map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDateOfBirth,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _selectedDateOfBirth != null
                            ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                            : 'Select date',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettingsSection() {
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
            const SizedBox(height: 8),

            SwitchListTile(
              title: const Text('Private Account'),
              subtitle: const Text('Only followers can see your content'),
              value: _isPrivate,
              onChanged: (value) {
                setState(() {
                  _isPrivate = value;
                });
              },
              activeColor: Colors.pink,
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.verified, color: Colors.blue),
              title: const Text('Verification Status'),
              subtitle: Text(_isVerified ? 'Verified' : 'Not Verified'),
              trailing: _isVerified
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Text('Apply'),
              onTap: _isVerified ? null : () {
                // Navigate to verification application
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Social Links',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _websiteController,
              label: 'Website',
              prefixIcon: Icons.link,
              keyboardType: TextInputType.url,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy & Security',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            ListTile(
              leading: const Icon(Icons.lock, color: Colors.orange),
              title: const Text('Change Password'),
              subtitle: const Text('Update your account password'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to change password screen
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Account'),
              subtitle: const Text('Permanently delete your account'),
              onTap: _showDeleteAccountDialog,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
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

  Future<void> _deleteAccount() async {
    // Implement account deletion logic
  }
}