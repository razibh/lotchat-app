import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {

  const CustomButton({
    required this.text, required this.onPressed, super.key,
    this.isLoading = false,
    this.isFullWidth = true,
    this.color,
    this.textColor,
    this.height = 48,
    this.borderRadius = 8,
    this.icon,
    this.isOutlined = false,
  });
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

  @override
  Widget build(BuildContext context) {
    final ButtonStyle buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            side: BorderSide(color: color ?? Colors.blue),
            minimumSize: isFullWidth
                ? Size(double.infinity, height)
                : Size(height * 2, height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.blue,
            foregroundColor: textColor ?? Colors.white,
            minimumSize: isFullWidth
                ? Size(double.infinity, height)
                : Size(height * 2, height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          );

    if (isLoading) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: (color ?? Colors.blue).withValues(alpha: 0.5),
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

    if (icon != null) {
      return isOutlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(text),
              style: buttonStyle,
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(text),
              style: buttonStyle,
            );
    }

    return isOutlined
        ? OutlinedButton(
            onPressed: onPressed,
            style: buttonStyle,
            child: Text(text),
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: buttonStyle,
            child: Text(text),
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
  }
}