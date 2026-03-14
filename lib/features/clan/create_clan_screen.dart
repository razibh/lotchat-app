import 'dart:io';

import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/models/clan_model.dart';
import '../../core/services/clan_service.dart';
import '../../core/utils/image_picker_helper.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/form_mixin.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class CreateClanScreen extends StatefulWidget {
  const CreateClanScreen({super.key});

  @override
  State<CreateClanScreen> createState() => _CreateClanScreenState();
}

class _CreateClanScreenState extends State<CreateClanScreen> 
    with LoadingMixin, ToastMixin, FormMixin {
  
  final ClanService _clanService = ServiceLocator().get<ClanService>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _rulesController = TextEditingController();
  
  String? _emblemPath;
  ClanJoinType _joinType = ClanJoinType.open;
  final List<String> _selectedTags = <String>[];
  int _maxMembers = 50;

  final List<String> _availableTags = <String>[
    'Gaming',
    'Social',
    'Competitive',
    'Casual',
    'International',
    'Local',
    '18+',
    'Family',
    'Friendly',
    'Active',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  Future<void> _pickEmblem() async {
    final File? file = await ImagePickerHelper.pickImageFromGallery();
    if (file != null) {
      setState(() {
        _emblemPath = file.path;
      });
    }
  }

  Future<void> _createClan() async {
    if (!validateForm()) return;

    await runWithLoading(() async {
      try {
        final ClanModel? clan = await _clanService.createClan(
          name: _nameController.text,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          rules: _rulesController.text.isNotEmpty
              ? _rulesController.text
              : null,
          emblem: _emblemPath, // Would need to upload to storage first
          joinType: _joinType,
          tags: _selectedTags,
        );

        if (clan != null) {
          showSuccess('Clan created successfully!');
          Navigator.pop(context, clan);
        } else {
          showError('Failed to create clan');
        }
      } catch (e) {
        showError(e.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Clan'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <>[
              // Emblem
              Center(
                child: GestureDetector(
                  onTap: _pickEmblem,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.deepPurple,
                        width: 2,
                      ),
                      image: _emblemPath != null
                          ? DecorationImage(
                              image: FileImage(File(_emblemPath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _emblemPath == null
                        ? const Icon(
                            Icons.add_photo_alternate,
                            size: 40,
                            color: Colors.deepPurple,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Clan Name
              CustomTextField(
                controller: _nameController,
                label: 'Clan Name',
                prefixIcon: Icons.groups,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a clan name';
                  }
                  if (value.length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                prefixIcon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Rules
              CustomTextField(
                controller: _rulesController,
                label: 'Rules',
                prefixIcon: Icons.rule,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Join Type
              const Text(
                'Join Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildJoinTypeOption(
                'Open',
                'Anyone can join without approval',
                ClanJoinType.open,
              ),
              _buildJoinTypeOption(
                'Approval Required',
                'Members need to be approved',
                ClanJoinType.approval,
              ),
              _buildJoinTypeOption(
                'Invite Only',
                'Only invited users can join',
                ClanJoinType.invite,
              ),
              const SizedBox(height: 16),

              // Max Members
              const Text(
                'Max Members',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: <int>[10, 25, 50, 100, 200].map((int max) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text('$max'),
                        selected: _maxMembers == max,
                        onSelected: (bool selected) {
                          setState(() {
                            _maxMembers = max;
                          });
                        },
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: Colors.deepPurple,
                        labelStyle: TextStyle(
                          color: _maxMembers == max ? Colors.white : null,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Tags
              const Text(
                'Tags',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _availableTags.map((String tag) {
                  final bool isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: Colors.deepPurple,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Create Button
              CustomButton(
                text: 'Create Clan',
                onPressed: _createClan,
                isLoading: isLoading,
                color: Colors.deepPurple,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinTypeOption(String title, String subtitle, ClanJoinType type) {
    return RadioListTile<ClanJoinType>(
      title: Text(title),
      subtitle: Text(subtitle),
      value: type,
      groupValue: _joinType,
      onChanged: (Object? value) {
        setState(() {
          _joinType = value;
        });
      },
      activeColor: Colors.deepPurple,
    );
  }
}