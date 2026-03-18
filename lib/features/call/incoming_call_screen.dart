// lib/features/call/incoming_call_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class IncomingCallScreen extends StatefulWidget {
  final String callerId;
  final String callerName;
  final String? callerAvatar;
  final String callType; // 'audio' or 'video'
  final String channelId;

  const IncomingCallScreen({
    super.key,
    required this.callerId,
    required this.callerName,
    this.callerAvatar,
    required this.callType,
    required this.channelId,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('callerId', callerId));
    properties.add(StringProperty('callerName', callerName));
    properties.add(StringProperty('callerAvatar', callerAvatar));
    properties.add(StringProperty('callType', callType));
    properties.add(StringProperty('channelId', channelId));
  }
}

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade900,
              Colors.purple.shade700,
              Colors.purple.shade500,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Caller Info
              Column(
                children: [
                  // Caller Avatar
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      backgroundImage: widget.callerAvatar != null
                          ? NetworkImage(widget.callerAvatar!)
                          : null,
                      child: widget.callerAvatar == null
                          ? Text(
                        widget.callerName.isNotEmpty
                            ? widget.callerName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                        ),
                      )
                          : null,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Caller Name
                  Text(
                    widget.callerName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Call Type
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.callType == 'video'
                            ? Icons.videocam
                            : Icons.call,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.callType == 'video'
                            ? 'Incoming Video Call'
                            : 'Incoming Voice Call',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Decline Button
                    _buildActionButton(
                      icon: Icons.call_end,
                      color: Colors.red,
                      onTap: _declineCall,
                    ),

                    // Accept Button
                    _buildActionButton(
                      icon: widget.callType == 'video'
                          ? Icons.videocam
                          : Icons.call,
                      color: Colors.green,
                      onTap: _acceptCall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  void _acceptCall() {
    Navigator.pushReplacementNamed(
      context,
      widget.callType == 'video' ? '/call/video' : '/call/audio',
      arguments: {
        'callerId': widget.callerId,
        'callerName': widget.callerName,
        'callerAvatar': widget.callerAvatar,
        'channelId': widget.channelId,
      },
    );
  }

  void _declineCall() {
    Navigator.pop(context);
    // TODO: Send decline signal via socket
  }
}// TODOImplement this library.