import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class NeumorphicButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? shadowColor;
  final EdgeInsetsGeometry? padding;
  final bool disabled;

  const NeumorphicButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.backgroundColor,
    this.shadowColor,
    this.padding,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !disabled;

    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: Container(
        width: width,
        height: height,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor ?? (isEnabled
              ? AppColors.accentPurple.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: isEnabled ? [
            BoxShadow(
              color: (shadowColor ?? AppColors.accentPurple).withOpacity(0.3),
              offset: const Offset(4, 4),
              blurRadius: 8,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              offset: const Offset(-4, -4),
              blurRadius: 8,
            ),
          ] : [],
        ),
        child: Center(child: child),
      ),
    );
  }
}

// Rounded variant
class NeumorphicRoundButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;

  const NeumorphicRoundButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.size = 56,
    this.iconSize = 24,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? (isEnabled
              ? AppColors.accentPurple.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1)),
          shape: BoxShape.circle,
          boxShadow: isEnabled ? [
            BoxShadow(
              color: (backgroundColor ?? AppColors.accentPurple).withOpacity(0.3),
              offset: const Offset(4, 4),
              blurRadius: 8,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              offset: const Offset(-4, -4),
              blurRadius: 8,
            ),
          ] : [],
        ),
        child: Icon(
          icon,
          color: iconColor ?? (isEnabled ? AppColors.accentPurple : Colors.grey),
          size: iconSize,
        ),
      ),
    );
  }
}

// Outlined variant
class NeumorphicOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double borderRadius;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;

  const NeumorphicOutlinedButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.borderRadius = 12,
    this.borderColor,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor ?? (isEnabled
                ? AppColors.accentPurple
                : Colors.grey),
            width: 2,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }
}