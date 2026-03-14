import 'package:flutter/material.dart';

class AppDivider extends StatelessWidget {

  const AppDivider({
    super.key,
    this.text,
    this.thickness = 1,
    this.indent = 16,
    this.endIndent = 16,
    this.color,
    this.textStyle,
  });
  final String? text;
  final double thickness;
  final double indent;
  final double endIndent;
  final Color? color;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    if (text == null) {
      return Divider(
        thickness: thickness,
        indent: indent,
        endIndent: endIndent,
        color: color ?? Colors.grey.shade300,
      );
    }

    return Row(
      children: <>[
        Expanded(
          child: Divider(
            thickness: thickness,
            indent: indent,
            color: color ?? Colors.grey.shade300,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text!,
            style: textStyle ?? const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            thickness: thickness,
            endIndent: endIndent,
            color: color ?? Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('text', text));
    properties.add(DoubleProperty('thickness', thickness));
    properties.add(DoubleProperty('indent', indent));
    properties.add(DoubleProperty('endIndent', endIndent));
    properties.add(ColorProperty('color', color));
    properties.add(DiagnosticsProperty<TextStyle?>('textStyle', textStyle));
  }
}

class VerticalDividerWithText extends StatelessWidget {

  const VerticalDividerWithText({
    required this.text, super.key,
    this.thickness = 1,
    this.height = 20,
    this.color,
    this.textStyle,
  });
  final String text;
  final double thickness;
  final double height;
  final Color? color;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <>[
        Container(
          width: thickness,
          height: height,
          color: color ?? Colors.grey.shade300,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: textStyle ?? const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('text', text));
    properties.add(DoubleProperty('thickness', thickness));
    properties.add(DoubleProperty('height', height));
    properties.add(ColorProperty('color', color));
    properties.add(DiagnosticsProperty<TextStyle?>('textStyle', textStyle));
  }
}

class DashedDivider extends StatelessWidget {

  const DashedDivider({
    super.key,
    this.height = 1,
    this.color = Colors.grey,
    this.dashWidth = 5,
    this.dashSpacing = 3,
  });
  final double height;
  final Color color;
  final double dashWidth;
  final double dashSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double totalWidth = constraints.maxWidth;
        final int dashCount = (totalWidth / (dashWidth + dashSpacing)).floor();
        
        return Row(
          children: List.generate(dashCount, (int index) {
            return Container(
              width: dashWidth,
              height: height,
              margin: EdgeInsets.only(right: dashSpacing),
              color: color,
            );
          }),
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('height', height));
    properties.add(ColorProperty('color', color));
    properties.add(DoubleProperty('dashWidth', dashWidth));
    properties.add(DoubleProperty('dashSpacing', dashSpacing));
  }
}