import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditPostScreen extends StatefulWidget {
  final String postId;
  final Map<String, dynamic>? post;

  const EditPostScreen({
    required this.postId,
    this.post,
    super.key,
  });

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('postId', postId));
    properties.add(DiagnosticsProperty<Map<String, dynamic>?>('post', post));
  }
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final List<String> _tags = [];
  final _tagController = TextEditingController();

  List<File> _mediaFiles = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String _selectedCategory = 'General';
  bool _isPublic = true;
  bool _allowComments = true;

  final List<String> _categories = [
    'General',
    'News',
    'Event',
    'Announcement',
    'Question',
    'Discussion',
    'Review',
    'Tutorial',
  ];

  @override
  void initState() {
    super.initState();
    _loadPostData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _loadPostData() {
    // Simulate loading post data
    if (widget.post != null) {
      _titleController.text = widget.post!['title'] ?? '';
      _contentController.text = widget.post!['content'] ?? '';
      _selectedCategory = widget.post!['category'] ?? 'General';
      _isPublic = widget.post!['isPublic'] ?? true;
      _allowComments = widget.post!['allowComments'] ?? true;
      if (widget.post!['tags'] != null) {
        _tags.addAll(List<String>.from(widget.post!['tags']));
      }
    } else {
      // Mock data for demo
      _titleController.text = 'Sample Post Title';
      _contentController.text = 'This is the content of the post that needs to be edited.';
      _tags.addAll(['flutter', 'development', 'mobile']);
    }
  }

  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    setState(() {
      _mediaFiles.addAll(images.map((file) => File(file.path)));
    });
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        _mediaFiles.add(File(photo.path));
      });
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _mediaFiles.removeAt(index);
    });
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty && !_tags.contains(_tagController.text)) {
      setState(() {
        _tags.add(_tagController.text);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _savePost() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() => _isSaving = false);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _savePost,
            child: Text(
              _isSaving ? 'Saving...' : 'Save',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'Enter post title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.category),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Content Field
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Content',
                hintText: 'Write your post content...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter post content';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Media Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Media',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Media Grid
                    if (_mediaFiles.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _mediaFiles.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(_mediaFiles[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 12,
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
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 12),

                    // Add Media Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickMedia,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Gallery'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _takePhoto,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Camera'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tags Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tag Input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagController,
                            decoration: InputDecoration(
                              hintText: 'Enter tag',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onSubmitted: (_) => _addTag(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addTag,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Tag Chips
                    Wrap(
                      spacing: 4,
                      children: _tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          onDeleted: () => _removeTag(tag),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Settings Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Public Post'),
                      subtitle: const Text('Visible to everyone'),
                      value: _isPublic,
                      onChanged: (value) {
                        setState(() {
                          _isPublic = value;
                        });
                      },
                    ),
                    const Divider(height: 0),
                    SwitchListTile(
                      title: const Text('Allow Comments'),
                      subtitle: const Text('Enable comments on this post'),
                      value: _allowComments,
                      onChanged: (value) {
                        setState(() {
                          _allowComments = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Delete Button
            OutlinedButton.icon(
              onPressed: _showDeleteDialog,
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text(
                'Delete Post',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              setState(() => _isLoading = true);
              await Future.delayed(const Duration(seconds: 1));

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Post deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );

              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Simplified version for error fixing
class EditPostScreenSimple extends StatelessWidget {
  final String postId;

  const EditPostScreenSimple({
    required this.postId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Post: $postId'),
      ),
      body: const Center(
        child: Text('Edit Post Screen'),
      ),
    );
  }
}