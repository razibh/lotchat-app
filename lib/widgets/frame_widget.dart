import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FrameWidget extends StatelessWidget {

  const FrameWidget({
    Key? key,
    required this.framePath,
    required this.child,
    this.size = 120,
    this.isAnimated = false,
  }) : super(key: key);
  final String framePath;
  final Widget child;
  final double size;
  final bool isAnimated;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: framePath.endsWith('.svg')
            ? null
            : DecorationImage(
                image: AssetImage(framePath),
                fit: BoxFit.contain,
              ),
      ),
      child: isAnimated
          ? _buildAnimatedFrame()
          : Stack(
              alignment: Alignment.center,
              children: <>[
                if (framePath.endsWith('.svg'))
                  SvgPicture.asset(
                    framePath,
                    width: size,
                    height: size,
                    fit: BoxFit.contain,
                  ),
                ClipOval(
                  child: SizedBox(
                    width: size * 0.85,
                    height: size * 0.85,
                    child: child,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAnimatedFrame() {
    return Stack(
      alignment: Alignment.center,
      children: <>[
        // Animated frame background
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: <>[Colors.purple, Colors.pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        
        // Rotating border
        TweenAnimationBuilder(
          tween: Tween(begin: 0.0, end: 2 * 3.14159),
          duration: const Duration(seconds: 10),
          builder: (context, double angle, child) {
            return Transform.rotate(
              angle: angle,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.amber,
                    width: 4,
                  ),
                ),
              ),
            );
          },
        ),
        
        // Sparkle effects
        ...List.generate(8, (int index) {
          final double sparkleSize = size * 0.05;
          return Positioned(
            top: (index < 4 ? 0.1 : 0.9) * size,
            left: (index % 4) * size * 0.25 + size * 0.1,
            child: TweenAnimationBuilder(
              tween: Tween(begin: 0.5, end: 1.0),
              duration: Duration(milliseconds: 500 + (index * 200)),
              curve: Curves.easeInOut,
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Container(
                    width: sparkleSize,
                    height: sparkleSize,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          );
        }),
        
        // Center avatar
        ClipOval(
          child: SizedBox(
            width: size * 0.7,
            height: size * 0.7,
            child: child,
          ),
        ),
      ],
    );
  }
}