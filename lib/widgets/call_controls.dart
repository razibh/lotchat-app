import 'package:flutter/material.dart';

class CallControls extends StatelessWidget {

  const CallControls({
    Key? key,
    required this.isVideoCall,
    required this.isMicMuted,
    required this.isSpeakerOn,
    required this.isCameraOn,
    required this.isFrontCamera,
    this.isScreenSharing = false,
    required this.onToggleMic,
    required this.onToggleSpeaker,
    required this.onToggleCamera,
    required this.onFlipCamera,
    required this.onToggleScreenShare,
    required this.onEndCall,
  }) : super(key: key);
  final bool isVideoCall;
  final bool isMicMuted;
  final bool isSpeakerOn;
  final bool isCameraOn;
  final bool isFrontCamera;
  final bool isScreenSharing;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onToggleCamera;
  final VoidCallback onFlipCamera;
  final VoidCallback onToggleScreenShare;
  final VoidCallback onEndCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            // Main Controls Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <>[
                _buildControlButton(
                  icon: isMicMuted ? Icons.mic_off : Icons.mic,
                  label: isMicMuted ? 'Unmute' : 'Mute',
                  color: isMicMuted ? Colors.red : Colors.white,
                  onTap: onToggleMic,
                ),
                _buildControlButton(
                  icon: isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                  label: isSpeakerOn ? 'Speaker' : 'Earpiece',
                  color: isSpeakerOn ? Colors.green : Colors.white,
                  onTap: onToggleSpeaker,
                ),
                if (isVideoCall)
                  _buildControlButton(
                    icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
                    label: isCameraOn ? 'Camera' : 'Camera Off',
                    color: isCameraOn ? Colors.green : Colors.red,
                    onTap: onToggleCamera,
                  ),
                _buildControlButton(
                  icon: Icons.call_end,
                  label: 'End',
                  color: Colors.red,
                  size: 60,
                  onTap: onEndCall,
                ),
                if (isVideoCall)
                  _buildControlButton(
                    icon: Icons.flip_camera_ios,
                    label: 'Flip',
                    color: Colors.white,
                    onTap: onFlipCamera,
                  ),
                if (isVideoCall)
                  _buildControlButton(
                    icon: isScreenSharing ? Icons.stop_screen_share : Icons.screen_share,
                    label: isScreenSharing ? 'Stop' : 'Share',
                    color: isScreenSharing ? Colors.green : Colors.white,
                    onTap: onToggleScreenShare,
                  ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Additional Info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <>[
                if (isScreenSharing)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: <>[
                        Icon(Icons.fiber_manual_record, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'Screen Sharing',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    double size = 50,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <>[
          Container(
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
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class CallTimer extends StatelessWidget {

  const CallTimer({Key? key, required this.duration}) : super(key: key);
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <>[
          const Icon(
            Icons.timer,
            color: Colors.white70,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            _formatDuration(duration),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes % 60;
    final int seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }
}

class IncomingCallControls extends StatelessWidget {

  const IncomingCallControls({
    Key? key,
    required this.onAccept,
    required this.onDecline,
    required this.callerName,
    required this.isVideoCall,
  }) : super(key: key);
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final String callerName;
  final bool isVideoCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <>[
          Text(
            callerName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isVideoCall ? 'Incoming video call...' : 'Incoming voice call...',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <>[
              _buildActionButton(
                icon: Icons.call_end,
                label: 'Decline',
                color: Colors.red,
                onTap: onDecline,
                size: 70,
              ),
              _buildActionButton(
                icon: isVideoCall ? Icons.videocam : Icons.call,
                label: 'Accept',
                color: Colors.green,
                onTap: onAccept,
                size: 70,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    double size = 60,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <>[
          Container(
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
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}