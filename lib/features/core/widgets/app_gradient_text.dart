import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // DiagnosticPropertiesBuilder এর জন্য

class AppGradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  const AppGradientText({
    required this.text,
    required this.style,
    required this.gradient,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) => gradient.createShader(
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('text', text));
    properties.add(DiagnosticsProperty<TextStyle>('style', style));
    properties.add(DiagnosticsProperty<Gradient>('gradient', gradient));
    properties.add(EnumProperty<TextAlign>('textAlign', textAlign));
    properties.add(IntProperty('maxLines', maxLines));
    properties.add(EnumProperty<TextOverflow>('overflow', overflow));
  }
}

enum GradientType { linear, radial, sweep }

class GradientTextWidget extends StatelessWidget {
  final String text;
  final TextStyle style;
  final List<Color> colors;
  final GradientType type;
  final TextAlign textAlign;
  final int? maxLines;

  const GradientTextWidget({
    required this.text,
    required this.style,
    required this.colors,
    this.type = GradientType.linear,
    this.textAlign = TextAlign.start,
    this.maxLines,
    super.key,
  });

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
        break;
      case GradientType.radial:
        gradient = RadialGradient(
          colors: colors,
        );
        break;
      case GradientType.sweep:
        gradient = SweepGradient(
          colors: colors,
        );
        break;
    }

    return ShaderMask(
      shaderCallback: (Rect bounds) => gradient.createShader(
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('text', text));
    properties.add(DiagnosticsProperty<TextStyle>('style', style));
    properties.add(IterableProperty<Color>('colors', colors));
    properties.add(EnumProperty<GradientType>('type', type));
    properties.add(EnumProperty<TextAlign>('textAlign', textAlign));
    properties.add(IntProperty('maxLines', maxLines));
  }
}

class AnimatedGradientText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final List<Color> colors;
  final Duration duration;

  const AnimatedGradientText({
    required this.text,
    required this.style,
    required this.colors,
    this.duration = const Duration(seconds: 3),
    super.key,
  });

  @override
  State<AnimatedGradientText> createState() => _AnimatedGradientTextState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('text', text));
    properties.add(DiagnosticsProperty<TextStyle>('style', style));
    properties.add(IterableProperty<Color>('colors', colors));
    properties.add(DiagnosticsProperty<Duration>('duration', duration));
  }
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
      builder: (BuildContext context, Widget? child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
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