import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_background.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/custom_button.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/pk_service.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/loading_mixin.dart';

class CreatePKScreen extends StatefulWidget {
  final String hostId;

  const CreatePKScreen({
    super.key,
    required this.hostId,
  });

  @override
  State<CreatePKScreen> createState() => _CreatePKScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('hostId', hostId));
  }
}

class _CreatePKScreenState extends State<CreatePKScreen>
    with LoadingMixin, ToastMixin, TickerProviderStateMixin {

  late final AnalyticsService _analyticsService;
  late final PKService _pkService;

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prizeController = TextEditingController();
  final _entryFeeController = TextEditingController();

  // Form state
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // PK options
  PKType _selectedType = PKType.friendly;
  PKDuration _selectedDuration = PKDuration.minutes30;
  PKVisibility _selectedVisibility = PKVisibility.public;

  // Participants
  List<String> _invitedParticipants = [];
  final List<String> _availableFriends = [
    'user_1', 'user_2', 'user_3', 'user_4', 'user_5',
  ];

  // Battle rules
  bool _allowGifts = true;
  bool _allowComments = true;
  bool _allowSpectators = true;
  int _maxParticipants = 2;

  // Prize options
  bool _isPrizeCoins = true;
  bool _hasEntryFee = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _analyticsService = AnalyticsService();
    _pkService = PKService();
    await _analyticsService.initialize();

    _analyticsService.trackScreen(
      'CreatePK',
      screenClass: 'CreatePKScreen',
      parameters: {'host_id': widget.hostId},
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _prizeController.dispose();
    _entryFeeController.dispose();
    super.dispose();
  }

  Future<void> _createPK() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final pkData = {
        'hostId': widget.hostId,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'type': _selectedType.toString(),
        'duration': _selectedDuration.toString(),
        'visibility': _selectedVisibility.toString(),
        'maxParticipants': _maxParticipants,
        'allowGifts': _allowGifts,
        'allowComments': _allowComments,
        'allowSpectators': _allowSpectators,
        'prize': {
          'type': _isPrizeCoins ? 'coins' : 'item',
          'value': int.tryParse(_prizeController.text) ?? 0,
        },
        'entryFee': _hasEntryFee ? int.tryParse(_entryFeeController.text) ?? 0 : 0,
        'invitedParticipants': _invitedParticipants,
      };

      final result = await _pkService.createPK(pkData);

      await _analyticsService.trackEvent(
        'pk_created',
        parameters: {
          'host_id': widget.hostId,
          'pk_type': _selectedType.toString(),
          'pk_duration': _selectedDuration.toString(),
          'prize_amount': _prizeController.text,
        },
      );

      showSuccess('PK Battle created successfully!');

      Navigator.pop(context, result);

    } catch (e, stackTrace) {
      showError('Failed to create PK: $e');

      await _analyticsService.trackError(
        errorMessage: e.toString(),
        screen: 'CreatePKScreen',
        stackTrace: stackTrace,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: _isLoading
              ? const LoadingWidget(message: 'Creating PK Battle...')
              : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfo(),
                  const SizedBox(height: 20),
                  _buildBattleType(),
                  const SizedBox(height: 20),
                  _buildDuration(),
                  const SizedBox(height: 20),
                  _buildVisibility(),
                  const SizedBox(height: 20),
                  _buildParticipants(),
                  const SizedBox(height: 20),
                  _buildRules(),
                  const SizedBox(height: 20),
                  _buildPrize(),
                  const SizedBox(height: 20),
                  _buildEntryFee(),
                  const SizedBox(height: 20),
                  _buildInviteFriends(),
                  const SizedBox(height: 30),
                  _buildCreateButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Create PK Battle',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.pink.withValues(alpha: 0.1),
            Colors.purple.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.pink, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Basic Information',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Battle Title',
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.pink),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description (Optional)',
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.pink),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBattleType() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.1),
            Colors.red.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sports_kabaddi, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Battle Type',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTypeChip(
                  type: PKType.friendly,
                  icon: Icons.favorite,
                  label: 'Friendly',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTypeChip(
                  type: PKType.competitive,
                  icon: Icons.emoji_events,
                  label: 'Competitive',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTypeChip(
                  type: PKType.tournament,
                  icon: Icons.tour,
                  label: 'Tournament',
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTypeChip(
                  type: PKType.team,
                  icon: Icons.groups,
                  label: 'Team Battle',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip({
    required PKType type,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [color, color.withValues(alpha: 0.5)],
          )
              : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuration() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.1),
            Colors.cyan.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timer, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Battle Duration',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDurationChip(
                  duration: PKDuration.minutes15,
                  label: '15 min',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDurationChip(
                  duration: PKDuration.minutes30,
                  label: '30 min',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDurationChip(
                  duration: PKDuration.hours1,
                  label: '1 hour',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDurationChip(
                  duration: PKDuration.hours2,
                  label: '2 hours',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDurationChip({
    required PKDuration duration,
    required String label,
  }) {
    final isSelected = _selectedDuration == duration;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDuration = duration;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisibility() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.1),
            Colors.teal.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Visibility',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildVisibilityChip(
                  visibility: PKVisibility.public,
                  icon: Icons.public,
                  label: 'Public',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildVisibilityChip(
                  visibility: PKVisibility.followers,
                  icon: Icons.people,
                  label: 'Followers',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildVisibilityChip(
                  visibility: PKVisibility.inviteOnly,
                  icon: Icons.lock,
                  label: 'Invite Only',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildVisibilityChip(
                  visibility: PKVisibility.private,
                  icon: Icons.private_connectivity,
                  label: 'Private',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityChip({
    required PKVisibility visibility,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedVisibility == visibility;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedVisibility = visibility;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.green, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipants() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha: 0.1),
            Colors.pink.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.group, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Participants',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildParticipantChip(2, '1v1'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildParticipantChip(4, '2v2'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildParticipantChip(6, '3v3'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildParticipantChip(8, '4v4'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildParticipantChip(10, '5v5'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildParticipantChip(12, '6v6'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantChip(int count, String label) {
    final isSelected = _maxParticipants == count;
    return GestureDetector(
      onTap: () {
        setState(() {
          _maxParticipants = count;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRules() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.1),
            Colors.orange.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rule, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Battle Rules',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text(
              'Allow Gifts',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Participants can send gifts',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            value: _allowGifts,
            activeColor: Colors.pink,
            onChanged: (value) {
              setState(() {
                _allowGifts = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text(
              'Allow Comments',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Spectators can comment',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            value: _allowComments,
            activeColor: Colors.pink,
            onChanged: (value) {
              setState(() {
                _allowComments = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text(
              'Allow Spectators',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Others can watch the battle',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            value: _allowSpectators,
            activeColor: Colors.pink,
            onChanged: (value) {
              setState(() {
                _allowSpectators = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrize() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.1),
            Colors.lime.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Prize',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Coins'),
                  selected: _isPrizeCoins,
                  onSelected: (selected) {
                    setState(() {
                      _isPrizeCoins = true;
                    });
                  },
                  selectedColor: Colors.green,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Item'),
                  selected: !_isPrizeCoins,
                  onSelected: (selected) {
                    setState(() {
                      _isPrizeCoins = false;
                    });
                  },
                  selectedColor: Colors.purple,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _prizeController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: _isPrizeCoins ? 'Prize Amount (Coins)' : 'Item ID',
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.pink),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter prize details';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEntryFee() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withValues(alpha: 0.1),
            Colors.orange.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.money, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Entry Fee',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Switch(
                value: _hasEntryFee,
                onChanged: (value) {
                  setState(() {
                    _hasEntryFee = value;
                  });
                },
                activeColor: Colors.pink,
              ),
            ],
          ),
          if (_hasEntryFee) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _entryFeeController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Entry Fee (Coins)',
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.pink),
                ),
              ),
              validator: (value) {
                if (_hasEntryFee && (value == null || value.isEmpty)) {
                  return 'Please enter entry fee';
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInviteFriends() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.1),
            Colors.indigo.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_add, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Invite Friends',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableFriends.map((friendId) {
              final isInvited = _invitedParticipants.contains(friendId);
              return FilterChip(
                label: Text('User $friendId'),
                selected: isInvited,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _invitedParticipants.add(friendId);
                    } else {
                      _invitedParticipants.remove(friendId);
                    }
                  });
                },
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                selectedColor: Colors.pink,
                labelStyle: const TextStyle(color: Colors.white),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return CustomButton(
      text: 'Create PK Battle',
      onPressed: _createPK,
      color: Colors.pink,
      isLoading: _isLoading,
      icon: Icons.add,
    );
  }
}

// Enums
enum PKType { friendly, competitive, tournament, team }
enum PKDuration { minutes15, minutes30, hours1, hours2 }
enum PKVisibility { public, followers, inviteOnly, private }