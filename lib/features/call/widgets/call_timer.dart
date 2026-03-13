import 'package:flutter/material.dart';

class CallTimer extends StatefulWidget {

  const CallTimer({Key? key, required this.duration}) : super(key: key);
  final int duration;

  @override
  State<CallTimer> createState() => _CallTimerState();
}

class _CallTimerState extends State<CallTimer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <>[
        // Pulse animation when call is active
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: 10 + (_controller.value * 5),
              height: 10 + (_controller.value * 5),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: <>[
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 10 * _controller.value,
                    spreadRadius: 2 * _controller.value,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        Text(
          _formatDuration(widget.duration),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}