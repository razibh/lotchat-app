import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/call_service.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/models/user_model.dart';
import '../../../mixins/loading_mixin.dart';
import '../../../mixins/toast_mixin.dart';
import '../participant_grid.dart';
import '../call_controls.dart';
import '../call_timer.dart';
import '../beauty_filter_panel.dart';
import '../audio_wave.dart';

class GroupCallScreen extends StatefulWidget {

  const GroupCallScreen({
    Key? key,
    required this.participants,
    required this.isVideoCall,
    required this.roomId,
  }) : super(key: key);
  final List<UserModel> participants;
  final bool isVideoCall;
  final String roomId;

  @override
  State<GroupCallScreen> createState() => _GroupCallScreenState();
}

class _GroupCallScreenState extends State<GroupCallScreen> with LoadingMixin, ToastMixin {
  final CallService _callService = ServiceLocator().get<CallService>();
  final SocketService _socketService = ServiceLocator().get<SocketService>();
  
  late List<Participant> _participants;
  bool _isMicMuted = false;
  bool _isSpeakerOn = false;
  bool _isCameraOn = true;
  bool _isFrontCamera = true;
  bool _showParticipants = true;
  bool _showChat = false;
  bool _showFilters = false;
  int _callDuration = 0;
  String? _pinnedUserId;

  @override
  void initState() {
    super.initState();
    _initializeCall();
    _setupSocketListeners();
  }

  Future<void> _initializeCall() async {
    await runWithLoading(() async {
      await _callService.initialize();
      
      // Convert users to participants
      _participants = widget.participants.map((user) {
        return Participant(
          userId: user.uid,
          name: user.username,
          avatar: user.photoURL,
          hasVideo: false,
          isMuted: false,
          isSpeaking: false,
          isPinned: false,
          audioLevel: 0.0,
        );
      }).toList();
      
      // Add local user
      _participants.add(Participant(
        userId: 'local',
        name: 'You',
        hasVideo: widget.isVideoCall,
        isMuted: false,
        isSpeaking: false,
        isPinned: false,
        audioLevel: 0.0,
      ));
      
      _startCallTimer();
    });
  }

  void _setupSocketListeners() {
    _socketService.on('user-joined', (data) {
      setState(() {
        _participants.add(Participant(
          userId: data['userId'],
          name: data['name'],
          avatar: data['avatar'],
          hasVideo: false,
          isMuted: false,
          isSpeaking: false,
          isPinned: false,
          audioLevel: 0.0,
        ));
      });
    });

    _socketService.on('user-left', (data) {
      setState(() {
        _participants.removeWhere((Object? p) => p.userId == data['userId']);
      });
    });

    _socketService.on('audio-level', (data) {
      setState(() {
        final participant = _participants.firstWhere(
          (Object? p) => p.userId == data['userId'],
          orElse: () => Participant(userId: '', name: ''),
        );
        if (participant.userId.isNotEmpty) {
          participant.audioLevel = data['level'];
          participant.isSpeaking = data['level'] > 0.1;
        }
      });
    });

    _socketService.on('mute-state-changed', (data) {
      setState(() {
        final participant = _participants.firstWhere(
          (Object? p) => p.userId == data['userId'],
          orElse: () => Participant(userId: '', name: ''),
        );
        if (participant.userId.isNotEmpty) {
          participant.isMuted = data['isMuted'];
        }
      });
    });
  }

  void _startCallTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _callDuration++;
        });
        _startCallTimer();
      }
    });
  }

  void _toggleMic() {
    setState(() {
      _isMicMuted = !_isMicMuted;
    });
    _callService.toggleMic(_isMicMuted);
    
    _socketService.emit('mute-state-changed', <String, Object>{
      'userId': 'local',
      'isMuted': _isMicMuted,
    });
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
    _callService.setSpeakerphone(_isSpeakerOn);
  }

  void _toggleCamera() {
    if (!widget.isVideoCall) return;
    setState(() {
      _isCameraOn = !_isCameraOn;
    });
    _callService.toggleCamera(_isCameraOn);
  }

  void _flipCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    _callService.switchCamera();
  }

  Future<void> _endCall() async {
    await _callService.endCall();
    Navigator.pop(context);
  }

  void _onParticipantTap(String userId) {
    // Show participant options
  }

  void _onMuteParticipant(String userId) {
    // Mute/unmute participant (host only)
  }

  void _onPinParticipant(String userId) {
    setState(() {
      if (_pinnedUserId == userId) {
        _pinnedUserId = null;
      } else {
        _pinnedUserId = userId;
      }
      
      for (final p in _participants) {
        p.isPinned = p.userId == _pinnedUserId;
      }
    });
  }

  void _showAddParticipant() {
    // Show add participant dialog
  }

  void _showRaiseHand() {
    _socketService.emit('raise-hand', <String, String>{
      'userId': 'local',
    });
    showInfo('Hand raised');
  }

  void _showReaction(String reaction) {
    _socketService.emit('reaction', <String, String>{
      'userId': 'local',
      'reaction': reaction,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <>[
          // Main content
          Column(
            children: <>[
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.black54,
                child: Row(
                  children: <>[
                    const Icon(Icons.group, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      '${_participants.length} participants',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const Spacer(),
                    CallTimer(duration: _callDuration),
                  ],
                ),
              ),

              // Participant grid or pinned view
              Expanded(
                child: _pinnedUserId != null
                    ? _buildPinnedView()
                    : ParticipantGrid(
                        participants: _participants,
                        localUserId: 'local',
                        onParticipantTap: _onParticipantTap,
                        onMuteParticipant: _onMuteParticipant,
                        onPinParticipant: _onPinParticipant,
                      ),
              ),

              // Controls
              CallControls(
                isVideoCall: widget.isVideoCall,
                isMicMuted: _isMicMuted,
                isSpeakerOn: _isSpeakerOn,
                isCameraOn: _isCameraOn,
                isFrontCamera: _isFrontCamera,
                onToggleMic: _toggleMic,
                onToggleSpeaker: _toggleSpeaker,
                onToggleCamera: _toggleCamera,
                onFlipCamera: _flipCamera,
                onToggleScreenShare: () {},
                onEndCall: _endCall,
              ),
            ],
          ),

          // Additional controls overlay
          Positioned(
            top: 60,
            right: 16,
            child: Column(
              children: <>[
                _buildFloatingButton(
                  icon: Icons.group_add,
                  onPressed: _showAddParticipant,
                ),
                const SizedBox(height: 8),
                _buildFloatingButton(
                  icon: Icons.pan_tool,
                  onPressed: _showRaiseHand,
                ),
                const SizedBox(height: 8),
                _buildFloatingButton(
                  icon: Icons.emoji_emotions,
                  onPressed: () => _showReaction('👍'),
                ),
                const SizedBox(height: 8),
                _buildFloatingButton(
                  icon: Icons.format_paint,
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                ),
                const SizedBox(height: 8),
                _buildFloatingButton(
                  icon: _showParticipants ? Icons.people : Icons.people_outline,
                  onPressed: () {
                    setState(() {
                      _showParticipants = !_showParticipants;
                    });
                  },
                ),
              ],
            ),
          ),

          // Chat panel
          if (_showChat)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 300,
                color: Colors.white,
                child: Column(
                  children: <>[
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.green,
                      child: Row(
                        children: <>[
                          const Text(
                            'Chat',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _showChat = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text('U${index + 1}'),
                            ),
                            title: Text('User ${index + 1}'),
                            subtitle: Text('Hello everyone!'),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: <>[
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Type a message...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send, color: Colors.green),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Filters panel
          if (_showFilters)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BeautyFilterPanel(
                onFilterChanged: (filters) {
                  // Apply filters
                },
              ),
            ),

          // Loading indicator
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 24),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildPinnedView() {
    final pinnedUser = _participants.firstWhere(
      (Object? p) => p.userId == _pinnedUserId,
      orElse: () => _participants.first,
    );

    return Column(
      children: <>[
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <>[
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: pinnedUser.avatar != null
                        ? NetworkImage(pinnedUser.avatar!)
                        : null,
                    child: pinnedUser.avatar == null
                        ? Text(
                            pinnedUser.name[0].toUpperCase(),
                            style: const TextStyle(fontSize: 40),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    pinnedUser.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (pinnedUser.isSpeaking)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: AudioWave(isActive: true, color: Colors.green),
                    ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: ParticipantGrid(
            participants: _participants.where((Object? p) => p.userId != _pinnedUserId).toList(),
            localUserId: 'local',
            onParticipantTap: _onParticipantTap,
            onMuteParticipant: _onMuteParticipant,
            onPinParticipant: _onPinParticipant,
          ),
        ),
      ],
    );
  }
}