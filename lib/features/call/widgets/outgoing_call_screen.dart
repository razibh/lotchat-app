import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../audio_wave.dart';

class OutgoingCallScreen extends StatefulWidget {

  const OutgoingCallScreen({
    Key? key,
    required this.user,
    required this.isVideoCall,
  }) : super(key: key);
  final UserModel user;
  final bool isVideoCall;

  @override
  State<OutgoingCallScreen> createState() => _OutgoingCallScreenState();
}

class _OutgoingCallScreenState extends State<OutgoingCallScreen> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _pulseController;
  int _ringingDuration = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _ringingDuration++;
        });
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          children: <>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <>[
                  // User Avatar with pulse animation
                  ScaleTransition(
                    scale: _pulseController,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: <>[
                          BoxShadow(
                            color: widget.isVideoCall 
                                ? Colors.red.withOpacity(0.5)
                                : Colors.green.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: widget.user.photoURL != null
                            ? NetworkImage(widget.user.photoURL!)
                            : null,
                        child: widget.user.photoURL == null
                            ? Text(
                                widget.user.username[0].toUpperCase(),
                                style: const TextStyle(fontSize: 40),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // User Name
                  Text(
                    widget.user.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Call Type
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <>[
                      Icon(
                        widget.isVideoCall ? Icons.videocam : Icons.call,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.isVideoCall ? 'Video Call' : 'Voice Call',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Audio Wave
                  AudioWave(
                    isActive: true,
                    color: widget.isVideoCall ? Colors.red : Colors.green,
                  ),
                  const SizedBox(height: 20),
                  
                  // Ringing Timer
                  Text(
                    _formatDuration(_ringingDuration),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Status Text
                  const Text(
                    'Ringing...',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Call Controls
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <>[
                  // Mute Button
                  _buildControlButton(
                    icon: Icons.mic,
                    color: Colors.white,
                    onTap: () {},
                  ),
                  
                  // Speaker Button
                  _buildControlButton(
                    icon: Icons.volume_up,
                    color: Colors.white,
                    onTap: () {},
                  ),
                  
                  // End Call Button
                  _buildControlButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    size: 70,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  
                  // Camera Flip (Video only)
                  if (widget.isVideoCall)
                    _buildControlButton(
                      icon: Icons.flip_camera_ios,
                      color: Colors.white,
                      onTap: () {},
                    ),
                  
                  // Keypad Button
                  _buildControlButton(
                    icon: Icons.dialpad,
                    color: Colors.white,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    double size = 60,
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