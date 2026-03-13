import 'package:flutter/material.dart';

class AppShimmer extends StatefulWidget {

  const AppShimmer({
    Key? key,
    required this.child,
    this.isLoading = true,
    this.baseColor = Colors.grey,
    this.highlightColor = Colors.white,
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);
  final Widget child;
  final bool isLoading;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
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
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: <>[widget.baseColor, widget.highlightColor, widget.baseColor],
          stops: const <double>[0.0, 0.5, 1.0],
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

  const ShimmerLoading({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: child,
    );
  }
}

// Shimmer Placeholders
class ShimmerRect extends StatelessWidget {

  const ShimmerRect({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = 0,
  }) : super(key: key);
  final double width;
  final double height;
  final double borderRadius;

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
}

class ShimmerCircle extends StatelessWidget {

  const ShimmerCircle({Key? key, required this.radius}) : super(key: key);
  final double radius;

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
}

class ShimmerText extends StatelessWidget {

  const ShimmerText({
    Key? key,
    required this.width,
    this.height = 16,
  }) : super(key: key);
  final double width;
  final double height;

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
}

class ShimmerCard extends StatelessWidget {

  const ShimmerCard({
    Key? key,
    required this.height,
    required this.width,
  }) : super(key: key);
  final double height;
  final double width;

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
}

class ShimmerList extends StatelessWidget {

  const ShimmerList({
    Key? key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.spacing = 8,
  }) : super(key: key);
  final int itemCount;
  final double itemHeight;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
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
}

class ShimmerGrid extends StatelessWidget {

  const ShimmerGrid({
    Key? key,
    this.crossAxisCount = 2,
    this.itemCount = 6,
    this.itemHeight = 200,
    this.spacing = 8,
  }) : super(key: key);
  final int crossAxisCount;
  final int itemCount;
  final double itemHeight;
  final double spacing;

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
      itemBuilder: (context, index) {
        return ShimmerCard(
          height: itemHeight,
          width: double.infinity,
        );
      },
    );
  }
}