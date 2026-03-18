import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// ==================== ENUMS (ক্লাসের বাইরে) ====================

enum BackgroundPattern { dots, lines, grid, circles }

// ==================== MAIN WIDGET ====================

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final Alignment begin;
  final Alignment end;
  final bool useScaffold;
  final EdgeInsets padding;
  final BoxDecoration? decoration;
  final bool showBottomGlow;

  const GradientBackground({
    Key? key,
    required this.child,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.useScaffold = false,
    this.padding = EdgeInsets.zero,
    this.decoration,
    this.showBottomGlow = false,
  }) : super(key: key);

  /// Default gradient background with purple and blue
  factory GradientBackground.primary({
    required Widget child,
    bool useScaffold = false,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return GradientBackground(
      colors: const [AppColors.accentPurple, AppColors.accentBlue],
      child: child,
      useScaffold: useScaffold,
      padding: padding,
    );
  }

  /// Dark gradient background
  factory GradientBackground.dark({
    required Widget child,
    bool useScaffold = false,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return GradientBackground(
      colors: const [AppColors.backgroundDark, Color(0xFF1A1A2E)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      child: child,
      useScaffold: useScaffold,
      padding: padding,
    );
  }

  /// Light gradient background
  factory GradientBackground.light({
    required Widget child,
    bool useScaffold = false,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return GradientBackground(
      colors: const [Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      child: child,
      useScaffold: useScaffold,
      padding: padding,
    );
  }

  /// Sunset gradient background (orange to pink)
  factory GradientBackground.sunset({
    required Widget child,
    bool useScaffold = false,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return GradientBackground(
      colors: const [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      child: child,
      useScaffold: useScaffold,
      padding: padding,
    );
  }

  /// Midnight gradient background (dark blue to purple)
  factory GradientBackground.midnight({
    required Widget child,
    bool useScaffold = false,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return GradientBackground(
      colors: const [Color(0xFF141E30), Color(0xFF243B55)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      child: child,
      useScaffold: useScaffold,
      padding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradientBox = Container(
      decoration: decoration ??
          BoxDecoration(
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: colors ?? const [AppColors.accentPurple, AppColors.accentBlue],
            ),
          ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (useScaffold) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: gradientBox,
      );
    }

    return gradientBox;
  }
}

/// Scrollable gradient background with app bar support
class ScrollableGradientBackground extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final List<Color>? colors;
  final Alignment begin;
  final Alignment end;

  const ScrollableGradientBackground({
    Key? key,
    required this.child,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            colors: colors ?? const [AppColors.accentPurple, AppColors.accentBlue],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: child,
        ),
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

/// Gradient background with animated overlay effects
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final Duration animationDuration;
  final bool useScaffold;
  final EdgeInsets padding;

  const AnimatedGradientBackground({
    Key? key,
    required this.child,
    required this.colors,
    this.animationDuration = const Duration(seconds: 5),
    this.useScaffold = false,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _beginAnimation;
  late Animation<Alignment> _endAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat(reverse: true);

    _beginAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: ConstantTween<Alignment>(Alignment.topLeft),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Alignment>(
          begin: Alignment.topLeft,
          end: Alignment.bottomLeft,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<Alignment>(
          begin: Alignment.bottomLeft,
          end: Alignment.bottomRight,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<Alignment>(
          begin: Alignment.bottomRight,
          end: Alignment.topRight,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<Alignment>(
          begin: Alignment.topRight,
          end: Alignment.topLeft,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
    ]).animate(_controller);

    _endAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: ConstantTween<Alignment>(Alignment.bottomRight),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Alignment>(
          begin: Alignment.bottomRight,
          end: Alignment.topRight,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<Alignment>(
          begin: Alignment.topRight,
          end: Alignment.topLeft,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<Alignment>(
          begin: Alignment.topLeft,
          end: Alignment.bottomLeft,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<Alignment>(
          begin: Alignment.bottomLeft,
          end: Alignment.bottomRight,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradientBox = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: _beginAnimation.value,
              end: _endAnimation.value,
              colors: widget.colors,
            ),
          ),
          child: Padding(
            padding: widget.padding,
            child: child,
          ),
        );
      },
      child: widget.child,
    );

    if (widget.useScaffold) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: gradientBox,
      );
    }

    return gradientBox;
  }
}

/// Gradient background with overlay pattern (dots, lines, etc.)
class PatternGradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final Alignment begin;
  final Alignment end;
  final BackgroundPattern pattern;  // ← enum ব্যবহার করুন
  final double patternOpacity;
  final bool useScaffold;
  final EdgeInsets padding;

  const PatternGradientBackground({
    Key? key,
    required this.child,
    required this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.pattern = BackgroundPattern.dots,  // ← enum ব্যবহার
    this.patternOpacity = 0.1,
    this.useScaffold = false,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gradientBox = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _PatternPainter(
                pattern: pattern,
                opacity: patternOpacity,
              ),
            ),
          ),
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );

    if (useScaffold) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: gradientBox,
      );
    }

    return gradientBox;
  }
}

class _PatternPainter extends CustomPainter {
  final BackgroundPattern pattern;  // ← enum ব্যবহার
  final double opacity;

  _PatternPainter({
    required this.pattern,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    switch (pattern) {
      case BackgroundPattern.dots:  // ← enum ব্যবহার
        _drawDots(canvas, size, paint);
        break;
      case BackgroundPattern.lines:
        _drawLines(canvas, size, paint);
        break;
      case BackgroundPattern.grid:
        _drawGrid(canvas, size, paint);
        break;
      case BackgroundPattern.circles:
        _drawCircles(canvas, size, paint);
        break;
    }
  }

  void _drawDots(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;
    const spacing = 30.0;
    const radius = 2.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  void _drawLines(Canvas canvas, Size size, Paint paint) {
    const spacing = 20.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  void _drawGrid(Canvas canvas, Size size, Paint paint) {
    const spacing = 40.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  void _drawCircles(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    const spacing = 50.0;
    const radius = 15.0;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}