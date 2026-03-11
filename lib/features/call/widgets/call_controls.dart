import 'package:flutter/material.dart';

class CallControls extends StatelessWidget {
  final bool isVideoCall;
  final bool isMicMuted;
  final bool isSpeakerOn;
  final bool isCameraOn;
  final bool isFrontCamera;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onToggleCamera;
  final VoidCallback onFlipCamera;
  final VoidCallback onToggleScreenShare;
  final VoidCallback onEndCall;

  const CallControls({
    Key? key,
    required this.isVideoCall,
    required this.isMicMuted,
    required this.isSpeakerOn,
    required this.isCameraOn,
    required this.isFrontCamera,
    required this.onToggleMic,
    required this.onToggleSpeaker,
    required this.onToggleCamera,
    required this.onFlipCamera,
    required this.onToggleScreenShare,
    required this.onEndCall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mic Button
          _buildControlButton(
            icon: isMicMuted ? Icons.mic_off : Icons.mic,
            color: isMicMuted ? Colors.red : Colors.white,
            onTap: onToggleMic,
          ),
          
          // Speaker Button
          _buildControlButton(
            icon: isSpeakerOn ? Icons.volume_up : Icons.volume_off,
            color: isSpeakerOn ? Colors.green : Colors.white,
            onTap: onToggleSpeaker,
          ),
          
          // Camera Button (Video call only)
          if (isVideoCall)
            _buildControlButton(
              icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
              color: isCameraOn ? Colors.green : Colors.red,
              onTap: onToggleCamera,
            ),
          
          // Flip Camera Button (Video call only)
          if (isVideoCall)
            _buildControlButton(
              icon: Icons.flip_camera_ios,
              color: Colors.white,
              onTap: onFlipCamera,
            ),
          
          // Screen Share Button
          if (isVideoCall)
            _buildControlButton(
              icon: Icons.screen_share,
              color: Colors.blue,
              onTap: onToggleScreenShare,
            ),
          
          // End Call Button
          _buildControlButton(
            icon: Icons.call_end,
            color: Colors.red,
            size: 60,
            onTap: onEndCall,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    double size = 50,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(
          icon,
          color: color,
          size: size * 0.4,
        ),
      ),
    );
  }
}