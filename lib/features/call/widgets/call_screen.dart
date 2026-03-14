import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/models/user_model.dart';

class CallScreen extends StatefulWidget {
  
  const CallScreen({
    required this.user, required this.isVideoCall, super.key,
  });
  final UserModel user;
  final bool isVideoCall;

  @override
  State<CallScreen> createState() => _CallScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<UserModel>('user', user));
    properties.add(DiagnosticsProperty<bool>('isVideoCall', isVideoCall));
  }
}

class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {
  late RtcEngine _engine;
  bool isMicMuted = false;
  bool isSpeakerOn = false;
  bool isCameraOn = true;
  bool isFrontCamera = true;
  int callDuration = 0;
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    
    _initAgora();
    _startCallTimer();
  }
  
  Future<void> _initAgora() async {
    await <>[Permission.microphone, Permission.camera].request();
    
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: 'YOUR_AGORA_APP_ID',
    ),);
    
    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        debugPrint('Joined channel');
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        debugPrint('User joined: $remoteUid');
      },
      onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
        debugPrint('User offline: $remoteUid');
      },
    ),);
    
    await _engine.enableVideo();
    await _engine.startPreview();
    
    await _engine.joinChannel(
      token: 'YOUR_TOKEN',
      channelId: 'channel_${DateTime.now().millisecondsSinceEpoch}',
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }
  
  void _startCallTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          callDuration++;
        });
        _startCallTimer();
      }
    });
  }
  
  String _formatDuration(int seconds) {
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <>[
          // Remote Video
          ColoredBox(
            color: Colors.black,
            child: const Center(
              child: Text(
                'Remote User',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          
          // Local Video (Picture in Picture)
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: widget.isVideoCall && isCameraOn
                  ? AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: _engine,
                        canvas: const VideoCanvas(uid: 0),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
            ),
          ),
          
          // Call Info
          Positioned(
            top: 40,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  widget.user.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatDuration(callDuration),
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          
          // Controls
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <>[
                _buildControlButton(
                  icon: isMicMuted ? Icons.mic_off : Icons.mic,
                  color: isMicMuted ? Colors.red : Colors.white,
                  onTap: () {
                    setState(() {
                      isMicMuted = !isMicMuted;
                      _engine.muteLocalAudioStream(isMicMuted);
                    });
                  },
                ),
                _buildControlButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  onTap: () {
                    _engine.leaveChannel();
                    Navigator.pop(context);
                  },
                ),
                _buildControlButton(
                  icon: isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                  color: isSpeakerOn ? Colors.green : Colors.white,
                  onTap: () {
                    setState(() {
                      isSpeakerOn = !isSpeakerOn;
                      _engine.setEnableSpeakerphone(isSpeakerOn);
                    });
                  },
                ),
                if (widget.isVideoCall) ...<>[
                  _buildControlButton(
                    icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
                    color: isCameraOn ? Colors.green : Colors.red,
                    onTap: () {
                      setState(() {
                        isCameraOn = !isCameraOn;
                        _engine.muteLocalVideoStream(!isCameraOn);
                      });
                    },
                  ),
                  _buildControlButton(
                    icon: Icons.flip_camera_ios,
                    color: Colors.white,
                    onTap: () {
                      setState(() {
                        isFrontCamera = !isFrontCamera;
                        _engine.switchCamera();
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
          
          // Ringing Animation (for incoming call)
          if (callDuration == 0)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <>[
                      ScaleTransition(
                        scale: _pulseController,
                        child: const Icon(
                          Icons.phone_in_talk,
                          color: Colors.green,
                          size: 80,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Ringing...',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
  
  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isMicMuted', isMicMuted));
    properties.add(DiagnosticsProperty<bool>('isSpeakerOn', isSpeakerOn));
    properties.add(DiagnosticsProperty<bool>('isCameraOn', isCameraOn));
    properties.add(DiagnosticsProperty<bool>('isFrontCamera', isFrontCamera));
    properties.add(IntProperty('callDuration', callDuration));
  }
}