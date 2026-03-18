import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // DiagnosticPropertiesBuilder এর জন্য

class AppBadge extends StatelessWidget {
  final Widget child;
  final String? text;
  final int? count;
  final Color color;
  final Color textColor;
  final double size;
  final bool showZero;
  final bool isDot;

  const AppBadge({
    required this.child,
    this.text,
    this.count,
    this.color = Colors.red,
    this.textColor = Colors.white,
    this.size = 20,
    this.showZero = false,
    this.isDot = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final int displayCount = count ?? 0;

    if (!showZero && displayCount == 0 && !isDot) {
      return child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -size * 0.3,
          right: -size * 0.3,
          child: _buildBadge(),
        ),
      ],
    );
  }

  Widget _buildBadge() {
    if (isDot) {
      return Container(
        width: size * 0.6,
        height: size * 0.6,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 1.5,
          ),
        ),
      );
    }

    final String displayText = text ?? _getCountText();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.3,
        vertical: size * 0.1,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.5),
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
      ),
      child: Center(
        child: Text(
          displayText,
          style: TextStyle(
            color: textColor,
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getCountText() {
    final int displayCount = count ?? 0;
    if (displayCount > 99) {
      return '99+';
    }
    return displayCount.toString();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('text', text));
    properties.add(IntProperty('count', count));
    properties.add(ColorProperty('color', color));
    properties.add(ColorProperty('textColor', textColor));
    properties.add(DoubleProperty('size', size));
    properties.add(DiagnosticsProperty<bool>('showZero', showZero));
    properties.add(DiagnosticsProperty<bool>('isDot', isDot));
  }
}

class NotificationBadge extends StatelessWidget {
  final int count;
  final Color color;

  const NotificationBadge({
    required this.count,
    this.color = Colors.red,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('count', count));
    properties.add(ColorProperty('color', color));
  }
}

class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final double fontSize;

  const StatusBadge({
    required this.text,
    required this.color,
    this.textColor = Colors.white,
    this.fontSize = 12,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('text', text));
    properties.add(ColorProperty('color', color));
    properties.add(ColorProperty('textColor', textColor));
    properties.add(DoubleProperty('fontSize', fontSize));
  }
}