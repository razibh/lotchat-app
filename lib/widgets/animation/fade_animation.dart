import 'package:flutter/material.dart';

class FadeAnimation extends StatefulWidget {

  const FadeAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
  }) : super(key: key);
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  @override
  State<FadeAnimation> createState() => _FadeAnimationState();
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

  const SlideFadeAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
    this.offset = const Offset(0, 0.3),
  }) : super(key: key);
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(begin: offset, end: Offset.zero),
      duration: duration,
      curve: curve,
      child: child,
      builder: (context, Offset offset, child) {
        return Opacity(
          opacity: 1 - (offset.distance / offset.distance).clamp(0, 1),
          child: Transform.translate(
            offset: offset * 100,
            child: child,
          ),
        );
      },
    );
  }
}