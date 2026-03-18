import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ClanProgressBar extends StatelessWidget {
  final double progress;
  final Color color;
  final double height;
  final bool showPercentage;

  const ClanProgressBar({
    required this.progress,
    super.key,
    this.color = Colors.blue,
    this.height = 8,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure progress is between 0 and 1
    final double clampedProgress = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${(clampedProgress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Stack(
          children: [
            // Background
            Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            // Progress
            Container(
              height: height,
              width: MediaQuery.of(context).size.width * clampedProgress,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('progress', progress));
    properties.add(ColorProperty('color', color));
    properties.add(DoubleProperty('height', height));
    properties.add(DiagnosticsProperty<bool>('showPercentage', showPercentage));
  }
}