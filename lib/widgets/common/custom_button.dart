import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Color? color;
  final Color? textColor;
  final double height;
  final double borderRadius;
  final IconData? icon;
  final bool isOutlined;
  final double? fontSize; // নতুন প্যারামিটার যোগ করা হয়েছে
  final EdgeInsets? padding; // নতুন প্যারামিটার যোগ করা হয়েছে

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.color,
    this.textColor,
    this.height = 48,
    this.borderRadius = 8,
    this.icon,
    this.isOutlined = false,
    this.fontSize, // অপশনাল প্যারামিটার
    this.padding, // অপশনাল প্যারামিটার
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
      side: BorderSide(color: color ?? Theme.of(context).primaryColor),
      minimumSize: isFullWidth
          ? Size(double.infinity, height)
          : Size(height * 2, height),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: padding,
    )
        : ElevatedButton.styleFrom(
      backgroundColor: color ?? Theme.of(context).primaryColor,
      foregroundColor: textColor ?? Colors.white,
      minimumSize: isFullWidth
          ? Size(double.infinity, height)
          : Size(height * 2, height),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: padding,
    );

    if (isLoading) {
      return Container(
        height: height,
        width: isFullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          color: (color ?? Theme.of(context).primaryColor).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    final textWidget = Text(
      text,
      style: TextStyle(
        fontSize: fontSize ?? 14,
        fontWeight: FontWeight.w500,
      ),
    );

    if (icon != null) {
      return isOutlined
          ? OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: fontSize != null ? fontSize! + 2 : 16),
        label: textWidget,
        style: buttonStyle,
      )
          : ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: fontSize != null ? fontSize! + 2 : 16),
        label: textWidget,
        style: buttonStyle,
      );
    }

    return isOutlined
        ? OutlinedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: textWidget,
    )
        : ElevatedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: textWidget,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('text', text));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onPressed', onPressed));
    properties.add(DiagnosticsProperty<bool>('isLoading', isLoading));
    properties.add(DiagnosticsProperty<bool>('isFullWidth', isFullWidth));
    properties.add(ColorProperty('color', color));
    properties.add(ColorProperty('textColor', textColor));
    properties.add(DoubleProperty('height', height));
    properties.add(DoubleProperty('borderRadius', borderRadius));
    properties.add(DiagnosticsProperty<IconData?>('icon', icon));
    properties.add(DiagnosticsProperty<bool>('isOutlined', isOutlined));
    properties.add(DoubleProperty('fontSize', fontSize));
    properties.add(DiagnosticsProperty<EdgeInsets?>('padding', padding));
  }
}