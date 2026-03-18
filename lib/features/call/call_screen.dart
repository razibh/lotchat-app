// lib/features/call/call_screen.dart

import 'dart:async'; // 🟢 Timer এর জন্য এই import যোগ করুন
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class CallScreen extends StatefulWidget {
  final dynamic user;
  final bool isVideoCall;

  const CallScreen({
    super.key,
    this.user,
    required this.isVideoCall,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<dynamic>('user', user));
    properties.add(DiagnosticsProperty<bool>('isVideoCall', isVideoCall));
  }
}

class _CallScreenState extends State<CallScreen> {
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  bool _isVideoEnabled = true;
  Duration _callDuration = Duration.zero;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startCallTimer();
  }

  void _startCallTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration = Duration(seconds: _callDuration.inSeconds + 1);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return "$hours:$minutes:$seconds";
    } else {
      return "$minutes:$seconds";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            color: Colors.black,
          ),

          // Main Video (if video call)
          if (widget.isVideoCall)
            Container(
              color: Colors.black87,
              child: const Center(
                child: Text(
                  'Video Preview',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),

          // Small Video Preview (if video call)
          if (widget.isVideoCall)
            Positioned(
              top: 60,
              right: 20,
              child: Container(
                width: 100,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Text(
                    'You',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

          // Audio Call UI (if audio call)
          if (!widget.isVideoCall)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // User Avatar
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.purple.shade200,
                    child: Text(
                      widget.user?.name?[0]?.toUpperCase() ?? '?',
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // User Name
                  Text(
                    widget.user?.name ?? 'Unknown User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Call Duration
                  Text(
                    _formatDuration(_callDuration),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Call Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Connected',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _endCall,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatDuration(_callDuration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mute Button
                _buildControlButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  color: _isMuted ? Colors.red : Colors.white70,
                  onTap: _toggleMute,
                ),

                // Speaker Button (Audio) / Flip Camera (Video)
                _buildControlButton(
                  icon: widget.isVideoCall
                      ? Icons.flip_camera_ios
                      : (_isSpeakerOn ? Icons.volume_up : Icons.volume_off),
                  color: widget.isVideoCall
                      ? Colors.white70
                      : (_isSpeakerOn ? Colors.blue : Colors.white70),
                  onTap: widget.isVideoCall ? _flipCamera : _toggleSpeaker,
                ),

                // Video Button (Video Call only)
                if (widget.isVideoCall)
                  _buildControlButton(
                    icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                    color: _isVideoEnabled ? Colors.blue : Colors.red,
                    onTap: _toggleVideo,
                  ),

                // End Call Button
                _buildControlButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  size: 24,
                  onTap: _endCall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    double size = 20,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1),
        ),
        child: Icon(
          icon,
          color: color,
          size: size,
        ),
      ),
    );
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    // TODO: Implement actual mute functionality
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
    // TODO: Implement speaker toggle
  }

  void _flipCamera() {
    // TODO: Implement camera flip
  }

  void _toggleVideo() {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
    // TODO: Implement video toggle
  }

  void _endCall() {
    _timer.cancel();
    Navigator.pop(context);
    // TODO: Implement call end functionality
  }
}