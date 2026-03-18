import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';  // DiagnosticPropertiesBuilder এর জন্য

class ClanBadge extends StatelessWidget {
  final int level;
  final double size;

  const ClanBadge({
    required this.level,
    super.key,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String icon;

    if (level >= 50) {
      backgroundColor = Colors.amber;
      textColor = Colors.white;
      icon = '👑';
    } else if (level >= 30) {
      backgroundColor = Colors.purple;
      textColor = Colors.white;
      icon = '💎';
    } else if (level >= 20) {
      backgroundColor = Colors.blue;
      textColor = Colors.white;
      icon = '⭐';
    } else if (level >= 10) {
      backgroundColor = Colors.green;
      textColor = Colors.white;
      icon = '🌟';
    } else {
      backgroundColor = Colors.grey;
      textColor = Colors.white;
      icon = '⚡';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.3,
        vertical: size * 0.15,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size * 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            icon,
            style: TextStyle(fontSize: size * 0.5),
          ),
          const SizedBox(width: 2),
          Text(
            '$level',
            style: TextStyle(
              color: textColor,
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('level', level));
    properties.add(DoubleProperty('size', size));
  }
}