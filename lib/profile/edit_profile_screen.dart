import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/profile_model.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_edit_field.dart';
import '../../../core/utils/image_picker_helper.dart';
import '../../../core/utils/validators.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/upload_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../widgets/common/custom_button.dart';

class EditProfileScreen extends StatefulWidget {

  const EditProfileScreen({Key? key, required this.profile}) : super(key: key);
  final ProfileModel profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uploadService = ServiceLocator().get<UploadService>();
  final _notificationService = ServiceLocator().get<NotificationService>();
  
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late TextEditingController _websiteController;
  
  String? _avatarPath;
  String? _coverPath;
  List<String> _selectedInterests = <String>[];
  DateTime? _birthDate;
  String? _gender;
  bool _isLoading = false;

  final List<String> _availableInterests = <String>[
    'Music', 'Travel', 'Gaming', 'Sports', 'Art', 'Food',
    'Fashion', 'Technology', 'Movies', 'Books', 'Dancing',
    'Photography', 'Fitness', 'Cooking', 'Pets', 'Nature',
  ];

  final List<String> _genders = <String>['Male', 'Female', 'Non-binary', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _displayNameController = TextEditingController(
      text: widget.profile.displayName ?? '',
    );
    _bioController = TextEditingController(
      text: widget.profile.bio ?? '',
    );
    _locationController = TextEditingController(
      text: widget.profile.location ?? '',
    );
    _websiteController = TextEditingController(
      text: widget.profile.website ?? '',
    );
    _selectedInterests = List.from(widget.profile.interests);
    _birthDate = widget.profile.birthDate;
    _gender = widget.profile.gender;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    final file = await ImagePickerHelper.pickImageFromGallery();
    if (file != null) {
      setState(() {
        if (type == 'avatar') {
          _avatarPath = file.path;
        } else {
          _coverPath = file.path;
        }
      });
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _birthDate = date;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? avatarUrl;
      String? coverUrl;

      // Upload new avatar if changed
      if (_avatarPath != null) {
        avatarUrl = await _uploadService.uploadProfilePicture(
          image: XFile(_avatarPath!),
          userId: widget.profile.userId,
        );
      }

      // Upload new cover if changed
      if (_coverPath != null) {
        coverUrl = await _uploadService.uploadFile(
          filePath: _coverPath!,
          folder: 'users/${widget.profile.userId}/cover',
        );
      }

      final updates = ProfileUpdateModel(
        displayName: _displayNameController.text.isNotEmpty
            ? _displayNameController.text
            : null,
        bio: _bioController.text.isNotEmpty
            ? _bioController.text
            : null,
        location: _locationController.text.isNotEmpty
            ? _locationController.text
            : null,
        website: _websiteController.text.isNotEmpty
            ? _websiteController.text
            : null,
        birthDate: _birthDate,
        gender: _gender,
        interests: _selectedInterests.isNotEmpty ? _selectedInterests : null,
        avatar: avatarUrl,
        coverImage: coverUrl,
      );

      await context.read<ProfileProvider>().updateProfile(updates);
      
      _notificationService.showSuccess('Profile updated successfully');
      Navigator.pop(context);
    } catch (e) {
      _notificationService.showError('Failed to update profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.blue,
        actions: <>[
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <>[
                    // Cover Image
                    Stack(
                      children: <>[
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            image: _coverPath != null
                                ? DecorationImage(
                                    image: FileImage(File(_coverPath!)),
                                    fit: BoxFit.cover,
                                  )
                                : (widget.profile.coverImage != null
                                    ? DecorationImage(
                                        image: NetworkImage(widget.profile.coverImage!),
                                        fit: BoxFit.cover,
                                      )
                                    : null),
                          ),
                          child: _coverPath == null && widget.profile.coverImage == null
                              ? const Center(
                                  child: Icon(Icons.image, size: 50, color: Colors.grey),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, color: Colors.white),
                              onPressed: () => _pickImage('cover'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Avatar
                    Stack(
                      children: <>[
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _avatarPath != null
                              ? FileImage(File(_avatarPath!))
                              : (widget.profile.avatar != null
                                  ? NetworkImage(widget.profile.avatar!)
                                  : null),
                          backgroundColor: Colors.grey.shade300,
                          child: _avatarPath == null && widget.profile.avatar == null
                              ? const Icon(Icons.person, size: 60, color: Colors.grey)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.blue,
                            radius: 18,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                              onPressed: () => _pickImage('avatar'),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Form Fields
                    ProfileEditField(
                      controller: _displayNameController,
                      label: 'Display Name',
                      icon: Icons.person,
                      validator: Validators.validateUsername,
                    ),
                    const SizedBox(height: 16),

                    ProfileEditField(
                      controller: _bioController,
                      label: 'Bio',
                      icon: Icons.info,
                      maxLines: 3,
                      maxLength: 150,
                    ),
                    const SizedBox(height: 16),

                    ProfileEditField(
                      controller: _locationController,
                      label: 'Location',
                      icon: Icons.location_on,
                    ),
                    const SizedBox(height: 16),

                    ProfileEditField(
                      controller: _websiteController,
                      label: 'Website',
                      icon: Icons.link,
                      validator: (value) => value != null && value.isNotEmpty
                          ? Validators.validateUrl(value)
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Birthday
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: <>[
                            const Icon(Icons.cake, color: Colors.grey),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <>[
                                  const Text(
                                    'Birthday',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  Text(
                                    _birthDate != null
                                        ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                                        : 'Not set',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Gender
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _gender,
                          hint: const Text('Select Gender'),
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          items: _genders.map((String gender) {
                            return DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _gender = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Interests
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <>[
                          const Text(
                            'Interests',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availableInterests.map((String interest) {
                              final bool isSelected = _selectedInterests.contains(interest);
                              return FilterChip(
                                label: Text(interest),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedInterests.add(interest);
                                    } else {
                                      _selectedInterests.remove(interest);
                                    }
                                  });
                                },
                                backgroundColor: Colors.grey.shade100,
                                selectedColor: Colors.blue,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : null,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    CustomButton(
                      text: 'Save Changes',
                      onPressed: _isLoading ? null : _saveProfile,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}