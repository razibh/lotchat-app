import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // DiagnosticPropertiesBuilder এর জন্য

class AppShimmer extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const AppShimmer({
    required this.child,
    this.isLoading = true,
    this.baseColor = Colors.grey,
    this.highlightColor = Colors.white,
    this.duration = const Duration(milliseconds: 1500),
    super.key,
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isLoading', isLoading));
    properties.add(ColorProperty('baseColor', baseColor));
    properties.add(ColorProperty('highlightColor', highlightColor));
    properties.add(DiagnosticsProperty<Duration>('duration', duration));
  }
}

class _AppShimmerState extends State<AppShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: [widget.baseColor, widget.highlightColor, widget.baseColor],
          stops: const [0, 0.5, 1],
          begin: Alignment(-1 + _animation.value * 2, -0.5),
          end: Alignment(1 + _animation.value * 2, 0.5),
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: widget.child,
    );
  }
}

class ShimmerLoading extends StatelessWidget {
  final Widget child;

  const ShimmerLoading({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: child,
    );
  }
}

// Shimmer Placeholders
class ShimmerRect extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerRect({
    required this.width,
    required this.height,
    this.borderRadius = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('width', width));
    properties.add(DoubleProperty('height', height));
    properties.add(DoubleProperty('borderRadius', borderRadius));
  }
}

class ShimmerCircle extends StatelessWidget {
  final double radius;

  const ShimmerCircle({required this.radius, super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('radius', radius));
  }
}

class ShimmerText extends StatelessWidget {
  final double width;
  final double height;

  const ShimmerText({
    required this.width,
    this.height = 16,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('width', width));
    properties.add(DoubleProperty('height', height));
  }
}

class ShimmerCard extends StatelessWidget {
  final double height;
  final double width;

  const ShimmerCard({
    required this.height,
    required this.width,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('height', height));
    properties.add(DoubleProperty('width', width));
  }
}

class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double spacing;

  const ShimmerList({
    this.itemCount = 5,
    this.itemHeight = 80,
    this.spacing = 8,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: ShimmerCard(
            height: itemHeight,
            width: double.infinity,
          ),
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('itemCount', itemCount));
    properties.add(DoubleProperty('itemHeight', itemHeight));
    properties.add(DoubleProperty('spacing', spacing));
  }
}

class ShimmerGrid extends StatelessWidget {
  final int crossAxisCount;
  final int itemCount;
  final double itemHeight;
  final double spacing;

  const ShimmerGrid({
    this.crossAxisCount = 2,
    this.itemCount = 6,
    this.itemHeight = 200,
    this.spacing = 8,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: itemHeight / (MediaQuery.of(context).size.width / crossAxisCount - spacing * 2),
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) {
        return ShimmerCard(
          height: itemHeight,
          width: double.infinity,
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('crossAxisCount', crossAxisCount));
    properties.add(IntProperty('itemCount', itemCount));
    properties.add(DoubleProperty('itemHeight', itemHeight));
    properties.add(DoubleProperty('spacing', spacing));
  }
}