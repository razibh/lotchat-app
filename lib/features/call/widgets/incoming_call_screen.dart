import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';  // DiagnosticPropertiesBuilder এর জন্য
import 'package:audioplayers/audioplayers.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/call_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/models/user_models.dart' as app;  // ← alias ব্যবহার
import '../../../widgets/animation/pulse_animation.dart';
import 'call_screen.dart';

// CallType enum
enum CallType {
  audio,
  video,
}

class IncomingCallScreen extends StatefulWidget {
  final String callerId;
  final String callerName;
  final String? callerAvatar;
  final CallType callType;

  const IncomingCallScreen({
    required this.callerId,
    required this.callerName,
    required this.callType,
    super.key,
    this.callerAvatar,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('callerId', callerId));
    properties.add(StringProperty('callerName', callerName));
    properties.add(StringProperty('callerAvatar', callerAvatar));
    properties.add(EnumProperty<CallType>('callType', callType));
  }
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  final CallService _callService = ServiceLocator().get<CallService>();
  final NotificationService _notificationService = ServiceLocator().get<NotificationService>();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRinging = true;

  @override
  void initState() {
    super.initState();
    _startRinging();
  }

  Future<void> _startRinging() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('sounds/call_ringtone.mp3'));
  }

  Future<void> _stopRinging() async {
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
  }

  Future<void> _acceptCall() async {
    await _stopRinging();

    // Initialize call service
    await _callService.initialize();

    // Join the call
    await _callService.joinCall(_callService.currentChannelId!);

    // Create user object
    final user = app.User(
      id: widget.callerId,
      username: widget.callerName,
      email: '',
      name: widget.callerName,
      role: app.UserRole.user,
      countryId: '',
      createdAt: DateTime.now(),
      photoURL: widget.callerAvatar,
    );

    // Navigate to call screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          user: user,
          isVideoCall: widget.callType == CallType.video,
        ),
      ),
    );
  }

  Future<void> _rejectCall() async {
    await _stopRinging();

    // Send rejection via socket
    // _socketService.emit('call-rejected', {'callerId': widget.callerId});

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Caller Info
            Column(
              children: [
                // Avatar with pulse animation
                PulseAnimation(
                  animate: _isRinging,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.green,
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: widget.callerAvatar != null
                          ? NetworkImage(widget.callerAvatar!)
                          : null,
                      child: widget.callerAvatar == null
                          ? Text(
                        widget.callerName[0].toUpperCase(),
                        style: const TextStyle(fontSize: 40),
                      )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.callerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.callType == CallType.video ? 'Video Call' : 'Voice Call',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Call Status
            const Text(
              'Incoming call...',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 40),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Decline Button
                _buildActionButton(
                  icon: Icons.call_end,
                  label: 'Decline',
                  color: Colors.red,
                  onTap: _rejectCall,
                ),

                // Accept Button
                _buildActionButton(
                  icon: widget.callType == CallType.video
                      ? Icons.videocam
                      : Icons.call,
                  label: 'Accept',
                  color: Colors.green,
                  onTap: _acceptCall,
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}