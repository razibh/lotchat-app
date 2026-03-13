import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../../../core/utils/image_picker_helper.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({Key? key}) : super(key: key);

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
        actions: <>[
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
        children: <>[
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
        children: <>[
          GestureDetector(
            onTap: _pickGroupAvatar,
            child: Stack(
              children: <>[
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
             