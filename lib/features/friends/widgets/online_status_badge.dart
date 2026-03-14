import 'package:flutter/material.dart';

class OnlineStatusBadge extends StatelessWidget {

  const OnlineStatusBadge({
    required this.child, required this.isOnline, super.key,
    this.size = 12,
  });
  final Widget child;
  final bool isOnline;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <>[
        child,
        if (isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isOnline', isOnline));
    properties.add(DoubleProperty('size', size));
  }
}

class OnlineStatusIndicator extends StatelessWidget {

  const OnlineStatusIndicator({
    required this.status, super.key,
    this.size = 12,
  });
  final OnlineStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case OnlineStatus.online:
        color = Colors.green;
      case OnlineStatus.away:
        color = Colors.orange;
      case OnlineStatus.busy:
        color = Colors.red;
      case OnlineStatus.offline:
        color = Colors.grey;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<OnlineStatus>('status', status));
    properties.add(DoubleProperty('size', size));
  }
}