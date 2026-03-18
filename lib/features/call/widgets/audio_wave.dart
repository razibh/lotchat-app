import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';  // DiagnosticPropertiesBuilder এর জন্য

class AudioWave extends StatefulWidget {
  final bool isActive;
  final Color color;
  final double height;
  final double width;
  final int barCount;
  final Duration animationDuration;

  const AudioWave({
    super.key,
    this.isActive = true,
    this.color = Colors.green,
    this.height = 40,
    this.width = 40,
    this.barCount = 5,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<AudioWave> createState() => _AudioWaveState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isActive', isActive));
    properties.add(ColorProperty('color', color));
    properties.add(DoubleProperty('height', height));
    properties.add(DoubleProperty('width', width));
    properties.add(IntProperty('barCount', barCount));
    properties.add(DiagnosticsProperty<Duration>('animationDuration', animationDuration));
  }
}

class _AudioWaveState extends State<AudioWave> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _heights = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat(reverse: true);

    // Initialize random heights
    for (var i = 0; i < widget.barCount; i++) {
      _heights.add(0.3 + (i * 0.1));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return SizedBox(
        height: widget.height,
        width: widget.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.barCount, (index) {
            return Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          height: widget.height,
          width: widget.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.barCount, (index) {
              final scale = 0.5 + (index * 0.1) + (_controller.value * 0.5);
              return Container(
                width: 4,
                height: 8 * scale,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class CircularAudioWave extends StatefulWidget {
  final bool isActive;
  final Color color;
  final double radius;
  final int ringCount;

  const CircularAudioWave({
    super.key,
    this.isActive = true,
    this.color = Colors.green,
    this.radius = 50,
    this.ringCount = 3,
  });

  @override
  State<CircularAudioWave> createState() => _CircularAudioWaveState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isActive', isActive));
    properties.add(ColorProperty('color', color));
    properties.add(DoubleProperty('radius', radius));
    properties.add(IntProperty('ringCount', ringCount));
  }
}

class _CircularAudioWaveState extends State<CircularAudioWave> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return CircleAvatar(
        radius: widget.radius,
        backgroundColor: widget.color.withOpacity(0.1),
        child: Icon(
          Icons.mic_off,
          color: widget.color,
          size: widget.radius,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.radius * 2, widget.radius * 2),
          painter: CircularWavePainter(
            color: widget.color,
            progress: _controller.value,
            ringCount: widget.ringCount,
          ),
          child: Center(
            child: CircleAvatar(
              radius: widget.radius * 0.4,
              backgroundColor: widget.color,
              child: const Icon(
                Icons.mic,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

class CircularWavePainter extends CustomPainter {
  final Color color;
  final double progress;
  final int ringCount;

  CircularWavePainter({
    required this.color,
    required this.progress,
    required this.ringCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double maxRadius = size.width / 2;

    for (var i = 0; i < ringCount; i++) {
      final double ringProgress = (progress + i / ringCount) % 1.0;
      final double radius = maxRadius * (0.3 + ringProgress * 0.7);
      final double opacity = (1.0 - ringProgress).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = color.withOpacity(opacity * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CircularWavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}