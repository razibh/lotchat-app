import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppAnimatedButton extends StatefulWidget {

  const AppAnimatedButton({
    required this.text, super.key,
    this.onPressed,
    this.icon,
    this.color,
    this.textColor,
    this.height = 48,
    this.width = double.infinity,
    this.isLoading = false,
    this.isFullWidth = true,
    this.borderRadius = 8,
    this.boxShadow,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
  });
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final double height;
  final double width;
  final bool isLoading;
  final bool isFullWidth;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;
  final Duration animationDuration;
  final Curve animationCurve;

  @override
  State<AppAnimatedButton> createState() => _AppAnimatedButtonState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('text', text));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onPressed', onPressed));
    properties.add(DiagnosticsProperty<IconData?>('icon', icon));
    properties.add(ColorProperty('color', color));
    properties.add(ColorProperty('textColor', textColor));
    properties.add(DoubleProperty('height', height));
    properties.add(DoubleProperty('width', width));
    properties.add(DiagnosticsProperty<bool>('isLoading', isLoading));
    properties.add(DiagnosticsProperty<bool>('isFullWidth', isFullWidth));
    properties.add(DoubleProperty('borderRadius', borderRadius));
    properties.add(IterableProperty<BoxShadow>('boxShadow', boxShadow));
    properties.add(DiagnosticsProperty<Duration>('animationDuration', animationDuration));
    properties.add(DiagnosticsProperty<Curve>('animationCurve', animationCurve));
  }
}

class _AppAnimatedButtonState extends State<AppAnimatedButton> 
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      HapticFeedback.lightImpact();
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return Transform.scale(
            scale: 1.0 - (_controller.value * 0.05),
            child: Container(
              width: widget.isFullWidth ? widget.width : null,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: widget.color != null
                    ? null
                    : LinearGradient(
                        colors: <>[
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: widget.color,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: widget.boxShadow ?? <>[
                  BoxShadow(
                    color: (widget.color ?? Theme.of(context).primaryColor)
                        .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  splashColor: Colors.white.withValues(alpha: 0.2),
                  highlightColor: Colors.transparent,
                  child: Center(
                    child: widget.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.textColor ?? Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <>[
                              if (widget.icon != null) ...<>[
                                Icon(
                                  widget.icon,
                                  color: widget.textColor ?? Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                widget.text,
                                style: TextStyle(
                                  color: widget.textColor ?? Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AnimatedIconButton extends StatefulWidget {

  const AnimatedIconButton({
    required this.icon, super.key,
    this.onPressed,
    this.color,
    this.size = 24,
    this.tooltip,
    this.animationDuration = const Duration(milliseconds: 200),
  });
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final String? tooltip;
  final Duration animationDuration;

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onPressed', onPressed));
    properties.add(ColorProperty('color', color));
    properties.add(DoubleProperty('size', size));
    properties.add(StringProperty('tooltip', tooltip));
    properties.add(DiagnosticsProperty<Duration>('animationDuration', animationDuration));
  }
}

class _AnimatedIconButtonState extends State<AnimatedIconButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: Tooltip(
        message: widget.tooltip ?? '',
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return Transform.scale(
              scale: 1.0 - (_controller.value * 0.1),
              child: Container(
                padding: EdgeInsets.all(widget.size * 0.2),
                child: Icon(
                  widget.icon,
                  color: widget.color ?? Theme.of(context).iconTheme.color,
                  size: widget.size,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}