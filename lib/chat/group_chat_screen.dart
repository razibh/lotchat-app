import 'package:flutter/material.dart';
import 'dart:io'; // File class এর জন্য
import 'models/chat_model.dart';
import '../../core/utils/image_picker_helper.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final List<Map<String, dynamic>> _selectedContacts = <Map<String, dynamic>>[];
  String? _groupAvatar;

  final List<Map<String, dynamic>> _contacts = List.generate(20, (int index) {
    return <String, dynamic>{
      'id': 'user_$index',
      'name': 'User ${index + 1}',
      'avatar': null,
      'isSelected': false,
    };
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group'),
        actions: <Widget>[
          TextButton(
            onPressed: _selectedContacts.length >= 2
                ? _createGroup
                : null,
            child: const Text(
              'Create',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildGroupInfo(),
          const Divider(),
          Expanded(
            child: _buildContactsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: _pickGroupAvatar,
            child: Stack(
              children: <Widget>[
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _groupAvatar != null
                      ? FileImage(File(_groupAvatar!))
                      : null,
                  child: _groupAvatar == null
                      ? const Icon(Icons.group, size: 40)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                hintText: 'Group name (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList() {
    return ListView.builder(
      itemCount: _contacts.length,
      itemBuilder: (BuildContext context, int index) {
        final Map<String, dynamic> contact = _contacts[index];
        final bool isSelected = _selectedContacts.contains(contact);

        return CheckboxListTile(
          secondary: CircleAvatar(
            child: Text(contact['name'][0]),
          ),
          title: Text(contact['name']),
          value: isSelected,
          onChanged: (value) {
            setState(() {
              if (value ?? false) {
                _selectedContacts.add(contact);
              } else {
                _selectedContacts.remove(contact);
              }
            });
          },
        );
      },
    );
  }

  Future<void> _pickGroupAvatar() async {
    final ImagePickerHelper helper = ImagePickerHelper();
    final File? imageFile = await ImagePickerHelper.pickImageFromGallery();

    if (imageFile != null) {
      setState(() {
        _groupAvatar = imageFile.path;
      });
    }
  }

  void _createGroup() {
    if (_selectedContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one contact'),
        ),
      );
      return;
    }

    // Create group logic here
    final String groupName = _groupNameController.text.isEmpty
        ? 'New Group'
        : _groupNameController.text;

    // TODO: Save group to database
    debugPrint('Creating group: $groupName');
    debugPrint('Members: ${_selectedContacts.length}');
    debugPrint('Avatar: $_groupAvatar');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Group "$groupName" created successfully'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }
}