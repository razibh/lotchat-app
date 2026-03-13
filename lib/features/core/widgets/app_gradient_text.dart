import 'package:flutter/material.dart';

class AppGradientText extends StatelessWidget {

  const AppGradientText({
    Key? key,
    required this.text,
    required this.style,
    required this.gradient,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  }) : super(key: key);
  final String text;
  final TextStyle style;
  final Gradient gradient;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}

class GradientTextWidget extends StatelessWidget {

  const GradientTextWidget({
    Key? key,
    required this.text,
    required this.style,
    required this.colors,
    this.type = GradientType.linear,
    this.textAlign = TextAlign.start,
    this.maxLines,
  }) : super(key: key);
  final String text;
  final TextStyle style;
  final List<Color> colors;
  final GradientType type;
  final TextAlign textAlign;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    Gradient gradient;
    
    switch (type) {
      case GradientType.linear:
        gradient = LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case GradientType.radial:
        gradient = RadialGradient(
          colors: colors,
        );
      case GradientType.sweep:
        gradient = SweepGradient(
          colors: colors,
        );
    }

    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

enum GradientType { linear, radial, sweep }

class AnimatedGradientText extends StatefulWidget {

  const AnimatedGradientText({
    Key? key,
    required this.text,
    required this.style,
    required this.colors,
    this.duration = const Duration(seconds: 3),
  }) : super(key: key);
  final String text;
  final TextStyle style;
  final List<Color> colors;
  final Duration duration;

  @override
  State<AnimatedGradientText> createState() => _AnimatedGradientTextState();
}

class _AnimatedGradientTextState extends State<AnimatedGradientText> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
    
    _animation = Tween<Offset>(
      begin: const Offset(-1, -1),
      end: const Offset(1, 1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
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
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: widget.colors,
              begin: Alignment(_animation.value.dx, _animation.value.dy),
              end: Alignment(-_animation.value.dx, -_animation.value.dy),
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: widget.style.copyWith(color: Colors.white),
          ),
        );
      },
    );
  }
}