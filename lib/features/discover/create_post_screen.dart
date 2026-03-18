import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../core/di/service_locator.dart';
import '../../core/services/upload_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/image_picker_helper.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen>
    with LoadingMixin, ToastMixin {

  final UploadService _uploadService = ServiceLocator().get<UploadService>();
  final NotificationService _notificationService = ServiceLocator().get<NotificationService>();

  final TextEditingController _contentController = TextEditingController();
  final List<File> _selectedMedia = [];
  List<String> _uploadedMediaUrls = [];
  String _selectedPrivacy = 'Public';
  bool _allowComments = true;
  bool _allowGifts = true;

  final List<String> _privacyOptions = ['Public', 'Friends Only', 'Private'];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Media',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMediaOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  color: Colors.blue,
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickFromGallery();
                  },
                ),
                _buildMediaOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  color: Colors.green,
                  onTap: () async {
                    Navigator.pop(context);
                    await _takePhoto();
                  },
                ),
                _buildMediaOption(
                  icon: Icons.videocam,
                  label: 'Video',
                  color: Colors.red,
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickVideo();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    final List<File> files = await ImagePickerHelper.pickMultipleImages();
    if (files.isNotEmpty) {
      setState(() {
        _selectedMedia.addAll(files);
      });
    }
  }

  Future<void> _takePhoto() async {
    final File? file = await ImagePickerHelper.pickImageFromCamera();
    if (file != null) {
      setState(() {
        _selectedMedia.add(file);
      });
    }
  }

  Future<void> _pickVideo() async {
    final File? file = await ImagePickerHelper.pickVideoFromGallery();
    if (file != null) {
      setState(() {
        _selectedMedia.add(file);
      });
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty && _selectedMedia.isEmpty) {
      showError('Please add some content or media');
      return;
    }

    await runWithLoading(() async {
      try {
        // Upload media if any
        _uploadedMediaUrls = [];
        for (File media in _selectedMedia) {
          final String? url = await _uploadService.uploadFile(
            filePath: media.path,
            folder: 'posts/${DateTime.now().millisecondsSinceEpoch}',
          );
          if (url != null) {
            _uploadedMediaUrls.add(url);
          }
        }

        // Create post (would integrate with backend)
        await Future.delayed(const Duration(seconds: 2));

        // Fix: showSuccess এর পরিবর্তে showSuccess ব্যবহার করুন (toast mixin থেকে)
        showSuccess('Post created successfully!');

        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        showError('Failed to create post: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _createPost,
            child: const Text(
              'Post',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Info
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=current'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'John Doe',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.public,
                            size: 14,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _selectedPrivacy,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Content Input
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              maxLines: 5,
              maxLength: 500,
            ),

            const SizedBox(height: 16),

            // Media Preview
            if (_selectedMedia.isNotEmpty) ...[
              const Text(
                'Media',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedMedia.length,
                  itemBuilder: (context, index) {
                    final media = _selectedMedia[index];
                    return Stack(
                      children: [
                        Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(media),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeMedia(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Add Media Button
            if (_selectedMedia.length < 5)
              OutlinedButton.icon(
                onPressed: _pickMedia,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Photos/Videos'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                ),
              ),

            const SizedBox(height: 24),

            // Privacy Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Privacy Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Privacy Level
                    DropdownButtonFormField<String>(
                      value: _selectedPrivacy,
                      decoration: const InputDecoration(
                        labelText: 'Who can see this post?',
                        border: OutlineInputBorder(),
                      ),
                      items: _privacyOptions.map((String option) {
                        return DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedPrivacy = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    // Allow Comments
                    SwitchListTile(
                      title: const Text('Allow Comments'),
                      value: _allowComments,
                      onChanged: (bool value) {
                        setState(() {
                          _allowComments = value;
                        });
                      },
                      activeColor: Colors.purple,
                    ),

                    // Allow Gifts
                    SwitchListTile(
                      title: const Text('Allow Gifts'),
                      value: _allowGifts,
                      onChanged: (bool value) {
                        setState(() {
                          _allowGifts = value;
                        });
                      },
                      activeColor: Colors.purple,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Post Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _createPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text(
                  'Post',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}