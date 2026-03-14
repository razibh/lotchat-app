import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLogo extends StatelessWidget {

  const AppLogo({
    super.key,
    this.size = 100,
    this.withText = true,
    this.color,
    this.imagePath,
  });
  final double size;
  final bool withText;
  final Color? color;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <>[
        // Logo Icon
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <>[
                color ?? Theme.of(context).primaryColor,
                (color ?? Theme.of(context).primaryColor).withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: <>[
              BoxShadow(
                color: (color ?? Theme.of(context).primaryColor).withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipOval(
            child: imagePath != null
                ? (imagePath!.endsWith('.svg')
                    ? SvgPicture.asset(
                        imagePath!,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        imagePath!,
                        fit: BoxFit.cover,
                      ))
                : Center(
                    child: Icon(
                      Icons.chat,
                      color: Colors.white,
                      size: size * 0.5,
                    ),
                  ),
          ),
        ),
        
        if (withText) ...<>[
          const SizedBox(height: 16),
          // Logo Text
          Text(
            'LotChat',
            style: TextStyle(
              fontSize: size * 0.24,
              fontWeight: FontWeight.bold,
              color: color ?? Theme.of(context).primaryColor,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Connect. Chat. Celebrate.',
            style: TextStyle(
              fontSize: size * 0.1,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('size', size));
    properties.add(DiagnosticsProperty<bool>('withText', withText));
    properties.add(ColorProperty('color', color));
    properties.add(StringProperty('imagePath', imagePath));
  }
}

class LogoText extends StatelessWidget {

  const LogoText({
    super.key,
    this.fontSize = 24,
    this.color,
  });
  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: <>[
          TextSpan(
            text: 'Lot',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: color ?? Theme.of(context).primaryColor,
            ),
          ),
          TextSpan(
            text: 'Chat',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: color ?? Theme.of(context).secondaryHeaderColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('fontSize', fontSize));
    properties.add(ColorProperty('color', color));
  }
}

class LogoIcon extends StatelessWidget {

  const LogoIcon({
    super.key,
    this.size = 40,
    this.color,
  });
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <>[
            color ?? Theme.of(context).primaryColor,
            (color ?? Theme.of(context).primaryColor).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.chat,
          color: Colors.white,
          size: size * 0.6,
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('size', size));
    properties.add(ColorProperty('color', color));
  }
}

class AnimatedLogo extends StatefulWidget {

  const AnimatedLogo({super.key, this.size = 100});
  final double size;

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('size', size));
  }
}

class _AnimatedLogoState extends State<AnimatedLogo> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <>[Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: <>[
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.chat,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}