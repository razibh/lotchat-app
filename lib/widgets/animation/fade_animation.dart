import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class FadeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const FadeAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
  });

  @override
  State<FadeAnimation> createState() => _FadeAnimationState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Duration>('duration', duration));
    properties.add(DiagnosticsProperty<Duration>('delay', delay));
    properties.add(DiagnosticsProperty<Curve>('curve', curve));
  }
}

class _FadeAnimationState extends State<FadeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

class SlideFadeAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final Offset offset;

  const SlideFadeAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
    this.offset = const Offset(0, 0.3),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: offset, end: Offset.zero),
      duration: duration,
      curve: curve,
      child: child,
      builder: (BuildContext context, Offset offset, Widget? child) {
        final double opacity = 1.0 - (offset.distance / offset.distance).clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity.isFinite ? opacity : 1.0,
          child: Transform.translate(
            offset: offset * 100,
            child: child,
          ),
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Duration>('duration', duration));
    properties.add(DiagnosticsProperty<Duration>('delay', delay));
    properties.add(DiagnosticsProperty<Curve>('curve', curve));
    properties.add(DiagnosticsProperty<Offset>('offset', offset));
  }
}

// Scale animation with fade
class ScaleFadeAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double beginScale;

  const ScaleFadeAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
    this.beginScale = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: beginScale, end: 1.0),
      duration: duration,
      curve: curve,
      child: child,
      builder: (BuildContext context, double scale, Widget? child) {
        return Opacity(
          opacity: scale,
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Duration>('duration', duration));
    properties.add(DiagnosticsProperty<Duration>('delay', delay));
    properties.add(DiagnosticsProperty<Curve>('curve', curve));
    properties.add(DoubleProperty('beginScale', beginScale));
  }
}

// Sequence animation for list items
class ListFadeAnimation extends StatelessWidget {
  final List<Widget> children;
  final Duration itemDuration;
  final Duration interval;
  final Curve curve;

  const ListFadeAnimation({
    super.key,
    required this.children,
    this.itemDuration = const Duration(milliseconds: 300),
    this.interval = const Duration(milliseconds: 100),
    this.curve = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        return FadeAnimation(
          delay: Duration(milliseconds: index * interval.inMilliseconds),
          duration: itemDuration,
          curve: curve,
          child: child,
        );
      }).toList(),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Duration>('itemDuration', itemDuration));
    properties.add(DiagnosticsProperty<Duration>('interval', interval));
    properties.add(DiagnosticsProperty<Curve>('curve', curve));
  }
}

// Repeat fade animation (pulse effect)
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minOpacity;
  final double maxOpacity;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.minOpacity = 0.3,
    this.maxOpacity = 1.0,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Duration>('duration', duration));
    properties.add(DoubleProperty('minOpacity', minOpacity));
    properties.add(DoubleProperty('maxOpacity', maxOpacity));
  }
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
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
      builder: (context, child) {
        return Opacity(
          opacity: widget.minOpacity + (widget.maxOpacity - widget.minOpacity) * _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

// Shake animation
class ShakeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double offset;

  const ShakeAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.offset = 10.0,
  });

  @override
  State<ShakeAnimation> createState() => _ShakeAnimationState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Duration>('duration', duration));
    properties.add(DoubleProperty('offset', offset));
  }
}

class _ShakeAnimationState extends State<ShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: -widget.offset, end: widget.offset).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticIn,
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });

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
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: widget.child,
        );
      },
    );
  }
}