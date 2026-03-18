import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;
  final double size;

  const LoadingWidget({
    super.key,
    this.message,
    this.color,
    this.size = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated loading spinner
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Colors.pink,
              ),
              strokeWidth: 4,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// Shimmer loading effect for content
class ShimmerLoadingWidget extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoadingWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: const ShimmerEffect(),
    );
  }
}

class ShimmerEffect extends StatefulWidget {
  const ShimmerEffect({super.key});

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment(_animation.value - 1, 0),
                end: Alignment(_animation.value, 0),
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.3),
                  Colors.white.withValues(alpha: 0.1),
                ],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: Container(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
        );
      },
    );
  }
}

// Full screen loading with background
class FullScreenLoadingWidget extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;

  const FullScreenLoadingWidget({
    super.key,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                  strokeWidth: 3,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Loading overlay for buttons
class ButtonLoadingWidget extends StatelessWidget {
  final Color? color;
  final double size;

  const ButtonLoadingWidget({
    super.key,
    this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Colors.white,
        ),
        strokeWidth: 2,
      ),
    );
  }
}

// List loading shimmer
class ListLoadingShimmer extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double spacing;

  const ListLoadingShimmer({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: spacing),
      itemBuilder: (_, index) {
        return Row(
          children: [
            const ShimmerLoadingWidget(
              width: 50,
              height: 50,
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLoadingWidget(
                    width: double.infinity,
                    height: 16,
                  ),
                  const SizedBox(height: 8),
                  ShimmerLoadingWidget(
                    width: 150,
                    height: 12,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// Grid loading shimmer
class GridLoadingShimmer extends StatelessWidget {
  final int crossAxisCount;
  final int itemCount;
  final double aspectRatio;

  const GridLoadingShimmer({
    super.key,
    this.crossAxisCount = 2,
    this.itemCount = 4,
    this.aspectRatio = 1,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: aspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (_, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ShimmerLoadingWidget(
                width: 50,
                height: 50,
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
              const SizedBox(height: 12),
              ShimmerLoadingWidget(
                width: 100,
                height: 16,
              ),
              const SizedBox(height: 4),
              ShimmerLoadingWidget(
                width: 60,
                height: 12,
              ),
            ],
          ),
        );
      },
    );
  }
}