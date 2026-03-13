import 'package:flutter/material.dart';

class AppDivider extends StatelessWidget {

  const AppDivider({
    Key? key,
    this.text,
    this.thickness = 1,
    this.indent = 16,
    this.endIndent = 16,
    this.color,
    this.textStyle,
  }) : super(key: key);
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
}

class VerticalDividerWithText extends StatelessWidget {

  const VerticalDividerWithText({
    Key? key,
    required this.text,
    this.thickness = 1,
    this.height = 20,
    this.color,
    this.textStyle,
  }) : super(key: key);
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
}

class DashedDivider extends StatelessWidget {

  const DashedDivider({
    Key? key,
    this.height = 1,
    this.color = Colors.grey,
    this.dashWidth = 5,
    this.dashSpacing = 3,
  }) : super(key: key);
  final double height;
  final Color color;
  final double dashWidth;
  final double dashSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final dashCount = (totalWidth / (dashWidth + dashSpacing)).floor();
        
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
}