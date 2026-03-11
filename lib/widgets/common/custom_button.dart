import 'package:flutter/material.dart';

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

  const CustomButton({
    Key? key,
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonStyle = isOutlined
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
          color: (color ?? Colors.blue).withOpacity(0.5),
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
}