import 'package:flutter/material.dart';

class PulseAnimation extends StatefulWidget {

  const PulseAnimation({
    required this.child, super.key,
    this.animate = true,
    this.duration = const Duration(milliseconds: 800),
    this.minScale = 1.0,
    this.maxScale = 1.1,
    this.curve = Curves.easeInOut,
  });
  final Widget child;
  final bool animate;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final Curve curve;

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('animate', animate));
    properties.add(DiagnosticsProperty<Duration>('duration', duration));
    properties.add(DoubleProperty('minScale', minScale));
    properties.add(DoubleProperty('maxScale', maxScale));
    properties.add(DiagnosticsProperty<Curve>('curve', curve));
  }
}

class _PulseAnimationState extends State<PulseAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ),);

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulseAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

class CircularPulseAnimation extends StatefulWidget {

  const CircularPulseAnimation({
    super.key,
    this.color = Colors.blue,
    this.size = 100,
    this.duration = const Duration(seconds: 2),
    this.ringCount = 3,
  });
  final Color color;
  final double size;
  final Duration duration;
  final int ringCount;

  @override
  State<CircularPulseAnimation> createState() => _CircularPulseAnimationState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('color', color));
    properties.add(DoubleProperty('size', size));
    properties.add(DiagnosticsProperty<Duration>('duration', duration));
    properties.add(IntProperty('ringCount', ringCount));
  }
}

class _CircularPulseAnimationState extends State<CircularPulseAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: _CircularPulsePainter(
        color: widget.color,
        progress: _controller.value,
        ringCount: widget.ringCount,
      ),
    );
  }
}

class _CircularPulsePainter extends CustomPainter {

  _CircularPulsePainter({
    required this.color,
    required this.progress,
    required this.ringCount,
  });
  final Color color;
  final double progress;
  final int ringCount;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double maxRadius = size.width / 2;

    for (var i = 0; i < ringCount; i++) {
      final double ringProgress = (progress + i / ringCount) % 1.0;
      final double radius = maxRadius * (0.3 + ringProgress * 0.7);
      final double opacity = (1.0 - ringProgress).clamp(0.0, 1.0);

      final Paint paint = Paint()
        ..color = color.withValues(alpha: opacity * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircularPulsePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class ScaleInAnimation extends StatefulWidget {

  const ScaleInAnimation({
    required this.child, super.key,
    this.duration = const Duration(milliseconds: 300),
    this.begin = 0.8,
    this.curve = Curves.elasticOut,
  });
  final Widget child;
  final Duration duration;
  final double begin;
  final Curve curve;

  @override
  State<ScaleInAnimation> createState() => _ScaleInAnimationState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Duration>('duration', duration));
    properties.add(DoubleProperty('begin', begin));
    properties.add(DiagnosticsProperty<Curve>('curve', curve));
  }
}

class _ScaleInAnimationState extends State<ScaleInAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(
      begin: widget.begin,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ),);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

class SlideInAnimation extends StatefulWidget {

  const SlideInAnimation({
    required this.child, super.key,
    this.duration = const Duration(milliseconds: 300),
    this.begin = const Offset(0, 0.1),
    this.curve = Curves.easeOut,
  });
  final Widget child;
  final Duration duration;
  final Offset begin;
  final Curve curve;

  @override
  State<SlideInAnimation> createState() => _SlideInAnimationState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Duration>('duration', duration));
    properties.add(DiagnosticsProperty<Offset>('begin', begin));
    properties.add(DiagnosticsProperty<Curve>('curve', curve));
  }
}

class _SlideInAnimationState extends State<SlideInAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<Offset>(
      begin: widget.begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ),);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}