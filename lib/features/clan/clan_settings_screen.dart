import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // DiagnosticPropertiesBuilder এর জন্য
import '../../core/di/service_locator.dart';
import '../clan/services/clan_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/image_picker_helper.dart';
import '../../core/models/clan_model.dart'; // ClanModel এর জন্য
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/dialog_mixin.dart';
import '../../mixins/form_mixin.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class ClanSettingsScreen extends StatefulWidget {
  final ClanModel clan;

  const ClanSettingsScreen({required this.clan, super.key});

  @override
  State<ClanSettingsScreen> createState() => _ClanSettingsScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ClanModel>('clan', clan));
  }
}

class _ClanSettingsScreenState extends State<ClanSettingsScreen>
    with LoadingMixin, ToastMixin, DialogMixin, FormMixin {

  final ClanService _clanService = ServiceLocator().get<ClanService>();
  final AuthService _authService = ServiceLocator().get<AuthService>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _rulesController;
  late ClanJoinType _joinType;
  late int _maxMembers;
  late List<String> _tags;
  String? _newEmblem;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.clan.name);
    _descriptionController = TextEditingController(text: widget.clan.description ?? '');
    _rulesController = TextEditingController(text: widget.clan.rules ?? '');
    _joinType = widget.clan.joinType;
    _maxMembers = widget.clan.maxMembers;
    _tags = List.from(widget.clan.tags);
  }

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
        _newEmblem = file.path;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (!validateForm()) return;

    await runWithLoading(() async {
      await Future.delayed(const Duration(seconds: 1));

      String? emblemUrl = widget.clan.emblem;
      if (_newEmblem != null) {
        emblemUrl = _newEmblem;
      }

      final bool success = true;

      if (success) {
        showSuccess('Settings saved');
        if (mounted) Navigator.pop(context, true);
      } else {
        showError('Failed to save settings');
      }
    });
  }

  Future<void> _transferLeadership() async {
    final members = widget.clan.members
        .where((m) => m.role == ClanRole.coLeader)
        .toList();

    if (members.isEmpty) {
      showError('No co-leaders to transfer to');
      return;
    }

    final selectedMember = await showDialog<ClanMember>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Transfer Leadership'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: members.length,
            itemBuilder: (BuildContext context, int index) {
              final member = members[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: member.avatar != null
                      ? NetworkImage(member.avatar!)
                      : null,
                  backgroundColor: Colors.deepPurple.shade100,
                  child: member.avatar == null
                      ? Text(member.username[0].toUpperCase())
                      : null,
                ),
                title: Text(member.username),
                onTap: () => Navigator.pop(context, member),
              );
            },
          ),
        ),
      ),
    );

    if (selectedMember != null) {
      final bool? confirmed = await showConfirmDialog(
        context,
        title: 'Confirm Transfer',
        message: 'Transfer leadership to ${selectedMember.username}? You will become a co-leader.',
      );

      if (confirmed ?? false) {
        await runWithLoading(() async {
          await Future.delayed(const Duration(seconds: 1));
          showSuccess('Leadership transferred');
          if (mounted) {
            Navigator.pop(context, true);
          }
        });
      }
    }
  }

  Future<void> _disbandClan() async {
    final bool? confirmed = await showConfirmDialog(
      context,
      title: 'Disband Clan',
      message: 'Are you sure you want to disband the clan? This action cannot be undone.',
    );

    if (confirmed ?? false) {
      await runWithLoading(() async {
        await Future.delayed(const Duration(seconds: 1));
        showSuccess('Clan disbanded');
        if (mounted) {
          Navigator.pop(context, true);
          Navigator.pop(context, true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clan Settings'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emblem
              Center(
                child: GestureDetector(
                  onTap: _pickEmblem,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.deepPurple,
                            width: 2,
                          ),
                          image: _newEmblem != null
                              ? DecorationImage(
                            image: FileImage(File(_newEmblem!)),
                            fit: BoxFit.cover,
                          )
                              : (widget.clan.emblem != null
                              ? DecorationImage(
                            image: NetworkImage(widget.clan.emblem!),
                            fit: BoxFit.cover,
                          )
                              : null),
                        ),
                        child: widget.clan.emblem == null && _newEmblem == null
                            ? const Icon(
                          Icons.groups,
                          size: 60,
                          color: Colors.deepPurple,
                        )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Clan Name
              CustomTextField(
                controller: _nameController,
                label: 'Clan Name',
                prefixIcon: Icons.groups,
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
                children: [10, 25, 50, 100, 200].map((int max) {
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
              const SizedBox(height: 24),

              // Danger Zone
              const Text(
                'Danger Zone',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: Colors.red.shade50,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.swap_horiz, color: Colors.orange),
                      title: const Text('Transfer Leadership'),
                      subtitle: const Text('Transfer clan ownership to a co-leader'),
                      onTap: _transferLeadership,
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.delete_forever, color: Colors.red),
                      title: const Text('Disband Clan'),
                      subtitle: const Text('Permanently delete the clan'),
                      onTap: _disbandClan,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
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
                      : const Text('Save Settings'),
                ),
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
      onChanged: (ClanJoinType? value) {
        setState(() {
          _joinType = value!;
        });
      },
      activeColor: Colors.deepPurple,
    );
  }
}